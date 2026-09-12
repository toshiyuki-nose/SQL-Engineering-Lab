/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 06 - Aggregation and Grouping

File
----
lesson06.sql

Purpose
-------
Practice aggregate functions, grouping, and filtering aggregated results.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Lesson 05.

Topics
------
1. COUNT
2. COUNT and NULL
3. SUM
4. AVG
5. MIN / MAX
6. GROUP BY
7. Aggregate expressions
8. WHERE before aggregation
9. HAVING
10. ORDER BY with aggregated results

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 06
PROMPT Aggregation and Grouping
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

COLUMN CATEGORY FORMAT A15
COLUMN MINIMUM_PRICE FORMAT 999999.99
COLUMN MAXIMUM_PRICE FORMAT 999999.99
COLUMN AVERAGE_PRICE FORMAT 999999.99
COLUMN INVENTORY_VALUE FORMAT 99999999.99

COLUMN TITLE FORMAT A30
COLUMN SUBTITLE FORMAT A50


-------------------------------------------------------------------------------
-- Step 1
-- Verify the current session
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 1: Session Context ===
PROMPT

SHOW USER
SHOW CON_NAME

SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

-------------------------------------------------------------------------------
-- Step 2
-- Inspect the source data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Source Data ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    subtitle
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 3
-- COUNT all rows
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: COUNT All Books ===
PROMPT

SELECT
    COUNT(*) AS book_count
FROM books;

-------------------------------------------------------------------------------
-- Step 4
-- COUNT and NULL
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: COUNT and NULL ===
PROMPT

SELECT
    COUNT(*) AS total_books,
    COUNT(subtitle) AS books_with_subtitle
FROM books;

PROMPT
PROMPT COUNT(*) counts rows.
PROMPT COUNT(SUBTITLE) counts only non-NULL SUBTITLE values.
PROMPT

-------------------------------------------------------------------------------
-- Step 5
-- SUM
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: SUM ===
PROMPT

SELECT
    SUM(stock) AS total_stock
FROM books;

-------------------------------------------------------------------------------
-- Step 6
-- Aggregate an expression
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Total Inventory Value ===
PROMPT

SELECT
    SUM(price * stock) AS inventory_value
FROM books;

-------------------------------------------------------------------------------
-- Step 7
-- AVG
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: AVG ===
PROMPT

SELECT
    ROUND(AVG(price), 2) AS average_price
FROM books;

-------------------------------------------------------------------------------
-- Step 8
-- MIN and MAX
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: MIN and MAX ===
PROMPT

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM books;

-------------------------------------------------------------------------------
-- Step 9
-- Multiple aggregate functions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Catalog Summary ===
PROMPT

SELECT
    COUNT(*) AS book_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books;

-------------------------------------------------------------------------------
-- Step 10
-- GROUP BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Books by Category ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category
ORDER BY category ASC;

-------------------------------------------------------------------------------
-- Step 11
-- Multiple aggregates by category
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Category Summary ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock
FROM books
GROUP BY category
ORDER BY category ASC;

-------------------------------------------------------------------------------
-- Step 12
-- Aggregate expressions by category
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Inventory Value by Category ===
PROMPT

SELECT
    category,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category
ORDER BY
    inventory_value DESC,
    category ASC;

-------------------------------------------------------------------------------
-- Step 13
-- WHERE before GROUP BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Aggregate In-Stock Books Only ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books
WHERE stock > 0
GROUP BY category
ORDER BY category ASC;

-------------------------------------------------------------------------------
-- Step 14
-- HAVING
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: HAVING ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category
HAVING COUNT(*) >= 3
ORDER BY
    book_count DESC,
    category ASC;

PROMPT
PROMPT HAVING filters groups after aggregation.
PROMPT

-------------------------------------------------------------------------------
-- Step 15
-- WHERE and HAVING together
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: WHERE + GROUP BY + HAVING ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count,
    SUM(stock) AS total_stock
FROM books
WHERE stock > 0
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY
    book_count DESC,
    category ASC;

-------------------------------------------------------------------------------
-- Step 16
-- Full category analysis
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Category Analysis ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category
ORDER BY
    inventory_value DESC,
    category ASC;

-------------------------------------------------------------------------------
-- Step 17
-- Final business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Final Business Question ===
PROMPT

PROMPT The bookstore wants a category-level inventory report.
PROMPT
PROMPT Requirements:
PROMPT   - only books currently in stock
PROMPT   - group books by CATEGORY
PROMPT   - count books as BOOK_COUNT
PROMPT   - calculate average price as AVERAGE_PRICE
PROMPT   - round AVERAGE_PRICE to two decimal places
PROMPT   - calculate total stock as TOTAL_STOCK
PROMPT   - calculate SUM(PRICE * STOCK) as INVENTORY_VALUE
PROMPT   - include only categories with at least two in-stock books
PROMPT   - show the largest INVENTORY_VALUE first
PROMPT   - use CATEGORY as the final tie-breaker
PROMPT

SELECT
    category,
    COUNT(*) AS book_count,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books
WHERE stock > 0
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY
    inventory_value DESC,
    category ASC;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 06 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   COUNT
PROMPT   SUM
PROMPT   AVG
PROMPT   MIN / MAX
PROMPT   GROUP BY
PROMPT   WHERE before aggregation
PROMPT   HAVING
PROMPT   Aggregate expressions
PROMPT   ORDER BY with aggregated results
PROMPT
PROMPT Course 02 - SQL Fundamentals completed.
PROMPT ============================================================