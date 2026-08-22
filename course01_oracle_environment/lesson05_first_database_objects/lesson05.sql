/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 05 - Creating Your First Database Objects

File
----
lesson05.sql

Purpose
-------
Create the first official SQL-Engineering-Lab table and verify that
the Course 01 Oracle environment works as expected.

Execute as:

    SQL_LAB @ FREEPDB1

This script performs the following tasks.

1. Verify the current session
2. Create the LEARNING_TOPICS table
3. Verify the created object
4. Verify the tablespace
5. Insert sample data
6. Commit the transaction
7. Query the inserted rows
8. Inspect the final schema state

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 01 - Lesson 05
PROMPT Creating Your First Database Objects
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

SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

-------------------------------------------------------------------------------
-- Step 2
-- Create LEARNING_TOPICS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Creating LEARNING_TOPICS ===
PROMPT

CREATE TABLE learning_topics (
    topic_id    NUMBER,
    topic_name  VARCHAR2(100),
    status      VARCHAR2(20),
    created_at  DATE
);

-------------------------------------------------------------------------------
-- Step 3
-- Verify the created object
-------------------------------------------------------------------------------

PROMPT
PROMPT === Verify Schema Object ===
PROMPT

COLUMN OBJECT_NAME FORMAT A30
COLUMN OBJECT_TYPE FORMAT A20

SELECT
    object_name,
    object_type
FROM user_objects
WHERE object_name = 'LEARNING_TOPICS';

-------------------------------------------------------------------------------
-- Step 4
-- Verify the table and tablespace
-------------------------------------------------------------------------------

PROMPT
PROMPT === Verify Table and Tablespace ===
PROMPT

COLUMN TABLE_NAME FORMAT A30
COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'LEARNING_TOPICS';

-------------------------------------------------------------------------------
-- Step 5
-- Display the table structure
-------------------------------------------------------------------------------

PROMPT
PROMPT === Table Definition ===
PROMPT

DESCRIBE learning_topics

-------------------------------------------------------------------------------
-- Step 6
-- Insert sample data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Insert Sample Data ===
PROMPT

INSERT INTO learning_topics (
    topic_id,
    topic_name,
    status,
    created_at
)
VALUES (
    1,
    'SQL Basics',
    'READY',
    SYSDATE
);

INSERT INTO learning_topics
VALUES (
    2,
    'SELECT',
    'PLANNED',
    SYSDATE
);

INSERT INTO learning_topics
VALUES (
    3,
    'Filtering',
    'PLANNED',
    SYSDATE
);

INSERT INTO learning_topics
VALUES (
    4,
    'Sorting',
    'PLANNED',
    SYSDATE
);

INSERT INTO learning_topics
VALUES (
    5,
    'Joins',
    'PLANNED',
    SYSDATE
);

-------------------------------------------------------------------------------
-- Step 7
-- Commit the transaction
-------------------------------------------------------------------------------

PROMPT
PROMPT === Commit Changes ===
PROMPT

COMMIT;

-------------------------------------------------------------------------------
-- Step 8
-- Query the data
-------------------------------------------------------------------------------

PROMPT
PROMPT === LEARNING_TOPICS Data ===
PROMPT

COLUMN TOPIC_NAME FORMAT A20
COLUMN STATUS FORMAT A12
COLUMN CREATED_AT FORMAT A20

SELECT
    topic_id,
    topic_name,
    status,
    TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') AS created_at
FROM learning_topics
ORDER BY topic_id;

-------------------------------------------------------------------------------
-- Step 9
-- Inspect the final schema state
-------------------------------------------------------------------------------

PROMPT
PROMPT === Current SQL_LAB Objects ===
PROMPT

SELECT
    object_name,
    object_type
FROM user_objects
ORDER BY object_type, object_name;

-------------------------------------------------------------------------------
-- Step 10
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 05 completed.
PROMPT
PROMPT Expected Environment:
PROMPT
PROMPT   User              : SQL_LAB
PROMPT   Container         : FREEPDB1
PROMPT   Schema            : SQL_LAB
PROMPT   Table             : LEARNING_TOPICS
PROMPT   Tablespace        : FREEPDB1_DATA
PROMPT   Sample Rows       : 5
PROMPT
PROMPT Use cleanup.sql to reset this lesson.
PROMPT ============================================================