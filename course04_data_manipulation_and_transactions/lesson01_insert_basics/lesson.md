# Lesson 01 — INSERT Basics

## Overview

Course 03 taught us how the Book Store Database relates books, categories, and authors. In Course 04, we begin modifying data. This lesson introduces `INSERT` and the checks needed to add rows safely.

**Scenario:** The bookstore has received new titles and needs to register them in `BOOKS`. We will insert temporary training records, inspect them, and roll them back so the baseline dataset remains unchanged.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Explain the basic structure of `INSERT INTO ... VALUES`.
2. Use explicit column lists and understand omitted nullable columns.
3. Insert multiple rows using Oracle's `INSERT ALL` syntax.
4. Check candidate primary keys and foreign-key values before inserting.
5. Verify inserted rows using `SELECT` and `COUNT(*)`.
6. Undo uncommitted practice inserts with `ROLLBACK TO SAVEPOINT`.

## 1. The `INSERT` Statement

Use `INSERT` to add rows to an existing table:

```sql
INSERT INTO table_name (column_a, column_b)
VALUES (value_a, value_b);
```

The columns and values must correspond in number and order. Prefer an **explicit column list**: it documents your intent and protects the statement from changes in table column order.

For the Book Store Database, relevant columns are:

| Column | Purpose |
| --- | --- |
| `BOOK_ID` | Primary key identifying a book |
| `TITLE` | Book title |
| `CATEGORY_ID` | Foreign key referencing `CATEGORIES` |
| `PRICE` | Book price |
| `STOCK` | Available stock |
| `PUBLISHED_YEAR` | Publication year |
| `SUBTITLE` | Optional subtitle |

## 2. Pre-insert Validation

Before inserting, confirm that the practice IDs are not already used:

```sql
SELECT book_id, title
FROM books
WHERE book_id IN (4901, 4902, 4903)
ORDER BY book_id;
```

Expected result in the course baseline: **no rows**. If any rows appear, stop and investigate; do not overwrite or delete them.

Also confirm that the category exists:

```sql
SELECT category_id, category_name
FROM categories
WHERE category_id = 60;
```

The Course 03 Lesson 04 setup introduced category `60` (`Reference`). A book referencing a missing category would violate the foreign key.

## 3. Insert One Book

```sql
INSERT INTO books
    (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES
    (4901, 'SQL Practice Handbook', 60, 2800, 12, 2026, NULL);
```

`NULL` represents an unknown or absent subtitle. If a column is nullable and has no required value, you may omit it from the column list; however, explicitly specifying `NULL` can make a teaching example clearer.

## 4. Insert Multiple Books

Oracle supports multi-table insert syntax. We can use `INSERT ALL` to add multiple rows to the **same** table:

```sql
INSERT ALL
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4902, 'Relational Data Workbook', 60, 3200, 8, 2025, 'Exercises and Examples')
    INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (4903, 'Database Operations Guide', 60, 3500, 5, 2026, NULL)
SELECT 1 FROM dual;
```

The final `SELECT` supplies one source row, causing each `INTO` clause to execute once. This is an Oracle-specific form; multi-row insertion syntax differs among database systems.

## 5. Verify the Result

```sql
SELECT book_id, title, category_id, price, stock, published_year, subtitle
FROM books
WHERE book_id BETWEEN 4901 AND 4903
ORDER BY book_id;
```

Expected: **three** practice books. Confirm the count separately:

```sql
SELECT COUNT(*) AS practice_book_count
FROM books
WHERE book_id IN (4901, 4902, 4903);
```

Expected count: `3`.

## 6. Constraints and Common Errors

| Situation | Typical Oracle error | Explanation |
| --- | --- | --- |
| Duplicate `BOOK_ID` | `ORA-00001` | A unique or primary-key constraint was violated |
| Missing referenced `CATEGORY_ID` | `ORA-02291` | The foreign-key parent row does not exist |
| Missing required value | `ORA-01400` | A `NOT NULL` column received `NULL` |
| Too many characters | `ORA-12899` | A value exceeds its column size |

These are **illustrative errors**, not operations the main script intentionally triggers. Do not change the production-like baseline just to reproduce them.

## 7. Transactions and Cleanup

`INSERT` changes are transactional. In this lesson we create a savepoint before inserting, then return to it after verification:

```sql
SAVEPOINT lesson01_start;
-- Perform practice inserts and verification.
ROLLBACK TO SAVEPOINT lesson01_start;
```

A savepoint allows the lesson to undo its own changes without issuing a full-session `ROLLBACK`. **Do not run `COMMIT` between the savepoint and cleanup.** If you have other pending changes in the same session, finish or isolate that work before running this lesson.

The script checks that the practice IDs are absent again after rollback. Transaction visibility, `COMMIT`, and `ROLLBACK` will be studied more deeply in Lesson 05.

## 8. Hands-on Execution

From the repository root in PowerShell:

```powershell
New-Item -ItemType Directory -Force course04_data_manipulation_and_transactions/lesson01_insert_basics/logs | Out-Null
sqlplus sql_lab@localhost:1521/FREEPDB1
```

After entering the password, run this command inside SQL*Plus:

```sql
@course04_data_manipulation_and_transactions/lesson01_insert_basics/lesson01.sql
```

The script writes to `course04_data_manipulation_and_transactions/lesson01_insert_basics/logs/lesson01.log`. Run SQL*Plus from the repository root so the relative path resolves correctly.

**Safety:** The script assumes that IDs `4901`–`4903` are unused and that category `60` exists. It stops before inserting if those prerequisites fail. It does not commit any data.

## 9. Practice Questions

1. Why is an explicit column list preferable to `INSERT INTO books VALUES (...)`?
2. What would happen if you inserted a book using a nonexistent `CATEGORY_ID`?
3. How does `INSERT ALL` differ from a single-row `INSERT`?
4. Why do we verify both the inserted rows and their count?
5. Why should `COMMIT` not be issued before the cleanup in this lesson?

## Completion Checklist

- [ ] Verified the connection and active schema.
- [ ] Confirmed that the practice IDs were initially unused.
- [ ] Confirmed that category `60` exists.
- [ ] Inserted three practice rows successfully.
- [ ] Verified the inserted data and row count.
- [ ] Rolled back the practice changes and confirmed zero remaining practice rows.
- [ ] Reviewed `logs/lesson01.log` for SQL errors.

## Next Lesson

**Lesson 02 — UPDATE Statements:** change selected rows safely using `UPDATE`, `SET`, and `WHERE`.
