-- Course 04 / Lesson 03 - DELETE Statements
-- Execute from the SQL-Engineering-Lab repository root.
-- Requires Course 03 setup (CATEGORIES category_id = 60).
-- Training books 4901-4903 are inserted temporarily and never committed.
-- Create the logs directory before running.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course04_data_manipulation_and_transactions/lesson03_delete_statements/logs/lesson03.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 03: DELETE Statements
PROMPT ==========================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Validate prerequisites
SELECT book_id, title FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;
SELECT category_id, category_name FROM categories WHERE category_id = 60;

DECLARE
    v_existing_books NUMBER;
    v_category_count NUMBER;
    v_schema VARCHAR2(128);
BEGIN
    SELECT COUNT(*) INTO v_existing_books FROM books WHERE book_id IN (4901, 4902, 4903);
    SELECT COUNT(*) INTO v_category_count FROM categories WHERE category_id = 60;
    v_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    IF v_existing_books <> 0 OR v_category_count <> 1 OR v_schema <> 'SQL_LAB' THEN
        RAISE_APPLICATION_ERROR(-20005, 'Prerequisite check failed: check schema, unused practice IDs, and category 60.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Create savepoint and insert temporary books
SAVEPOINT lesson03_start;

INSERT ALL
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4901, 'SQL Practice Handbook', 60, 2800, 12, 2026, NULL)
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4902, 'Relational Data Workbook', 60, 3200, 8, 2025, 'Exercises and Examples')
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4903, 'Database Operations Guide', 60, 3500, 5, 2026, NULL)
SELECT 1 FROM dual;

SELECT book_id, title FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;

PROMPT [3] Preview and delete one book
SELECT book_id, title FROM books WHERE book_id = 4901;
DELETE FROM books WHERE book_id = 4901;
SELECT COUNT(*) AS remaining_book_4901 FROM books WHERE book_id = 4901;

PROMPT [4] Preview and delete two books
SELECT book_id, title FROM books WHERE book_id IN (4902, 4903) ORDER BY book_id;
DELETE FROM books WHERE book_id IN (4902, 4903);
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (4901, 4902, 4903);

PROMPT [5] Validate deletion results
DECLARE
    v_remaining NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_remaining FROM books WHERE book_id IN (4901, 4902, 4903);
    IF v_remaining <> 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Delete validation failed: temporary books remain.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Delete validation passed: no temporary books remain.');
END;
/

PROMPT [6] Roll back all training changes
ROLLBACK TO SAVEPOINT lesson03_start;

PROMPT [7] Verify cleanup (expected count: 0)
SELECT COUNT(*) AS remaining_after_rollback FROM books WHERE book_id IN (4901, 4902, 4903);

DECLARE
    v_remaining NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_remaining FROM books WHERE book_id IN (4901, 4902, 4903);
    IF v_remaining <> 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Cleanup validation failed: temporary books remain.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cleanup validation passed.');
END;
/

PROMPT Lesson 03 completed. No COMMIT was issued.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
