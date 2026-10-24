# Lesson 03 — DELETE Statements

## Overview

In Lesson 01, we inserted records. In Lesson 02, we updated records. This lesson covers how to **remove rows safely** using `DELETE`.

Our continuing Book Store Database contains `BOOKS`, `CATEGORIES`, `AUTHORS`, and `BOOK_AUTHORS`. We will use temporary book records so the original course data is preserved.

## Learning Objectives

- Use `DELETE FROM ... WHERE` to delete specific rows.
- Preview target rows before deletion.
- Understand the danger of omitting `WHERE`.
- Verify deleted row counts and remaining data.
- Understand how foreign keys affect deletion.
- Restore uncommitted deletions using `ROLLBACK TO SAVEPOINT`.

## 1. Basic DELETE Syntax

```sql
DELETE FROM books
WHERE book_id = 4901;
```

`DELETE` removes **rows**, not individual column values. To clear a column value without removing a row, use `UPDATE ... SET column = NULL` when permitted.

**Important:** `DELETE FROM books;` without a `WHERE` clause attempts to delete every row. Never execute it casually.

## 2. Preview Before You Delete

Always confirm which rows match your condition:

```sql
SELECT book_id, title
FROM books
WHERE book_id = 4901;
```

Then run `DELETE` with the same predicate and verify the result:

```sql
DELETE FROM books WHERE book_id = 4901;

SELECT COUNT(*) AS remaining
FROM books
WHERE book_id = 4901;
```

The expected remaining count is `0`.

## 3. Delete Multiple Rows

Use `IN` to delete a known set of records:

```sql
DELETE FROM books
WHERE book_id IN (4902, 4903);
```

In our practice script, these are temporary books inserted during the lesson.

## 4. Foreign Keys and Delete Order

The Book Store Database uses a many-to-many relationship between books and authors through `BOOK_AUTHORS`.

A `BOOK_AUTHORS` row references a `BOOKS` row. Deleting a referenced book may fail with `ORA-02292` if the foreign key does not cascade. When cascading is configured, deleting the parent can also delete child rows.

For a safe, explicit approach, remove dependent rows first:

```sql
DELETE FROM book_authors WHERE book_id = 4901;
DELETE FROM books WHERE book_id = 4901;
```

The executable lesson **does not modify `BOOK_AUTHORS`** because its temporary books have no author mappings. It also does not intentionally trigger constraint errors.

## 5. DELETE vs. TRUNCATE vs. DROP

| Statement | Purpose | Transaction note |
| --- | --- | --- |
| `DELETE` | Removes matching rows | DML; uncommitted changes can be rolled back |
| `TRUNCATE TABLE` | Removes all rows from a table | DDL in Oracle; causes implicit commit and cannot be rolled back |
| `DROP TABLE` | Removes the table definition | DDL in Oracle; causes implicit commit |

We use only `DELETE` in this lesson. Do **not** experiment with `TRUNCATE` or `DROP` on course tables.

## 6. Transactions and Safe Practice

The practice script uses:

```sql
SAVEPOINT lesson03_start;
```

It inserts three temporary books, deletes one book, deletes the other two, and checks that none remain. It then executes:

```sql
ROLLBACK TO SAVEPOINT lesson03_start;
```

This undoes the temporary inserts and deletes, leaving the original course data unchanged.

**Note:** Because all three books were inserted *after* the savepoint, they will still be absent after rollback. To demonstrate restoring a deleted **existing** row, you would need a different savepoint sequence. That topic will be explored in Lesson 05.

## 7. Practical Safety Checklist

1. Confirm the correct user, PDB, and schema.
2. Inspect rows with `SELECT` before deleting.
3. Use a precise `WHERE` condition, ideally a primary key.
4. Verify the affected row count.
5. Inspect related child tables and foreign key rules.
6. Validate results before committing.
7. Keep a rollback strategy.

## 8. Practice Exercises

1. What happens if you omit `WHERE` from `DELETE`?
2. How can you verify that exactly one book was deleted?
3. Why can deleting a book with author mappings fail?
4. What is the difference between `DELETE` and `TRUNCATE` in Oracle?
5. Why do we use temporary training IDs?

## Execution

From the repository root, create the log directory:

```powershell
New-Item -ItemType Directory -Force course04_data_manipulation_and_transactions/lesson03_delete_statements/logs | Out-Null
sqlplus sql_lab@localhost:1521/FREEPDB1
```

In SQL*Plus:

```sql
@course04_data_manipulation_and_transactions/lesson03_delete_statements/lesson03.sql
```

The output log is `course04_data_manipulation_and_transactions/lesson03_delete_statements/logs/lesson03.log`.

## Expected Results

- Prerequisite check passed.
- Three temporary books inserted.
- One row deleted by a single-ID `DELETE`.
- Two rows deleted by an `IN` predicate.
- Zero temporary books remain before rollback.
- Rollback completes successfully.
- Zero temporary books remain after rollback.
- No `COMMIT` issued.

**Next:** Lesson 04 — MERGE and Upsert.
