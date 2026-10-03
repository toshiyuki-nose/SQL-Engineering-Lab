/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 03 - INNER JOIN

File
----
lesson03.sql

Purpose
-------
Practice retrieving related data from multiple tables using INNER JOIN.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Course 03 Lesson 02.

Required tables:

    CATEGORIES
    BOOKS
    AUTHORS
    BOOK_AUTHORS

Topics
------
1. INNER JOIN
2. JOIN conditions
3. Table aliases
4. Two-table JOIN
5. Three-table JOIN
6. Junction tables
7. Four-table JOIN
8. JOIN with WHERE
9. JOIN with ORDER BY
10. JOIN with aggregation

Execution Log
-------------
SQL*Plus output is written to:

    logs/lesson03.log

==============================================================================
*/

SPOOL logs/lesson03.log

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 03
PROMPT INNER JOIN
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
-- Inspect BOOKS before JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: BOOKS before JOIN ===
PROMPT

COLUMN TITLE FORMAT A30

SELECT
    book_id,
    title,
    category_id
FROM books
ORDER BY book_id;

PROMPT
PROMPT CATEGORY_ID identifies the relationship,
PROMPT but CATEGORY_ID alone does not show the category name.
PROMPT

-------------------------------------------------------------------------------
-- Step 4
-- Inspect CATEGORIES
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: CATEGORIES ===
PROMPT

COLUMN CATEGORY_NAME FORMAT A20

SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

-------------------------------------------------------------------------------
-- Step 5
-- First INNER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: BOOKS INNER JOIN CATEGORIES ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.category_id,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 6
-- Select only useful columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Hide Technical Relationship Column ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

PROMPT
PROMPT CATEGORY_ID is still used by the JOIN,
PROMPT even though it does not have to appear in the SELECT list.
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- JOIN with WHERE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: JOIN with WHERE ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
WHERE c.category_name = 'Technology'
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 8
-- JOIN with multiple filtering conditions
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: JOIN with Multiple Conditions ===
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
WHERE c.category_name IN (
    'Technology',
    'Data Science'
)
AND b.stock > 0
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 9
-- JOIN with ORDER BY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: JOIN with ORDER BY ===
PROMPT

SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY
    c.category_name,
    b.price DESC;

-------------------------------------------------------------------------------
-- Step 10
-- Inspect BOOK_AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Inspect BOOK_AUTHORS ===
PROMPT

SELECT
    book_id,
    author_id
FROM book_authors
ORDER BY
    book_id,
    author_id;

PROMPT
PROMPT BOOK_AUTHORS contains relationship IDs.
PROMPT Next, JOIN will turn those IDs into useful information.
PROMPT

-------------------------------------------------------------------------------
-- Step 11
-- Inspect AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Inspect AUTHORS ===
PROMPT

COLUMN AUTHOR_NAME FORMAT A25

SELECT
    author_id,
    author_name
FROM authors
ORDER BY author_id;

-------------------------------------------------------------------------------
-- Step 12
-- Three-table JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: BOOKS -> BOOK_AUTHORS -> AUTHORS ===
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
ORDER BY
    b.book_id,
    a.author_id;

-------------------------------------------------------------------------------
-- Step 13
-- Observe a book with multiple authors
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: One Book with Multiple Authors ===
PROMPT

SELECT
    b.book_id,
    b.title,
    a.author_name
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE b.book_id = 1002
ORDER BY a.author_name;

PROMPT
PROMPT BOOK_ID 1002 should appear once for each related author.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Join all four tables
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Join All Four Tables ===
PROMPT

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
-- Step 15
-- JOIN with aggregation
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Count Books by Category ===
PROMPT

SELECT
    c.category_name,
    COUNT(*) AS book_count
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
GROUP BY c.category_name
ORDER BY c.category_name;

-------------------------------------------------------------------------------
-- Step 16
-- Count authors per book
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Count Authors per Book ===
PROMPT

SELECT
    b.book_id,
    b.title,
    COUNT(ba.author_id) AS author_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
GROUP BY
    b.book_id,
    b.title
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 17
-- Filter aggregated JOIN results
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Books with Multiple Authors ===
PROMPT

SELECT
    b.book_id,
    b.title,
    COUNT(ba.author_id) AS author_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
GROUP BY
    b.book_id,
    b.title
HAVING COUNT(ba.author_id) > 1
ORDER BY b.book_id;

PROMPT
PROMPT This query combines:
PROMPT   INNER JOIN
PROMPT   GROUP BY
PROMPT   HAVING
PROMPT

-------------------------------------------------------------------------------
-- Step 18
-- Practical business query
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 18: Practical Business Query ===
PROMPT

PROMPT
PROMPT Question:
PROMPT Which Technology or Data Science books are currently in stock,
PROMPT and who wrote them?
PROMPT

COLUMN CATEGORY_NAME FORMAT A20
COLUMN AUTHOR_NAME FORMAT A25

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
-- Step 19
-- Final relationship review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 19: Final Relationship Review ===
PROMPT

PROMPT
PROMPT Relational Model:
PROMPT
PROMPT   CATEGORIES
PROMPT       CATEGORY_ID PK
PROMPT            |
PROMPT            | 1
PROMPT            |
PROMPT            | N
PROMPT          BOOKS
PROMPT       BOOK_ID     PK
PROMPT       CATEGORY_ID FK
PROMPT            |
PROMPT            | 1
PROMPT            |
PROMPT            | N
PROMPT      BOOK_AUTHORS
PROMPT       BOOK_ID   PK, FK
PROMPT       AUTHOR_ID PK, FK
PROMPT            |
PROMPT            | N
PROMPT            |
PROMPT            | 1
PROMPT         AUTHORS
PROMPT       AUTHOR_ID PK
PROMPT

PROMPT INNER JOIN follows these relationships to combine related rows.
PROMPT

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 03 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   INNER JOIN
PROMPT   ON
PROMPT   Table aliases
PROMPT   Two-table JOIN
PROMPT   Three-table JOIN
PROMPT   Junction-table JOIN
PROMPT   Four-table JOIN
PROMPT   JOIN + WHERE
PROMPT   JOIN + ORDER BY
PROMPT   JOIN + GROUP BY
PROMPT   JOIN + HAVING
PROMPT
PROMPT Execution log:
PROMPT   logs/lesson03.log
PROMPT
PROMPT Next:
PROMPT   Lesson 04 - OUTER JOIN
PROMPT ============================================================
PROMPT

SPOOL OFF