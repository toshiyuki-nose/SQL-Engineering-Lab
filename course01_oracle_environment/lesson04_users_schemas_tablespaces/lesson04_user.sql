/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 04 - Users, Schemas, and Tablespaces

File
----
lesson04_user.sql

Purpose
-------
Inspect the SQL_LAB environment from the user's perspective.

Execute as:

    SQL_LAB @ FREEPDB1

This script verifies:

1. Current session
2. User configuration
3. Tablespace quota
4. System privileges
5. Granted roles
6. Schema objects

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 01 - Lesson 04
PROMPT User Perspective
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON

-------------------------------------------------------------------------------
-- Step 1
-- Verify the session context
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
-- Inspect the current user
-------------------------------------------------------------------------------

PROMPT
PROMPT === My User Configuration ===
PROMPT

COLUMN USERNAME FORMAT A15
COLUMN DEFAULT_TABLESPACE FORMAT A20
COLUMN TEMPORARY_TABLESPACE FORMAT A20

SELECT
    username,
    default_tablespace,
    temporary_tablespace
FROM user_users;

-------------------------------------------------------------------------------
-- Step 3
-- Inspect the tablespace quota
-------------------------------------------------------------------------------

PROMPT
PROMPT === My Tablespace Quota ===
PROMPT

COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    tablespace_name,
    bytes,
    max_bytes
FROM user_ts_quotas;

-------------------------------------------------------------------------------
-- Step 4
-- Inspect system privileges
-------------------------------------------------------------------------------

PROMPT
PROMPT === My System Privileges ===
PROMPT

COLUMN PRIVILEGE FORMAT A30

SELECT
    privilege
FROM user_sys_privs
ORDER BY privilege;

-------------------------------------------------------------------------------
-- Step 5
-- Inspect granted roles
-------------------------------------------------------------------------------

PROMPT
PROMPT === My Roles ===
PROMPT

COLUMN GRANTED_ROLE FORMAT A30

SELECT
    granted_role
FROM user_role_privs
ORDER BY granted_role;

-------------------------------------------------------------------------------
-- Step 6
-- Inspect objects owned by the current schema
-------------------------------------------------------------------------------

PROMPT
PROMPT === My Schema Objects ===
PROMPT

COLUMN OBJECT_NAME FORMAT A30
COLUMN OBJECT_TYPE FORMAT A20

SELECT
    object_name,
    object_type
FROM user_objects
ORDER BY object_type, object_name;

-------------------------------------------------------------------------------
-- Expected Environment
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Expected Environment
PROMPT
PROMPT User                : SQL_LAB
PROMPT Container           : FREEPDB1
PROMPT Current Schema      : SQL_LAB
PROMPT Default Tablespace  : FREEPDB1_DATA
PROMPT Temporary Tablespace: TEMP
PROMPT Tablespace Quota    : UNLIMITED (MAX_BYTES = -1)
PROMPT
PROMPT Expected System Privileges:
PROMPT   CREATE SEQUENCE
PROMPT   CREATE SESSION
PROMPT   CREATE TABLE
PROMPT   CREATE VIEW
PROMPT
PROMPT Expected Roles:
PROMPT   None
PROMPT ============================================================