# Lesson 02 — UPDATE Statements

## Overview

In Lesson 01, we learned how to add rows with `INSERT`. Now we will modify existing rows using `UPDATE`.

**Scenario:** A bookstore needs to correct a book price, replenish inventory, and apply a category-wide stock adjustment. We will work only with temporary training books, then undo all changes to preserve the Course 03 dataset.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Explain the structure of `UPDATE ... SET ... WHERE`.
2. Update one column or several columns in a single statement.
3. Use arithmetic expressions based on current column values.
4. Apply conditional changes using `CASE`.
5. Predict and verify the number of affected rows.
6. Avoid accidental mass updates and restore training changes with `ROLLBACK TO SAVEPOINT`.

## 1. Basic UPDATE Syntax

```sql
UPDATE table_name
SET column_name = new_value
WHERE condition;
```

The `WHERE` clause determines **which rows** are modified. Without `WHERE`, an `UPDATE` applies to every row in the table.

Before updating, run a `SELECT` using the **same condition**:

```sql
SELECT book_id, title, price
FROM books
WHERE book_id = 4901;
```

Then apply the change:

```sql
UPDATE books
SET price = 3000
WHERE book_id = 4901;
```

> **Safety rule:** Check the target rows before executing any `UPDATE`, especially when working with production data.

## 2. Update Multiple Columns

A single `UPDATE` can change several columns:

```sql
UPDATE books
SET price = 3400,
    stock = 15
WHERE book_id = 4902;
```

Use commas between assignments. The `WHERE` clause still controls which rows are affected.

## 3. Update Values Relative to Existing Data

Rather than hard-coding a new stock quantity, calculate it from the current value:

```sql
UPDATE books
SET stock = stock + 5
WHERE book_id = 4903;
```

If the previous stock was `5`, it becomes `10`.

This is useful for inventory adjustments, price changes, and counters. Be careful: rerunning the same statement adds another `5`, so it is **not idempotent**.

## 4. Update Multiple Rows with CASE

`CASE` allows different values to be assigned to different rows:

```sql
UPDATE books
SET stock = CASE
                WHEN stock < 10 THEN stock + 3
                ELSE stock + 1
            END
WHERE book_id IN (4901, 4902, 4903);
```

Each matching row is evaluated using its own current `STOCK` value.

## 5. Verify Affected Rows and Values

SQL*Plus reports the number of rows updated. However, a successful statement does not prove that the **correct** rows were modified.

After each update, inspect the data:

```sql
SELECT book_id, title, price, stock
FROM books
WHERE book_id IN (4901, 4902, 4903)
ORDER BY book_id;
```

For critical applications, the program should also check the affected-row count (`SQL%ROWCOUNT` in PL/SQL) and raise an error if it differs from the expected number.

## 6. Common UPDATE Risks

| Risk | Why it matters | Prevention |
| --- | --- | --- |
| Missing `WHERE` | Every row may be changed | Always review the target predicate |
| Wrong `WHERE` | Unintended rows may be changed | Preview matching rows with `SELECT` |
| Repeated arithmetic update | Values change again on rerun | Design for safe retries |
| Unexpected row count | Data may not match assumptions | Verify counts and values |
| Premature `COMMIT` | Changes become permanent | Validate before committing |

**Important:** `ROLLBACK TO SAVEPOINT` does not undo previously committed work. It only undoes changes made after the named savepoint in the current transaction.

## 7. Practice Script Walkthrough

`lesson02.sql` performs the following sequence:

1. Confirms the connection and checks that practice IDs `4901`–`4903` are unused.
2. Creates a savepoint and inserts three temporary books.
3. Updates a single price.
4. Updates both price and stock for another book.
5. Increases stock using an arithmetic expression.
6. Performs a conditional multi-row update with `CASE`.
7. Validates the expected final values.
8. Rolls back to the savepoint and confirms that all three training rows are gone.

**Expected values immediately before rollback:**

| BOOK_ID | PRICE | STOCK |
| --- | ---: | ---: |
| 4901 | 3000 | 13 |
| 4902 | 3400 | 16 |
| 4903 | 3500 | 11 |

No `COMMIT` is issued. The script uses a fail-fast SQL*Plus error setting so an unexpected SQL error exits with a rollback.

## 8. Exercises

Before looking at the script's answer, try reasoning through these questions:

1. If the `WHERE` clause is removed from an update, what happens?
2. Why is `SET stock = stock + 5` unsafe to rerun blindly?
3. Why is checking only SQL*Plus's “rows updated” message insufficient?
4. How does `CASE` decide which stock adjustment to apply?
5. Why do we insert temporary rows rather than changing existing course books?

## Execution

Run from the repository root. Create the ignored log directory first:

```powershell
New-Item -ItemType Directory -Force course04_data_manipulation_and_transactions/lesson02_update_statements/logs | Out-Null
sqlplus sql_lab@localhost:1521/FREEPDB1
```

In SQL*Plus:

```sql
@course04_data_manipulation_and_transactions/lesson02_update_statements/lesson02.sql
```

Review `course04_data_manipulation_and_transactions/lesson02_update_statements/logs/lesson02.log`.

## Completion Checklist

- [ ] Prerequisite checks passed.
- [ ] Single-row and multi-column updates worked.
- [ ] Arithmetic and `CASE` updates produced expected values.
- [ ] Final validation passed.
- [ ] Rollback removed the temporary books.
- [ ] No SQL or PL/SQL errors occurred.

**Next:** Lesson 03 — DELETE Statements.
