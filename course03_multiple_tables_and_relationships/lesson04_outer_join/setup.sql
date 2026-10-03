/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 04 - OUTER JOIN

File
----
setup.sql

Purpose
-------
Add unmatched sample data used to demonstrate OUTER JOIN.

This script adds:

    CATEGORIES
        60  Reference

    AUTHORS
        509 Noah Anderson

No BOOKS row references Category 60.

No BOOK_AUTHORS row references Author 509.

These intentionally unmatched rows allow Lesson 04 to demonstrate
OUTER JOIN behavior.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Course 03 Lesson 03.

Execution Log
-------------
SQL*Plus output is written to:

    logs/setup.log

==============================================================================
*/

SPOOL logs/setup.log

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 04
PROMPT OUTER JOIN Setup
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
-- Verify the current CATEGORIES data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Current CATEGORIES ===
PROMPT

COLUMN CATEGORY_NAME FORMAT A20

SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

-------------------------------------------------------------------------------
-- Step 4
-- Add an unmatched category
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Add Unmatched Category ===
PROMPT

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    60,
    'Reference'
);

-------------------------------------------------------------------------------
-- Step 5
-- Verify that Category 60 has no books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Verify Category 60 Has No Books ===
PROMPT

SELECT
    COUNT(*) AS reference_book_count
FROM books
WHERE category_id = 60;

PROMPT
PROMPT Expected:
PROMPT   REFERENCE_BOOK_COUNT = 0
PROMPT

-------------------------------------------------------------------------------
-- Step 6
-- Verify the current AUTHORS data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Current AUTHORS ===
PROMPT

COLUMN AUTHOR_NAME FORMAT A25

SELECT
    author_id,
    author_name
FROM authors
ORDER BY author_id;

-------------------------------------------------------------------------------
-- Step 7
-- Add an unmatched author
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Add Unmatched Author ===
PROMPT

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    509,
    'Noah Anderson'
);

-------------------------------------------------------------------------------
-- Step 8
-- Verify that Author 509 has no BOOK_AUTHORS relationship
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Verify Author 509 Has No Book Relationship ===
PROMPT

SELECT
    COUNT(*) AS author_book_count
FROM book_authors
WHERE author_id = 509;

PROMPT
PROMPT Expected:
PROMPT   AUTHOR_BOOK_COUNT = 0
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- Commit Lesson 04 sample data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Commit Lesson 04 Sample Data ===
PROMPT

COMMIT;

-------------------------------------------------------------------------------
-- Step 10
-- Final verification
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Final Verification ===
PROMPT

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

PROMPT
PROMPT ============================================================
PROMPT Lesson 04 setup completed successfully.
PROMPT
PROMPT Added:
PROMPT
PROMPT   CATEGORIES
PROMPT     60  Reference
PROMPT
PROMPT   AUTHORS
PROMPT     509 Noah Anderson
PROMPT
PROMPT These rows intentionally have no related data.
PROMPT
PROMPT Continue with:
PROMPT
PROMPT   @lesson04.sql
PROMPT ============================================================
PROMPT

SPOOL OFF

WHENEVER SQLERROR CONTINUE