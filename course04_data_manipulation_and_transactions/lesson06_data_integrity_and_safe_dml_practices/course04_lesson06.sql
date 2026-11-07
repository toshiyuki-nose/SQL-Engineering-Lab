-- Course 04 / Lesson 06 - Data Integrity and Safe DML Practices
-- Execute from the SQL-Engineering-Lab repository root.
-- Requires Course 03 Book Store Database, including category 60.
-- Dedicated SQL*Plus session REQUIRED: CREATE/DROP TABLE cause implicit commits.
-- No explicit COMMIT is issued. A temporary practice table is dropped at the end.
-- Create the lesson logs directory before execution.

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

SPOOL course04_data_manipulation_and_transactions/lesson06_data_integrity_and_safe_dml_practices/logs/lesson06.log

PROMPT ==========================================================
PROMPT Course 04 - Lesson 06: Data Integrity and Safe DML Practices
PROMPT ==========================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify prerequisites
SELECT category_id, category_name FROM categories WHERE category_id = 60;
SELECT book_id, title FROM books WHERE book_id IN (6901, 6902, 6903) ORDER BY book_id;
SELECT column_name, nullable FROM user_tab_columns WHERE table_name = 'BOOKS' AND column_name = 'TITLE';
PROMPT BOOKS.TITLE may be nullable; NOT NULL is tested in a dedicated practice table.

DECLARE
    v_category NUMBER;
    v_existing NUMBER;
    v_practice_table NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_category FROM categories WHERE category_id = 60;
    SELECT COUNT(*) INTO v_existing FROM books WHERE book_id IN (6901, 6902, 6903);
    SELECT COUNT(*) INTO v_practice_table
    FROM user_tables WHERE table_name = 'LESSON06_REQUIRED_TITLE';
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_category <> 1 OR v_existing <> 0 OR v_practice_table <> 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Prerequisite failed: schema, PDB, category, IDs, or leftover practice table.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisite check passed.');
END;
/

PROMPT [2] Create dedicated NOT NULL practice table (DDL causes implicit COMMIT)
CREATE TABLE lesson06_required_title (
    test_id NUMBER PRIMARY KEY,
    title VARCHAR2(100) NOT NULL
);

SELECT table_name FROM user_tables WHERE table_name = 'LESSON06_REQUIRED_TITLE';
SELECT column_name, nullable FROM user_tab_columns WHERE table_name = 'LESSON06_REQUIRED_TITLE' AND column_name = 'TITLE';

PROMPT [3] Create savepoint and one temporary book
SAVEPOINT lesson06_start;

INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (6901, 'Integrity Practice Book', 60, 2900, 5, 2026, NULL);

SELECT book_id, title, category_id, price, stock FROM books WHERE book_id = 6901;

PROMPT [4] Verify duplicate primary key is rejected (expected ORA-00001)
DECLARE
    v_error NUMBER;
BEGIN
    BEGIN
        INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
        VALUES (6901, 'Duplicate ID Book', 60, 2500, 3, 2026, NULL);
        RAISE_APPLICATION_ERROR(-20022, 'Unexpected success: duplicate BOOK_ID was accepted.');
    EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLCODE;
            IF v_error <> -1 THEN
                RAISE;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Primary key validation passed: ORA-00001 rejected duplicate BOOK_ID.');
    END;
END;
/

PROMPT [5] Verify invalid foreign key is rejected (expected ORA-02291)
DECLARE
    v_error NUMBER;
BEGIN
    BEGIN
        INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
        VALUES (6902, 'Invalid Category Book', 999999, 2500, 3, 2026, NULL);
        RAISE_APPLICATION_ERROR(-20023, 'Unexpected success: invalid CATEGORY_ID was accepted.');
    EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLCODE;
            IF v_error <> -2291 THEN
                RAISE;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Foreign key validation passed: ORA-02291 rejected invalid CATEGORY_ID.');
    END;
END;
/

PROMPT [6] Verify dedicated practice table NOT NULL (expected ORA-01400)
DECLARE
    v_error NUMBER;
BEGIN
    BEGIN
        INSERT INTO lesson06_required_title (test_id, title)
        VALUES (1, NULL);
        RAISE_APPLICATION_ERROR(-20024, 'Unexpected success: NULL TITLE was accepted in practice table.');
    EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLCODE;
            IF v_error <> -1400 THEN
                RAISE;
            END IF;
            DBMS_OUTPUT.PUT_LINE('NOT NULL validation passed: ORA-01400 rejected NULL TITLE in practice table.');
    END;
END;
/

PROMPT [7] Preview target and safely update exactly one row
SELECT book_id, title, stock FROM books WHERE book_id = 6901;

DECLARE
    v_affected NUMBER;
BEGIN
    UPDATE books SET stock = 9 WHERE book_id = 6901;
    v_affected := SQL%ROWCOUNT;
    IF v_affected <> 1 THEN
        RAISE_APPLICATION_ERROR(-20025, 'UPDATE validation failed: expected exactly one affected row.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Safe UPDATE passed: exactly one row updated.');
END;
/

SELECT book_id, title, stock FROM books WHERE book_id = 6901;

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM books WHERE book_id = 6901 AND stock = 9;
    IF v_count <> 1 THEN
        RAISE_APPLICATION_ERROR(-20026, 'UPDATE value validation failed.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('UPDATE value validation passed: stock = 9.');
END;
/

PROMPT [8] Preview target and safely delete exactly one row
SELECT book_id, title FROM books WHERE book_id = 6901;

DECLARE
    v_affected NUMBER;
BEGIN
    DELETE FROM books WHERE book_id = 6901;
    v_affected := SQL%ROWCOUNT;
    IF v_affected <> 1 THEN
        RAISE_APPLICATION_ERROR(-20027, 'DELETE validation failed: expected exactly one affected row.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Safe DELETE passed: exactly one row deleted.');
END;
/

SELECT COUNT(*) AS remaining_before_rollback FROM books WHERE book_id IN (6901, 6902, 6903);

PROMPT [9] Roll back training changes
ROLLBACK TO SAVEPOINT lesson06_start;

PROMPT [10] Verify book cleanup (expected count: 0)
SELECT COUNT(*) AS remaining_practice_books FROM books WHERE book_id IN (6901, 6902, 6903);

DECLARE
    v_remaining NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_remaining FROM books WHERE book_id IN (6901, 6902, 6903);
    IF v_remaining <> 0 THEN
        RAISE_APPLICATION_ERROR(-20028, 'Cleanup validation failed: training books remain.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cleanup validation passed: no training books remain.');
END;
/

PROMPT [11] Drop dedicated practice table (DDL causes implicit COMMIT)
DROP TABLE lesson06_required_title PURGE;

SELECT COUNT(*) AS remaining_practice_tables
FROM user_tables WHERE table_name = 'LESSON06_REQUIRED_TITLE';

PROMPT Lesson 06 completed. Expected constraint errors were handled; practice table dropped.
PROMPT No explicit COMMIT was issued. CREATE/DROP TABLE performed implicit commits.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
