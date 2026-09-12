/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 01 - SELECT Basics

File
----
lesson01.sql

Purpose
-------
Learn the fundamentals of retrieving data using the SELECT statement.

Execute as:

    SQL_LAB @ FREEPDB1

This script demonstrates:

1. Session verification
2. Selecting all columns
3. Selecting specific columns
4. Changing the display order of columns
5. Using column aliases
6. Using DISTINCT
7. Inspecting the final results

Prerequisite
------------
The LEARNING_TOPICS table created in Course 01 must exist.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 01
PROMPT SELECT Basics
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

COLUMN CURRENT_USER FORMAT A15
COLUMN CONTAINER_NAME FORMAT A20
COLUMN CURRENT_SCHEMA FORMAT A20

SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

-------------------------------------------------------------------------------
-- Step 2
-- Verify the learning table
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Verify LEARNING_TOPICS ===
PROMPT

COLUMN TABLE_NAME FORMAT A30
COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'LEARNING_TOPICS';

DESCRIBE learning_topics

-------------------------------------------------------------------------------
-- Step 3
-- SELECT all columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: SELECT All Columns ===
PROMPT

COLUMN TOPIC_NAME FORMAT A20
COLUMN STATUS FORMAT A15
COLUMN CREATED_AT FORMAT A20

SELECT *
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 4
-- SELECT a single column
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: SELECT One Column ===
PROMPT

SELECT
    topic_name
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 5
-- SELECT specific columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: SELECT Specific Columns ===
PROMPT

SELECT
    topic_id,
    topic_name
FROM learning_topics;

SELECT
    topic_id,
    topic_name,
    status
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 6
-- Change the display order of columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Change Column Order ===
PROMPT

SELECT
    status,
    topic_name,
    topic_id
FROM learning_topics;

PROMPT
PROMPT The table structure has not changed.
PROMPT Only the structure of the query result has changed.
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- Use column aliases
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Column Aliases ===
PROMPT

COLUMN TOPIC FORMAT A20
COLUMN LEARNING_STATUS FORMAT A20

SELECT
    topic_name AS topic,
    status AS learning_status
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 8
-- Use aliases containing spaces
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Aliases with Spaces ===
PROMPT

COLUMN "Topic Name" FORMAT A20
COLUMN "Learning Status" FORMAT A20

SELECT
    topic_name AS "Topic Name",
    status AS "Learning Status"
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 9
-- SELECT values without DISTINCT
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: STATUS Values without DISTINCT ===
PROMPT

SELECT
    status
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 10
-- SELECT unique values using DISTINCT
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: DISTINCT ===
PROMPT

SELECT DISTINCT
    status
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 11
-- DISTINCT with multiple columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: DISTINCT with Multiple Columns ===
PROMPT

SELECT DISTINCT
    status,
    topic_name
FROM learning_topics;

-------------------------------------------------------------------------------
-- Step 12
-- Final review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Final Review ===
PROMPT

SELECT
    topic_id AS id,
    topic_name AS topic,
    status AS learning_status
FROM learning_topics;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 01 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   SELECT *
PROMPT   SELECT specific columns
PROMPT   Column order
PROMPT   Column aliases
PROMPT   DISTINCT
PROMPT
PROMPT Next:
PROMPT   Lesson 02 - Filtering Rows
PROMPT ============================================================