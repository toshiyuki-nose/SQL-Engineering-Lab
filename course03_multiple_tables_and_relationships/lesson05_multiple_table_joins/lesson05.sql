/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 05 - Multiple Table Joins

File
----
lesson05.sql

Purpose
-------
Practice building queries across multiple related tables.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Course 03 Lessons 01-04.

Required tables:

    CATEGORIES
    BOOKS
    AUTHORS
    BOOK_AUTHORS

Topics
------
1. JOIN paths
2. Three-table JOIN
3. Four-table JOIN
4. Table aliases
5. Row multiplication
6. COUNT and COUNT(DISTINCT)
7. INNER JOIN with multiple tables
8. LEFT JOIN chains
9. JOIN with WHERE
10. JOIN with GROUP BY
11. Query grain
12. Practical multi-table queries

Execution Log
-------------
SQL*Plus output is written to:

    logs/lesson05.log

==============================================================================
*/

SPOOL logs/lesson05.log

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 05
PROMPT Multiple Table Joins
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
-- Review the relationship model
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Relationship Model ===
PROMPT

PROMPT
PROMPT CATEGORIES
PROMPT      |
PROMPT      | 1:N
PROMPT      |
PROMPT    BOOKS
PROMPT      |
PROMPT      | 1:N
PROMPT      |
PROMPT BOOK_AUTHORS
PROMPT      |
PROMPT      | N:1
PROMPT      |
PROMPT   AUTHORS
PROMPT

-------------------------------------------------------------------------------
-- Step 4
-- Start with BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Start with BOOKS ===
PROMPT

COLUMN TITLE FORMAT A30

SELECT
    b.book_id,
    b.title,
    b.category_id
FROM books b
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 5
-- Add CATEGORIES
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: BOOKS + CATEGORIES ===
PROMPT

COLUMN CATEGORY_NAME FORMAT A20

SELECT
    b.book_id,
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 6
-- Add BOOK_AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Add BOOK_AUTHORS ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    ba.author_id
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
ORDER BY
    b.book_id,
    ba.author_id;

PROMPT
PROMPT Notice:
PROMPT   BOOK_AUTHORS is needed to reach AUTHORS.
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- Add AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Four-Table JOIN ===
PROMPT

COLUMN AUTHOR_NAME FORMAT A25

SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
ORDER BY
    b.book_id,
    a.author_name;

-------------------------------------------------------------------------------
-- Step 8
-- Compare source row counts
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Source Row Counts ===
PROMPT

SELECT COUNT(*) AS book_count
FROM books;

SELECT COUNT(*) AS book_author_relationships
FROM book_authors;

PROMPT
PROMPT BOOKS counts books.
PROMPT BOOK_AUTHORS counts book-author relationships.
PROMPT These numbers do not have to be the same.
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- Demonstrate row multiplication
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Row Multiplication ===
PROMPT

SELECT
    b.book_id,
    b.title,
    a.author_id,
    a.author_name
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE b.book_id = 1002
ORDER BY a.author_id;

PROMPT
PROMPT BOOK_ID 1002 appears once for each author relationship.
PROMPT

-------------------------------------------------------------------------------
-- Step 10
-- COUNT(*) after JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: COUNT(*) after JOIN ===
PROMPT

SELECT
    COUNT(*) AS joined_rows
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;

PROMPT
PROMPT JOINED_ROWS represents book-author relationships,
PROMPT not necessarily unique books.
PROMPT

-------------------------------------------------------------------------------
-- Step 11
-- COUNT(DISTINCT)
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: COUNT vs COUNT(DISTINCT) ===
PROMPT

SELECT
    COUNT(*) AS relationship_count,
    COUNT(DISTINCT b.book_id) AS distinct_book_count,
    COUNT(DISTINCT ba.author_id) AS distinct_author_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;

PROMPT
PROMPT COUNT(*) counts relationship rows.
PROMPT COUNT(DISTINCT ...) counts unique entities.
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- Multi-table JOIN with WHERE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Multi-Table JOIN with WHERE ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name,
    b.price,
    b.stock
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE c.category_name IN (
    'Technology',
    'Data Science'
)
AND b.stock > 0
ORDER BY
    c.category_name,
    b.title,
    a.author_name;

-------------------------------------------------------------------------------
-- Step 13
-- Preserve all categories
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Preserve All Categories ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title,
    a.author_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
ORDER BY
    c.category_id,
    b.book_id,
    a.author_name;

PROMPT
PROMPT Category 60 - Reference should remain in the result.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Demonstrate JOIN type propagation
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: JOIN Type Propagation ===
PROMPT

PROMPT
PROMPT First, preserve CATEGORIES with LEFT JOIN,
PROMPT then use INNER JOIN for BOOK_AUTHORS.
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title,
    ba.author_id
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
ORDER BY
    c.category_id,
    b.book_id,
    ba.author_id;

PROMPT
PROMPT Notice:
PROMPT   The empty Reference category disappears.
PROMPT
PROMPT The later INNER JOIN requires a matching BOOK_AUTHORS row.
PROMPT

-------------------------------------------------------------------------------
-- Step 15
-- Preserve the optional relationship chain
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Preserve the Entire Relationship Chain ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title,
    a.author_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
ORDER BY
    c.category_id,
    b.book_id,
    a.author_name;

PROMPT
PROMPT Using LEFT JOIN through the chain preserves empty categories.
PROMPT

-------------------------------------------------------------------------------
-- Step 16
-- Count books by category
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Count Books by Category ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

PROMPT
PROMPT Reference should have BOOK_COUNT = 0.
PROMPT

-------------------------------------------------------------------------------
-- Step 17
-- Count authors by category
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Count Authors by Category ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT a.author_id) AS author_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 18
-- Combined category report
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 18: Category Report ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count,
    COUNT(DISTINCT a.author_id) AS author_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 19
-- Show aggregation risk
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 19: Aggregation after a One-to-Many JOIN ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.stock,
    COUNT(ba.author_id) AS author_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
GROUP BY
    b.book_id,
    b.title,
    b.stock
ORDER BY b.book_id;

PROMPT
PROMPT A book with multiple authors participates in multiple JOIN rows.
PROMPT
PROMPT Before using SUM or AVG after a multi-table JOIN,
PROMPT always understand the grain of the result.
PROMPT

-------------------------------------------------------------------------------
-- Step 20
-- Compare grains
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 20: Compare Query Grains ===
PROMPT

PROMPT
PROMPT BOOKS:
PROMPT   one row = one book
PROMPT
PROMPT BOOK_AUTHORS:
PROMPT   one row = one book-author relationship
PROMPT
PROMPT BOOKS JOIN BOOK_AUTHORS:
PROMPT   one row = one book-author relationship
PROMPT

SELECT
    COUNT(*) AS books_table_rows
FROM books;

SELECT
    COUNT(*) AS relationship_rows
FROM book_authors;

SELECT
    COUNT(*) AS joined_rows
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;

-------------------------------------------------------------------------------
-- Step 21
-- Practical book report
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 21: Practical Book Report ===
PROMPT

PROMPT
PROMPT Question:
PROMPT
PROMPT Show Technology and Data Science books that are currently in stock,
PROMPT including category, author, price, and stock.
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name,
    b.price,
    b.stock
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE c.category_name IN (
    'Technology',
    'Data Science'
)
AND b.stock > 0
ORDER BY
    c.category_name,
    b.title,
    a.author_name;

-------------------------------------------------------------------------------
-- Step 22
-- Practical category report
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 22: Practical Category Report ===
PROMPT

PROMPT
PROMPT Question:
PROMPT
PROMPT Show every category and count the number of different books
PROMPT and authors represented in each category.
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count,
    COUNT(DISTINCT a.author_id) AS author_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 23
-- Final review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 23: Final Review ===
PROMPT

PROMPT
PROMPT When building a multi-table query:
PROMPT
PROMPT   1. Define the business question.
PROMPT   2. Identify the required columns.
PROMPT   3. Identify which tables contain those columns.
PROMPT   4. Follow PK/FK relationships between the tables.
PROMPT   5. Add JOINs incrementally.
PROMPT   6. Check the result row count.
PROMPT   7. Understand the grain of the result.
PROMPT   8. Add filtering and aggregation carefully.
PROMPT

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 05 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   JOIN paths
PROMPT   Three-table JOIN
PROMPT   Four-table JOIN
PROMPT   Table aliases
PROMPT   Row multiplication
PROMPT   COUNT(DISTINCT)
PROMPT   Multiple INNER JOINs
PROMPT   Multiple LEFT JOINs
PROMPT   JOIN type propagation
PROMPT   Multi-table filtering
PROMPT   Multi-table aggregation
PROMPT   Query grain
PROMPT   Practical reporting queries
PROMPT
PROMPT Execution log:
PROMPT   logs/lesson05.log
PROMPT
PROMPT Next:
PROMPT   Lesson 06 - Subqueries
PROMPT ============================================================
PROMPT

SPOOL OFF