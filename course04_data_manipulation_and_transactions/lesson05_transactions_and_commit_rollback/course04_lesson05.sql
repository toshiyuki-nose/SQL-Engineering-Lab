-- Course 04 / Lesson 05 - Transactions and COMMIT / ROLLBACK
-- Run in a NEW, DEDICATED SQL*Plus session with no pending work.
-- This lesson intentionally executes COMMIT. It commits all pending session work.
-- Prerequisite: Course 03 schema and category_id = 60.
-- Create logs/ before execution.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
COLUMN title FORMAT A36
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL course04_data_manipulation_and_transactions/lesson05_transactions_and_commit_rollback/logs/lesson05.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 05: Transactions and COMMIT / ROLLBACK
PROMPT ==========================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify prerequisites and unused training IDs
SELECT category_id, category_name FROM categories WHERE category_id = 60;
SELECT book_id, title FROM books WHERE book_id IN (5901, 5902, 5903) ORDER BY book_id;
DECLARE
    v_category NUMBER;
    v_existing NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_category FROM categories WHERE category_id = 60;
    SELECT COUNT(*) INTO v_existing FROM books WHERE book_id IN (5901, 5902, 5903);
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_category <> 1 OR v_existing <> 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Prerequisite check failed: schema, PDB, category, or practice IDs.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Scenario A: INSERT and full ROLLBACK
INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (5901, 'Transaction Practice A', 60, 2000, 3, 2026, NULL);
SELECT book_id, title, stock FROM books WHERE book_id = 5901;
ROLLBACK;
SELECT COUNT(*) AS remaining_5901 FROM books WHERE book_id = 5901;

PROMPT [3] Scenario B: SAVEPOINT and partial ROLLBACK
INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (5902, 'Transaction Practice B', 60, 2500, 7, 2026, NULL);
SAVEPOINT before_stock_update;
UPDATE books SET stock = 20 WHERE book_id = 5902;
SELECT book_id, stock FROM books WHERE book_id = 5902;
ROLLBACK TO SAVEPOINT before_stock_update;
SELECT book_id, stock FROM books WHERE book_id = 5902;
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock INTO v_stock FROM books WHERE book_id = 5902;
    IF v_stock <> 7 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Partial rollback failed: stock should be 7.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Partial rollback validation passed: stock restored to 7.');
END;
/
ROLLBACK;
SELECT COUNT(*) AS remaining_5902 FROM books WHERE book_id = 5902;

PROMPT [4] Scenario C: COMMIT makes an INSERT durable
INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (5903, 'Transaction Practice C', 60, 3000, 4, 2026, NULL);
COMMIT;
SELECT book_id, title, stock FROM books WHERE book_id = 5903;
ROLLBACK;
SELECT COUNT(*) AS committed_5903_count FROM books WHERE book_id = 5903;
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM books
    WHERE book_id = 5903 AND title = 'Transaction Practice C' AND stock = 4;
    IF v_count <> 1 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Commit validation failed: training row not found.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('COMMIT validation passed: row persists after ROLLBACK.');
END;
/

PROMPT [5] Cleanup: explicitly DELETE committed training row and COMMIT
DELETE FROM books WHERE book_id = 5903 AND title = 'Transaction Practice C';
COMMIT;

PROMPT [6] Final validation: no training books remain
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (5901, 5902, 5903);
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM books WHERE book_id IN (5901, 5902, 5903);
    IF v_count <> 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Cleanup validation failed: training rows remain.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cleanup validation passed: no training rows remain.');
END;
/
PROMPT Lesson 05 completed. COMMIT and ROLLBACK were demonstrated.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
