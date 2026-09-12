/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 05 - SQL Functions

File
----
lesson05.sql

Purpose
-------
Practice character, numeric, and NULL-handling SQL functions.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Lesson 04.

Topics
------
1. UPPER
2. LOWER
3. LENGTH
4. SUBSTR
5. ROUND
6. TRUNC
7. NVL
8. COALESCE
9. Nested functions
10. Functions with WHERE and ORDER BY

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 05
PROMPT SQL Functions
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

COLUMN TITLE FORMAT A30
COLUMN UPPER_TITLE FORMAT A30
COLUMN LOWER_TITLE FORMAT A30
COLUMN SHORT_TITLE FORMAT A15
COLUMN SUBTITLE FORMAT A50
COLUMN DISPLAY_SUBTITLE FORMAT A50
COLUMN DISPLAY_NAME FORMAT A50
COLUMN CATEGORY FORMAT A15
COLUMN PRICE FORMAT 999999.99
COLUMN INVENTORY_VALUE FORMAT 99999999.99
COLUMN ROUNDED_VALUE FORMAT 999999.99
COLUMN TRUNCATED_VALUE FORMAT 999999.99

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

SELECT COUNT(*) AS book_count
FROM books;

SELECT
    COUNT(*) AS books_with_subtitle
FROM books
WHERE subtitle IS NOT NULL;

SELECT
    COUNT(*) AS books_without_subtitle
FROM books
WHERE subtitle IS NULL;

-------------------------------------------------------------------------------
-- Step 3
-- UPPER
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: UPPER ===
PROMPT

SELECT
    book_id,
    title,
    UPPER(title) AS upper_title
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 4
-- LOWER
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: LOWER ===
PROMPT

SELECT
    book_id,
    title,
    LOWER(title) AS lower_title
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 5
-- LENGTH
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: LENGTH ===
PROMPT

SELECT
    book_id,
    title,
    LENGTH(title) AS title_length
FROM books
ORDER BY
    title_length DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 6
-- SUBSTR
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: SUBSTR ===
PROMPT

SELECT
    book_id,
    title,
    SUBSTR(title, 1, 10) AS short_title
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 7
-- ROUND
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: ROUND ===
PROMPT

SELECT
    book_id,
    title,
    price,
    price * 1.10 AS calculated_price,
    ROUND(price * 1.10) AS rounded_price
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 8
-- ROUND and TRUNC
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: ROUND vs TRUNC ===
PROMPT

SELECT
    book_id,
    title,
    price,
    ROUND(price / 3, 2) AS rounded_value,
    TRUNC(price / 3, 2) AS truncated_value
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 9
-- NVL
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: NVL ===
PROMPT

SELECT
    book_id,
    title,
    subtitle,
    NVL(subtitle, 'No subtitle') AS display_subtitle
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 10
-- COALESCE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: COALESCE ===
PROMPT

SELECT
    book_id,
    title,
    subtitle,
    COALESCE(subtitle, title) AS display_name
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 11
-- Nested functions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Nested Functions ===
PROMPT

SELECT
    book_id,
    title,
    UPPER(NVL(subtitle, 'No subtitle')) AS display_subtitle
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 12
-- Function in WHERE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Function in WHERE ===
PROMPT

SELECT
    book_id,
    title
FROM books
WHERE UPPER(title) LIKE '%SQL%'
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 13
-- Function in ORDER BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Function Result in ORDER BY ===
PROMPT

SELECT
    book_id,
    title,
    LENGTH(title) AS title_length
FROM books
ORDER BY
    title_length DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 14
-- Function with arithmetic expression
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Function + Arithmetic Expression ===
PROMPT

SELECT
    book_id,
    title,
    price,
    stock,
    ROUND(price * stock, 2) AS inventory_value
FROM books
WHERE stock > 0
ORDER BY
    inventory_value DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 15
-- Combine functions with filtering
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Catalog Display ===
PROMPT

SELECT
    book_id,
    UPPER(title) AS upper_title,
    NVL(subtitle, 'No subtitle') AS display_subtitle,
    category
FROM books
WHERE category IN ('Technology', 'Data Science')
ORDER BY
    category ASC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Step 16
-- Final business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Final Business Question ===
PROMPT

PROMPT The bookstore is preparing a catalog review.
PROMPT
PROMPT Requirements:
PROMPT   - only books currently in stock
PROMPT   - display TITLE in uppercase
PROMPT   - replace a NULL SUBTITLE with No subtitle
PROMPT   - calculate PRICE * STOCK as INVENTORY_VALUE
PROMPT   - round INVENTORY_VALUE to two decimal places
PROMPT   - highest INVENTORY_VALUE first
PROMPT   - BOOK_ID as the final tie-breaker
PROMPT

SELECT
    book_id,
    UPPER(title) AS upper_title,
    NVL(subtitle, 'No subtitle') AS display_subtitle,
    price,
    stock,
    ROUND(price * stock, 2) AS inventory_value
FROM books
WHERE stock > 0
ORDER BY
    inventory_value DESC,
    book_id ASC;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 05 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   UPPER / LOWER
PROMPT   LENGTH / SUBSTR
PROMPT   ROUND / TRUNC
PROMPT   NVL / COALESCE
PROMPT   Nested functions
PROMPT   Functions in WHERE
PROMPT   Functions in ORDER BY
PROMPT   Functions with expressions
PROMPT
PROMPT Next:
PROMPT   Lesson 06 - Aggregation and Grouping
PROMPT ============================================================