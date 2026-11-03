-- Course 06 - Lesson 02: Database Normalization
-- Oracle Database 23ai Free | FREEPDB1 | SQL_LAB
-- WARNING: This script creates and populates C06L02_ practice tables.
-- It does not modify existing BOOKS, AUTHORS, CATEGORIES, BOOK_AUTHORS.
-- Run ONCE in the SQL_LAB schema. Oracle DDL implicitly commits.

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON

COLUMN TABLE_NAME FORMAT A20
COLUMN TITLE FORMAT A25
COLUMN CATEGORY_NAME FORMAT A20
COLUMN AUTHOR_NAME FORMAT A20


-- Query 00: Verify the current session before executing DDL.
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

-- Step 01: Deliberately redundant association table (1NF, not 2NF).
CREATE TABLE c06l02_flat (
    book_id       NUMBER NOT NULL,
    title         VARCHAR2(100) NOT NULL,
    category_id   NUMBER NOT NULL,
    category_name VARCHAR2(50) NOT NULL,
    author_id     NUMBER NOT NULL,
    author_name   VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_c06l02_flat PRIMARY KEY (book_id, author_id)
);

INSERT INTO c06l02_flat VALUES (1001, 'Database Basics', 10, 'Technology', 201, 'A. Writer');
INSERT INTO c06l02_flat VALUES (1001, 'Database Basics', 10, 'Technology', 202, 'B. Editor');
INSERT INTO c06l02_flat VALUES (1002, 'SQL Practice',    10, 'Technology', 201, 'A. Writer');

-- Step 02: Normalized tables.
CREATE TABLE c06l02_categories (
    category_id   NUMBER PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL
);

CREATE TABLE c06l02_books (
    book_id     NUMBER PRIMARY KEY,
    title       VARCHAR2(100) NOT NULL,
    category_id NUMBER NOT NULL,
    CONSTRAINT fk_c06l02_books_category
        FOREIGN KEY (category_id) REFERENCES c06l02_categories (category_id)
);

CREATE TABLE c06l02_authors (
    author_id   NUMBER PRIMARY KEY,
    author_name VARCHAR2(100) NOT NULL
);

CREATE TABLE c06l02_book_authors (
    book_id   NUMBER NOT NULL,
    author_id NUMBER NOT NULL,
    CONSTRAINT pk_c06l02_book_authors PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_c06l02_ba_book FOREIGN KEY (book_id)
        REFERENCES c06l02_books (book_id),
    CONSTRAINT fk_c06l02_ba_author FOREIGN KEY (author_id)
        REFERENCES c06l02_authors (author_id)
);

-- Step 03: Populate normalized tables from the sample facts.
INSERT INTO c06l02_categories VALUES (10, 'Technology');
INSERT INTO c06l02_books VALUES (1001, 'Database Basics', 10);
INSERT INTO c06l02_books VALUES (1002, 'SQL Practice', 10);
INSERT INTO c06l02_authors VALUES (201, 'A. Writer');
INSERT INTO c06l02_authors VALUES (202, 'B. Editor');
INSERT INTO c06l02_book_authors VALUES (1001, 201);
INSERT INTO c06l02_book_authors VALUES (1001, 202);
INSERT INTO c06l02_book_authors VALUES (1002, 201);
COMMIT;

-- Query 01: Row counts.
SELECT 'FLAT' AS table_name, COUNT(*) AS row_count FROM c06l02_flat
UNION ALL SELECT 'CATEGORIES', COUNT(*) FROM c06l02_categories
UNION ALL SELECT 'BOOKS', COUNT(*) FROM c06l02_books
UNION ALL SELECT 'AUTHORS', COUNT(*) FROM c06l02_authors
UNION ALL SELECT 'BOOK_AUTHORS', COUNT(*) FROM c06l02_book_authors;

-- Query 02: View the redundant rows.
SELECT book_id, title, category_id, category_name, author_id, author_name
FROM c06l02_flat
ORDER BY book_id, author_id;

-- Query 03: Reconstruct the same associations from normalized tables.
SELECT b.book_id, b.title, c.category_id, c.category_name,
       a.author_id, a.author_name
FROM c06l02_books b
JOIN c06l02_categories c ON c.category_id = b.category_id
JOIN c06l02_book_authors ba ON ba.book_id = b.book_id
JOIN c06l02_authors a ON a.author_id = ba.author_id
ORDER BY b.book_id, a.author_id;

-- Query 04: Count authors per book.
SELECT b.book_id, b.title, COUNT(ba.author_id) AS author_count
FROM c06l02_books b
LEFT JOIN c06l02_book_authors ba ON ba.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY b.book_id;

-- Query 05: Verify that both representations contain the same facts.
-- Expected: 0 rows. MINUS compares distinct rows; these sample keys are unique.
WITH normalized AS (
    SELECT b.book_id, b.title, c.category_id, c.category_name,
           a.author_id, a.author_name
    FROM c06l02_books b
    JOIN c06l02_categories c ON c.category_id = b.category_id
    JOIN c06l02_book_authors ba ON ba.book_id = b.book_id
    JOIN c06l02_authors a ON a.author_id = ba.author_id
)
SELECT 'FLAT_ONLY' AS source_name, x.*
FROM (
    SELECT book_id, title, category_id, category_name, author_id, author_name
    FROM c06l02_flat
    MINUS
    SELECT book_id, title, category_id, category_name, author_id, author_name
    FROM normalized
) x
UNION ALL
SELECT 'NORMALIZED_ONLY' AS source_name, x.*
FROM (
    SELECT book_id, title, category_id, category_name, author_id, author_name
    FROM normalized
    MINUS
    SELECT book_id, title, category_id, category_name, author_id, author_name
    FROM c06l02_flat
) x;

-- Optional inspection: no destructive cleanup is included.
-- Keep C06L02_ tables for Lesson 03, or review and drop them manually later.
