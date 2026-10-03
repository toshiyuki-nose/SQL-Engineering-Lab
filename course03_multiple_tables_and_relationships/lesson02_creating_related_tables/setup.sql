/*
==============================================================================
SQL-Engineering-Lab

Course 03 - Multiple Tables and Relationships
Lesson 02 - Creating Related Tables

File
----
setup.sql

Purpose
-------
Transform the existing Course 02 BOOKS table into a relational Book Store
Database.

This script:

1. Verifies the current BOOKS table
2. Creates CATEGORIES
3. Migrates BOOKS.CATEGORY to BOOKS.CATEGORY_ID
4. Creates the BOOKS -> CATEGORIES foreign key
5. Removes the old BOOKS.CATEGORY column
6. Creates AUTHORS
7. Creates BOOK_AUTHORS
8. Inserts sample authors and relationships
9. Verifies the resulting relational model

Execute as:

    SQL_LAB @ FREEPDB1

Prerequisite
------------
Complete:

    Course 02 - SQL Fundamentals
    Course 03 - Lesson 01

Important
---------
This script changes the existing BOOKS table.

This setup is intended to be executed once.

If an unexpected SQL error occurs, SQL*Plus stops the script immediately
instead of continuing with a partially completed migration.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 03 - Lesson 02
PROMPT Related Tables Setup
PROMPT ============================================================
PROMPT

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100

/*
------------------------------------------------------------------------------
Safety setting

Stop SQL*Plus immediately if an unexpected SQL error occurs.

This prevents later DDL statements from running after an earlier migration
step has failed.
------------------------------------------------------------------------------
*/

WHENEVER SQLERROR EXIT SQL.SQLCODE

-------------------------------------------------------------------------------
-- Step 1
-- Verify current session
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
-- Verify the existing BOOKS table
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Verify Existing BOOKS ===
PROMPT

COLUMN TABLE_NAME FORMAT A20
COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';

SELECT
    COUNT(*) AS book_count
FROM books;

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 3
-- Inspect existing CATEGORY data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Existing CATEGORY Data ===
PROMPT

COLUMN CATEGORY FORMAT A20

SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category
ORDER BY category;

PROMPT
PROMPT Expected categories:
PROMPT
PROMPT   Business
PROMPT   Data Science
PROMPT   Environment
PROMPT   History
PROMPT   Technology
PROMPT

-------------------------------------------------------------------------------
-- Step 4
-- Create CATEGORIES
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Create CATEGORIES ===
PROMPT

CREATE TABLE categories (
    category_id   NUMBER,
    category_name VARCHAR2(30) NOT NULL,
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_name UNIQUE (category_name)
);

-------------------------------------------------------------------------------
-- Step 5
-- Insert category master data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Insert CATEGORIES ===
PROMPT

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    10,
    'Technology'
);

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    20,
    'Data Science'
);

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    30,
    'Business'
);

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    40,
    'History'
);

INSERT INTO categories (
    category_id,
    category_name
)
VALUES (
    50,
    'Environment'
);

COMMIT;

COLUMN CATEGORY_NAME FORMAT A20

SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

-------------------------------------------------------------------------------
-- Step 6
-- Add CATEGORY_ID to BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Add CATEGORY_ID to BOOKS ===
PROMPT

ALTER TABLE books
ADD category_id NUMBER;

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 7
-- Migrate existing CATEGORY values
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 7: Migrate CATEGORY Data ===
PROMPT

UPDATE books b
SET category_id = (
    SELECT c.category_id
    FROM categories c
    WHERE c.category_name = b.category
);

PROMPT
PROMPT Rows updated:
PROMPT

SELECT
    COUNT(*) AS books_with_category_id
FROM books
WHERE category_id IS NOT NULL;

-------------------------------------------------------------------------------
-- Step 8
-- Verify that no category failed to migrate
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 8: Check for Migration Problems ===
PROMPT

COLUMN TITLE FORMAT A30

SELECT
    book_id,
    title,
    category
FROM books
WHERE category_id IS NULL;

PROMPT
PROMPT Expected result:
PROMPT   no rows selected
PROMPT

-------------------------------------------------------------------------------
-- Step 9
-- Compare old and new category representations
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 9: Compare Old and New CATEGORY Data ===
PROMPT

COLUMN OLD_CATEGORY FORMAT A20
COLUMN NEW_CATEGORY FORMAT A20

SELECT
    b.book_id,
    b.title,
    b.category AS old_category,
    b.category_id,
    c.category_name AS new_category
FROM books b
LEFT JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 10
-- Validate the migration before removing CATEGORY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 10: Validate CATEGORY Migration ===
PROMPT

SELECT
    COUNT(*) AS migration_error_count
FROM books b
LEFT JOIN categories c
    ON b.category_id = c.category_id
WHERE b.category_id IS NULL
   OR c.category_id IS NULL
   OR b.category <> c.category_name;

PROMPT
PROMPT Expected:
PROMPT
PROMPT   MIGRATION_ERROR_COUNT = 0
PROMPT

/*
The script intentionally performs the validation before dropping CATEGORY.

Do not remove the old representation until the new relationship has been
verified.
*/

-------------------------------------------------------------------------------
-- Step 11
-- Create BOOKS -> CATEGORIES foreign key
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 11: Create BOOKS -> CATEGORIES Foreign Key ===
PROMPT

ALTER TABLE books
ADD CONSTRAINT fk_books_category
    FOREIGN KEY (category_id)
    REFERENCES categories (category_id);

-------------------------------------------------------------------------------
-- Step 12
-- Make CATEGORY_ID mandatory
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 12: Make CATEGORY_ID NOT NULL ===
PROMPT

ALTER TABLE books
MODIFY category_id NOT NULL;

-------------------------------------------------------------------------------
-- Step 13
-- Verify the relationship before removing CATEGORY
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 13: Verify BOOKS -> CATEGORIES Relationship ===
PROMPT

SELECT
    b.book_id,
    b.title,
    b.category_id,
    c.category_name
FROM books b
JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

SELECT
    COUNT(*) AS related_book_count
FROM books b
JOIN categories c
    ON b.category_id = c.category_id;

PROMPT
PROMPT Expected:
PROMPT   RELATED_BOOK_COUNT = 15
PROMPT

-------------------------------------------------------------------------------
-- Step 14
-- Remove the old CATEGORY column
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 14: Remove Old CATEGORY Column ===
PROMPT

ALTER TABLE books
DROP COLUMN category;

PROMPT
PROMPT BOOKS.CATEGORY has been replaced by BOOKS.CATEGORY_ID.
PROMPT

DESCRIBE books

-------------------------------------------------------------------------------
-- Step 15
-- Create AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 15: Create AUTHORS ===
PROMPT

CREATE TABLE authors (
    author_id   NUMBER,
    author_name VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_authors PRIMARY KEY (author_id)
);

-------------------------------------------------------------------------------
-- Step 16
-- Insert sample AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 16: Insert AUTHORS ===
PROMPT

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    501,
    'Alex Morgan'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    502,
    'Maya Chen'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    503,
    'Daniel Carter'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    504,
    'Sophia Patel'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    505,
    'Kenji Sato'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    506,
    'Emma Wilson'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    507,
    'Lucas Martin'
);

INSERT INTO authors (
    author_id,
    author_name
)
VALUES (
    508,
    'Olivia Brown'
);

COMMIT;

COLUMN AUTHOR_NAME FORMAT A25

SELECT
    author_id,
    author_name
FROM authors
ORDER BY author_id;

-------------------------------------------------------------------------------
-- Step 17
-- Create BOOK_AUTHORS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 17: Create BOOK_AUTHORS ===
PROMPT

CREATE TABLE book_authors (
    book_id   NUMBER,
    author_id NUMBER,
    CONSTRAINT pk_book_authors PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id)
        REFERENCES books (book_id),
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id)
        REFERENCES authors (author_id)
);

-------------------------------------------------------------------------------
-- Step 18
-- Insert BOOK_AUTHORS relationships
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 18: Insert BOOK_AUTHORS ===
PROMPT

INSERT INTO book_authors VALUES (1001, 501);

INSERT INTO book_authors VALUES (1002, 501);
INSERT INTO book_authors VALUES (1002, 502);

INSERT INTO book_authors VALUES (1003, 503);

INSERT INTO book_authors VALUES (1004, 504);
INSERT INTO book_authors VALUES (1005, 504);
INSERT INTO book_authors VALUES (1006, 502);

INSERT INTO book_authors VALUES (1007, 506);
INSERT INTO book_authors VALUES (1008, 506);

INSERT INTO book_authors VALUES (1009, 507);
INSERT INTO book_authors VALUES (1010, 505);

INSERT INTO book_authors VALUES (1011, 508);
INSERT INTO book_authors VALUES (1012, 508);

INSERT INTO book_authors VALUES (1013, 503);

INSERT INTO book_authors VALUES (1014, 502);

INSERT INTO book_authors VALUES (1015, 506);

COMMIT;

-------------------------------------------------------------------------------
-- Step 19
-- Verify row counts
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 19: Verify Row Counts ===
PROMPT

SELECT
    COUNT(*) AS category_count
FROM categories;

SELECT
    COUNT(*) AS book_count
FROM books;

SELECT
    COUNT(*) AS author_count
FROM authors;

SELECT
    COUNT(*) AS book_author_count
FROM book_authors;

PROMPT
PROMPT Expected:
PROMPT
PROMPT   CATEGORIES    = 5
PROMPT   BOOKS         = 15
PROMPT   AUTHORS       = 8
PROMPT   BOOK_AUTHORS  = 16
PROMPT

-------------------------------------------------------------------------------
-- Step 20
-- Verify final BOOKS data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 20: Verify BOOKS with CATEGORIES ===
PROMPT

COLUMN TITLE FORMAT A30
COLUMN CATEGORY_NAME FORMAT A20

SELECT
    b.book_id,
    b.title,
    b.category_id,
    c.category_name
FROM books b
JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.book_id;

-------------------------------------------------------------------------------
-- Step 21
-- Verify BOOK_AUTHORS data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 21: Verify BOOK_AUTHORS ===
PROMPT

SELECT
    book_id,
    author_id
FROM book_authors
ORDER BY
    book_id,
    author_id;

-------------------------------------------------------------------------------
-- Step 22
-- Verify constraints
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 22: Verify Constraints ===
PROMPT

COLUMN TABLE_NAME FORMAT A20
COLUMN CONSTRAINT_NAME FORMAT A30
COLUMN CONSTRAINT_TYPE FORMAT A15
COLUMN STATUS FORMAT A15

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
-- Step 23
-- Verify constraint columns
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 23: Verify Constraint Columns ===
PROMPT

COLUMN COLUMN_NAME FORMAT A20

SELECT
    table_name,
    constraint_name,
    column_name,
    position
FROM user_cons_columns
WHERE table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
ORDER BY
    table_name,
    constraint_name,
    position;

-------------------------------------------------------------------------------
-- Step 24
-- Verify foreign key relationships
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 24: Verify Foreign Key Relationships ===
PROMPT

COLUMN CHILD_TABLE FORMAT A20
COLUMN FOREIGN_KEY FORMAT A30
COLUMN CHILD_COLUMN FORMAT A20
COLUMN PARENT_TABLE FORMAT A20
COLUMN PARENT_COLUMN FORMAT A20

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
-- Step 25
-- Final model
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 25: Final Relational Model ===
PROMPT

PROMPT
PROMPT   CATEGORIES
PROMPT       CATEGORY_ID PK
PROMPT            |
PROMPT            | FK_BOOKS_CATEGORY
PROMPT            |
PROMPT            +----< BOOKS
PROMPT                     BOOK_ID     PK
PROMPT                     CATEGORY_ID FK
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
PROMPT Related tables setup completed successfully.
PROMPT
PROMPT Final row counts:
PROMPT
PROMPT   CATEGORIES    5
PROMPT   BOOKS         15
PROMPT   AUTHORS       8
PROMPT   BOOK_AUTHORS 16
PROMPT
PROMPT Relationships:
PROMPT
PROMPT   CATEGORIES 1 ---- N BOOKS
PROMPT
PROMPT   BOOKS      1 ---- N BOOK_AUTHORS
PROMPT   AUTHORS    1 ---- N BOOK_AUTHORS
PROMPT
PROMPT BOOKS <-> AUTHORS is represented as a many-to-many
PROMPT relationship through BOOK_AUTHORS.
PROMPT
PROMPT Continue with:
PROMPT
PROMPT   @lesson02.sql
PROMPT ============================================================

/*
------------------------------------------------------------------------------
Restore normal SQL*Plus error behavior.

The setup has completed successfully.
------------------------------------------------------------------------------
*/

WHENEVER SQLERROR CONTINUE