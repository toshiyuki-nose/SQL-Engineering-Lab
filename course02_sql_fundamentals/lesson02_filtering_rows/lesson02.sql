/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 02 - Filtering Rows

File
----
lesson02.sql

Purpose
-------
Practice filtering rows using the WHERE clause.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Run setup.sql before this script.

Topics
------
1. WHERE
2. Comparison operators
3. AND
4. OR
5. NOT
6. BETWEEN
7. IN
8. LIKE
9. Combined conditions

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 02
PROMPT Filtering Rows
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 160
SET PAGESIZE 100

COLUMN TITLE FORMAT A30
COLUMN CATEGORY FORMAT A15
COLUMN PRICE FORMAT 999999.99

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
-- Inspect the complete dataset
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Inspect BOOKS ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year
FROM books;

-------------------------------------------------------------------------------
-- Step 3
-- Equality
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: CATEGORY = Technology ===
PROMPT

SELECT
    book_id,
    title,
    category
FROM books
WHERE category = 'Technology';

-------------------------------------------------------------------------------
-- Step 4
-- Not equal
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: CATEGORY <> Technology ===
PROMPT

SELECT
    book_id,
    title,
    category
FROM books
WHERE category <> 'Technology';

-------------------------------------------------------------------------------
-- Step 5
-- Numeric comparisons
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5A: PRICE >= 3000 ===
PROMPT

SELECT
    title,
    price
FROM books
WHERE price >= 3000;

PROMPT
PROMPT === Step 5B: PRICE < 2000 ===
PROMPT

SELECT
    title,
    price
FROM books
WHERE price < 2000;

-------------------------------------------------------------------------------
-- Step 6
-- AND
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: AND ===
PROMPT

SELECT
    title,
    category,
    price
FROM books
WHERE category = 'Technology'
  AND price >= 3000;

-------------------------------------------------------------------------------
-- Step 7
-- OR
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: OR ===
PROMPT

SELECT
    title,
    category
FROM books
WHERE category = 'Technology'
   OR category = 'Data Science';

-------------------------------------------------------------------------------
-- Step 8
-- NOT
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: NOT ===
PROMPT

SELECT
    title,
    category
FROM books
WHERE NOT category = 'Technology';

-------------------------------------------------------------------------------
-- Step 9
-- BETWEEN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: BETWEEN ===
PROMPT

SELECT
    title,
    published_year
FROM books
WHERE published_year BETWEEN 2020 AND 2024;

-------------------------------------------------------------------------------
-- Step 10
-- IN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: IN ===
PROMPT

SELECT
    title,
    category
FROM books
WHERE category IN (
    'Technology',
    'Data Science',
    'Business'
);

-------------------------------------------------------------------------------
-- Step 11
-- LIKE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11A: Titles Containing SQL ===
PROMPT

SELECT
    book_id,
    title
FROM books
WHERE title LIKE '%SQL%';

PROMPT
PROMPT === Step 11B: Titles Starting with Data ===
PROMPT

SELECT
    book_id,
    title
FROM books
WHERE title LIKE 'Data%';

-------------------------------------------------------------------------------
-- Step 12
-- Stock filtering
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12A: Books in Stock ===
PROMPT

SELECT
    title,
    stock
FROM books
WHERE stock > 0;

PROMPT
PROMPT === Step 12B: Out-of-Stock Books ===
PROMPT

SELECT
    title,
    stock
FROM books
WHERE stock = 0;

-------------------------------------------------------------------------------
-- Step 13
-- Combined conditions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Combined Conditions ===
PROMPT

SELECT
    title,
    category,
    price,
    stock
FROM books
WHERE category IN ('Technology', 'Data Science')
  AND price <= 4000
  AND stock > 0;

-------------------------------------------------------------------------------
-- Step 14
-- Parentheses and logical conditions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Parentheses ===
PROMPT

SELECT
    title,
    category,
    stock
FROM books
WHERE (
        category = 'Technology'
        OR category = 'Data Science'
      )
  AND stock > 0;

-------------------------------------------------------------------------------
-- Step 15
-- Final business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Final Business Question ===
PROMPT

PROMPT Find Technology or Data Science books:
PROMPT   - published between 2020 and 2025
PROMPT   - price <= 4000
PROMPT   - stock > 0
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
  AND published_year BETWEEN 2020 AND 2025
  AND price <= 4000
  AND stock > 0;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 02 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   WHERE
PROMPT   Comparison operators
PROMPT   AND / OR / NOT
PROMPT   BETWEEN
PROMPT   IN
PROMPT   LIKE
PROMPT   Combined conditions
PROMPT
PROMPT Next:
PROMPT   Lesson 03 - Sorting Results
PROMPT ============================================================