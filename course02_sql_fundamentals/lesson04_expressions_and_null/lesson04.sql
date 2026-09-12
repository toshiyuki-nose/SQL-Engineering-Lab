/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 04 - Expressions and NULL

File
----
lesson04.sql

Purpose
-------
Practice SQL expressions and learn how SQL handles NULL values.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Lesson 03 and run the Lesson 04 setup.sql once.

Topics
------
1. Arithmetic expressions
2. Expressions with columns
3. Column aliases
4. Character concatenation
5. NULL
6. IS NULL
7. IS NOT NULL
8. NULL in expressions
9. WHERE + expressions + ORDER BY

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 04
PROMPT Expressions and NULL
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

COLUMN TITLE FORMAT A30
COLUMN SUBTITLE FORMAT A50
COLUMN CATEGORY FORMAT A15
COLUMN PRICE FORMAT 999999.99
COLUMN INVENTORY_VALUE FORMAT 99999999.99
COLUMN BOOK_DESCRIPTION FORMAT A60

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
-- Inspect the evolved BOOKS table
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Inspect BOOKS ===
PROMPT

SELECT
    book_id,
    title,
    subtitle,
    category,
    price,
    stock,
    published_year
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 3
-- Basic arithmetic expression
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Arithmetic Expression ===
PROMPT

SELECT
    book_id,
    title,
    price,
    price * 1.10 AS price_with_tax
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 4
-- Calculate inventory value
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: PRICE * STOCK ===
PROMPT

SELECT
    book_id,
    title,
    price,
    stock,
    price * stock AS inventory_value
FROM books
ORDER BY inventory_value DESC;

-------------------------------------------------------------------------------
-- Step 5
-- Expressions do not change stored values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Stored Value vs Calculated Value ===
PROMPT

SELECT
    book_id,
    title,
    price,
    price + 500 AS hypothetical_price
FROM books
WHERE book_id IN (1001, 1002, 1003)
ORDER BY book_id;

PROMPT
PROMPT IMPORTANT:
PROMPT The expression changes only the query result.
PROMPT The stored PRICE value is not updated.
PROMPT

-------------------------------------------------------------------------------
-- Step 6
-- Character concatenation
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Concatenation ===
PROMPT

SELECT
    book_id,
    title || ' - ' || category AS book_description
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 7
-- Combine stored values into a display expression
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Build a Display Value ===
PROMPT

SELECT
    book_id,
    title || ' (' || published_year || ')' AS book_description
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 8
-- Inspect NULL values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Inspect SUBTITLE ===
PROMPT

SELECT
    book_id,
    title,
    subtitle
FROM books
ORDER BY book_id;

PROMPT
PROMPT Some books have a SUBTITLE.
PROMPT Other books contain NULL in SUBTITLE.
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- Find NULL values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: IS NULL ===
PROMPT

SELECT
    book_id,
    title,
    subtitle
FROM books
WHERE subtitle IS NULL
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 10
-- Find non-NULL values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: IS NOT NULL ===
PROMPT

SELECT
    book_id,
    title,
    subtitle
FROM books
WHERE subtitle IS NOT NULL
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 11
-- Incorrect NULL comparison
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: NULL Cannot Be Compared with = ===
PROMPT

SELECT
    book_id,
    title,
    subtitle
FROM books
WHERE subtitle = NULL;

PROMPT
PROMPT The query returns no matching rows.
PROMPT Use IS NULL instead of = NULL.
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- NULL in arithmetic expressions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: NULL in an Arithmetic Expression ===
PROMPT

SELECT
    book_id,
    title,
    price,
    NULL AS discount_amount,
    price - NULL AS calculated_price
FROM books
WHERE book_id IN (1001, 1002, 1003)
ORDER BY book_id;

PROMPT
PROMPT A calculation involving NULL normally produces NULL.
PROMPT

-------------------------------------------------------------------------------
-- Step 13
-- NULL and concatenation in Oracle
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: NULL and Concatenation ===
PROMPT

SELECT
    book_id,
    title,
    subtitle,
    title || ' - ' || subtitle AS book_description
FROM books
ORDER BY book_id;

PROMPT
PROMPT IMPORTANT:
PROMPT Oracle currently treats a zero-length character value as NULL.
PROMPT In concatenation, a NULL character value does not necessarily make
PROMPT the complete concatenated result NULL.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Combine filtering, expressions, and sorting
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Filter + Expression + Sort ===
PROMPT

SELECT
    book_id,
    title,
    price,
    stock,
    price * stock AS inventory_value
FROM books
WHERE stock > 0
ORDER BY inventory_value DESC;

-------------------------------------------------------------------------------
-- Step 15
-- Expressions with multiple conditions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Technology and Data Science Inventory ===
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    price * stock AS inventory_value
FROM books
WHERE category IN ('Technology', 'Data Science')
  AND stock > 0
ORDER BY
    inventory_value DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 16
-- Final business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Final Business Question ===
PROMPT

PROMPT The bookstore wants to review books that do not yet have a subtitle.
PROMPT
PROMPT Requirements:
PROMPT   - SUBTITLE is missing
PROMPT   - book is currently in stock
PROMPT   - calculate PRICE * STOCK as INVENTORY_VALUE
PROMPT   - show the highest inventory value first
PROMPT   - use BOOK_ID as the final tie-breaker
PROMPT

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    price * stock AS inventory_value
FROM books
WHERE subtitle IS NULL
  AND stock > 0
ORDER BY
    inventory_value DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 04 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   Arithmetic expressions
PROMPT   Column aliases
PROMPT   Character concatenation
PROMPT   NULL
PROMPT   IS NULL / IS NOT NULL
PROMPT   NULL in expressions
PROMPT   WHERE + expressions + ORDER BY
PROMPT
PROMPT Next:
PROMPT   Lesson 05 - SQL Functions
PROMPT ============================================================