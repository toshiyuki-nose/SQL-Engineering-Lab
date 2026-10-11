-- Course 04 / Lesson 02 - UPDATE Statements
-- Run from the SQL-Engineering-Lab repository root.
-- Requires Course 03 setup (including category 60).
-- No COMMIT is issued; all temporary training data is rolled back.
-- Create lesson02_update_statements/logs before running.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course04_data_manipulation_and_transactions/lesson02_update_statements/logs/lesson02.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 02: UPDATE Statements
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
BEGIN
    SELECT COUNT(*) INTO v_existing_books FROM books WHERE book_id IN (4901, 4902, 4903);
    SELECT COUNT(*) INTO v_category_count FROM categories WHERE category_id = 60;
    IF v_existing_books <> 0 OR v_category_count <> 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Prerequisite check failed: practice IDs must be unused and category 60 must exist.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Create savepoint and temporary training books
SAVEPOINT lesson02_start;

INSERT ALL
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4901, 'SQL Practice Handbook', 60, 2800, 12, 2026, NULL)
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4902, 'Relational Data Workbook', 60, 3200, 8, 2025, 'Exercises and Examples')
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4903, 'Database Operations Guide', 60, 3500, 5, 2026, NULL)
SELECT 1 FROM dual;

SELECT book_id, title, price, stock FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;

PROMPT [3] Update one column for one book
SELECT book_id, price FROM books WHERE book_id = 4901;
UPDATE books SET price = 3000 WHERE book_id = 4901;
SELECT book_id, price FROM books WHERE book_id = 4901;

PROMPT [4] Update two columns for one book
SELECT book_id, price, stock FROM books WHERE book_id = 4902;
UPDATE books SET price = 3400, stock = 15 WHERE book_id = 4902;
SELECT book_id, price, stock FROM books WHERE book_id = 4902;

PROMPT [5] Update a value using arithmetic
SELECT book_id, stock FROM books WHERE book_id = 4903;
UPDATE books SET stock = stock + 5 WHERE book_id = 4903;
SELECT book_id, stock FROM books WHERE book_id = 4903;

PROMPT [6] Conditional update across three rows
SELECT book_id, stock FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;
UPDATE books
SET stock = CASE WHEN stock < 10 THEN stock + 3 ELSE stock + 1 END
WHERE book_id IN (4901, 4902, 4903);
SELECT book_id, title, price, stock FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;

PROMPT [7] Assert expected final values
DECLARE
    v_correct_rows NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_correct_rows
    FROM books
    WHERE (book_id = 4901 AND price = 3000 AND stock = 13)
       OR (book_id = 4902 AND price = 3400 AND stock = 16)
       OR (book_id = 4903 AND price = 3500 AND stock = 11);
    IF v_correct_rows <> 3 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Validation failed: updated book values differ from expectations.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Validation passed: all three books have expected values.');
END;
/

PROMPT [8] Roll back temporary inserts and updates
ROLLBACK TO SAVEPOINT lesson02_start;

PROMPT [9] Verify cleanup (expected count: 0)
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (4901, 4902, 4903);

DECLARE
    v_remaining NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_remaining FROM books WHERE book_id IN (4901, 4902, 4903);
    IF v_remaining <> 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cleanup validation failed: temporary books remain.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cleanup validation passed.');
END;
/

PROMPT Lesson 02 completed. No COMMIT was issued.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
