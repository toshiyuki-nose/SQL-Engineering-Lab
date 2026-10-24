-- Course 05 - Lesson 04: Window Functions Basics
-- Oracle Database Free / SQL*Plus
-- Read-only lesson. No permanent objects or data are changed.

SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET SERVEROUTPUT ON
SET PAGESIZE 100
SET LINESIZE 180
SET TRIMSPOOL ON
SET NUMFORMAT 999999990.00

COLUMN BOOK_ID FORMAT 999999
COLUMN CATEGORY_ID FORMAT 999999
COLUMN PUBLISHED_YEAR FORMAT 9999
COLUMN STOCK FORMAT 999999


WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL course05_advanced_sql_queries/lesson04_window_functions_basics/logs/lesson04.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 04: Window Functions Basics
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
        RAISE_APPLICATION_ERROR(-20531, 'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES containing data.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] GROUP BY - one row per category
SELECT category_id, COUNT(*) AS book_count
FROM books
GROUP BY category_id
ORDER BY category_id;

PROMPT [3] OVER PARTITION BY - preserve individual book rows
SELECT book_id, title, category_id,
       COUNT(*) OVER (PARTITION BY category_id) AS category_book_count,
       COUNT(*) OVER () AS all_book_count
FROM books
ORDER BY category_id, book_id;

PROMPT [4] ROW_NUMBER - unique global price ordering
SELECT book_id, title, price,
       ROW_NUMBER() OVER (ORDER BY price DESC NULLS LAST, book_id) AS price_row_number
FROM books
ORDER BY price_row_number;

PROMPT [5] ROW_NUMBER - restart within each category
SELECT book_id, title, category_id, price,
       ROW_NUMBER() OVER (
           PARTITION BY category_id
           ORDER BY price DESC NULLS LAST, book_id
       ) AS category_row_number
FROM books
ORDER BY category_id, category_row_number;

PROMPT [6] Compare ROW_NUMBER, RANK, and DENSE_RANK on fixed ties
WITH sample_prices AS (
    SELECT 1 AS sample_id, 4500 AS price FROM dual
    UNION ALL SELECT 2, 4200 FROM dual
    UNION ALL SELECT 3, 4200 FROM dual
    UNION ALL SELECT 4, 3600 FROM dual
)
SELECT sample_id, price,
       ROW_NUMBER() OVER (ORDER BY price DESC, sample_id) AS row_num,
       RANK() OVER (ORDER BY price DESC) AS price_rank,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_price_rank
FROM sample_prices
ORDER BY price DESC, sample_id;

PROMPT [7] Compare ranking functions on actual BOOKS data
SELECT book_id, title, category_id, price,
       ROW_NUMBER() OVER (
           PARTITION BY category_id ORDER BY price DESC NULLS LAST, book_id
       ) AS row_num,
       RANK() OVER (
           PARTITION BY category_id ORDER BY price DESC NULLS LAST
       ) AS price_rank,
       DENSE_RANK() OVER (
           PARTITION BY category_id ORDER BY price DESC NULLS LAST
       ) AS dense_price_rank
FROM books
ORDER BY category_id, price DESC NULLS LAST, book_id;

PROMPT [8] Top-priced book per nonempty category (CTE + ROW_NUMBER)
WITH ranked_books AS (
    SELECT book_id, title, category_id, price,
           ROW_NUMBER() OVER (
               PARTITION BY category_id
               ORDER BY price DESC NULLS LAST, book_id
           ) AS rn
    FROM books
)
SELECT c.category_id, c.category_name, r.book_id, r.title, r.price
FROM ranked_books r
JOIN categories c ON c.category_id = r.category_id
WHERE r.rn = 1
ORDER BY c.category_id;

PROMPT [9] Verify window counts and top-book selection
DECLARE
    v_books NUMBER;
    v_window_rows NUMBER;
    v_category_count NUMBER;
    v_top_rows NUMBER;
    v_bad_counts NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_books FROM books;

    SELECT COUNT(*) INTO v_window_rows
    FROM (SELECT COUNT(*) OVER (PARTITION BY category_id) AS category_count FROM books);

    SELECT COUNT(*) INTO v_category_count
    FROM (SELECT category_id FROM books GROUP BY category_id);

    SELECT COUNT(*) INTO v_top_rows
    FROM (
        SELECT ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY price DESC NULLS LAST, book_id
        ) AS rn
        FROM books
    )
    WHERE rn = 1;

    SELECT COUNT(*) INTO v_bad_counts
    FROM (
        SELECT category_id,
               COUNT(*) OVER (PARTITION BY category_id) AS analytic_count
        FROM books
    ) w
    WHERE w.analytic_count <> (
        SELECT COUNT(*) FROM books b WHERE b.category_id = w.category_id
    );

    IF v_books <> v_window_rows
       OR v_category_count <> v_top_rows
       OR v_bad_counts <> 0 THEN
        RAISE_APPLICATION_ERROR(-20532, 'Window function validation failed.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Validation passed: BOOKS=' || v_books ||
        ', window rows=' || v_window_rows ||
        ', nonempty categories=' || v_category_count ||
        ', top books=' || v_top_rows ||
        ', mismatched category counts=' || v_bad_counts);
END;
/

PROMPT Lesson 04 completed. All statements were read-only.
SPOOL OFF
