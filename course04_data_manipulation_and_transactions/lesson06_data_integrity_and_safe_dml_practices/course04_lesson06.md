# Lesson 06 — Data Integrity and Safe DML Practices

## Overview

The final lesson of Course 04 combines SQL data manipulation with safeguards that protect a relational database. Using the Book Store Database, we will verify **primary key**, **foreign key**, and **NOT NULL** constraints, then apply a safe update-and-delete workflow.

This lab uses temporary book IDs `6901`–`6903` and a dedicated practice table, `LESSON06_REQUIRED_TITLE`, for the NOT NULL test. Book changes are rolled back, and the practice table is dropped at the end. **Oracle DDL performs implicit commits**, so run this script in a fresh, dedicated SQL*Plus session with no unrelated uncommitted work.

## Learning Objectives

By the end of this lesson, you should be able to:

1. Explain how database constraints preserve data integrity.
2. Recognize Oracle errors for duplicate primary keys, invalid foreign keys, and NULL values in required columns.
3. Validate the target of a DML statement before changing it.
4. Check the exact number of affected rows using `SQL%ROWCOUNT`.
5. Use a savepoint and rollback to leave the training database unchanged.

## 1. Data Integrity in the Book Store Database

The existing schema includes these relationships:

| Table | Integrity rule | Why it matters |
| --- | --- | --- |
| `BOOKS` | `BOOK_ID` is the primary key | Prevents duplicate book identifiers |
| `BOOKS` | `CATEGORY_ID` references `CATEGORIES` | Prevents assigning a nonexistent category |
| `LESSON06_REQUIRED_TITLE` (practice table) | `TITLE` is `NOT NULL` | Demonstrates rejecting a missing title without changing the existing `BOOKS` schema |
| `BOOK_AUTHORS` | References `BOOKS` and `AUTHORS` | Preserves book–author relationships |

> In this repository's current schema, `BOOKS.TITLE` allows `NULL` (`NULLABLE = Y`). We intentionally **do not modify `BOOKS` or earlier lessons**. Instead, the lab creates a separate table with `TITLE NOT NULL`, tests it, and drops the table after verification.

### Primary key constraint

A primary key uniquely identifies a row. Trying to insert a second book with the same `BOOK_ID` raises `ORA-00001` (unique constraint violated).

### Foreign key constraint

A foreign key ensures a referenced parent row exists. Trying to insert a book with a nonexistent `CATEGORY_ID` raises `ORA-02291` (parent key not found).

### NOT NULL constraint

A required column cannot contain `NULL`. Inserting a row with a NULL title into the dedicated practice table raises `ORA-01400` (cannot insert NULL). This does **not** imply `BOOKS.TITLE` has a NOT NULL constraint.

## 2. Expected Errors Are Part of the Exercise

The script intentionally tests invalid INSERT statements. Rather than allowing SQL*Plus to terminate, each test runs inside a PL/SQL block with an exception handler that:

1. Verifies the **specific expected Oracle error code**.
2. Prints a confirmation message if the correct constraint blocked the change.
3. Raises an error if the INSERT unexpectedly succeeds or fails for another reason.

This approach tests integrity rules without treating expected constraint violations as lab failures.

## 3. Safe DML Workflow

Use the following sequence when changing data:

1. **Confirm the environment**: user, PDB, schema.
2. **Inspect the target** with `SELECT` using the intended predicate.
3. **Use a precise `WHERE` clause**, preferably on a primary key.
4. **Check `SQL%ROWCOUNT`** immediately after `UPDATE` or `DELETE` inside PL/SQL.
5. **Verify final values** with a separate query or assertion.
6. **Commit only after approval**; otherwise roll back.

Example of checking an UPDATE's row count:

```sql
BEGIN
    UPDATE books
    SET stock = 9
    WHERE book_id = 6901;

    IF SQL%ROWCOUNT <> 1 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Expected exactly one updated row.');
    END IF;
END;
/
```

`SQL%ROWCOUNT` describes the **most recent implicit SQL statement**. Capture or test it immediately after the relevant DML statement, before another SQL statement changes its value.

## 4. Safe Practice Scenario

The script follows this sequence:

| Step | Action | Expected result |
| --- | --- | --- |
| 1 | Check schema, training IDs, and absence of a leftover practice table | Prerequisites passed |
| 2 | Create `LESSON06_REQUIRED_TITLE` with `TITLE NOT NULL` | Practice table created (implicit commit) |
| 3 | Create savepoint and insert book `6901` | 1 row inserted |
| 4 | Try duplicate `BOOK_ID = 6901` | `ORA-00001` caught and verified |
| 5 | Try nonexistent category `999999` | `ORA-02291` caught and verified |
| 6 | Try a NULL `TITLE` in the practice table | `ORA-01400` caught and verified |
| 7 | Preview and update book `6901` | Exactly 1 row updated; stock = 9 |
| 8 | Preview and delete book `6901` | Exactly 1 row deleted |
| 9 | Roll back to the savepoint | No training books remain |
| 10 | Verify cleanup, then drop the practice table | No training books or practice table remain |

All intentionally invalid statements use `BOOK_ID` values in the reserved practice range and must fail before inserting a row.

## 5. DELETE Safety and Referential Integrity

In the Book Store Database, `BOOK_AUTHORS` stores relationships between books and authors. Deleting a book that is referenced by `BOOK_AUTHORS` may be blocked by its foreign key, depending on the constraint's delete rule. Never assume child rows are removed automatically.

The executable lab inserts no `BOOK_AUTHORS` rows for its temporary book, so its final DELETE does not disturb relationship data.

## 6. Transaction Safety

After creating the dedicated practice table, the script begins its book-data changes with:

```sql
SAVEPOINT lesson06_start;
```

After all demonstrations, it executes:

```sql
ROLLBACK TO SAVEPOINT lesson06_start;
```

The book changes occur after the savepoint and are rolled back before the practice table is dropped. **No explicit `COMMIT` is issued**, but Oracle automatically commits before and after successful `CREATE TABLE` and `DROP TABLE` statements. The script therefore requires a dedicated session; `ROLLBACK` cannot undo DDL.

> Important: Run the script in a **new dedicated SQL*Plus session**. DDL implicitly commits any prior transaction. The `WHENEVER SQLERROR ... ROLLBACK` setting rolls back pending DML on unexpected SQL errors, but **cannot undo CREATE/DROP TABLE**. If execution stops before cleanup, the practice table may remain; do not rerun until its state is reviewed.

## 7. Practice Questions

1. Why is `BOOK_ID` a better predicate than `TITLE` when changing exactly one book?
2. What is the difference between `ORA-00001` and `ORA-02291`?
3. Why should an exception handler check `SQLCODE` instead of catching every error indiscriminately?
4. What could happen if a `DELETE` statement omits `WHERE`?
5. Why should `SQL%ROWCOUNT` be checked immediately after DML?
6. When is it appropriate to issue `COMMIT` in a real application?

## 8. Execution

Create the lesson and `logs` directories using the **separate PowerShell commands provided in the chat**. From the repository root, connect:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Then execute:

```sql
@course04_data_manipulation_and_transactions/lesson06_data_integrity_and_safe_dml_practices/lesson06.sql
```

Expected output file:

`course04_data_manipulation_and_transactions/lesson06_data_integrity_and_safe_dml_practices/logs/lesson06.log`

## Completion Checklist

- [ ] Prerequisite checks passed.
- [ ] Duplicate primary key test verified `ORA-00001`.
- [ ] Invalid foreign key test verified `ORA-02291`.
- [ ] Dedicated practice table NOT NULL test verified `ORA-01400`.
- [ ] Exactly one training book updated and deleted.
- [ ] Savepoint rollback completed.
- [ ] Training IDs absent and `LESSON06_REQUIRED_TITLE` dropped at the end.
- [ ] No unexpected Oracle errors.

**Course 04 complete:** INSERT, UPDATE, DELETE, MERGE, transactions, and safe DML practices.
