-- Course 06 / Lesson 04: Views
-- Oracle Database 23ai Free | SQL_LAB | FREEPDB1
-- First-run only. Use course06_lesson04_cleanup.sql before a rerun.
-- Creates only C06L04_ objects. Existing Book Store tables are untouched.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === Query 00: Verify session ===
SELECT USER AS connected_user, SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name FROM dual;

-- Stop before any DDL if the connection is not the intended sandbox.
BEGIN
  IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Expected SQL_LAB in FREEPDB1');
  END IF;
END;
/

PROMPT === Step 01: Create practice base tables ===
CREATE TABLE c06l04_categories (
  category_id NUMBER(4) CONSTRAINT pk_c06l04_categories PRIMARY KEY,
  category_name VARCHAR2(50) NOT NULL
);
CREATE TABLE c06l04_books (
  book_id NUMBER(6) CONSTRAINT pk_c06l04_books PRIMARY KEY,
  title VARCHAR2(100) NOT NULL,
  category_id NUMBER(4) NOT NULL,
  price NUMBER(8,2) NOT NULL,
  stock NUMBER(6) NOT NULL,
  CONSTRAINT fk_c06l04_books_category FOREIGN KEY (category_id)
    REFERENCES c06l04_categories(category_id),
  CONSTRAINT ck_c06l04_price CHECK (price >= 0),
  CONSTRAINT ck_c06l04_stock CHECK (stock >= 0)
);
INSERT INTO c06l04_categories VALUES (10, 'Technology');
INSERT INTO c06l04_categories VALUES (20, 'Literature');
INSERT INTO c06l04_books VALUES (1001, 'Database Fundamentals', 10, 35.50, 8);
INSERT INTO c06l04_books VALUES (1002, 'SQL Practice', 10, 28.00, 4);
INSERT INTO c06l04_books VALUES (1003, 'Short Stories', 20, 18.00, 6);
COMMIT;

PROMPT === Step 02: Create a join view ===
CREATE VIEW c06l04_v_book_details AS
SELECT b.book_id, b.title, c.category_name, b.price
FROM c06l04_books b
JOIN c06l04_categories c ON c.category_id = b.category_id;
SELECT * FROM c06l04_v_book_details ORDER BY book_id;

PROMPT === Step 03: Create an aggregate view ===
CREATE VIEW c06l04_v_category_summary AS
SELECT c.category_id, c.category_name,
       COUNT(b.book_id) AS book_count,
       NVL(SUM(b.stock), 0) AS total_stock,
       NVL(SUM(b.price * b.stock), 0) AS inventory_value
FROM c06l04_categories c
LEFT JOIN c06l04_books b ON b.category_id = c.category_id
GROUP BY c.category_id, c.category_name;
SELECT * FROM c06l04_v_category_summary ORDER BY category_id;

PROMPT === Step 04: Replace a view definition ===
CREATE OR REPLACE VIEW c06l04_v_book_details AS
SELECT b.book_id, b.title, c.category_name, b.price, b.stock
FROM c06l04_books b
JOIN c06l04_categories c ON c.category_id = b.category_id;
SELECT * FROM c06l04_v_book_details ORDER BY book_id;

PROMPT === Step 05: Create a simple updatable view WITH CHECK OPTION ===
CREATE VIEW c06l04_v_technology_books AS
SELECT book_id, title, category_id, price, stock
FROM c06l04_books
WHERE category_id = 10
WITH CHECK OPTION CONSTRAINT ck_c06l04_tech_view;

PROMPT === Step 06: Test an update through the view, then roll back ===
SAVEPOINT before_view_update;
UPDATE c06l04_v_technology_books SET price = price + 1 WHERE book_id = 1001;
SELECT book_id, title, price FROM c06l04_books WHERE book_id = 1001;
ROLLBACK TO SAVEPOINT before_view_update;
SELECT book_id, title, price FROM c06l04_books WHERE book_id = 1001;

PROMPT === Step 07: Test CHECK OPTION (expected ORA-01402) ===
DECLARE
  l_rejected BOOLEAN := FALSE;
BEGIN
  BEGIN
    UPDATE c06l04_v_technology_books SET category_id = 20 WHERE book_id = 1001;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1402 THEN
        l_rejected := TRUE;
        DBMS_OUTPUT.PUT_LINE('PASS WITH CHECK OPTION rejected category change: ORA-01402');
      ELSE
        RAISE;
      END IF;
  END;
  IF NOT l_rejected THEN
    RAISE_APPLICATION_ERROR(-20005, 'FAIL: CHECK OPTION unexpectedly allowed the update');
  END IF;
END;
/

PROMPT === Step 08: Create a read-only view ===
CREATE VIEW c06l04_v_read_only_books AS
SELECT book_id, title, price FROM c06l04_books
WITH READ ONLY;

PROMPT === Step 09: Test READ ONLY (expected ORA-42399) ===
DECLARE
  l_rejected BOOLEAN := FALSE;
BEGIN
  BEGIN
    UPDATE c06l04_v_read_only_books SET price = 99 WHERE book_id = 1001;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -42399 THEN
        l_rejected := TRUE;
        DBMS_OUTPUT.PUT_LINE('PASS READ ONLY rejected update: ORA-42399');
      ELSE
        RAISE;
      END IF;
  END;
  IF NOT l_rejected THEN
    RAISE_APPLICATION_ERROR(-20006, 'FAIL: READ ONLY view unexpectedly allowed update');
  END IF;
END;
/

PROMPT === Query 01: Inspect view metadata ===
COLUMN VIEW_NAME FORMAT A35
SELECT view_name, read_only FROM user_views
WHERE view_name LIKE 'C06L04_V_%' ORDER BY view_name;

PROMPT === Query 02: Verify base table counts and restored price ===
SELECT 'CATEGORIES' AS table_name, COUNT(*) AS row_count FROM c06l04_categories
UNION ALL
SELECT 'BOOKS', COUNT(*) FROM c06l04_books;
SELECT book_id, title, category_id, price, stock FROM c06l04_books ORDER BY book_id;
PROMPT === Lesson 04 complete: objects retained for inspection ===
