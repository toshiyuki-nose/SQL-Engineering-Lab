-- Course 05 - Lesson 05: Advanced Window Functions
-- Run from the repository root in SQL*Plus.
-- This script is read-only.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
SET NUMFORMAT 999999990.00

COLUMN BOOK_ID FORMAT 999999
COLUMN CATEGORY_ID FORMAT 999999
COLUMN PUBLISHED_YEAR FORMAT 9999
COLUMN STOCK FORMAT 999999
COLUMN FRAME_ROW_COUNT FORMAT 999999
COLUMN CATEGORY_BOOK_COUNT FORMAT 999999

WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL course05_advanced_sql_queries/lesson05_advanced_window_functions/logs/lesson05.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 05: Advanced Window Functions
PROMPT ======================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify required schema and sample data
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
        RAISE_APPLICATION_ERROR(-20541,
            'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES containing data.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] LAG and LEAD within each category (descending price)
SELECT book_id, category_id, title, price,
       LAG(price) OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
       ) AS previous_price,
       LEAD(price) OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
       ) AS next_price
FROM books
ORDER BY category_id, price DESC NULLS LAST, book_id;

PROMPT [3] Price difference from the preceding ranked book
WITH compared_books AS (
    SELECT book_id, title, category_id, price,
           LAG(price) OVER (
               PARTITION BY category_id
               ORDER BY price DESC NULLS LAST, book_id
           ) AS previous_price
    FROM books
)
SELECT book_id, category_id, title, price, previous_price,
       price - previous_price AS price_difference
FROM compared_books
ORDER BY category_id, price DESC NULLS LAST, book_id;

PROMPT [4] Running total of prices within each category
SELECT book_id, category_id, title, price,
       SUM(price) OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_price_total
FROM books
ORDER BY category_id, price DESC NULLS LAST, book_id;

PROMPT [5] Three-row moving average (current plus two preceding)
SELECT book_id, category_id, title, price,
       ROUND(AVG(price) OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_price,
       COUNT(*) OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS frame_row_count
FROM books
ORDER BY category_id, price DESC NULLS LAST, book_id;

PROMPT [6] Compare ROWS and RANGE on tied prices
WITH sample_prices AS (
    SELECT 1 AS sample_id, 4500 AS price FROM dual
    UNION ALL SELECT 2, 4200 FROM dual
    UNION ALL SELECT 3, 4200 FROM dual
    UNION ALL SELECT 4, 3600 FROM dual
)
SELECT sample_id, price,
       SUM(price) OVER (
           ORDER BY price DESC, sample_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS rows_running_total,
       SUM(price) OVER (
           ORDER BY price DESC
           RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS range_running_total
FROM sample_prices
ORDER BY price DESC, sample_id;

PROMPT [7] Full-category window total retains all book rows
SELECT book_id, category_id, price,
       SUM(price) OVER (PARTITION BY category_id) AS category_price_total,
       COUNT(*) OVER (PARTITION BY category_id) AS category_book_count
FROM books
ORDER BY category_id, book_id;

PROMPT [8] GROUP BY category totals for comparison
SELECT category_id,
       COUNT(*) AS category_book_count,
       SUM(price) AS category_price_total
FROM books
GROUP BY category_id
ORDER BY category_id;

PROMPT [9] Validate row counts, frame sizes, and running totals
DECLARE
    v_books NUMBER;
    v_analytic_rows NUMBER;
    v_invalid_frames NUMBER;
    v_invalid_totals NUMBER;
    v_invalid_last_totals NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_books FROM books;

    SELECT COUNT(*) INTO v_analytic_rows
    FROM (
        SELECT SUM(price) OVER (PARTITION BY category_id) AS category_total
        FROM books
    );

    SELECT COUNT(*) INTO v_invalid_frames
    FROM (
        SELECT COUNT(*) OVER (
            PARTITION BY category_id
            ORDER BY price DESC NULLS LAST, book_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS frame_count
        FROM books
    )
    WHERE frame_count NOT BETWEEN 1 AND 3;

    SELECT COUNT(*) INTO v_invalid_totals
    FROM (
        SELECT category_id, price, running_total,
               LAG(running_total) OVER (
                   PARTITION BY category_id
                   ORDER BY price DESC NULLS LAST, book_id
               ) AS previous_running_total
        FROM (
            SELECT book_id, category_id, price,
                   SUM(price) OVER (
                       PARTITION BY category_id
                       ORDER BY price DESC NULLS LAST, book_id
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                   ) AS running_total
            FROM books
        )
    )
    WHERE previous_running_total IS NOT NULL
      AND running_total < previous_running_total;

    SELECT COUNT(*) INTO v_invalid_last_totals
    FROM (
        SELECT category_id, price,
               SUM(price) OVER (
                   PARTITION BY category_id
                   ORDER BY price DESC NULLS LAST, book_id
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS running_total,
               SUM(price) OVER (PARTITION BY category_id) AS category_total,
               ROW_NUMBER() OVER (
                   PARTITION BY category_id
                   ORDER BY price ASC NULLS FIRST, book_id DESC
               ) AS reverse_row_number
        FROM books
    )
    WHERE reverse_row_number = 1
      AND (running_total <> category_total OR running_total IS NULL AND category_total IS NOT NULL);

    IF v_books <> v_analytic_rows OR v_invalid_frames <> 0
       OR v_invalid_totals <> 0 OR v_invalid_last_totals <> 0 THEN
        RAISE_APPLICATION_ERROR(-20542, 'Advanced window validation failed.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Validation passed: BOOKS=' || v_books ||
        ', analytic rows=' || v_analytic_rows ||
        ', invalid frames=' || v_invalid_frames ||
        ', decreasing totals=' || v_invalid_totals ||
        ', mismatched final totals=' || v_invalid_last_totals);
END;
/

PROMPT Lesson 05 completed. All statements were read-only.
SPOOL OFF
