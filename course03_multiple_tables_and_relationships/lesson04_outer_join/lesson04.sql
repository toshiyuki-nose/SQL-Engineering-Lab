/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 04 - OUTER JOIN

File
----
lesson04.sql

Purpose
-------
Practice retrieving matched and unmatched rows using OUTER JOIN.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Run:

    @setup.sql

Required tables:

    CATEGORIES
    BOOKS
    AUTHORS
    BOOK_AUTHORS

Topics
------
1. INNER JOIN review
2. LEFT OUTER JOIN
3. LEFT JOIN
4. Finding unmatched rows
5. RIGHT OUTER JOIN
6. FULL OUTER JOIN
7. Multi-table OUTER JOIN
8. OUTER JOIN with aggregation
9. COUNT(*) vs COUNT(column)
10. Choosing the correct JOIN

Execution Log
-------------
SQL*Plus output is written to:

    logs/lesson04.log

==============================================================================
*/

SPOOL logs/lesson04.log

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 04
PROMPT OUTER JOIN
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
-- Verify Lesson 04 sample data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Verify Lesson 04 Sample Data ===
PROMPT

COLUMN CATEGORY_NAME FORMAT A20
COLUMN AUTHOR_NAME FORMAT A25

SELECT
    category_id,
    category_name
FROM categories
WHERE category_id = 60;

SELECT
    author_id,
    author_name
FROM authors
WHERE author_id = 509;

-------------------------------------------------------------------------------
-- Step 3
-- INNER JOIN review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: INNER JOIN Review ===
PROMPT

COLUMN TITLE FORMAT A30

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title
FROM categories c
INNER JOIN books b
    ON c.category_id = b.category_id
ORDER BY
    c.category_id,
    b.book_id;

PROMPT
PROMPT Notice:
PROMPT   Category 60 - Reference does not appear.
PROMPT
PROMPT INNER JOIN returns only matching relationships.
PROMPT

-------------------------------------------------------------------------------
-- Step 4
-- LEFT OUTER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: LEFT OUTER JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title
FROM categories c
LEFT OUTER JOIN books b
    ON c.category_id = b.category_id
ORDER BY
    c.category_id,
    b.book_id;

PROMPT
PROMPT Notice:
PROMPT   Category 60 - Reference appears.
PROMPT   BOOK_ID and TITLE are NULL because no book matches.
PROMPT

-------------------------------------------------------------------------------
-- Step 5
-- LEFT JOIN shorthand
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: LEFT JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
ORDER BY
    c.category_id,
    b.book_id;

PROMPT
PROMPT LEFT JOIN and LEFT OUTER JOIN mean the same thing.
PROMPT

-------------------------------------------------------------------------------
-- Step 6
-- Find categories without books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Categories without Books ===
PROMPT

SELECT
    c.category_id,
    c.category_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
WHERE b.book_id IS NULL
ORDER BY c.category_id;

PROMPT
PROMPT Expected:
PROMPT   60  Reference
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- RIGHT OUTER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: RIGHT OUTER JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title
FROM books b
RIGHT OUTER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY
    c.category_id,
    b.book_id;

PROMPT
PROMPT RIGHT OUTER JOIN preserves the table on the right.
PROMPT
PROMPT In this query, CATEGORIES is the right table.
PROMPT Therefore Category 60 is preserved.
PROMPT

-------------------------------------------------------------------------------
-- Step 8
-- Compare LEFT and RIGHT semantics
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: LEFT vs RIGHT JOIN ===
PROMPT

PROMPT
PROMPT These two patterns preserve the same table:
PROMPT
PROMPT   CATEGORIES LEFT JOIN BOOKS
PROMPT
PROMPT   BOOKS RIGHT JOIN CATEGORIES
PROMPT
PROMPT In both cases, every CATEGORIES row is preserved.
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- FULL OUTER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: FULL OUTER JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    b.book_id,
    b.title
FROM categories c
FULL OUTER JOIN books b
    ON c.category_id = b.category_id
ORDER BY
    c.category_id,
    b.book_id;

PROMPT
PROMPT FULL OUTER JOIN preserves unmatched rows from both sides.
PROMPT
PROMPT Because BOOKS.CATEGORY_ID has referential integrity,
PROMPT there are currently no orphan BOOKS rows.
PROMPT

-------------------------------------------------------------------------------
-- Step 10
-- INNER JOIN authors review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: AUTHORS with INNER JOIN ===
PROMPT

SELECT
    a.author_id,
    a.author_name,
    ba.book_id
FROM authors a
INNER JOIN book_authors ba
    ON a.author_id = ba.author_id
ORDER BY
    a.author_id,
    ba.book_id;

PROMPT
PROMPT Author 509 - Noah Anderson does not appear.
PROMPT

-------------------------------------------------------------------------------
-- Step 11
-- LEFT JOIN AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: AUTHORS with LEFT JOIN ===
PROMPT

SELECT
    a.author_id,
    a.author_name,
    ba.book_id
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
ORDER BY
    a.author_id,
    ba.book_id;

PROMPT
PROMPT Author 509 is preserved even though BOOK_ID is NULL.
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- Find authors without books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Authors without Books ===
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
PROMPT Expected:
PROMPT   509  Noah Anderson
PROMPT

-------------------------------------------------------------------------------
-- Step 13
-- Multi-table LEFT JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: AUTHORS -> BOOK_AUTHORS -> BOOKS ===
PROMPT

SELECT
    a.author_id,
    a.author_name,
    b.book_id,
    b.title
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
LEFT JOIN books b
    ON ba.book_id = b.book_id
ORDER BY
    a.author_id,
    b.book_id;

PROMPT
PROMPT Noah Anderson remains in the result.
PROMPT His BOOK_ID and TITLE are NULL.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- COUNT(*) with OUTER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: COUNT(*) with LEFT JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(*) AS result_row_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

PROMPT
PROMPT Important:
PROMPT
PROMPT Category 60 has no books,
PROMPT but COUNT(*) returns 1 because the OUTER JOIN produces
PROMPT one result row containing NULL BOOKS columns.
PROMPT

-------------------------------------------------------------------------------
-- Step 15
-- COUNT(column) with OUTER JOIN
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: COUNT(BOOK_ID) with LEFT JOIN ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(b.book_id) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

PROMPT
PROMPT Expected:
PROMPT
PROMPT   Reference = 0
PROMPT
PROMPT COUNT(b.book_id) ignores NULL values.
PROMPT

-------------------------------------------------------------------------------
-- Step 16
-- Compare COUNT(*) and COUNT(column)
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Compare COUNT(*) and COUNT(BOOK_ID) ===
PROMPT

SELECT
    c.category_id,
    c.category_name,
    COUNT(*) AS result_rows,
    COUNT(b.book_id) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;

PROMPT
PROMPT For Category 60:
PROMPT
PROMPT   RESULT_ROWS = 1
PROMPT   BOOK_COUNT  = 0
PROMPT

-------------------------------------------------------------------------------
-- Step 17
-- Count books for every author
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Book Count for Every Author ===
PROMPT

SELECT
    a.author_id,
    a.author_name,
    COUNT(ba.book_id) AS book_count
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
GROUP BY
    a.author_id,
    a.author_name
ORDER BY a.author_id;

PROMPT
PROMPT Noah Anderson should have BOOK_COUNT = 0.
PROMPT

-------------------------------------------------------------------------------
-- Step 18
-- Practical query: empty categories
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 18: Practical Query - Empty Categories ===
PROMPT

PROMPT
PROMPT Question:
PROMPT Which categories currently contain no books?
PROMPT

SELECT
    c.category_id,
    c.category_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
WHERE b.book_id IS NULL
ORDER BY c.category_id;

-------------------------------------------------------------------------------
-- Step 19
-- Practical query: authors without books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 19: Practical Query - Authors without Books ===
PROMPT

PROMPT
PROMPT Question:
PROMPT Which authors currently have no books assigned?
PROMPT

SELECT
    a.author_id,
    a.author_name
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
WHERE ba.book_id IS NULL
ORDER BY a.author_id;

-------------------------------------------------------------------------------
-- Step 20
-- JOIN comparison
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 20: JOIN Comparison ===
PROMPT

PROMPT
PROMPT INNER JOIN
PROMPT   Returns only matching rows.
PROMPT
PROMPT LEFT JOIN
PROMPT   Preserves every row from the left table.
PROMPT
PROMPT RIGHT JOIN
PROMPT   Preserves every row from the right table.
PROMPT
PROMPT FULL OUTER JOIN
PROMPT   Preserves every row from both tables.
PROMPT

-------------------------------------------------------------------------------
-- Step 21
-- Final review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 21: Final Review ===
PROMPT

PROMPT
PROMPT Ask this question before choosing a JOIN:
PROMPT
PROMPT   Which rows must remain even when there is no match?
PROMPT
PROMPT Examples:
PROMPT
PROMPT   Only matched categories/books
PROMPT       -> INNER JOIN
PROMPT
PROMPT   Every category, even empty categories
PROMPT       -> CATEGORIES LEFT JOIN BOOKS
PROMPT
PROMPT   Every author, even authors without books
PROMPT       -> AUTHORS LEFT JOIN BOOK_AUTHORS
PROMPT

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 04 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   INNER JOIN review
PROMPT   LEFT OUTER JOIN
PROMPT   LEFT JOIN
PROMPT   RIGHT OUTER JOIN
PROMPT   FULL OUTER JOIN
PROMPT   Finding unmatched rows
PROMPT   IS NULL with OUTER JOIN
PROMPT   Multi-table OUTER JOIN
PROMPT   OUTER JOIN + GROUP BY
PROMPT   COUNT(*) vs COUNT(column)
PROMPT
PROMPT Execution log:
PROMPT   logs/lesson04.log
PROMPT
PROMPT Next:
PROMPT   Lesson 05 - Self Join
PROMPT ============================================================
PROMPT

SPOOL OFF