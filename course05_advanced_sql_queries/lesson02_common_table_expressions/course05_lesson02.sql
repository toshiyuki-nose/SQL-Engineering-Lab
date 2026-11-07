-- SQL-Engineering-Lab
-- Course 05 - Lesson 02: Common Table Expressions (CTEs)
-- Read-only lab. Run from repository root in SQL*Plus.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 180
SET SERVEROUTPUT ON
SET DEFINE OFF
COLUMN title FORMAT A36
COLUMN category_name FORMAT A20
COLUMN stock_status FORMAT A16
COLUMN avg_price FORMAT 999999.99
COLUMN price FORMAT 999999.99
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL course05_advanced_sql_queries/lesson02_common_table_expressions/logs/lesson02.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 02: Common Table Expressions
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
        RAISE_APPLICATION_ERROR(-20511, 'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES.');
    END IF;

    SELECT COUNT(*) INTO v_books FROM books;
    IF v_books = 0 THEN
        RAISE_APPLICATION_ERROR(-20512, 'BOOKS must contain sample data.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] Basic CTE - books priced below 3000
WITH affordable_books AS (
    SELECT book_id, title, price
    FROM books
    WHERE price < 3000
)
SELECT book_id, title, price
FROM affordable_books
ORDER BY price, book_id;

PROMPT [3] Equivalent inline view
SELECT x.book_id, x.title, x.price
FROM (
    SELECT book_id, title, price
    FROM books
    WHERE price < 3000
) x
ORDER BY x.price, x.book_id;

PROMPT [4] Aggregate inside a CTE - category averages
WITH category_stats AS (
    SELECT category_id,
           COUNT(*) AS book_count,
           AVG(price) AS avg_price
    FROM books
    GROUP BY category_id
)
SELECT c.category_id, c.category_name,
       NVL(s.book_count, 0) AS book_count,
       s.avg_price
FROM categories c
LEFT JOIN category_stats s
    ON s.category_id = c.category_id
ORDER BY c.category_id;

PROMPT [5] Chained CTEs - books above their category average
WITH book_prices AS (
    SELECT book_id, title, category_id, price
    FROM books
    WHERE price IS NOT NULL
),
category_average AS (
    SELECT category_id, AVG(price) AS avg_price
    FROM book_prices
    GROUP BY category_id
)
SELECT b.book_id, b.title, b.category_id,
       b.price, a.avg_price
FROM book_prices b
JOIN category_average a
    ON a.category_id = b.category_id
WHERE b.price > a.avg_price
ORDER BY b.category_id, b.price DESC, b.book_id;

PROMPT [6] CTE with CASE - stock status summary
WITH classified_books AS (
    SELECT book_id, category_id,
           CASE
               WHEN stock IS NULL THEN 'Unknown'
               WHEN stock <= 0 THEN 'Out of stock'
               WHEN stock < 5 THEN 'Low stock'
               ELSE 'Available'
           END AS stock_status
    FROM books
)
SELECT category_id, stock_status, COUNT(*) AS book_count
FROM classified_books
GROUP BY category_id, stock_status
ORDER BY category_id, stock_status;

PROMPT [7] CTE and LEFT JOIN - retain categories with no books
WITH book_counts AS (
    SELECT category_id, COUNT(*) AS book_count
    FROM books
    GROUP BY category_id
)
SELECT c.category_id, c.category_name,
       NVL(bc.book_count, 0) AS book_count
FROM categories c
LEFT JOIN book_counts bc
    ON bc.category_id = c.category_id
ORDER BY c.category_id;

PROMPT [8] Business report - multiple CTEs and conditional aggregation
WITH classified_books AS (
    SELECT book_id, category_id, price,
           CASE
               WHEN stock IS NULL THEN 'Unknown'
               WHEN stock <= 0 THEN 'Out of stock'
               WHEN stock < 5 THEN 'Low stock'
               ELSE 'Available'
           END AS stock_status
    FROM books
),
category_metrics AS (
    SELECT category_id,
           COUNT(*) AS total_books,
           SUM(CASE WHEN stock_status = 'Out of stock' THEN 1 ELSE 0 END) AS out_of_stock_books,
           SUM(CASE WHEN stock_status = 'Low stock' THEN 1 ELSE 0 END) AS low_stock_books,
           SUM(CASE WHEN price >= 4000 THEN 1 ELSE 0 END) AS premium_books
    FROM classified_books
    GROUP BY category_id
)
SELECT c.category_id, c.category_name,
       NVL(m.total_books, 0) AS total_books,
       NVL(m.out_of_stock_books, 0) AS out_of_stock_books,
       NVL(m.low_stock_books, 0) AS low_stock_books,
       NVL(m.premium_books, 0) AS premium_books
FROM categories c
LEFT JOIN category_metrics m
    ON m.category_id = c.category_id
ORDER BY c.category_id;

PROMPT [9] Verify CTE book counts match BOOKS
WITH book_counts AS (
    SELECT category_id, COUNT(*) AS book_count
    FROM books
    GROUP BY category_id
)
SELECT (SELECT COUNT(*) FROM books) AS books_table_count,
       (SELECT NVL(SUM(book_count), 0) FROM book_counts) AS cte_total_count
FROM dual;

DECLARE
    v_books NUMBER;
    v_grouped NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_books FROM books;
    SELECT NVL(SUM(book_count), 0) INTO v_grouped
    FROM (
        SELECT COUNT(*) AS book_count
        FROM books
        GROUP BY category_id
    );
    IF v_books <> v_grouped THEN
        RAISE_APPLICATION_ERROR(-20513, 'Grouped book counts do not match BOOKS.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Verification passed: grouped counts match BOOKS (' || v_books || ').');
END;
/

PROMPT Lesson 02 completed. All statements were read-only.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
