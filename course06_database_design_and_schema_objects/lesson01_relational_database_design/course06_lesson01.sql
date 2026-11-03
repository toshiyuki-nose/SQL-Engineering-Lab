-- Course 06 - Lesson 01: Relational Database Design
-- Oracle Database 23ai Free | FREEPDB1 | SQL_LAB
-- Read-only schema exploration: no DDL or DML.
-- Run queries one at a time, connected as SQL_LAB.

SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON

COLUMN TABLE_NAME FORMAT A20
COLUMN COLUMN_NAME FORMAT A24
COLUMN CONSTRAINT_NAME FORMAT A30
COLUMN DATA_TYPE FORMAT A15
COLUMN STATUS FORMAT A10
COLUMN VALIDATED FORMAT A15


-- Query 00: Verify your session.
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

-- Query 01: Inventory the four Book Store tables.
SELECT table_name
FROM user_tables
WHERE table_name IN ('CATEGORIES', 'BOOKS', 'AUTHORS', 'BOOK_AUTHORS')
ORDER BY table_name;

-- Query 02: Inspect columns, data types, and nullability.
SELECT table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale,
       nullable
FROM user_tab_columns
WHERE table_name IN ('CATEGORIES', 'BOOKS', 'AUTHORS', 'BOOK_AUTHORS')
ORDER BY table_name, column_id;

-- Query 03: Inspect primary-key and unique constraints.
SELECT c.table_name,
       c.constraint_name,
       CASE c.constraint_type
           WHEN 'P' THEN 'PRIMARY KEY'
           WHEN 'U' THEN 'UNIQUE'
       END AS constraint_kind,
       c.status,
       c.validated
FROM user_constraints c
WHERE c.table_name IN ('CATEGORIES', 'BOOKS', 'AUTHORS', 'BOOK_AUTHORS')
  AND c.constraint_type IN ('P', 'U')
ORDER BY c.table_name, c.constraint_type, c.constraint_name;

-- Query 04: Inspect the columns belonging to PK/unique constraints.
SELECT c.table_name,
       c.constraint_name,
       c.constraint_type,
       cc.position,
       cc.column_name
FROM user_constraints c
JOIN user_cons_columns cc
  ON cc.constraint_name = c.constraint_name
 AND cc.table_name = c.table_name
WHERE c.table_name IN ('CATEGORIES', 'BOOKS', 'AUTHORS', 'BOOK_AUTHORS')
  AND c.constraint_type IN ('P', 'U')
ORDER BY c.table_name, c.constraint_name, cc.position;

-- Query 05: Resolve foreign keys to referenced parent key columns.
-- Matching child/parent POSITION is valid for Oracle referential constraints.
SELECT fk.table_name AS child_table,
       fk.constraint_name AS fk_name,
       child_col.position AS key_position,
       child_col.column_name AS child_column,
       pk.table_name AS parent_table,
       parent_col.column_name AS parent_column,
       fk.status,
       fk.validated
FROM user_constraints fk
JOIN user_constraints pk
  ON pk.constraint_name = fk.r_constraint_name
JOIN user_cons_columns child_col
  ON child_col.constraint_name = fk.constraint_name
 AND child_col.table_name = fk.table_name
JOIN user_cons_columns parent_col
  ON parent_col.constraint_name = pk.constraint_name
 AND parent_col.table_name = pk.table_name
 AND parent_col.position = child_col.position
WHERE fk.constraint_type = 'R'
  AND fk.table_name IN ('CATEGORIES', 'BOOKS', 'AUTHORS', 'BOOK_AUTHORS')
ORDER BY fk.table_name, fk.constraint_name, child_col.position;

-- Query 06: Count the current sample rows (not design constraints).
SELECT 'CATEGORIES' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'BOOKS', COUNT(*) FROM books
UNION ALL
SELECT 'AUTHORS', COUNT(*) FROM authors
UNION ALL
SELECT 'BOOK_AUTHORS', COUNT(*) FROM book_authors;

-- Query 07: Count book-author associations by book.
-- First verify actual column names in Query 02. This example assumes
-- BOOK_AUTHORS.BOOK_ID exists; adapt it if the schema differs.
SELECT ba.book_id,
       COUNT(*) AS author_association_count
FROM book_authors ba
GROUP BY ba.book_id
ORDER BY author_association_count DESC, ba.book_id;

-- Optional follow-up: after inspecting metadata, document the verified ER model.
-- No COMMIT is needed: these statements do not change data.
