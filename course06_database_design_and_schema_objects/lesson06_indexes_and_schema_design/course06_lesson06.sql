-- Course 06 - Lesson 06: Indexes and Schema Design
-- Oracle Database 23ai Free | FREEPDB1 | SQL_LAB
-- First-run script: creates C06L06_ objects only.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
COLUMN CONNECTED_USER FORMAT A20
COLUMN CONTAINER_NAME FORMAT A20
COLUMN TABLE_NAME FORMAT A24
COLUMN INDEX_NAME FORMAT A34
COLUMN COLUMN_NAME FORMAT A20
COLUMN TITLE FORMAT A30
COLUMN CATEGORY_NAME FORMAT A20
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === Query 00: Verify session ===
SELECT USER AS connected_user, SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name FROM dual;
BEGIN
  IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20006, 'Expected SQL_LAB in FREEPDB1');
  END IF;
END;
/

PROMPT === Step 01: Create practice tables ===
CREATE TABLE c06l06_categories (
  category_id NUMBER(4) CONSTRAINT pk_c06l06_categories PRIMARY KEY,
  category_name VARCHAR2(50) CONSTRAINT nn_c06l06_category_name NOT NULL,
  CONSTRAINT uq_c06l06_category_name UNIQUE (category_name)
);

CREATE TABLE c06l06_books (
  book_id NUMBER(6) CONSTRAINT pk_c06l06_books PRIMARY KEY,
  title VARCHAR2(100) CONSTRAINT nn_c06l06_book_title NOT NULL,
  category_id NUMBER(4) CONSTRAINT nn_c06l06_book_category NOT NULL,
  price NUMBER(8,2) CONSTRAINT nn_c06l06_price NOT NULL,
  stock NUMBER(6) CONSTRAINT nn_c06l06_stock NOT NULL,
  published_year NUMBER(4),
  CONSTRAINT fk_c06l06_book_category FOREIGN KEY (category_id)
    REFERENCES c06l06_categories(category_id),
  CONSTRAINT ck_c06l06_price CHECK (price >= 0),
  CONSTRAINT ck_c06l06_stock CHECK (stock >= 0)
);

PROMPT === Step 02: Insert sample data ===
INSERT INTO c06l06_categories VALUES (10, 'Technology');
INSERT INTO c06l06_categories VALUES (20, 'Literature');
INSERT INTO c06l06_categories VALUES (30, 'Business');
INSERT INTO c06l06_books VALUES (1001, 'Database Fundamentals', 10, 35.50, 8, 2022);
INSERT INTO c06l06_books VALUES (1002, 'SQL Practice', 10, 28.00, 4, 2023);
INSERT INTO c06l06_books VALUES (1003, 'Python for Data', 10, 42.00, 6, 2024);
INSERT INTO c06l06_books VALUES (1004, 'Short Stories', 20, 18.00, 5, 2021);
INSERT INTO c06l06_books VALUES (1005, 'Modern Fiction', 20, 24.00, 7, 2023);
INSERT INTO c06l06_books VALUES (1006, 'Business Strategy', 30, 39.00, 3, 2024);
COMMIT;

PROMPT === Query 01: Inspect constraint-supporting indexes ===
SELECT table_name, constraint_name, constraint_type, index_name
FROM user_constraints
WHERE table_name IN ('C06L06_CATEGORIES', 'C06L06_BOOKS')
  AND constraint_type IN ('P', 'U')
ORDER BY table_name, constraint_type, constraint_name;

PROMPT === Step 03: Create three explicit B-tree indexes ===
CREATE INDEX idx_c06l06_book_title ON c06l06_books(title);
CREATE INDEX idx_c06l06_book_cat_price ON c06l06_books(category_id, price);
CREATE INDEX idx_c06l06_book_year ON c06l06_books(published_year);

PROMPT === Query 02: Inspect explicitly created index metadata ===
SELECT index_name, table_name, uniqueness, index_type, status
FROM user_indexes
WHERE index_name LIKE 'IDX_C06L06_%'
ORDER BY index_name;

SELECT index_name, column_position, column_name, descend
FROM user_ind_columns
WHERE index_name LIKE 'IDX_C06L06_%'
ORDER BY index_name, column_position;

PROMPT === Query 03: Example lookup predicates ===
SELECT b.book_id, b.title, c.category_name, b.price
FROM c06l06_books b
JOIN c06l06_categories c ON c.category_id = b.category_id
WHERE b.category_id = 10 AND b.price BETWEEN 25 AND 40
ORDER BY b.price, b.book_id;

SELECT book_id, title, published_year
FROM c06l06_books
WHERE title = 'Modern Fiction';

PROMPT === Query 04: Verify sample counts ===
SELECT 'C06L06_CATEGORIES' AS table_name, COUNT(*) AS row_count FROM c06l06_categories
UNION ALL
SELECT 'C06L06_BOOKS', COUNT(*) FROM c06l06_books;

PROMPT === Lesson 06 complete: practice objects retained for inspection ===
-- Do not infer query speed or actual index use from successful creation.
