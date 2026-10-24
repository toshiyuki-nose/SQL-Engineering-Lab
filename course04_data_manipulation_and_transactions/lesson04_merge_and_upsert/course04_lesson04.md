# Lesson 04 — MERGE and Upsert

## Overview

The Book Store Database receives updated book information from an external catalog. Some records already exist and need updating; other records are new and need inserting.

In Oracle, `MERGE` can perform both operations in a single statement. This pattern is often called an **upsert** (update + insert).

This lesson uses only temporary training records. The original Book Store Database is preserved.

## Learning Objectives

By the end of this lesson, you should be able to:

1. Explain why upsert operations are useful in ETL and data synchronization.
2. Identify the `MERGE INTO`, `USING`, `ON`, `WHEN MATCHED`, and `WHEN NOT MATCHED` clauses.
3. Update existing rows and insert new rows with one `MERGE`.
4. Validate both matched and unmatched results.
5. Understand source-key uniqueness, retry safety, and transaction boundaries.

## 1. Why MERGE?

A catalog feed may contain:

| BOOK_ID | Existing in BOOKS? | Desired action |
| --- | --- | --- |
| 4901 | Yes | Update price and stock |
| 4902 | Yes | Update price and stock |
| 4903 | No | Insert new book |

Without `MERGE`, an application may need separate `UPDATE` and `INSERT` operations and additional existence checks.

## 2. MERGE Syntax

```sql
MERGE INTO books target
USING (
    SELECT 4901 AS book_id, 3000 AS price, 14 AS stock
    FROM dual
) source
ON (target.book_id = source.book_id)
WHEN MATCHED THEN
    UPDATE SET
        target.price = source.price,
        target.stock = source.stock
WHEN NOT MATCHED THEN
    INSERT (book_id, title, category_id, price, stock, published_year, subtitle)
    VALUES (source.book_id, 'SQL Practice Handbook', 60,
            source.price, source.stock, 2026, NULL);
```

- `MERGE INTO`: the target table to change.
- `USING`: the incoming source data (a query or table).
- `ON`: determines whether source and target rows match.
- `WHEN MATCHED THEN UPDATE`: changes an existing target row.
- `WHEN NOT MATCHED THEN INSERT`: adds a new target row.

**Oracle-specific note:** A column referenced in the `ON` condition cannot be updated in the same `MERGE`. Keep `BOOK_ID` unchanged.

## 3. Prepare the Training Data

Our executable script creates a savepoint and inserts books `4901` and `4902`. Book `4903` is deliberately absent.

The source feed then contains all three IDs. The `MERGE` must update the first two and insert the third.

The source is an inline query built using `UNION ALL` and `DUAL`; no additional staging table is required.

**Note: Simulated Source Catalog**

In this lesson, the external catalog is not a physical database table. Instead, it is simulated using an inline view constructed with `SELECT`, `UNION ALL`, and Oracle's `DUAL` table.

In real-world ETL processes, the source data may come from an actual staging table, such as `STG_BOOKS`.


## 4. Expected Results

Before the merge:

| BOOK_ID | PRICE | STOCK | Status |
| --- | ---: | ---: | --- |
| 4901 | 2800 | 12 | Existing |
| 4902 | 3200 | 8 | Existing |
| 4903 | — | — | Missing |

After the merge:

| BOOK_ID | PRICE | STOCK | Result |
| --- | ---: | ---: | --- |
| 4901 | 3000 | 14 | Updated |
| 4902 | 3400 | 10 | Updated |
| 4903 | 3500 | 5 | Inserted |

SQL*Plus should report **3 rows merged**. That number is the total affected by the `MERGE`; it does not separately report inserted and updated counts.

The script verifies all three final records and then rolls back the training changes.

## 5. MERGE in ETL Pipelines

A typical ETL synchronization flow is:

1. Extract new or changed data from a source system.
2. Clean and validate the incoming rows.
3. Match source records against the target using a stable business or surrogate key.
4. Update matched rows and insert new rows.
5. Validate counts and values before committing.

`MERGE` is common in data warehouses, dimension maintenance, and application data synchronization.

## 6. Important Safety Considerations

### Source-key uniqueness

Each source key should identify at most one source row for the intended target match. Duplicate source keys can cause unstable matching and Oracle errors (including `ORA-30926` in relevant cases). Deduplicate and validate the source before running `MERGE`.

### Repeatability

This lesson uses **absolute assignments** such as `stock = source.stock`, so rerunning the same merge with the same source generally yields the same final values. By contrast, `stock = target.stock + source.stock` would increase stock on every run.

### Constraints

`MERGE` still respects primary keys, foreign keys, and other table constraints. The training rows use the existing `CATEGORIES.CATEGORY_ID = 60`.

### Transactions

A successful `MERGE` is not automatically committed. Use `COMMIT` only after validation. In this lab, the script issues no `COMMIT` and rolls back its temporary changes.

### Avoid broad matching

Always choose a stable `ON` key. Matching on nonunique attributes such as a book title may produce incorrect updates.

## 7. Practice Exercises

1. What is the purpose of the `ON` condition?
2. Which records are updated, and which record is inserted in this lesson?
3. Why is an absolute stock assignment easier to retry safely?
4. What can happen if the source contains duplicate `BOOK_ID` values?
5. Why does the script roll back after validating the results?

## 8. Run the Script

From the repository root, create the lesson and log directories using the **separate PowerShell commands provided in the chat**.

Connect:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Run:

```sql
@course04_data_manipulation_and_transactions/lesson04_merge_and_upsert/lesson04.sql
```

Expected log path:

`course04_data_manipulation_and_transactions/lesson04_merge_and_upsert/logs/lesson04.log`

## Completion Checklist

- [ ] Connection and prerequisites verified.
- [ ] Two existing training books inserted.
- [ ] `MERGE` affected three rows.
- [ ] Two updates and one insert validated.
- [ ] Rollback completed.
- [ ] Training IDs absent after rollback.
- [ ] No SQL or PL/SQL errors.

**Next:** Lesson 05 — Transactions and COMMIT / ROLLBACK.
