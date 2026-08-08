/*
==============================================================================
SQL-Engineering-Lab

Course 01 - Oracle Environment
Lesson 03 - SQL Clients

Purpose
-------
Verify the SQL-Engineering-Lab environment using a SQL client.

This script is designed to be executed using both:

1. SQL*Plus
2. Oracle SQL Developer

The results should identify the same Oracle environment regardless of
which client is used.

Expected environment:

    User           : SQL_LAB
    Container      : FREEPDB1
    Current Schema : SQL_LAB
    Database Name  : FREEPDB1
    Service Name   : freepdb1

==============================================================================
*/

-------------------------------------------------------------------------------
-- Step 1
-- Verify the current user
-------------------------------------------------------------------------------

SELECT USER AS current_user
FROM dual;

-------------------------------------------------------------------------------
-- Step 2
-- Verify the current container
-------------------------------------------------------------------------------

SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

-------------------------------------------------------------------------------
-- Step 3
-- Verify the current schema
-------------------------------------------------------------------------------

SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

-------------------------------------------------------------------------------
-- Step 4
-- Verify the database name
-------------------------------------------------------------------------------

SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name
FROM dual;

-------------------------------------------------------------------------------
-- Step 5
-- Verify the service name
-------------------------------------------------------------------------------

SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name
FROM dual;

-------------------------------------------------------------------------------
-- Step 6
-- Display the environment in a single result
-------------------------------------------------------------------------------

SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema,
    SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
    SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name
FROM dual;

-------------------------------------------------------------------------------
-- Expected Result
-------------------------------------------------------------------------------

/*

CURRENT_USER     : SQL_LAB
CONTAINER_NAME   : FREEPDB1
CURRENT_SCHEMA   : SQL_LAB
DATABASE_NAME    : FREEPDB1
SERVICE_NAME     : freepdb1

*/

-------------------------------------------------------------------------------
-- End of Lesson 03
-------------------------------------------------------------------------------