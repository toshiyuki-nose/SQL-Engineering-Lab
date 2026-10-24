# Course 05 — Lesson 04: Window Functions Basics

## Learning objectives

By the end of this lesson, you will be able to:

1. Explain how analytic functions differ from `GROUP BY` aggregates.
2. Use `OVER()` to display a grand total without collapsing detail rows.
3. Use `PARTITION BY` to calculate values within each category.
4. Use `ROW_NUMBER`, `RANK`, and `DENSE_RANK` and explain their tie behavior.
5. Select the highest-priced book in each category using a CTE.
6. Apply deterministic tie-breaking and validate results.

## Prerequisites

- Oracle Database Free, PDB `FREEPDB1`, schema `SQL_LAB`.
- Existing `BOOKS` and `CATEGORIES` tables from previous lessons.
- No DML or DDL is performed. All examples are read-only.

## 1. Aggregate vs. analytic function

A grouped aggregate such as `COUNT(*) ... GROUP BY category_id` returns one row per category. An analytic expression such as `COUNT(*) OVER (PARTITION BY category_id)` keeps every book row and adds its category count.

General form:

```sql
function_name(...) OVER (
    PARTITION BY grouping_column
    ORDER BY sorting_column
)
```

`PARTITION BY` divides the result into independent windows. Without it, the entire result is one window. An analytic `ORDER BY` controls ordering *within* a window; the final result order still requires the query's outer `ORDER BY`.

## 2. Ranking functions

- `ROW_NUMBER()` assigns unique sequential numbers. When sort values tie, include a unique secondary key to make results deterministic.
- `RANK()` assigns the same rank to ties and leaves gaps after ties.
- `DENSE_RANK()` assigns the same rank to ties without gaps.

For prices `4500, 4200, 4200, 3600`, the ranks are:

| Price | ROW_NUMBER | RANK | DENSE_RANK |
|---:|---:|---:|---:|
| 4500 | 1 | 1 | 1 |
| 4200 | 2 | 2 | 2 |
| 4200 | 3 | 2 | 2 |
| 3600 | 4 | 4 | 3 |

`ROW_NUMBER` above assumes a deterministic secondary key for the two tied rows.

## 3. Top N per category

Compute a window function in a CTE, then filter its alias in the outer query:

```sql
WITH ranked_books AS (
    SELECT book_id, title, category_id, price,
           ROW_NUMBER() OVER (
               PARTITION BY category_id
               ORDER BY price DESC NULLS LAST, book_id
           ) AS rn
    FROM books
)
SELECT *
FROM ranked_books
WHERE rn = 1;
```

`ROW_NUMBER = 1` selects exactly one row per nonempty category. `RANK = 1` can select multiple rows if the top price ties.

## 4. Important Oracle details

- Analytic functions are evaluated after `FROM`, `WHERE`, `GROUP BY`, and `HAVING` in the query block; filter analytic aliases in an outer query/CTE.
- Always specify `NULLS LAST` when descending prices and nulls should not be ranked first. Oracle's default null ordering depends on the sort direction.
- An analytic function does not guarantee final display order: use a final `ORDER BY`.
- `COUNT(*) OVER ()` is useful for showing the total number of source rows alongside each detail row.

## 5. Practice workflow

1. Connect to `SQL_LAB` on `FREEPDB1` using SQL*Plus.
2. Run `lesson04.sql` from the repository root.
3. Review the nine numbered sections and the final validation output.
4. Save and submit `logs/lesson04.log` for review.

```powershell
cd E:\SQL\SQL-Engineering-Lab
sqlplus sql_lab@localhost:1521/FREEPDB1
```

```sql
@course05_advanced_sql_queries/lesson04_window_functions_basics/lesson04.sql
```

## Review questions

1. Why does `COUNT(*) OVER (PARTITION BY category_id)` preserve book rows while `GROUP BY` does not?
2. What happens to `RANK` and `DENSE_RANK` when two books share a price?
3. Why should `book_id` be included after `price` in the `ROW_NUMBER` ordering?
4. Why must `rn = 1` be filtered in an outer query?
5. Why is `NULLS LAST` explicit in descending-price rankings?

## Next lesson

Lesson 05 — Advanced Window Functions: `LAG`, `LEAD`, running totals, and explicit window frames.
