/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 04 - Expressions and NULL

File
----
setup.sql

Purpose
-------
Extend the existing BOOKS table with a nullable SUBTITLE column and prepare
sample data for practicing expressions and NULL.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Lesson 03 and keep the BOOKS table.

Important
---------
This script evolves the BOOKS table used throughout Course 02.

The SUBTITLE column is intentionally nullable because not every book has a
subtitle.

Normally, run this setup script only once.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 04
PROMPT Expressions and NULL Setup
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 160
SET PAGESIZE 100

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
-- Verify the existing BOOKS table
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

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 3
-- Add SUBTITLE
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Add SUBTITLE ===
PROMPT

PROMPT
PROMPT SUBTITLE is intentionally nullable.
PROMPT Not every book needs to have a subtitle.
PROMPT

ALTER TABLE books
ADD subtitle VARCHAR2(100);

-------------------------------------------------------------------------------
-- Step 4
-- Verify the new structure
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Verify the New Structure ===
PROMPT

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 5
-- Add subtitles to selected books
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Add Sample Subtitles ===
PROMPT

UPDATE books
SET subtitle = 'A Practical Introduction to Relational Queries'
WHERE book_id = 1001;

UPDATE books
SET subtitle = 'Patterns for Reliable Database Applications'
WHERE book_id = 1002;

UPDATE books
SET subtitle = 'From Tables to Relationships'
WHERE book_id = 1003;

UPDATE books
SET subtitle = 'Working with Real-World Datasets'
WHERE book_id = 1004;

UPDATE books
SET subtitle = 'Methods for Data-Driven Decisions'
WHERE book_id = 1007;

UPDATE books
SET subtitle = 'Understanding Climate in a Changing World'
WHERE book_id = 1011;

UPDATE books
SET subtitle = 'Exercises for Better SQL'
WHERE book_id = 1013;

COMMIT;

-------------------------------------------------------------------------------
-- Step 6
-- Verify NULL and non-NULL values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Verify SUBTITLE Data ===
PROMPT

COLUMN TITLE FORMAT A30
COLUMN SUBTITLE FORMAT A50

SELECT
    book_id,
    title,
    subtitle
FROM books
ORDER BY book_id;

PROMPT
PROMPT ============================================================
PROMPT Lesson 04 setup completed.
PROMPT
PROMPT BOOKS now contains both:
PROMPT   - rows with a SUBTITLE
PROMPT   - rows without a SUBTITLE
PROMPT
PROMPT Continue with:
PROMPT   @lesson04.sql
PROMPT ============================================================