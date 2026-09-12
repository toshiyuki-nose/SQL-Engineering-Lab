/*
==============================================================================
SQL-Engineering-Lab

Course 02 - SQL Fundamentals
Lesson 02 - Filtering Rows

File
----
setup.sql

Purpose
-------
Create and populate the BOOKS table used by Lesson 02 and later lessons.

Execute as:

    SQL_LAB @ FREEPDB1

Important
---------
BOOKS is part of the growing SQL-Engineering-Lab Book Store Database.

Normally, keep this table after completing Lesson 02 because later lessons
will continue to use it.

Use cleanup.sql only when you intentionally want to reset the dataset.

==============================================================================
*/

PROMPT
PROMPT ============================================================
PROMPT SQL-Engineering-Lab
PROMPT Course 02 - Lesson 02
PROMPT BOOKS Setup
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

SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;

-------------------------------------------------------------------------------
-- Step 2
-- Create BOOKS
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 2: Create BOOKS ===
PROMPT

PROMPT
PROMPT IMPORTANT:
PROMPT setup.sql creates a new BOOKS table.
PROMPT If BOOKS already exists, run cleanup.sql before running setup.sql again.
PROMPT


CREATE TABLE books (
    book_id         NUMBER,
    title           VARCHAR2(100),
    category        VARCHAR2(30),
    price           NUMBER(8,2),
    stock           NUMBER,
    published_year  NUMBER(4),
    CONSTRAINT pk_books PRIMARY KEY (book_id)
);


-------------------------------------------------------------------------------
-- Step 3
-- Verify the table
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 3: Verify BOOKS ===
PROMPT

COLUMN TABLE_NAME FORMAT A20
COLUMN TABLESPACE_NAME FORMAT A20

SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';

DESCRIBE books


COLUMN CONSTRAINT_NAME FORMAT A20
COLUMN CONSTRAINT_TYPE FORMAT A15
COLUMN STATUS FORMAT A10

SELECT
    constraint_name,
    constraint_type,
    table_name,
    status
FROM user_constraints
WHERE table_name = 'BOOKS';



-------------------------------------------------------------------------------
-- Step 4
-- Insert sample data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 4: Insert Sample Data ===
PROMPT

INSERT INTO books VALUES
    (1001, 'SQL Fundamentals', 'Technology', 2800, 12, 2022);

INSERT INTO books VALUES
    (1002, 'Advanced SQL Engineering', 'Technology', 4200, 5, 2024);

INSERT INTO books VALUES
    (1003, 'Database Design Basics', 'Technology', 3200, 0, 2021);

INSERT INTO books VALUES
    (1004, 'Python for Data Analysis', 'Data Science', 3600, 8, 2023);

INSERT INTO books VALUES
    (1005, 'Practical Machine Learning', 'Data Science', 4500, 3, 2025);

INSERT INTO books VALUES
    (1006, 'Statistics for Everyone', 'Data Science', 2500, 10, 2020);

INSERT INTO books VALUES
    (1007, 'Business Analytics', 'Business', 3000, 6, 2022);

INSERT INTO books VALUES
    (1008, 'The Modern Manager', 'Business', 2200, 0, 2019);

INSERT INTO books VALUES
    (1009, 'World History Essentials', 'History', 1800, 7, 2018);

INSERT INTO books VALUES
    (1010, 'Modern Japanese History', 'History', 2400, 4, 2021);

INSERT INTO books VALUES
    (1011, 'Climate and Society', 'Environment', 2700, 9, 2024);

INSERT INTO books VALUES
    (1012, 'Sustainable Cities', 'Environment', 3100, 2, 2025);

INSERT INTO books VALUES
    (1013, 'SQL Query Practice', 'Technology', 1900, 15, 2020);

INSERT INTO books VALUES
    (1014, 'Data Visualization Basics', 'Data Science', 2900, 0, 2022);

INSERT INTO books VALUES
    (1015, 'Economics in Daily Life', 'Business', 1600, 11, 2017);


-------------------------------------------------------------------------------
-- Step 5
-- Commit the sample data
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 5: Commit Sample Data ===
PROMPT

COMMIT;

-------------------------------------------------------------------------------
-- Step 6
-- Verify the dataset
-------------------------------------------------------------------------------

PROMPT
PROMPT === Step 6: Verify BOOKS Data ===
PROMPT

COLUMN TITLE FORMAT A30
COLUMN CATEGORY FORMAT A15
COLUMN PRICE FORMAT 999999.99

SELECT
    book_id,
    title,
    category,
    price,
    stock,
    published_year
FROM books;

PROMPT
PROMPT ============================================================
PROMPT BOOKS setup completed.
PROMPT
PROMPT Expected rows: 15
PROMPT
PROMPT BOOKS will be reused in later Course 02 lessons.
PROMPT ============================================================