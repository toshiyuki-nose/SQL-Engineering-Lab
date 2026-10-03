/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 02 - Creating Related Tables

File
----
lesson02.sql

Purpose
-------
Inspect the relational Book Store Database and verify that Oracle enforces
primary keys, foreign keys, and referential integrity.

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Run setup.sql successfully before this script.

Important
---------
Some statements in this lesson intentionally cause Oracle errors.

These errors are expected because they demonstrate that constraints are
protecting the database.

==============================================================================
*/

SPOOL logs/lesson02.log

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 02
PROMPT Creating Related Tables
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

COLUMN TABLE_NAME FORMAT A20
COLUMN COLUMN_NAME FORMAT A20
COLUMN CONSTRAINT_NAME FORMAT A30
COLUMN CONSTRAINT_TYPE FORMAT A15
COLUMN STATUS FORMAT A15
COLUMN CATEGORY_NAME FORMAT A20
COLUMN AUTHOR_NAME FORMAT A25
COLUMN TITLE FORMAT A30

-------------------------------------------------------------------------------
-- Step 1
-- Verify current session
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
-- Inspect the relational tables
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Relational Tables ===
PROMPT

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
ORDER BY table_name;

-------------------------------------------------------------------------------
-- Step 3
-- Inspect table structures
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3A: CATEGORIES ===
PROMPT

DESCRIBE categories

PROMPT
PROMPT === Step 3B: BOOKS ===
PROMPT

DESCRIBE books

PROMPT
PROMPT === Step 3C: AUTHORS ===
PROMPT

DESCRIBE authors

PROMPT
PROMPT === Step 3D: BOOK_AUTHORS ===
PROMPT

DESCRIBE book_authors

-------------------------------------------------------------------------------
-- Step 4
-- Inspect CATEGORIES
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: CATEGORIES Data ===
PROMPT

SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

-------------------------------------------------------------------------------
-- Step 5
-- Inspect BOOKS category relationships
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: BOOKS and CATEGORY_ID ===
PROMPT

SELECT
    book_id,
    title,
    category_id
FROM books
ORDER BY book_id;

PROMPT
PROMPT CATEGORY is no longer stored directly in BOOKS.
PROMPT CATEGORY_ID now represents the relationship.
PROMPT

-------------------------------------------------------------------------------
-- Step 6
-- Inspect AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: AUTHORS Data ===
PROMPT

SELECT
    author_id,
    author_name
FROM authors
ORDER BY author_id;

-------------------------------------------------------------------------------
-- Step 7
-- Inspect BOOK_AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: BOOK_AUTHORS Data ===
PROMPT

SELECT
    book_id,
    author_id
FROM book_authors
ORDER BY
    book_id,
    author_id;

PROMPT
PROMPT Notice that BOOK_ID 1002 appears more than once.
PROMPT One book can therefore be related to multiple authors.
PROMPT

-------------------------------------------------------------------------------
-- Step 8
-- Inspect all constraints
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Constraints ===
PROMPT

SELECT
    table_name,
    constraint_name,
    constraint_type,
    status
FROM user_constraints
WHERE table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
ORDER BY
    table_name,
    constraint_name;

-------------------------------------------------------------------------------
-- Step 9
-- Inspect primary keys
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Primary Keys ===
PROMPT

SELECT
    c.table_name,
    c.constraint_name,
    cc.column_name,
    cc.position
FROM user_constraints c
JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name
   AND c.table_name = cc.table_name
WHERE c.table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
  AND c.constraint_type = 'P'
ORDER BY
    c.table_name,
    c.constraint_name,
    cc.position;

-------------------------------------------------------------------------------
-- Step 10
-- Inspect foreign keys
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Foreign Keys ===
PROMPT

SELECT
    c.table_name AS child_table,
    c.constraint_name AS foreign_key,
    cc.column_name AS child_column,
    p.table_name AS parent_table,
    pc.column_name AS parent_column
FROM user_constraints c
JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name
   AND c.table_name = cc.table_name
JOIN user_constraints p
    ON c.r_constraint_name = p.constraint_name
JOIN user_cons_columns pc
    ON p.constraint_name = pc.constraint_name
   AND cc.position = pc.position
WHERE c.constraint_type = 'R'
  AND c.table_name IN (
      'BOOKS',
      'BOOK_AUTHORS'
  )
ORDER BY
    c.table_name,
    c.constraint_name,
    cc.position;

-------------------------------------------------------------------------------
-- Step 11
-- Observe the composite primary key
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: BOOK_AUTHORS Composite Primary Key ===
PROMPT

SELECT
    c.constraint_name,
    cc.column_name,
    cc.position
FROM user_constraints c
JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name
   AND c.table_name = cc.table_name
WHERE c.table_name = 'BOOK_AUTHORS'
  AND c.constraint_type = 'P'
ORDER BY cc.position;

PROMPT
PROMPT Expected:
PROMPT
PROMPT   Position 1 = BOOK_ID
PROMPT   Position 2 = AUTHOR_ID
PROMPT

-------------------------------------------------------------------------------
-- Step 12
-- Test referential integrity
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Referential Integrity Test ===
PROMPT
PROMPT EXPECTED ERROR:
PROMPT AUTHOR_ID 999 does not exist.
PROMPT Oracle should reject the following relationship.
PROMPT

SAVEPOINT before_invalid_author;

INSERT INTO book_authors (
    book_id,
    author_id
)
VALUES (
    1001,
    999
);

ROLLBACK TO before_invalid_author;

PROMPT
PROMPT If Oracle rejected AUTHOR_ID 999, the foreign key worked correctly.
PROMPT

-------------------------------------------------------------------------------
-- Step 13
-- Test duplicate relationship
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Composite Primary Key Test ===
PROMPT
PROMPT EXPECTED ERROR:
PROMPT BOOK_ID 1001 + AUTHOR_ID 501 already exists.
PROMPT Oracle should reject the duplicate relationship.
PROMPT

SAVEPOINT before_duplicate_relationship;

INSERT INTO book_authors (
    book_id,
    author_id
)
VALUES (
    1001,
    501
);

ROLLBACK TO before_duplicate_relationship;

PROMPT
PROMPT If Oracle rejected the duplicate pair, PK_BOOK_AUTHORS worked correctly.
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Verify no invalid test rows remain
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Verify Data After Constraint Tests ===
PROMPT

SELECT
    book_id,
    author_id
FROM book_authors
WHERE book_id = 1001
ORDER BY author_id;

SELECT
    COUNT(*) AS invalid_author_rows
FROM book_authors
WHERE author_id = 999;

-------------------------------------------------------------------------------
-- Step 15
-- Final relationship overview
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Relationship Overview ===
PROMPT

PROMPT
PROMPT   CATEGORIES
PROMPT       CATEGORY_ID PK
PROMPT            |
PROMPT            | FK_BOOKS_CATEGORY
PROMPT            |
PROMPT            +----< BOOKS
PROMPT                     BOOK_ID PK
PROMPT                         |
PROMPT                         |
PROMPT                         +----< BOOK_AUTHORS
PROMPT                                  BOOK_ID   PK, FK
PROMPT                                  AUTHOR_ID PK, FK
PROMPT                                      |
PROMPT                                      |
PROMPT                                      +---- AUTHORS
PROMPT                                            AUTHOR_ID PK
PROMPT

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

PROMPT
PROMPT ============================================================
PROMPT Lesson 02 completed.
PROMPT
PROMPT You practiced:
PROMPT
PROMPT   PRIMARY KEY
PROMPT   FOREIGN KEY
PROMPT   REFERENCES
PROMPT   UNIQUE
PROMPT   Composite Primary Key
PROMPT   Referential Integrity
PROMPT   Oracle Constraint Metadata
PROMPT
PROMPT The Book Store Database now contains related tables.
PROMPT
PROMPT Next:
PROMPT   Lesson 03 - INNER JOIN
PROMPT ============================================================

SPOOL OFF