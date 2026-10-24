# Course 05 — Lesson 05: Advanced Window Functions

## Learning objectives

By the end of this lesson, you will be able to:

1. Retrieve preceding and following rows with `LAG` and `LEAD`.
2. Calculate price differences within a category.
3. Produce running totals using `SUM(...) OVER (...)`.
4. Calculate moving averages using explicit window frames.
5. Distinguish `ROWS` frames from the default frame behavior when `ORDER BY` is present.
6. Validate analytic results without modifying the Book Store Database.

## Prerequisites

- Oracle Database Free 23ai and SQL*Plus.
- Connect to `FREEPDB1` as `SQL_LAB`.
- Existing `BOOKS` and `CATEGORIES` tables and sample rows.
- Course 05, Lesson 04 (Window Functions Basics).

## 1. Window ordering versus output ordering

The `ORDER BY` inside `OVER (...)` defines the order used for an analytic calculation. The final `ORDER BY` controls how result rows are displayed. They serve different purposes.

For reproducible results, use a unique tie-breaker such as `BOOK_ID` in analytic ordering.

## 2. LAG and LEAD

`LAG(price)` returns a price from an earlier row in the analytic ordering; `LEAD(price)` returns one from a later row. At partition boundaries, the result is `NULL` unless a default is provided.

```sql
SELECT book_id, category_id, price,
       LAG(price) OVER (
         PARTITION BY category_id
         ORDER BY price DESC NULLS LAST, book_id
       ) AS previous_price
FROM books;
```

Here, *previous* means the preceding row in **descending price order**, not the previous book entered into the database.

## 3. Price differences

Subtracting `LAG(price)` from `price` produces the change from the preceding ranked book. The first book in each category has no preceding book and therefore produces `NULL`.

## 4. Running totals

Use an explicit `ROWS` frame to calculate a row-by-row running total:

```sql
SUM(price) OVER (
  PARTITION BY category_id
  ORDER BY price DESC NULLS LAST, book_id
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

The running total resets for each category.

## 5. Moving averages

The following expression averages the current book and up to two preceding books:

```sql
AVG(price) OVER (
  PARTITION BY category_id
  ORDER BY price DESC NULLS LAST, book_id
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

At the beginning of a partition, fewer than three rows are available, so Oracle averages the available rows.

## 6. Explicit window frames matter

With an analytic `ORDER BY`, the default frame for many aggregate analytic functions is logically based on `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Rows with equal ordering values can be treated as peers. `ROWS` instead uses physical row positions in the defined order. This lesson demonstrates the difference with a small inline sample that contains ties.

## 7. Window totals versus GROUP BY totals

A full-partition window total retains every book row:

```sql
SUM(price) OVER (PARTITION BY category_id)
```

A `GROUP BY category_id` query produces one row per category. Both can return the same numeric category total while differing in row count.

## 8. Running the lesson

From the repository root, connect with:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Then run:

```sql
@course05_advanced_sql_queries/lesson05_advanced_window_functions/lesson05.sql
```

The script writes its log to:

`course05_advanced_sql_queries/lesson05_advanced_window_functions/logs/lesson05.log`

Create the `logs` directory before running the script. Execute SQL*Plus from the repository root so relative paths resolve correctly.

## 9. Review checklist

- [ ] Connection is `SQL_LAB` / `FREEPDB1`.
- [ ] `BOOKS` contains 15 sample rows (or the expected current sample count).
- [ ] `LAG` and `LEAD` reset at category boundaries.
- [ ] Running totals are nondecreasing for the existing nonnegative prices.
- [ ] Moving averages use at most three rows.
- [ ] The tied-price example demonstrates `ROWS` versus `RANGE`.
- [ ] Final PL/SQL validation passes.
- [ ] No persistent data is modified.

## Notes

- `NULL` prices are ignored by `SUM` and `AVG`; the current dataset uses non-NULL prices.
- Analytic calculations are not guaranteed to be faster than alternative queries. Examine execution plans when performance matters.
- The lesson uses `SELECT` statements and anonymous PL/SQL verification only; it does not perform DML or DDL.
