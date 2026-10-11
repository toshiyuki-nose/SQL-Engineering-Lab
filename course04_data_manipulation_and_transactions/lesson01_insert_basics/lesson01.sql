-- Course 04 / Lesson 01 - INSERT Basics
-- Run from the SQL-Engineering-Lab repository root.
-- Requires Course 03 setup (including category 60).
-- No COMMIT is issued. Practice inserts are rolled back.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course04_data_manipulation_and_transactions/lesson01_insert_basics/logs/lesson01.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 01: INSERT Basics
PROMPT ==========================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Validate practice IDs and category
SELECT book_id, title FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;
SELECT category_id, category_name FROM categories WHERE category_id = 60;

-- Abort safely before any inserts if the baseline is not as expected.
DECLARE
    v_existing_books NUMBER;
    v_category_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existing_books FROM books WHERE book_id IN (4901, 4902, 4903);
    SELECT COUNT(*) INTO v_category_count FROM categories WHERE category_id = 60;
    IF v_existing_books <> 0 OR v_category_count <> 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Prerequisite check failed: practice IDs must be unused and category 60 must exist.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Create savepoint
SAVEPOINT lesson01_start;

PROMPT [3] Insert a single book
INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (4901, 'SQL Practice Handbook', 60, 2800, 12, 2026, NULL);

PROMPT [4] Insert two books using INSERT ALL
INSERT ALL
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4902, 'Relational Data Workbook', 60, 3200, 8, 2025, 'Exercises and Examples')
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4903, 'Database Operations Guide', 60, 3500, 5, 2026, NULL)
SELECT 1 FROM dual;

PROMPT [5] Verify inserted books
SELECT book_id, title, category_id, price, stock, published_year, subtitle
FROM books
WHERE book_id IN (4901, 4902, 4903)
ORDER BY book_id;
SELECT COUNT(*) AS practice_book_count FROM books WHERE book_id IN (4901, 4902, 4903);

PROMPT [6] Roll back only the lesson inserts
ROLLBACK TO SAVEPOINT lesson01_start;

PROMPT [7] Verify cleanup (expected count: 0)
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (4901, 4902, 4903);

PROMPT Lesson 01 completed. No COMMIT was issued.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
