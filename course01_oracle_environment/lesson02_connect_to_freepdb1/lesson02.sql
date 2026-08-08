/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 02 - Connect to FREEPDB1

Purpose
-------
Prepare the Oracle learning environment for SQL-Engineering-Lab.

This script performs the following tasks.

1. Switch to FREEPDB1
2. Create the SQL_LAB user
3. Grant the required privileges
4. Verify the created user and privileges

Execute as:

    sqlplus / as sysdba

After this script completes, reconnect as SQL_LAB:

    sqlplus sql_lab/sql_lab@localhost:1521/FREEPDB1

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 01 - Lesson 02
PROMPT Preparing the Learning Environment
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON

-------------------------------------------------------------------------------
-- Step 1
-- Verify the current container
-------------------------------------------------------------------------------

PROMPT
PROMPT Current Container
PROMPT

SHOW CON_NAME

-------------------------------------------------------------------------------
-- Step 2
-- Switch to FREEPDB1
-------------------------------------------------------------------------------

PROMPT
PROMPT Switching to FREEPDB1...
PROMPT

ALTER SESSION SET CONTAINER = FREEPDB1;

PROMPT
PROMPT Current Container
PROMPT

SHOW CON_NAME

-------------------------------------------------------------------------------
-- Step 3
-- Create SQL_LAB
-------------------------------------------------------------------------------

PROMPT
PROMPT Creating SQL_LAB...
PROMPT

CREATE USER SQL_LAB
IDENTIFIED BY sql_lab
DEFAULT TABLESPACE FREEPDB1_DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FREEPDB1_DATA;

-------------------------------------------------------------------------------
-- Step 4
-- Grant required privileges
-------------------------------------------------------------------------------

PROMPT
PROMPT Granting privileges...
PROMPT

GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE VIEW,
    CREATE SEQUENCE
TO SQL_LAB;

-------------------------------------------------------------------------------
-- Step 5
-- Verify the created user
-------------------------------------------------------------------------------

PROMPT
PROMPT User Information
PROMPT

COLUMN USERNAME             FORMAT A20
COLUMN ACCOUNT_STATUS       FORMAT A20
COLUMN DEFAULT_TABLESPACE   FORMAT A20
COLUMN TEMPORARY_TABLESPACE FORMAT A20

SELECT
    USERNAME,
    ACCOUNT_STATUS,
    DEFAULT_TABLESPACE,
    TEMPORARY_TABLESPACE
FROM DBA_USERS
WHERE USERNAME = 'SQL_LAB';

-------------------------------------------------------------------------------
-- Step 6
-- Verify role grants
-------------------------------------------------------------------------------

PROMPT
PROMPT Granted Roles
PROMPT

COLUMN GRANTED_ROLE FORMAT A30

SELECT
    GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE = 'SQL_LAB'
ORDER BY GRANTED_ROLE;

-------------------------------------------------------------------------------
-- Step 7
-- Verify system privileges
-------------------------------------------------------------------------------

PROMPT
PROMPT System Privileges
PROMPT

COLUMN PRIVILEGE FORMAT A35

SELECT
    PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'SQL_LAB'
ORDER BY PRIVILEGE;

-------------------------------------------------------------------------------
-- Step 8
-- Final information
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT SQL_LAB has been created successfully.
PROMPT
PROMPT Reconnect using:
PROMPT
PROMPT sqlplus sql_lab/sql_lab@localhost:1521/FREEPDB1
PROMPT
PROMPT
PROMPT After reconnecting, verify the environment with:
PROMPT
PROMPT   SELECT USER FROM dual;
PROMPT
PROMPT   SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM dual;
PROMPT
PROMPT   SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') FROM dual;
PROMPT
PROMPT   SELECT SYS_CONTEXT('USERENV', 'DB_NAME') FROM dual;
PROMPT
PROMPT   SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') FROM dual;
PROMPT
PROMPT
PROMPT Expected values:
PROMPT
PROMPT   USER           = SQL_LAB
PROMPT   CON_NAME       = FREEPDB1
PROMPT   CURRENT_SCHEMA = SQL_LAB
PROMPT   DB_NAME        = FREEPDB1
PROMPT   SERVICE_NAME   = freepdb1
PROMPT
PROMPT ============================================================