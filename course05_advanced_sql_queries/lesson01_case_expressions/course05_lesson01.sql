-- SQL-Engineering-Lab
-- Course 05 / Lesson 01 - CASE Expressions
-- Read-only lab. Execute from the repository root in SQL*Plus.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 200
SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

COLUMN title FORMAT A36
COLUMN display_title FORMAT A36
COLUMN category_name FORMAT A20
COLUMN price_band FORMAT A16
COLUMN stock_status FORMAT A16
COLUMN category_label FORMAT A22

SPOOL course05_advanced_sql_queries/lesson01_case_expressions/logs/lesson01.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 01: CASE Expressions
PROMPT ======================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify required schema and tables
DECLARE
    v_tables NUMBER;
    v_books NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_tables
    FROM user_tables
    WHERE table_name IN ('BOOKS', 'CATEGORIES');

    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_tables <> 2 THEN
        RAISE_APPLICATION_ERROR(-20501, 'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES.');
    END IF;

    SELECT COUNT(*) INTO v_books FROM books;
    IF v_books = 0 THEN
        RAISE_APPLICATION_ERROR(-20502, 'BOOKS must contain sample data.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] Inspect book prices and stock
SELECT book_id, title, price, stock
FROM books
ORDER BY book_id;

PROMPT [3] Searched CASE - classify prices
SELECT
    book_id,
    title,
    price,
    CASE
        WHEN price IS NULL THEN 'Price unknown'
        WHEN price < 2000 THEN 'Budget'
        WHEN price < 4000 THEN 'Standard'
        ELSE 'Premium'
    END AS price_band
FROM books
ORDER BY book_id;

PROMPT [4] Verify boundaries using expressions from DUAL
SELECT
    price,
    CASE
        WHEN price < 2000 THEN 'Budget'
        WHEN price < 4000 THEN 'Standard'
        ELSE 'Premium'
    END AS price_band
FROM (
    SELECT 1999 AS price FROM dual
    UNION ALL SELECT 2000 FROM dual
    UNION ALL SELECT 3999 FROM dual
    UNION ALL SELECT 4000 FROM dual
)
ORDER BY price;

PROMPT [5] Simple CASE - identify reference category
SELECT
    b.book_id,
    b.category_id,
    CASE b.category_id
        WHEN 60 THEN 'Reference category'
        ELSE 'Other category'
    END AS category_label
FROM books b
ORDER BY b.book_id;

PROMPT [6] NULL-aware display title
SELECT
    book_id,
    title,
    CASE
        WHEN title IS NULL THEN '[Untitled]'
        ELSE title
    END AS display_title
FROM books
ORDER BY book_id;

PROMPT [7] Searched CASE - stock status
SELECT
    book_id,
    title,
    stock,
    CASE
        WHEN stock IS NULL THEN 'Unknown'
        WHEN stock <= 0 THEN 'Out of stock'
        WHEN stock < 5 THEN 'Low stock'
        ELSE 'Available'
    END AS stock_status
FROM books
ORDER BY book_id;

PROMPT [8] Conditional aggregation by category ID
SELECT
    category_id,
    COUNT(*) AS total_books,
    SUM(CASE WHEN stock > 0 THEN 1 ELSE 0 END) AS in_stock_books,
    SUM(CASE WHEN stock <= 0 THEN 1 ELSE 0 END) AS out_of_stock_books
FROM books
GROUP BY category_id
ORDER BY category_id;

PROMPT [9] Category report - JOIN and CASE aggregation
SELECT
    c.category_id,
    c.category_name,
    COUNT(b.book_id) AS total_books,
    SUM(CASE WHEN b.price >= 4000 THEN 1 ELSE 0 END) AS premium_books,
    SUM(CASE WHEN b.stock > 0 THEN 1 ELSE 0 END) AS in_stock_books
FROM categories c
LEFT JOIN books b
    ON b.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_id;

PROMPT [10] Verify total category book counts match BOOKS
SELECT
    (SELECT COUNT(*) FROM books) AS books_table_count,
    (SELECT COUNT(*) FROM book_authors) AS book_author_relationships
FROM dual;

PROMPT Lesson 01 completed. All statements were read-only.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
