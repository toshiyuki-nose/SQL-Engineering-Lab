/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 04 - Users, Schemas, and Tablespaces

File
----
lesson04_sys.sql

Purpose
-------
Inspect the SQL_LAB environment from the SYS administrator perspective.

Execute as:

    SYS @ FREEPDB1

This script verifies:

1. Current session
2. SQL_LAB user configuration
3. SQL_LAB tablespace quota
4. SQL_LAB system privileges
5. SQL_LAB granted roles
6. Objects owned by SQL_LAB

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 01 - Lesson 04
PROMPT SYS Perspective
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
-- Inspect SQL_LAB user configuration
-------------------------------------------------------------------------------

PROMPT
PROMPT === SQL_LAB User Configuration ===
PROMPT

COLUMN USERNAME FORMAT A15
COLUMN ACCOUNT_STATUS FORMAT A15
COLUMN DEFAULT_TABLESPACE FORMAT A20
COLUMN TEMPORARY_TABLESPACE FORMAT A20

SELECT
    username,
    account_status,
    default_tablespace,
    temporary_tablespace
FROM dba_users
WHERE username = 'SQL_LAB';

-------------------------------------------------------------------------------
-- Step 3
-- Inspect SQL_LAB tablespace quota
-------------------------------------------------------------------------------

PROMPT
PROMPT === SQL_LAB Tablespace Quota ===
PROMPT

COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    tablespace_name,
    username,
    bytes,
    max_bytes
FROM dba_ts_quotas
WHERE username = 'SQL_LAB';

-------------------------------------------------------------------------------
-- Step 4
-- Inspect SQL_LAB system privileges
-------------------------------------------------------------------------------

PROMPT
PROMPT === SQL_LAB System Privileges ===
PROMPT

COLUMN PRIVILEGE FORMAT A30

SELECT
    privilege
FROM dba_sys_privs
WHERE grantee = 'SQL_LAB'
ORDER BY privilege;

-------------------------------------------------------------------------------
-- Step 5
-- Inspect SQL_LAB granted roles
-------------------------------------------------------------------------------

PROMPT
PROMPT === SQL_LAB Roles ===
PROMPT

COLUMN GRANTED_ROLE FORMAT A30

SELECT
    granted_role
FROM dba_role_privs
WHERE grantee = 'SQL_LAB'
ORDER BY granted_role;

-------------------------------------------------------------------------------
-- Step 6
-- Inspect objects owned by SQL_LAB
-------------------------------------------------------------------------------

PROMPT
PROMPT === SQL_LAB Schema Objects ===
PROMPT

COLUMN OBJECT_NAME FORMAT A30
COLUMN OBJECT_TYPE FORMAT A20

SELECT
    object_name,
    object_type
FROM dba_objects
WHERE owner = 'SQL_LAB'
ORDER BY object_type, object_name;

-------------------------------------------------------------------------------
-- Expected Environment
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Expected Environment
PROMPT
PROMPT User                : SYS
PROMPT Container           : FREEPDB1
PROMPT Target User         : SQL_LAB
PROMPT Account Status      : OPEN
PROMPT Default Tablespace  : FREEPDB1_DATA
PROMPT Temporary Tablespace: TEMP
PROMPT Tablespace Quota    : UNLIMITED (MAX_BYTES = -1)
PROMPT
PROMPT Expected SQL_LAB System Privileges:
PROMPT   CREATE SEQUENCE
PROMPT   CREATE SESSION
PROMPT   CREATE TABLE
PROMPT   CREATE VIEW
PROMPT
PROMPT Expected SQL_LAB Roles:
PROMPT   None
PROMPT ============================================================