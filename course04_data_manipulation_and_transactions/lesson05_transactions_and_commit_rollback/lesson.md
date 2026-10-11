# Lesson 05 — Transactions and COMMIT / ROLLBACK

## Overview

A transaction is a unit of work whose changes can be made permanent with `COMMIT` or discarded with `ROLLBACK`. In this lesson, we use the Book Store Database to practice full rollback, partial rollback with a savepoint, and a successful commit.

**Important:** This lesson intentionally executes `COMMIT`. Run it in a **fresh, dedicated SQL*Plus session** with no unrelated uncommitted work. In Oracle, `COMMIT` commits *all* pending changes in the session, not only changes made by this script.

## Learning Objectives

- Explain the ACID properties of transactions.
- Distinguish `COMMIT`, `ROLLBACK`, and `ROLLBACK TO SAVEPOINT`.
- Understand that a savepoint is not a separate transaction.
- Observe the difference between uncommitted and committed changes.
- Clean up committed training records explicitly.

## 1. ACID Properties

| Property | Meaning |
| --- | --- |
| Atomicity | A transaction's changes are committed or rolled back as a unit. |
| Consistency | Transactions must respect defined integrity constraints. |
| Isolation | Concurrent transactions are controlled so they do not interfere in unintended ways. |
| Durability | Committed changes survive database recovery. |

Oracle's default isolation level is `READ COMMITTED`. A session can see its own uncommitted changes; other sessions normally cannot see them until commit.

## 2. COMMIT and ROLLBACK

```sql
INSERT INTO books (book_id, title, category_id, price, stock, published_year, subtitle)
VALUES (5901, 'Transaction Practice A', 60, 2000, 3, 2026, NULL);

ROLLBACK;
```

After `ROLLBACK`, book `5901` no longer exists. By contrast, `COMMIT` makes pending changes permanent until a later, separate transaction modifies or deletes them.

## 3. SAVEPOINT and Partial Rollback

```sql
SAVEPOINT before_update;
UPDATE books SET stock = 10 WHERE book_id = 5902;
ROLLBACK TO SAVEPOINT before_update;
```

The update is undone, while changes made earlier in the same transaction remain pending. A subsequent full `ROLLBACK` discards those earlier uncommitted changes too.

## 4. Demonstrating a Real COMMIT

The executable script inserts book `5903`, executes `COMMIT`, and checks that the record exists. A subsequent `ROLLBACK` cannot undo the committed insert.

The script then **explicitly deletes book `5903` and commits the cleanup**. This restores the database to its original state while demonstrating that committed data requires a new DML operation to remove it.

**Warning:** If execution stops between the first `COMMIT` and the cleanup `COMMIT`, book `5903` may remain. The script checks that practice IDs are unused before starting. If cleanup is needed, inspect the row first and remove only the specific training ID, as described below.

## 5. Oracle Transaction Boundaries

- `COMMIT` ends the current transaction and makes its changes permanent.
- `ROLLBACK` undoes the current transaction's uncommitted changes.
- `ROLLBACK TO SAVEPOINT` undoes only changes after that savepoint.
- Oracle DDL statements such as `CREATE TABLE`, `TRUNCATE TABLE`, and `DROP TABLE` cause implicit commits; do not use them inside rollback demonstrations.
- A savepoint does not isolate the script from other uncommitted work in the same session.

## 6. Script Scenarios and Expected Results

| Scenario | Action | Expected result |
| --- | --- | --- |
| A | Insert `5901`, then `ROLLBACK` | `5901` absent |
| B | Insert `5902`, set savepoint, update, roll back to savepoint | Original stock restored |
| B continued | Full `ROLLBACK` | `5902` absent |
| C | Insert `5903`, then `COMMIT` | `5903` present |
| C continued | Run `ROLLBACK` after commit | `5903` still present |
| Cleanup | Delete `5903`, then `COMMIT` | All three practice IDs absent |

The script uses `CATEGORIES.CATEGORY_ID = 60`, which was created in Course 03.

## 7. Manual Recovery (Only If Needed)

If the script fails after the first commit, connect as `SQL_LAB` and inspect the training records:

```sql
SELECT book_id, title FROM books
WHERE book_id IN (5901, 5902, 5903);
```

Only after confirming these are this lesson's training rows, clean them up:

```sql
DELETE FROM books WHERE book_id = 5903 AND title = 'Transaction Practice C';
COMMIT;
```

If unexpected rows or other errors appear, stop and review the log before deleting anything.

## 8. Practice Questions

1. Why should this script run in a new SQL*Plus session?
2. Can `ROLLBACK` undo an earlier `COMMIT`?
3. How does `ROLLBACK TO SAVEPOINT` differ from full `ROLLBACK`?
4. Why is the cleanup of `5903` a separate transaction?
5. What does `READ COMMITTED` imply about other sessions seeing uncommitted changes?

## Execution

Create the lesson and logs folders with the separate PowerShell commands supplied in chat. From the repository root:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

In SQL*Plus:

```sql
@course04_data_manipulation_and_transactions/lesson05_transactions_and_commit_rollback/lesson05.sql
```

Log output: `course04_data_manipulation_and_transactions/lesson05_transactions_and_commit_rollback/logs/lesson05.log`.

## Completion Checklist

- [ ] Connected to `SQL_LAB` on `FREEPDB1` in a fresh session.
- [ ] Prerequisite checks passed.
- [ ] Full rollback removed book `5901`.
- [ ] Savepoint rollback restored book `5902` stock.
- [ ] Full rollback removed book `5902`.
- [ ] `COMMIT` preserved book `5903` despite later `ROLLBACK`.
- [ ] Explicit delete and commit removed book `5903`.
- [ ] Final practice-book count is zero.

**Next:** Lesson 06 — Data Integrity and Safe DML Practices.
