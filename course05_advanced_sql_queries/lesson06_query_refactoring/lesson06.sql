-- Course 05 / Lesson 06: Query Refactoring
-- Run from the repository root. All statements are read-only.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET PAGESIZE 100
SET LINESIZE 180
SET DEFINE OFF
COLUMN BOOK_ID FORMAT 999999
COLUMN CATEGORY_ID FORMAT 999999
COLUMN PUBLISHED_YEAR FORMAT 9999
COLUMN STOCK FORMAT 999999
COLUMN CATEGORY_BOOK_COUNT FORMAT 999999
COLUMN BOOK_COUNT FORMAT 999999
COLUMN RN FORMAT 999999
COLUMN PRICE FORMAT 9999990.00
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL course05_advanced_sql_queries/lesson06_query_refactoring/logs/lesson06.log

PROMPT ======================================================
PROMPT Course 05 - Lesson 06: Query Refactoring
PROMPT ======================================================
SHOW USER
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema FROM dual;

PROMPT [1] Verify prerequisites
DECLARE
    v_tables NUMBER;
    v_books NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_tables
    FROM user_tables WHERE table_name IN ('BOOKS', 'CATEGORIES');
    SELECT COUNT(*) INTO v_books FROM books;
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'SQL_LAB'
       OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1'
       OR v_tables <> 2 OR v_books = 0 THEN
        RAISE_APPLICATION_ERROR(-20551, 'Expected SQL_LAB / FREEPDB1 with BOOKS and CATEGORIES.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Prerequisites passed. Book count: ' || v_books);
END;
/

PROMPT [2] Original category summary: direct join and aggregation
SELECT c.category_id, c.category_name,
       COUNT(b.book_id) AS book_count,
       NVL(SUM(b.price), 0) AS total_price
FROM categories c
LEFT JOIN books b ON b.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_id;

PROMPT [3] Refactored category summary: calculate book metrics first
WITH category_metrics AS (
    SELECT category_id, COUNT(*) AS book_count,
           NVL(SUM(price), 0) AS total_price
    FROM books
    GROUP BY category_id
)
SELECT c.category_id, c.category_name,
       NVL(m.book_count, 0) AS book_count,
       NVL(m.total_price, 0) AS total_price
FROM categories c
LEFT JOIN category_metrics m ON m.category_id = c.category_id
ORDER BY c.category_id;

PROMPT [4] Compare category summaries in both directions (expect zero rows)
WITH original_report AS (
    SELECT c.category_id, c.category_name,
           COUNT(b.book_id) AS book_count,
           NVL(SUM(b.price), 0) AS total_price
    FROM categories c LEFT JOIN books b ON b.category_id = c.category_id
    GROUP BY c.category_id, c.category_name
),
category_metrics AS (
    SELECT category_id, COUNT(*) AS book_count,
           NVL(SUM(price), 0) AS total_price
    FROM books GROUP BY category_id
),
refactored_report AS (
    SELECT c.category_id, c.category_name,
           NVL(m.book_count, 0) AS book_count,
           NVL(m.total_price, 0) AS total_price
    FROM categories c LEFT JOIN category_metrics m ON m.category_id = c.category_id
)
SELECT 'ORIGINAL_MINUS_REFACTORED' AS difference_side, x.*
FROM (SELECT * FROM original_report MINUS SELECT * FROM refactored_report) x
UNION ALL
SELECT 'REFACTORED_MINUS_ORIGINAL' AS difference_side, x.*
FROM (SELECT * FROM refactored_report MINUS SELECT * FROM original_report) x
ORDER BY 1, 2;

PROMPT [5] Original book-level report: correlated category average
SELECT b.book_id, b.title, b.category_id, b.price,
       (SELECT ROUND(AVG(b2.price), 2)
        FROM books b2 WHERE b2.category_id = b.category_id) AS category_avg_price,
       CASE
           WHEN b.price > (SELECT AVG(b3.price)
                           FROM books b3 WHERE b3.category_id = b.category_id)
               THEN 'ABOVE'
           WHEN b.price < (SELECT AVG(b3.price)
                           FROM books b3 WHERE b3.category_id = b.category_id)
               THEN 'BELOW'
           ELSE 'AT_OR_UNKNOWN'
       END AS price_position
FROM books b
ORDER BY b.book_id;

PROMPT [6] Refactored book-level report: calculate once, label once
WITH priced_books AS (
    SELECT b.book_id, b.title, b.category_id, b.price,
           AVG(b.price) OVER (PARTITION BY b.category_id) AS category_avg_raw
    FROM books b
),
labeled_books AS (
    SELECT book_id, title, category_id, price,
           ROUND(category_avg_raw, 2) AS category_avg_price,
           CASE
               WHEN price > category_avg_raw THEN 'ABOVE'
               WHEN price < category_avg_raw THEN 'BELOW'
               ELSE 'AT_OR_UNKNOWN'
           END AS price_position
    FROM priced_books
)
SELECT book_id, title, category_id, price, category_avg_price, price_position
FROM labeled_books
ORDER BY book_id;

PROMPT [7] Compare original and refactored book reports (expect zero rows)
WITH original_report AS (
    SELECT b.book_id, b.title, b.category_id, b.price,
           (SELECT ROUND(AVG(b2.price), 2) FROM books b2
            WHERE b2.category_id = b.category_id) AS category_avg_price,
           CASE
               WHEN b.price > (SELECT AVG(b3.price) FROM books b3
                               WHERE b3.category_id = b.category_id) THEN 'ABOVE'
               WHEN b.price < (SELECT AVG(b3.price) FROM books b3
                               WHERE b3.category_id = b.category_id) THEN 'BELOW'
               ELSE 'AT_OR_UNKNOWN'
           END AS price_position
    FROM books b
),
priced_books AS (
    SELECT b.book_id, b.title, b.category_id, b.price,
           AVG(b.price) OVER (PARTITION BY b.category_id) AS category_avg_raw
    FROM books b
),
refactored_report AS (
    SELECT book_id, title, category_id, price,
           ROUND(category_avg_raw, 2) AS category_avg_price,
           CASE
               WHEN price > category_avg_raw THEN 'ABOVE'
               WHEN price < category_avg_raw THEN 'BELOW'
               ELSE 'AT_OR_UNKNOWN'
           END AS price_position
    FROM priced_books
)
SELECT 'ORIGINAL_MINUS_REFACTORED' AS difference_side, x.*
FROM (SELECT * FROM original_report MINUS SELECT * FROM refactored_report) x
UNION ALL
SELECT 'REFACTORED_MINUS_ORIGINAL' AS difference_side, x.*
FROM (SELECT * FROM refactored_report MINUS SELECT * FROM original_report) x
ORDER BY 1, 2;

PROMPT [8] Refactor top-book query into ranking and presentation stages
WITH ranked_books AS (
    SELECT b.book_id, b.title, b.category_id, b.price,
           ROW_NUMBER() OVER (
               PARTITION BY b.category_id
               ORDER BY b.price DESC NULLS LAST, b.book_id
           ) AS rn
    FROM books b
),
top_books AS (
    SELECT book_id, title, category_id, price
    FROM ranked_books WHERE rn = 1
)
SELECT c.category_id, c.category_name, t.book_id, t.title, t.price
FROM top_books t
JOIN categories c ON c.category_id = t.category_id
ORDER BY c.category_id;

PROMPT [9] Verify one top book per nonempty category
WITH ranked_books AS (
    SELECT category_id,
           ROW_NUMBER() OVER (
               PARTITION BY category_id
               ORDER BY price DESC NULLS LAST, book_id
           ) AS rn
    FROM books
)
SELECT category_id, COUNT(*) AS top_book_count
FROM ranked_books
WHERE rn = 1
GROUP BY category_id
ORDER BY category_id;

PROMPT [10] Automated equivalence checks
DECLARE
    v_summary_diff NUMBER;
    v_book_diff NUMBER;
    v_original_rows NUMBER;
    v_refactored_rows NUMBER;
    v_nonempty_categories NUMBER;
    v_top_rows NUMBER;
BEGIN
    WITH original_report AS (
        SELECT c.category_id, c.category_name,
               COUNT(b.book_id) AS book_count,
               NVL(SUM(b.price), 0) AS total_price
        FROM categories c LEFT JOIN books b ON b.category_id = c.category_id
        GROUP BY c.category_id, c.category_name
    ),
    metrics AS (
        SELECT category_id, COUNT(*) AS book_count,
               NVL(SUM(price), 0) AS total_price
        FROM books GROUP BY category_id
    ),
    refactored_report AS (
        SELECT c.category_id, c.category_name,
               NVL(m.book_count, 0) AS book_count,
               NVL(m.total_price, 0) AS total_price
        FROM categories c LEFT JOIN metrics m ON m.category_id = c.category_id
    ),
    original_bag AS (
        SELECT category_id, category_name, book_count, total_price, COUNT(*) AS multiplicity
        FROM original_report GROUP BY category_id, category_name, book_count, total_price
    ),
    refactored_bag AS (
        SELECT category_id, category_name, book_count, total_price, COUNT(*) AS multiplicity
        FROM refactored_report GROUP BY category_id, category_name, book_count, total_price
    )
    SELECT COUNT(*) INTO v_summary_diff FROM (
        SELECT * FROM (SELECT * FROM original_bag MINUS SELECT * FROM refactored_bag)
        UNION ALL
        SELECT * FROM (SELECT * FROM refactored_bag MINUS SELECT * FROM original_bag)
    );

    WITH original_report AS (
        SELECT b.book_id, b.title, b.category_id, b.price,
               (SELECT ROUND(AVG(b2.price), 2) FROM books b2
                WHERE b2.category_id = b.category_id) AS category_avg_price,
               CASE
                   WHEN b.price > (SELECT AVG(b3.price) FROM books b3
                                   WHERE b3.category_id = b.category_id) THEN 'ABOVE'
                   WHEN b.price < (SELECT AVG(b3.price) FROM books b3
                                   WHERE b3.category_id = b.category_id) THEN 'BELOW'
                   ELSE 'AT_OR_UNKNOWN'
               END AS price_position
        FROM books b
    ),
    priced_books AS (
        SELECT b.book_id, b.title, b.category_id, b.price,
               AVG(b.price) OVER (PARTITION BY b.category_id) AS category_avg_raw
        FROM books b
    ),
    refactored_report AS (
        SELECT book_id, title, category_id, price,
               ROUND(category_avg_raw, 2) AS category_avg_price,
               CASE
                   WHEN price > category_avg_raw THEN 'ABOVE'
                   WHEN price < category_avg_raw THEN 'BELOW'
                   ELSE 'AT_OR_UNKNOWN'
               END AS price_position
        FROM priced_books
    ),
    original_bag AS (
        SELECT book_id, title, category_id, price, category_avg_price, price_position,
               COUNT(*) AS multiplicity
        FROM original_report
        GROUP BY book_id, title, category_id, price, category_avg_price, price_position
    ),
    refactored_bag AS (
        SELECT book_id, title, category_id, price, category_avg_price, price_position,
               COUNT(*) AS multiplicity
        FROM refactored_report
        GROUP BY book_id, title, category_id, price, category_avg_price, price_position
    )
    SELECT COUNT(*) INTO v_book_diff FROM (
        SELECT * FROM (SELECT * FROM original_bag MINUS SELECT * FROM refactored_bag)
        UNION ALL
        SELECT * FROM (SELECT * FROM refactored_bag MINUS SELECT * FROM original_bag)
    );

    SELECT COUNT(*) INTO v_original_rows FROM books;
    SELECT COUNT(*) INTO v_refactored_rows FROM (
        SELECT book_id, AVG(price) OVER (PARTITION BY category_id) AS category_avg
        FROM books
    );
    SELECT COUNT(*) INTO v_nonempty_categories
    FROM (SELECT category_id FROM books GROUP BY category_id);
    SELECT COUNT(*) INTO v_top_rows FROM (
        SELECT ROW_NUMBER() OVER (
            PARTITION BY category_id ORDER BY price DESC NULLS LAST, book_id
        ) AS rn FROM books
    ) WHERE rn = 1;

    IF v_summary_diff <> 0 OR v_book_diff <> 0
       OR v_original_rows <> v_refactored_rows
       OR v_nonempty_categories <> v_top_rows THEN
        RAISE_APPLICATION_ERROR(-20552, 'Refactoring validation failed.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Validation passed: summary differences=' || v_summary_diff ||
        ', book differences=' || v_book_diff ||
        ', book rows=' || v_refactored_rows ||
        ', top books=' || v_top_rows);
END;
/

PROMPT Lesson 06 completed. All statements were read-only.
SPOOL OFF
WHENEVER SQLERROR CONTINUE
