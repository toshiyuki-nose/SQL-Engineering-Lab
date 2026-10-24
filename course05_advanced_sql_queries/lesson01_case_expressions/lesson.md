# Lesson 01 — CASE Expressions

## Overview

SQL queries often need to translate raw values into business-friendly labels. In this lesson, use Oracle's `CASE` expression to classify books by price, describe inventory status, handle missing values, and summarize book counts by category.

All exercises use **read-only SELECT statements** against the Book Store Database. No permanent objects or rows are created, updated, or deleted.

## Learning Objectives

After completing this lesson, you should be able to:

1. Explain the difference between **searched CASE** and **simple CASE**.
2. Apply conditions in the correct order.
3. Handle `NULL` values explicitly with `IS NULL`.
4. Create readable business labels from book prices and stock levels.
5. Use `CASE` inside an aggregate expression to calculate conditional counts.
6. Distinguish row-level classification from group-level aggregation.

## 1. Prerequisites and Data Model

Connect as `SQL_LAB` to PDB `FREEPDB1`. The script verifies that the `BOOKS` and `CATEGORIES` tables exist and that `BOOKS` contains records.

Relevant columns:

| Table | Column | Purpose |
| --- | --- | --- |
| `BOOKS` | `BOOK_ID` | Unique book identifier |
| `BOOKS` | `TITLE` | Book title; nullable in the current schema |
| `BOOKS` | `CATEGORY_ID` | Category foreign key |
| `BOOKS` | `PRICE` | Book price |
| `BOOKS` | `STOCK` | Available stock |
| `BOOKS` | `PUBLISHED_YEAR` | Publication year |
| `CATEGORIES` | `CATEGORY_ID` | Category identifier |
| `CATEGORIES` | `CATEGORY_NAME` | Category label |

**Important:** `BOOKS.TITLE` is nullable in this repository. Do not assume it has a `NOT NULL` constraint.

## 2. Searched CASE

A searched `CASE` evaluates Boolean conditions in order and returns the result for the **first true** condition.

```sql
CASE
    WHEN price IS NULL THEN 'Price unknown'
    WHEN price < 2000 THEN 'Budget'
    WHEN price < 4000 THEN 'Standard'
    ELSE 'Premium'
END AS price_band
```

The second and third branches only apply after earlier conditions fail. A price of exactly `2000` belongs to `Standard`, and exactly `4000` belongs to `Premium`.

### Why order matters

Putting `WHEN price < 4000` before `WHEN price < 2000` would classify all budget books as standard. Write conditions from specific to general, and check boundary values.

## 3. Simple CASE

A simple `CASE` compares one expression against fixed values:

```sql
CASE category_id
    WHEN 60 THEN 'Reference category'
    ELSE 'Other category'
END AS category_label
```

Use simple `CASE` for equality comparisons. Use searched `CASE` for ranges, `IS NULL`, and combined conditions.

## 4. Handling NULL and Missing Values

`NULL` is not equal to any value, including another `NULL`. For a searched `CASE`, test missing values with `IS NULL`, not `= NULL`.

```sql
CASE
    WHEN title IS NULL THEN '[Untitled]'
    ELSE title
END AS display_title
```

A `CASE` expression without `ELSE` returns `NULL` when no branch matches. Adding `ELSE` makes classifications easier to interpret.

## 5. Stock Status

Use `CASE` to transform stock into operational labels:

```sql
CASE
    WHEN stock IS NULL THEN 'Unknown'
    WHEN stock <= 0 THEN 'Out of stock'
    WHEN stock < 5 THEN 'Low stock'
    ELSE 'Available'
END AS stock_status
```

The thresholds are **training rules**, not pre-existing database constraints or official business policies.

## 6. Conditional Aggregation

`CASE` can be used inside `SUM` to count rows meeting a condition:

```sql
SELECT
    category_id,
    COUNT(*) AS total_books,
    SUM(CASE WHEN stock > 0 THEN 1 ELSE 0 END) AS in_stock_books
FROM books
GROUP BY category_id
ORDER BY category_id;
```

Each row contributes `1` when the condition is true and `0` otherwise. `COUNT(*)` counts all rows, including rows with null values in individual columns.

## 7. CASE with JOIN and GROUP BY

Join `BOOKS` to `CATEGORIES` to display readable category names. Conditional aggregation can then answer questions such as:

- How many books are in each category?
- How many are out of stock?
- How many are premium-priced under our training thresholds?

When grouping, include nonaggregated selected columns in the `GROUP BY` clause.

## 8. Practice Exercises

1. Change the training price bands to: below 1500, 1500–2999.99, and 3000 or more. Explain where a price of exactly 3000 belongs.
2. Add a new stock label for `stock >= 20` called `Well stocked`. Put the branch in the correct order.
3. List the book IDs and titles for which `TITLE` is `NULL`, if any. Why should the query still work when there are no matching rows?
4. Count the number of books priced at least 4000 in each category.
5. Explain why `SUM(CASE WHEN stock > 0 THEN 1 ELSE 0 END)` and `COUNT(*)` may differ.

## 9. Execution

Create the lesson directory and its `logs` directory using the PowerShell commands provided separately in the chat.

From the repository root:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

In SQL*Plus:

```sql
@course05_advanced_sql_queries/lesson01_case_expressions/lesson01.sql
```

Log output:

`course05_advanced_sql_queries/lesson01_case_expressions/logs/lesson01.log`

The script includes environment and table checks, then runs read-only demonstrations. The exact result rows depend on the Book Store Database data currently present.

## Completion Checklist

- [ ] Environment and prerequisite checks passed.
- [ ] Searched CASE price bands returned expected classifications.
- [ ] Simple CASE returned category labels.
- [ ] NULL handling was understood.
- [ ] Stock status labels were verified.
- [ ] Conditional aggregation was reviewed.
- [ ] No unexpected Oracle errors appeared in the execution log.
- [ ] No data was modified.
