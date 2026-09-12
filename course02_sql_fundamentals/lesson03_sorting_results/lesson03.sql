/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 03 - Sorting Results

File
----
lesson03.sql

Purpose
-------
Practice sorting query results using the ORDER BY clause.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Lesson 02 and keep the BOOKS table.

Topics
------
1. ORDER BY
2. ASC
3. DESC
4. Multiple sort columns
5. WHERE + ORDER BY
6. Sorting by aliases
7. Sorting by column position
8. Deterministic ordering

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 03
PROMPT Sorting Results
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 160
SET PAGESIZE 100

COLUMN TITLE FORMAT A30
COLUMN CATEGORY FORMAT A15
COLUMN PRICE FORMAT 999999.99
COLUMN BOOK_PRICE FORMAT 999999.99

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
-- Verify the prerequisite
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Verify BOOKS ===
PROMPT

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';

SELECT COUNT(*) AS book_count
FROM books;

-------------------------------------------------------------------------------
-- Step 3
-- Inspect the dataset without ORDER BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: SELECT Without ORDER BY ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year
FROM books;

PROMPT
PROMPT IMPORTANT:
PROMPT Without ORDER BY, the result order should not be treated as guaranteed.
PROMPT

-------------------------------------------------------------------------------
-- Step 4
-- Ascending order
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4A: PRICE - Default Ascending Order ===
PROMPT

SELECT
    book_id,
    title,
    price
FROM books
ORDER BY price;

PROMPT
PROMPT === Step 4B: PRICE ASC ===
PROMPT

SELECT
    book_id,
    title,
    price
FROM books
ORDER BY price ASC;

-------------------------------------------------------------------------------
-- Step 5
-- Descending order
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: PRICE DESC ===
PROMPT

SELECT
    book_id,
    title,
    price
FROM books
ORDER BY price DESC;

-------------------------------------------------------------------------------
-- Step 6
-- Sort character values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: CATEGORY ASC ===
PROMPT

SELECT
    book_id,
    title,
    category
FROM books
ORDER BY category ASC;

-------------------------------------------------------------------------------
-- Step 7
-- Sort by publication year
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Newest Books First ===
PROMPT

SELECT
    book_id,
    title,
    published_year
FROM books
ORDER BY published_year DESC;

-------------------------------------------------------------------------------
-- Step 8
-- Multiple sort columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: CATEGORY ASC, PRICE ASC ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price
FROM books
ORDER BY
    category ASC,
    price ASC;

-------------------------------------------------------------------------------
-- Step 9
-- Different sort directions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: CATEGORY ASC, PUBLISHED_YEAR DESC ===
PROMPT

SELECT
    book_id,
    title,
    category,
    published_year
FROM books
ORDER BY
    category ASC,
    published_year DESC;

-------------------------------------------------------------------------------
-- Step 10
-- WHERE + ORDER BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Technology Books in Stock - Cheapest First ===
PROMPT

SELECT
    book_id,
    title,
    price,
    stock
FROM books
WHERE category = 'Technology'
  AND stock > 0
ORDER BY price ASC;

-------------------------------------------------------------------------------
-- Step 11
-- Filter by multiple categories and then sort
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Technology and Data Science - Cheapest First ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price
FROM books
WHERE category IN ('Technology', 'Data Science')
ORDER BY price ASC;

-------------------------------------------------------------------------------
-- Step 12
-- Sort by a column not displayed
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Sort by a Non-Selected Column ===
PROMPT

SELECT
    book_id,
    title
FROM books
ORDER BY published_year DESC;

-------------------------------------------------------------------------------
-- Step 13
-- Sort by a column alias
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Sort by Column Alias ===
PROMPT

SELECT
    book_id,
    title,
    price AS book_price
FROM books
ORDER BY book_price DESC;

-------------------------------------------------------------------------------
-- Step 14
-- Sort by column position
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Sort by Column Position ===
PROMPT

PROMPT In this SELECT list:
PROMPT   1 = TITLE
PROMPT   2 = CATEGORY
PROMPT   3 = PRICE
PROMPT

SELECT
    title,
    category,
    price
FROM books
ORDER BY 3 DESC;

-------------------------------------------------------------------------------
-- Step 15
-- Deterministic ordering with a tie-breaker
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Deterministic Ordering ===
PROMPT

SELECT
    book_id,
    title,
    published_year
FROM books
ORDER BY
    published_year DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 16
-- Combined filtering and sorting
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Combined Filtering and Sorting ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year
FROM books
WHERE price >= 2500
  AND stock > 0
ORDER BY
    price DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 17
-- Final business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Final Business Question ===
PROMPT

PROMPT Find Technology or Data Science books:
PROMPT   - currently in stock
PROMPT   - published between 2020 and 2025
PROMPT   - category ascending
PROMPT   - newest books first within each category
PROMPT   - BOOK_ID as the final tie-breaker
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year
FROM books
WHERE category IN ('Technology', 'Data Science')
  AND stock > 0
  AND published_year BETWEEN 2020 AND 2025
ORDER BY
    category ASC,
    published_year DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 03 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   ORDER BY
PROMPT   ASC / DESC
PROMPT   Multiple sort columns
PROMPT   WHERE + ORDER BY
PROMPT   Sorting by aliases
PROMPT   Sorting by column position
PROMPT   Deterministic ordering
PROMPT
PROMPT Next:
PROMPT   Lesson 04 - Expressions and NULL
PROMPT ============================================================