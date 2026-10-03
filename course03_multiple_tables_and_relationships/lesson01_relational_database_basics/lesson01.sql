/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 01 - Relational Database Basics

File
----
lesson01.sql

Purpose
-------
Inspect the existing BOOKS table and learn how Oracle represents tables,
columns, primary keys, and constraints in database metadata.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete Course 02.

This lesson does not create or modify database objects.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 01
PROMPT Relational Database Basics
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

COLUMN CURRENT_USER FORMAT A15
COLUMN CONTAINER_NAME FORMAT A20
COLUMN CURRENT_SCHEMA FORMAT A20

COLUMN TABLE_NAME FORMAT A30
COLUMN TABLESPACE_NAME FORMAT A20

COLUMN COLUMN_NAME FORMAT A25
COLUMN DATA_TYPE FORMAT A20
COLUMN NULLABLE FORMAT A10

COLUMN CONSTRAINT_NAME FORMAT A30
COLUMN CONSTRAINT_TYPE FORMAT A15
COLUMN STATUS FORMAT A15

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
-- List tables owned by SQL_LAB
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Current Tables ===
PROMPT

SELECT
    table_name,
    tablespace_name
FROM user_tables
ORDER BY table_name;

-------------------------------------------------------------------------------
-- Step 3
-- Verify BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Verify BOOKS ===
PROMPT

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 4
-- Inspect BOOKS data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Inspect BOOKS Data ===
PROMPT

COLUMN TITLE FORMAT A30
COLUMN CATEGORY FORMAT A15
COLUMN SUBTITLE FORMAT A50

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year,
    subtitle
FROM books
ORDER BY book_id;

-------------------------------------------------------------------------------
-- Step 5
-- Inspect BOOKS columns using Oracle metadata
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: BOOKS Column Metadata ===
PROMPT

SELECT
    column_id,
    column_name,
    data_type,
    data_length,
    nullable
FROM user_tab_columns
WHERE table_name = 'BOOKS'
ORDER BY column_id;

-------------------------------------------------------------------------------
-- Step 6
-- Inspect constraints
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: BOOKS Constraints ===
PROMPT

SELECT
    constraint_name,
    constraint_type,
    status
FROM user_constraints
WHERE table_name = 'BOOKS'
ORDER BY constraint_name;

PROMPT
PROMPT Constraint types:
PROMPT   P = Primary Key
PROMPT   R = Referential / Foreign Key
PROMPT   U = Unique
PROMPT   C = Check
PROMPT

-------------------------------------------------------------------------------
-- Step 7
-- Inspect constraint columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Constraint Columns ===
PROMPT

SELECT
    constraint_name,
    table_name,
    column_name,
    position
FROM user_cons_columns
WHERE table_name = 'BOOKS'
ORDER BY
    constraint_name,
    position;

-------------------------------------------------------------------------------
-- Step 8
-- Identify the BOOKS primary key
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: BOOKS Primary Key ===
PROMPT

SELECT
    c.constraint_name,
    cc.column_name,
    cc.position,
    c.status
FROM user_constraints c
JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name
   AND c.table_name = cc.table_name
WHERE c.table_name = 'BOOKS'
  AND c.constraint_type = 'P'
ORDER BY cc.position;

PROMPT
PROMPT BOOK_ID uniquely identifies each BOOKS row.
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- Inspect CATEGORY values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Current CATEGORY Values ===
PROMPT

SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category
ORDER BY category;

PROMPT
PROMPT CATEGORY is currently stored repeatedly as text in BOOKS.
PROMPT
PROMPT In Lesson 02, we will begin representing independent
PROMPT business concepts using related tables.
PROMPT

-------------------------------------------------------------------------------
-- Step 10
-- Compare row count and distinct category count
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Rows vs Categories ===
PROMPT

SELECT
    COUNT(*) AS book_count,
    COUNT(DISTINCT category) AS category_count
FROM books;

PROMPT
PROMPT Many BOOKS rows share a smaller set of CATEGORY values.
PROMPT

-------------------------------------------------------------------------------
-- Step 11
-- Preview the future relationship
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Future Relationship Model ===
PROMPT
PROMPT Current:
PROMPT
PROMPT   BOOKS
PROMPT     BOOK_ID   PK
PROMPT     TITLE
PROMPT     CATEGORY
PROMPT
PROMPT Future concept:
PROMPT
PROMPT   CATEGORIES
PROMPT     CATEGORY_ID   PK
PROMPT         |
PROMPT         |
PROMPT         +----< BOOKS
PROMPT                  BOOK_ID       PK
PROMPT                  CATEGORY_ID   FK
PROMPT
PROMPT One CATEGORY can be related to many BOOKS.
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- Preview many-to-many relationships
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Many-to-Many Relationship Preview ===
PROMPT
PROMPT A BOOK may have multiple AUTHORS.
PROMPT An AUTHOR may write multiple BOOKS.
PROMPT
PROMPT Therefore:
PROMPT
PROMPT   BOOKS
PROMPT      |
PROMPT      +----< BOOK_AUTHORS >----+
PROMPT                               |
PROMPT                            AUTHORS
PROMPT
PROMPT BOOK_AUTHORS will represent relationships between books and authors.
PROMPT

-------------------------------------------------------------------------------
-- Step 13
-- Final metadata review
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Final Metadata Review ===
PROMPT

SELECT
    t.table_name,
    c.constraint_name,
    c.constraint_type,
    cc.column_name
FROM user_tables t
LEFT JOIN user_constraints c
    ON t.table_name = c.table_name
LEFT JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name
   AND c.table_name = cc.table_name
WHERE t.table_name = 'BOOKS'
ORDER BY
    c.constraint_name,
    cc.position;

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 01 completed.
PROMPT
PROMPT You inspected:
PROMPT
PROMPT   BOOKS
PROMPT   USER_TABLES
PROMPT   USER_TAB_COLUMNS
PROMPT   USER_CONSTRAINTS
PROMPT   USER_CONS_COLUMNS
PROMPT
PROMPT You learned:
PROMPT
PROMPT   Entity
PROMPT   Primary Key
PROMPT   Foreign Key
PROMPT   Referential Integrity
PROMPT   One-to-Many
PROMPT   Many-to-Many
PROMPT   Junction Table
PROMPT
PROMPT No database objects were modified by this lesson.
PROMPT
PROMPT Next:
PROMPT   Lesson 02 - Creating Related Tables
PROMPT ============================================================