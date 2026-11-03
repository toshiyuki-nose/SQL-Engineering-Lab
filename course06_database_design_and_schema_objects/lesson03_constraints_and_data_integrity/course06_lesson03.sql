-- Course 06 - Lesson 03: Constraints and Data Integrity
-- Oracle Database 23ai Free | FREEPDB1 | SQL_LAB
-- First-run script: creates three C06L03_ practice tables and inserts sample data.
-- Run only once in SQL_LAB. Existing Book Store tables are not modified.
-- Expected constraint failures are caught and reported by PL/SQL.

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON

WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === Query 00: Verify session ===
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

PROMPT === Step 01: Create practice tables ===
CREATE TABLE c06l03_categories (
    category_id   NUMBER(4) CONSTRAINT pk_c06l03_categories PRIMARY KEY,
    category_name VARCHAR2(50) CONSTRAINT nn_c06l03_category_name NOT NULL,
    CONSTRAINT uq_c06l03_category_name UNIQUE (category_name)
);

CREATE TABLE c06l03_books (
    book_id       NUMBER(6) CONSTRAINT pk_c06l03_books PRIMARY KEY,
    title         VARCHAR2(100) CONSTRAINT nn_c06l03_book_title NOT NULL,
    isbn          VARCHAR2(20),
    price         NUMBER(8,2) DEFAULT 0 CONSTRAINT nn_c06l03_price NOT NULL,
    stock         NUMBER(6) DEFAULT 0 CONSTRAINT nn_c06l03_stock NOT NULL,
    category_id   NUMBER(4) CONSTRAINT nn_c06l03_book_category NOT NULL,
    CONSTRAINT uq_c06l03_isbn UNIQUE (isbn),
    CONSTRAINT ck_c06l03_price CHECK (price >= 0),
    CONSTRAINT ck_c06l03_stock CHECK (stock >= 0),
    CONSTRAINT fk_c06l03_book_category FOREIGN KEY (category_id)
        REFERENCES c06l03_categories (category_id)
);

CREATE TABLE c06l03_reviews (
    review_id NUMBER(6) CONSTRAINT pk_c06l03_reviews PRIMARY KEY,
    book_id   NUMBER(6) CONSTRAINT nn_c06l03_review_book NOT NULL,
    rating    NUMBER(1) CONSTRAINT nn_c06l03_rating NOT NULL,
    CONSTRAINT ck_c06l03_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_c06l03_review_book FOREIGN KEY (book_id)
        REFERENCES c06l03_books (book_id)
);

PROMPT === Step 02: Insert valid data ===
INSERT INTO c06l03_categories VALUES (10, 'Technology');
INSERT INTO c06l03_categories VALUES (20, 'Literature');
INSERT INTO c06l03_books (book_id, title, isbn, price, stock, category_id)
VALUES (1001, 'Database Fundamentals', 'ISBN-C06-001', 35.50, 8, 10);
INSERT INTO c06l03_books (book_id, title, isbn, price, stock, category_id)
VALUES (1002, 'SQL Practice', 'ISBN-C06-002', 28.00, 4, 10);
INSERT INTO c06l03_reviews VALUES (1, 1001, 5);
COMMIT;

PROMPT === Query 01: Inspect constraints ===
COLUMN TABLE_NAME FORMAT A22
COLUMN CONSTRAINT_NAME FORMAT A34
COLUMN CONSTRAINT_TYPE FORMAT A16
COLUMN STATUS FORMAT A10
COLUMN VALIDATED FORMAT A15
SELECT table_name, constraint_name, constraint_type, status, validated
FROM user_constraints
WHERE table_name IN ('C06L03_CATEGORIES', 'C06L03_BOOKS', 'C06L03_REVIEWS')
ORDER BY table_name, constraint_type, constraint_name;

PROMPT === Step 03: Deliberately invalid inserts (expected failures) ===
DECLARE
    PROCEDURE expect_error(p_test VARCHAR2, p_sql VARCHAR2, p_expected NUMBER) IS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        RAISE_APPLICATION_ERROR(-20001, p_test || ': unexpectedly succeeded');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = p_expected THEN
                DBMS_OUTPUT.PUT_LINE('PASS ' || p_test || ': ORA-' || LPAD(ABS(SQLCODE), 5, '0'));
            ELSE
                RAISE;
            END IF;
    END;
BEGIN
    expect_error('Duplicate primary key',
        q'[INSERT INTO c06l03_categories VALUES (10, 'Duplicate')]', -1);
    expect_error('Duplicate UNIQUE category name',
        q'[INSERT INTO c06l03_categories VALUES (30, 'Technology')]', -1);
    expect_error('Duplicate UNIQUE ISBN',
        q'[INSERT INTO c06l03_books (book_id, title, isbn, category_id) VALUES (1003, 'Other', 'ISBN-C06-001', 10)]', -1);
    expect_error('Missing parent category',
        q'[INSERT INTO c06l03_books (book_id, title, category_id) VALUES (1003, 'Orphan', 999)]', -2291);
    expect_error('Negative price CHECK',
        q'[INSERT INTO c06l03_books (book_id, title, price, category_id) VALUES (1003, 'Negative Price', -1, 10)]', -2290);
    expect_error('Invalid rating CHECK',
        q'[INSERT INTO c06l03_reviews VALUES (2, 1001, 6)]', -2290);
    expect_error('Required title NOT NULL',
        q'[INSERT INTO c06l03_books (book_id, title, category_id) VALUES (1003, NULL, 10)]', -1400);
    expect_error('Delete referenced parent',
        q'[DELETE FROM c06l03_categories WHERE category_id = 10]', -2292);
END;
/

PROMPT === Query 02: Verify valid rows remain unchanged ===
COLUMN TABLE_NAME FORMAT A20
SELECT 'CATEGORIES' AS table_name, COUNT(*) AS row_count FROM c06l03_categories
UNION ALL SELECT 'BOOKS', COUNT(*) FROM c06l03_books
UNION ALL SELECT 'REVIEWS', COUNT(*) FROM c06l03_reviews;

PROMPT === Query 03: Inspect sample data ===
COLUMN TITLE FORMAT A30
COLUMN CATEGORY_NAME FORMAT A20
SELECT b.book_id, b.title, b.price, b.stock, c.category_name
FROM c06l03_books b
JOIN c06l03_categories c ON c.category_id = b.category_id
ORDER BY b.book_id;

PROMPT === Lesson 03 complete: practice tables retained for inspection ===
-- No DROP statements are included. Review before any manual cleanup.
