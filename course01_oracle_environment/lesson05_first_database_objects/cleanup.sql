/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 05 - Creating Your First Database Objects

File
----
cleanup.sql

Purpose
-------
Remove the objects created by Lesson 05 so that the exercise can be
executed again from the beginning.

Execute as:

    SQL_LAB @ FREEPDB1

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 01 - Lesson 05
PROMPT Cleanup
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON

-------------------------------------------------------------------------------
-- Step 1
-- Verify the current session
-------------------------------------------------------------------------------

PROMPT
PROMPT === Session Context ===
PROMPT

SHOW USER
SHOW CON_NAME

-------------------------------------------------------------------------------
-- Step 2
-- Display the object before cleanup
-------------------------------------------------------------------------------

PROMPT
PROMPT === Object Before Cleanup ===
PROMPT

COLUMN OBJECT_NAME FORMAT A30
COLUMN OBJECT_TYPE FORMAT A20

SELECT
    object_name,
    object_type
FROM user_objects
WHERE object_name = 'LEARNING_TOPICS';

-------------------------------------------------------------------------------
-- Step 3
-- Drop LEARNING_TOPICS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Dropping LEARNING_TOPICS ===
PROMPT

DROP TABLE learning_topics PURGE;

-------------------------------------------------------------------------------
-- Step 4
-- Verify cleanup
-------------------------------------------------------------------------------

PROMPT
PROMPT === Verify Cleanup ===
PROMPT

SELECT
    object_name,
    object_type
FROM user_objects
WHERE object_name = 'LEARNING_TOPICS';

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Cleanup completed.
PROMPT
PROMPT LEARNING_TOPICS should no longer exist.
PROMPT
PROMPT lesson05.sql can now be executed again.
PROMPT ============================================================