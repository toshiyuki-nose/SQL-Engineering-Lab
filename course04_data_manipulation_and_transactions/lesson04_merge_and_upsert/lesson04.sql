-- Course 04 / Lesson 04 - MERGE and Upsert
-- Run from the SQL-Engineering-Lab repository root.
-- Requires Course 03 setup, including category 60.
-- Temporary training data only; no COMMIT.
-- Create the lesson's logs directory before execution.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
COLUMN title FORMAT A36
COLUMN category_name FORMAT A20
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course04_data_manipulation_and_transactions/lesson04_merge_and_upsert/logs/lesson04.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 04: MERGE and Upsert
PROMPT ==========================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Check prerequisites
SELECT book_id, title FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;
SELECT category_id, category_name FROM categories WHERE category_id = 60;

DECLARE
    v_books NUMBER;
    v_category NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_books FROM books WHERE book_id IN (4901, 4902, 4903);
    SELECT COUNT(*) INTO v_category FROM categories WHERE category_id = 60;
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_books <> 0 OR v_category <> 1 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Prerequisite check failed: schema, PDB, IDs, or category 60.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Savepoint and insert two existing target books
SAVEPOINT lesson04_start;

INSERT ALL
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4901, 'SQL Practice Handbook', 60, 2800, 12, 2026, NULL)
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4902, 'Relational Data Workbook', 60, 3200, 8, 2025, NULL)
SELECT 1 FROM dual;

SELECT book_id, title, price, stock FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;

PROMPT [3] Preview incoming catalog feed
SELECT 4901 AS book_id, 'SQL Practice Handbook' AS title, 3000 AS price, 14 AS stock FROM dual
UNION ALL
SELECT 4902, 'Relational Data Workbook', 3400, 10 FROM dual
UNION ALL
SELECT 4903, 'Database Operations Guide', 3500, 5 FROM dual;

PROMPT [4] MERGE existing books and new book
MERGE INTO books target
USING (
    SELECT 4901 AS book_id, 'SQL Practice Handbook' AS title, 60 AS category_id, 3000 AS price, 14 AS stock, 2026 AS published_year FROM dual
    UNION ALL
    SELECT 4902, 'Relational Data Workbook', 60, 3400, 10, 2025 FROM dual
    UNION ALL
    SELECT 4903, 'Database Operations Guide', 60, 3500, 5, 2026 FROM dual
) source
ON (target.book_id = source.book_id)
WHEN MATCHED THEN
    UPDATE SET target.title = source.title, target.price = source.price, target.stock = source.stock
WHEN NOT MATCHED THEN
    INSERT (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (source.book_id, source.title, source.category_id, source.price, source.stock, source.published_year, NULL);

PROMPT [5] Verify merged rows
SELECT book_id, title, category_id, price, stock, published_year FROM books WHERE book_id IN (4901, 4902, 4903) ORDER BY book_id;

DECLARE
    v_correct NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_correct
    FROM books
    WHERE (book_id = 4901 AND title = 'SQL Practice Handbook' AND category_id = 60 AND price = 3000 AND stock = 14)
       OR (book_id = 4902 AND title = 'Relational Data Workbook' AND category_id = 60 AND price = 3400 AND stock = 10)
       OR (book_id = 4903 AND title = 'Database Operations Guide' AND category_id = 60 AND price = 3500 AND stock = 5);
    IF v_correct <> 3 THEN
        RAISE_APPLICATION_ERROR(-20009, 'MERGE validation failed: expected three final book records.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('MERGE validation passed: two updated books and one inserted book.');
END;
/

PROMPT [6] Roll back all training changes
ROLLBACK TO SAVEPOINT lesson04_start;

PROMPT [7] Verify cleanup (expected count: 0)
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (4901, 4902, 4903);

DECLARE
    v_remaining NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_remaining FROM books WHERE book_id IN (4901, 4902, 4903);
    IF v_remaining <> 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Cleanup validation failed.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cleanup validation passed.');
END;
/

PROMPT Lesson 04 completed. No COMMIT was issued.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
