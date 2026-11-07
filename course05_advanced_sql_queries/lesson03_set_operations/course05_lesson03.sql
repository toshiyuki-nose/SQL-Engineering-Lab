-- SQL-Engineering-Lab
-- Course 05 / Lesson 03 - Set Operations
-- Read-only. Execute from the repository root in SQL*Plus.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET SERVEROUTPUT ON
SET PAGESIZE 100
SET LINESIZE 180
SET DEFINE OFF
COLUMN title FORMAT A36
COLUMN category_name FORMAT A20
COLUMN source_group FORMAT A12
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course05_advanced_sql_queries/lesson03_set_operations/logs/lesson03.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 03: Set Operations
PROMPT ======================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify required schema, tables, and sample data
DECLARE
    v_tables NUMBER;
    v_books NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_tables
    FROM user_tables
    WHERE table_name IN ('BOOKS', 'CATEGORIES');

    SELECT COUNT(*) INTO v_books FROM books;

    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_tables <> 2 OR v_books = 0 THEN
        RAISE_APPLICATION_ERROR(-20521, 'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES containing data.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] Inspect overlapping groups A and B
PROMPT Group A: category 10 (Technology)
SELECT book_id, title, category_id, price
FROM books
WHERE category_id = 10
ORDER BY book_id;

PROMPT Group B: price >= 3000
SELECT book_id, title, category_id, price
FROM books
WHERE price >= 3000
ORDER BY book_id;

PROMPT [3] UNION - distinct book IDs from either group
SELECT book_id FROM books WHERE category_id = 10
UNION
SELECT book_id FROM books WHERE price >= 3000
ORDER BY book_id;

PROMPT [4] UNION ALL - preserve duplicate book IDs
SELECT book_id FROM books WHERE category_id = 10
UNION ALL
SELECT book_id FROM books WHERE price >= 3000
ORDER BY book_id;

PROMPT [5] INTERSECT - book IDs in both groups
SELECT book_id FROM books WHERE category_id = 10
INTERSECT
SELECT book_id FROM books WHERE price >= 3000
ORDER BY book_id;

PROMPT [6] MINUS - category 10 but price below 3000 or NULL
SELECT book_id FROM books WHERE category_id = 10
MINUS
SELECT book_id FROM books WHERE price >= 3000
ORDER BY book_id;

PROMPT [7] Reverse MINUS - price >= 3000 but not category 10
SELECT book_id FROM books WHERE price >= 3000
MINUS
SELECT book_id FROM books WHERE category_id = 10
ORDER BY book_id;

PROMPT [8] Full-row duplicate semantics: source labels keep rows distinct
SELECT book_id, 'Category 10' AS source_group
FROM books WHERE category_id = 10
UNION
SELECT book_id, 'Price >=3000' AS source_group
FROM books WHERE price >= 3000
ORDER BY book_id, source_group;

PROMPT [9] NULL duplicate elimination using DUAL
SELECT CAST(NULL AS NUMBER) AS example_value FROM dual
UNION
SELECT CAST(NULL AS NUMBER) FROM dual;

PROMPT [10] UNION ALL preserves both NULL rows
SELECT CAST(NULL AS NUMBER) AS example_value FROM dual
UNION ALL
SELECT CAST(NULL AS NUMBER) FROM dual;

PROMPT [11] Category 20 OR stock = 0 (UNION)
SELECT book_id FROM books WHERE category_id = 20
UNION
SELECT book_id FROM books WHERE stock = 0
ORDER BY book_id;

PROMPT [12] Category 20 AND stock = 0 (INTERSECT)
SELECT book_id FROM books WHERE category_id = 20
INTERSECT
SELECT book_id FROM books WHERE stock = 0
ORDER BY book_id;

PROMPT [13] Category 20 EXCEPT stock = 0 (MINUS)
SELECT book_id FROM books WHERE category_id = 20
MINUS
SELECT book_id FROM books WHERE stock = 0
ORDER BY book_id;

PROMPT [14] Set operation with compatible character columns
SELECT title AS display_text FROM books WHERE category_id = 10
UNION
SELECT category_name AS display_text FROM categories WHERE category_id = 10
ORDER BY display_text;

PROMPT [15] Verify set cardinality identities (independent of sample counts)
DECLARE
    v_a NUMBER;
    v_b NUMBER;
    v_union NUMBER;
    v_union_all NUMBER;
    v_intersection NUMBER;
    v_a_minus_b NUMBER;
    v_b_minus_a NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_a FROM books WHERE category_id = 10;
    SELECT COUNT(*) INTO v_b FROM books WHERE price >= 3000;

    SELECT COUNT(*) INTO v_union FROM (
        SELECT book_id FROM books WHERE category_id = 10
        UNION
        SELECT book_id FROM books WHERE price >= 3000
    );

    SELECT COUNT(*) INTO v_union_all FROM (
        SELECT book_id FROM books WHERE category_id = 10
        UNION ALL
        SELECT book_id FROM books WHERE price >= 3000
    );

    SELECT COUNT(*) INTO v_intersection FROM (
        SELECT book_id FROM books WHERE category_id = 10
        INTERSECT
        SELECT book_id FROM books WHERE price >= 3000
    );

    SELECT COUNT(*) INTO v_a_minus_b FROM (
        SELECT book_id FROM books WHERE category_id = 10
        MINUS
        SELECT book_id FROM books WHERE price >= 3000
    );

    SELECT COUNT(*) INTO v_b_minus_a FROM (
        SELECT book_id FROM books WHERE price >= 3000
        MINUS
        SELECT book_id FROM books WHERE category_id = 10
    );

    IF v_union_all <> v_a + v_b
       OR v_union <> v_a + v_b - v_intersection
       OR v_a <> v_a_minus_b + v_intersection
       OR v_b <> v_b_minus_a + v_intersection THEN
        RAISE_APPLICATION_ERROR(-20522, 'Set cardinality validation failed.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Validation passed: A=' || v_a ||
        ', B=' || v_b || ', UNION=' || v_union ||
        ', UNION ALL=' || v_union_all || ', INTERSECT=' || v_intersection ||
        ', A MINUS B=' || v_a_minus_b || ', B MINUS A=' || v_b_minus_a);
END;
/

PROMPT Lesson 03 completed. All statements were read-only.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
