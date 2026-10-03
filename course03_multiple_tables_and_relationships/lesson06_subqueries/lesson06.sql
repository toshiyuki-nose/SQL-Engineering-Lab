/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 06 - Subqueries

File
----
lesson06.sql

Purpose
-------
Practice using subqueries with the SQL-Engineering-Lab Book Store Database.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Course 03 Lessons 01-05.

Required tables:

    CATEGORIES
    BOOKS
    AUTHORS
    BOOK_AUTHORS

Topics
------
1. Basic subqueries
2. Single-row subqueries
3. Aggregate subqueries
4. Multi-row subqueries
5. IN
6. EXISTS
7. NOT EXISTS
8. Correlated subqueries
9. Correlated aggregate subqueries
10. Subqueries and JOINs

Execution Log
-------------
SQL*Plus output is written to:

    logs/lesson06.log

==============================================================================
*/

SPOOL logs/lesson06.log

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 06
PROMPT Subqueries
PROMPT ============================================================
PROMPT

-------------------------------------------------------------------------------
-- Step 1
-- Execution information
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 1: Execution Information ===
PROMPT

COLUMN EXECUTED_AT FORMAT A20
COLUMN CURRENT_USER FORMAT A15
COLUMN CONTAINER_NAME FORMAT A20
COLUMN CURRENT_SCHEMA FORMAT A20

SELECT
    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS executed_at,
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

SHOW USER
SHOW CON_NAME

-------------------------------------------------------------------------------
-- Step 2
-- Verify required tables
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Verify Required Tables ===
PROMPT

COLUMN TABLE_NAME FORMAT A20

SELECT
    table_name
FROM user_tables
WHERE table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
ORDER BY table_name;

-------------------------------------------------------------------------------
-- Step 3
-- Inspect BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Inspect BOOKS ===
PROMPT

COLUMN TITLE FORMAT A30
COLUMN CATEGORY_NAME FORMAT A20
COLUMN AUTHOR_NAME FORMAT A25
COLUMN PRICE FORMAT 999999.99

SELECT
    book_id,
    title,
    category_id,
    price,
    stock
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 4
-- Run the inner query independently
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Calculate the Average Price ===
PROMPT

SELECT
    AVG(price) AS average_price
FROM books;

PROMPT
PROMPT This query returns one value.
PROMPT It can therefore be used as a single-row subquery.
PROMPT

-------------------------------------------------------------------------------
-- Step 5
-- Basic single-row subquery
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Books Above the Average Price ===
PROMPT

SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
)
ORDER BY price DESC;

-------------------------------------------------------------------------------
-- Step 6
-- Maximum price
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Most Expensive Book or Books ===
PROMPT

SELECT
    MAX(price) AS maximum_price
FROM books;

SELECT
    book_id,
    title,
    price
FROM books
WHERE price = (
    SELECT MAX(price)
    FROM books
)
ORDER BY book_id;

PROMPT
PROMPT The query does not hard-code the current maximum price.
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- Minimum price
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Least Expensive Book or Books ===
PROMPT

SELECT
    book_id,
    title,
    price
FROM books
WHERE price = (
    SELECT MIN(price)
    FROM books
)
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 8
-- Inspect a multi-row inner query
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Category IDs Returned by a Subquery ===
PROMPT

SELECT
    category_id,
    category_name
FROM categories
WHERE category_name IN (
    'Technology',
    'Data Science'
)
ORDER BY category_id;

PROMPT
PROMPT This query can return multiple rows.
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- IN with a subquery
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: IN with a Subquery ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.category_id,
    b.price
FROM books b
WHERE b.category_id IN (
    SELECT c.category_id
    FROM categories c
    WHERE c.category_name IN (
        'Technology',
        'Data Science'
    )
)
ORDER BY
    b.category_id,
    b.book_id;

-------------------------------------------------------------------------------
-- Step 10
-- Subquery using BOOK_AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Books with Author Relationships using IN ===
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE b.book_id IN (
    SELECT ba.book_id
    FROM book_authors ba
)
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 11
-- EXISTS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Books with Authors using EXISTS ===
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
)
ORDER BY b.book_id;

PROMPT
PROMPT EXISTS asks whether at least one matching row exists.
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- NOT EXISTS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Authors without Books ===
PROMPT

SELECT
    a.author_id,
    a.author_name
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.author_id = a.author_id
)
ORDER BY a.author_id;

PROMPT
PROMPT The author added in Lesson 04 without a book relationship
PROMPT should appear in this result.
PROMPT

-------------------------------------------------------------------------------
-- Step 13
-- Compare NOT EXISTS with LEFT JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: NOT EXISTS vs LEFT JOIN ===
PROMPT

PROMPT
PROMPT Method A - NOT EXISTS
PROMPT

SELECT
    a.author_id,
    a.author_name
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.author_id = a.author_id
)
ORDER BY a.author_id;

PROMPT
PROMPT Method B - LEFT JOIN and IS NULL
PROMPT

SELECT
    a.author_id,
    a.author_name
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
WHERE ba.book_id IS NULL
ORDER BY a.author_id;

PROMPT
PROMPT Both queries express the missing-relationship question differently.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Correlated subquery
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Correlated Subquery ===
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
)
ORDER BY b.book_id;

PROMPT
PROMPT The inner query references B.BOOK_ID from the outer query.
PROMPT This makes it a correlated subquery.
PROMPT

-------------------------------------------------------------------------------
-- Step 15
-- Global average
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Global Average Comparison ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.category_id,
    b.price
FROM books b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
)
ORDER BY
    b.price DESC,
    b.book_id;

PROMPT
PROMPT Every book is compared with one global average.
PROMPT

-------------------------------------------------------------------------------
-- Step 16
-- Category averages
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Inspect Category Average Prices ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    AVG(b.price) AS average_price
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 17
-- Correlated aggregate subquery
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Books Above Their Category Average ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.category_id,
    b.price
FROM books b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.category_id = b.category_id
)
ORDER BY
    b.category_id,
    b.price DESC,
    b.book_id;

PROMPT
PROMPT Each book is compared with the average price
PROMPT of books in its own category.
PROMPT

-------------------------------------------------------------------------------
-- Step 18
-- Show category names with correlated subquery result
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 18: Category-Average Business Report ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.category_id = b.category_id
)
ORDER BY
    c.category_name,
    b.price DESC;

-------------------------------------------------------------------------------
-- Step 19
-- Compare IN, EXISTS, and JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 19: IN vs EXISTS vs JOIN ===
PROMPT

PROMPT
PROMPT Method A - IN
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE b.book_id IN (
    SELECT ba.book_id
    FROM book_authors ba
)
ORDER BY b.book_id;

PROMPT
PROMPT Method B - EXISTS
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
)
ORDER BY b.book_id;

PROMPT
PROMPT Method C - JOIN
PROMPT

SELECT DISTINCT
    b.book_id,
    b.title
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
ORDER BY b.book_id;

PROMPT
PROMPT All three queries answer:
PROMPT   Which books have at least one author relationship?
PROMPT

-------------------------------------------------------------------------------
-- Step 20
-- Books with multiple authors
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 20: Books with Multiple Authors ===
PROMPT

SELECT
    b.book_id,
    b.title
FROM books b
WHERE b.book_id IN (
    SELECT
        ba.book_id
    FROM book_authors ba
    GROUP BY ba.book_id
    HAVING COUNT(*) > 1
)
ORDER BY b.book_id;

PROMPT
PROMPT The subquery first identifies BOOK_ID values
PROMPT having more than one author relationship.
PROMPT

-------------------------------------------------------------------------------
-- Step 21
-- Categories that contain books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 21: Categories Containing Books ===
PROMPT

SELECT
    c.category_id,
    c.category_name
FROM categories c
WHERE EXISTS (
    SELECT 1
    FROM books b
    WHERE b.category_id = c.category_id
)
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 22
-- Categories without books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 22: Categories without Books ===
PROMPT

SELECT
    c.category_id,
    c.category_name
FROM categories c
WHERE NOT EXISTS (
    SELECT 1
    FROM books b
    WHERE b.category_id = c.category_id
)
ORDER BY c.category_id;

PROMPT
PROMPT Category 60 - Reference should appear.
PROMPT

-------------------------------------------------------------------------------
-- Step 23
-- Practical business question
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 23: Practical Business Question ===
PROMPT

PROMPT
PROMPT Question:
PROMPT
PROMPT Find in-stock Technology or Data Science books
PROMPT whose price is above the overall average book price.
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price,
    b.stock
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
WHERE b.category_id IN (
    SELECT c2.category_id
    FROM categories c2
    WHERE c2.category_name IN (
        'Technology',
        'Data Science'
    )
)
AND b.price > (
    SELECT AVG(b2.price)
    FROM books b2
)
AND b.stock > 0
ORDER BY
    b.price DESC,
    b.book_id;

-------------------------------------------------------------------------------
-- Step 24
-- Final challenge
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 24: Final Challenge ===
PROMPT

PROMPT
PROMPT Question:
PROMPT
PROMPT Find books that:
PROMPT   - have at least one author
PROMPT   - are more expensive than the average book
PROMPT     in their own category
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
)
AND b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.category_id = b.category_id
)
ORDER BY
    c.category_name,
    b.price DESC,
    b.book_id;

-------------------------------------------------------------------------------
-- Step 25
-- Final review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 25: Final Review ===
PROMPT

PROMPT
PROMPT When working with subqueries:
PROMPT
PROMPT   1. Identify the information the inner query must return.
PROMPT   2. Run the inner query independently when debugging.
PROMPT   3. Determine whether it returns one row or multiple rows.
PROMPT   4. Choose the appropriate operator.
PROMPT   5. Check whether the inner query must reference the outer row.
PROMPT   6. Use EXISTS when the question is about existence.
PROMPT   7. Consider JOIN when columns from related tables are required.
PROMPT

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 06 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   Basic subqueries
PROMPT   Single-row subqueries
PROMPT   Aggregate subqueries
PROMPT   Multi-row subqueries
PROMPT   IN
PROMPT   EXISTS
PROMPT   NOT EXISTS
PROMPT   Correlated subqueries
PROMPT   Correlated aggregate subqueries
PROMPT   Subqueries vs JOINs
PROMPT   Practical business queries
PROMPT
PROMPT Execution log:
PROMPT   logs/lesson06.log
PROMPT
PROMPT Course 03 - Multiple Tables and Relationships completed.
PROMPT ============================================================
PROMPT

SPOOL OFF