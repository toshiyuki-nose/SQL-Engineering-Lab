# Course 05 — Advanced SQL Queries
# Lesson 02 — Common Table Expressions (CTEs)

## Overview

A **Common Table Expression (CTE)** is a named query block defined with the `WITH` clause. It helps divide a complex SQL statement into understandable steps. In Oracle Database, a CTE can be referenced by the main query and by later CTEs in the same statement.

In this lesson, we use the existing **Book Store Database** to build book-price reports, category summaries, and inventory reports without changing any data.

## Learning Objectives

By the end of this lesson, you should be able to:

1. Write a non-recursive CTE using `WITH name AS (SELECT ...)`.
2. Filter and aggregate the results of a CTE.
3. Define multiple CTEs and use earlier CTEs in later query blocks.
4. Combine CTEs with `JOIN`, `LEFT JOIN`, `GROUP BY`, and `CASE`.
5. Explain the scope of a CTE and distinguish readability from performance.

## Prerequisites

- Course 01–04 completed.
- Course 05 Lesson 01 (CASE Expressions) completed.
- Connected as `SQL_LAB` to the `FREEPDB1` pluggable database.
- Existing `BOOKS` and `CATEGORIES` tables with sample data.

No tables are created or changed in this lesson. All examples use `SELECT`.

## 1. What Is a CTE?

A basic CTE follows this pattern:

```sql
WITH affordable_books AS (
    SELECT book_id, title, price
    FROM books
    WHERE price < 3000
)
SELECT book_id, title, price
FROM affordable_books
ORDER BY price, book_id;
```

The CTE `affordable_books` names the result of the inner query. The outer query can select from it as though it were a temporary query result. It is **not** a permanently stored table or view.

### Scope

A CTE belongs to **one SQL statement**. To use the same logic in a later, separate statement, define the CTE again (or consider a view in a future course).

## 2. CTE Versus an Inline View

An inline view is a subquery in the `FROM` clause:

```sql
SELECT x.book_id, x.title, x.price
FROM (
    SELECT book_id, title, price
    FROM books
    WHERE price < 3000
) x
ORDER BY x.price, x.book_id;
```

Both patterns can express the same result. A CTE gives the intermediate result a meaningful name, which can be helpful when a query contains several stages.

## 3. Multiple CTEs

Separate CTE definitions with commas. A later CTE can reference an earlier CTE:

```sql
WITH book_prices AS (
    SELECT book_id, title, category_id, price
    FROM books
    WHERE price IS NOT NULL
),
category_average AS (
    SELECT category_id, AVG(price) AS avg_price
    FROM book_prices
    GROUP BY category_id
)
SELECT b.book_id, b.title, b.price, a.avg_price
FROM book_prices b
JOIN category_average a ON a.category_id = b.category_id
WHERE b.price > a.avg_price
ORDER BY b.category_id, b.price DESC, b.book_id;
```

The first CTE prepares the data; the second calculates category averages; the final query compares each book against its category average.

## 4. Reuse Lesson 01: CASE Expressions

A CTE can create a derived value, such as an inventory status:

```sql
WITH classified_books AS (
    SELECT book_id, category_id,
           CASE
               WHEN stock IS NULL THEN 'Unknown'
               WHEN stock <= 0 THEN 'Out of stock'
               WHEN stock < 5 THEN 'Low stock'
               ELSE 'Available'
           END AS stock_status
    FROM books
)
SELECT category_id, stock_status, COUNT(*) AS book_count
FROM classified_books
GROUP BY category_id, stock_status
ORDER BY category_id, stock_status;
```

This avoids repeating the complete `CASE` expression in the grouping query.

## 5. Preserve Categories with No Books

The `CATEGORIES` table includes the `Reference` category, which may have no books. A `LEFT JOIN` allows the report to retain such categories.

When using a left join, `COUNT(b.book_id)` counts matching books while `COUNT(*)` counts the joined row, including a row with no matching book. For empty categories, use `COUNT(b.book_id)`.

## 6. Readability and Performance

CTEs improve the structure of a query, but **do not automatically make it faster**. Oracle's optimizer may merge a CTE into the surrounding query or choose another execution strategy. Later courses will examine execution plans and tuning.

Good habits:

- Give each CTE a name that describes its business purpose.
- Select only the columns needed by later stages.
- Use explicit join conditions.
- Check the effect of `NULL` values on comparisons and averages.
- Include `ORDER BY` in the final query when the output order matters.

## 7. Lab Walkthrough

Run `lesson02.sql` to explore:

| Step | Exercise | Expected observation |
| --- | --- | --- |
| 1 | Verify connection and required tables | `SQL_LAB`, `FREEPDB1`, and the Book Store tables |
| 2 | Basic CTE | Books priced below 3,000 |
| 3 | Inline view comparison | Same result as Step 2 |
| 4 | CTE with aggregation | Average price and book count by category |
| 5 | Two chained CTEs | Books above their own category average |
| 6 | CTE with CASE | Stock status calculated once |
| 7 | CTE with LEFT JOIN | All categories, including those with zero books |
| 8 | Multiple CTEs for a business report | Category inventory and premium-book metrics |
| 9 | Verification | Category counts total the number of books |

**Note:** Exact counts depend on the current sample data. The lab does not hard-code the expected number of books.

## 8. Practice Questions

1. What does `WITH` make easier to understand compared with a deeply nested query?
2. Can a CTE defined in one statement be referenced by the next statement?
3. Why does the above-category-average report require a category-level aggregate?
4. Why is `COUNT(b.book_id)` preferable to `COUNT(*)` for an empty category in a left join?
5. Does a CTE guarantee that Oracle stores its intermediate results?
6. How does a CTE help avoid repeating a long `CASE` expression?

### Optional Challenge

Build a report that lists each category's name, total book count, number of books with stock between 1 and 4, and average price. Include categories with no books and sort by category ID. Use at least one CTE.

## 9. Execution

From the repository root (`E:\SQL\SQL-Engineering-Lab`), connect to SQL*Plus:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Then run:

```sql
@course05_advanced_sql_queries/lesson02_common_table_expressions/lesson02.sql
```

Log file:

`course05_advanced_sql_queries/lesson02_common_table_expressions/logs/lesson02.log`

Create the `logs` folder before running the script. SQL*Plus resolves the relative spool path from the current working directory.

## Completion Checklist

- [ ] Connection and table checks pass.
- [ ] Basic CTE and inline-view outputs match.
- [ ] Category average queries return plausible results.
- [ ] Category with no books remains in the LEFT JOIN report.
- [ ] Book-count verification passes.
- [ ] No unexpected Oracle errors.
- [ ] Execution log saved for review.
