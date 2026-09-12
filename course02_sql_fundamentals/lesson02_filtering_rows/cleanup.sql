/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 02 - Filtering Rows

File
----
cleanup.sql

Purpose
-------
Remove the BOOKS table when you intentionally want to reset the
Book Store dataset.

Execute as:

    SQL_LAB @ FREEPDB1

Important
---------
BOOKS is reused by later Course 02 lessons.

Do NOT run this script after every Lesson 02 exercise.

Use it only when you want to test setup.sql again from a clean state.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 02
PROMPT BOOKS Cleanup
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON

-------------------------------------------------------------------------------
-- Step 1
-- Verify the current session
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 1: Session Context ===
PROMPT

SHOW USER
SHOW CON_NAME

-------------------------------------------------------------------------------
-- Step 2
-- Verify BOOKS before cleanup
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: BOOKS Before Cleanup ===
PROMPT

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';

-------------------------------------------------------------------------------
-- Step 3
-- Drop BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Drop BOOKS ===
PROMPT

DROP TABLE books PURGE;

-------------------------------------------------------------------------------
-- Step 4
-- Verify cleanup
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Verify Cleanup ===
PROMPT

SELECT
    table_name
FROM user_tables
WHERE table_name = 'BOOKS';

PROMPT
PROMPT ============================================================
PROMPT Cleanup completed.
PROMPT
PROMPT BOOKS should no longer exist.
PROMPT Run setup.sql to recreate the dataset.
PROMPT ============================================================