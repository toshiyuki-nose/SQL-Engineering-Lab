# Course 05 — Lesson 03: Set Operations

## Overview

This lesson introduces Oracle SQL set operators using the existing Book Store Database. A set operator combines the results of two queries **by column position**, rather than joining rows by a key.

This lab is read-only. Run it as `SQL_LAB` in `FREEPDB1` after completing Course 05 Lessons 01–02.

## Learning Objectives

By the end of this lesson, you should be able to:

1. Distinguish `UNION`, `UNION ALL`, `INTERSECT`, and `MINUS`.
2. Predict when duplicate rows are retained or removed.
3. Write compatible SELECT lists for compound queries.
4. Apply `ORDER BY` to a compound query's final result.
5. Explain why `MINUS` is directional and why row order requires explicit sorting.
6. Compare set operations with a join and recognize when each is appropriate.

## 1. The Four Operators

| Operator | Meaning | Duplicates |
| --- | --- | --- |
| `UNION` | Rows from either query | Removes duplicates |
| `UNION ALL` | Rows from both queries | Keeps duplicates |
| `INTERSECT` | Rows common to both queries | Removes duplicates |
| `MINUS` | Rows in the first query but not the second | Removes duplicates |

For this lesson, use these two overlapping groups:

- **Group A:** Books in category `10` (Technology).
- **Group B:** Books priced at least `3000`.

A book may belong to both groups. Comparing the results of the four operators makes their behavior visible without modifying any rows.

## 2. UNION vs. UNION ALL

`UNION` returns distinct rows across the combined SELECT lists. `UNION ALL` retains repeated rows, so a book appearing in both groups appears twice.

```sql
SELECT book_id FROM books WHERE category_id = 10
UNION
SELECT book_id FROM books WHERE price >= 3000
ORDER BY book_id;
```

The corresponding `UNION ALL` query is identical except for the operator. Both SELECT statements return one compatible numeric column.

**Important:** Set operators compare the **entire selected row**. If you select `book_id` plus a source label such as `'A'` or `'B'`, the two rows for the same book are no longer duplicates because their labels differ.

## 3. INTERSECT

`INTERSECT` returns book IDs present in both groups. This is the overlap: Technology books with a price of at least 3000.

## 4. MINUS

`A MINUS B` returns Technology books that are *not* priced at least 3000. `B MINUS A` asks a different question: books priced at least 3000 that are *not* Technology books.

Unlike `UNION` and `INTERSECT`, `MINUS` is directional.

## 5. Column Compatibility

Each component SELECT must return the same number of expressions in corresponding positions, and the data types must be compatible. For example, combining `BOOK_ID` (numeric) with `TITLE` (character) in the same column position is not a valid compound query.

The output column names come from the first SELECT. Aliases can make the final output clearer.

## 6. ORDER BY and Parentheses

Apply `ORDER BY` **once at the end** of a compound query, rather than within each component SELECT. This lab sorts by the first SELECT's alias or by the output position.

For complex mixtures of set operators, explicitly structure the intended evaluation using subqueries or CTEs instead of depending on implicit precedence. This lesson uses one operator per query.

## 7. NULL and Set Semantics

Set operations treat rows containing corresponding `NULL` values as duplicates for duplicate elimination. This differs from ordinary comparisons such as `NULL = NULL`, which evaluate to unknown. The script demonstrates this with literal SELECTs from `DUAL`.

## 8. Set Operators vs. JOINs

A `JOIN` combines related columns from matching rows. A set operator stacks compatible query results into one result set. For example:

- `JOIN`: show each book with its category name.
- `UNION`: combine IDs from two different selection criteria.

Choose the construct that matches the question, rather than using them interchangeably.

## 9. Exercises

1. Predict whether `UNION ALL` can return more rows than `UNION`.
2. Find books in category `20` or with `stock = 0` using `UNION`.
3. Find books in category `20` **and** with `stock = 0` using `INTERSECT`.
4. Find books in category `20` **but not** with `stock = 0` using `MINUS`.
5. Explain why adding a source-label column changes duplicate elimination.
6. Explain why a final `ORDER BY` is necessary even if the output seems sorted.

## 10. Run the Lab

From the repository root, connect with SQL*Plus:

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Then execute:

```sql
@course05_advanced_sql_queries/lesson03_set_operations/lesson03.sql
```

The script writes its log to:

`course05_advanced_sql_queries/lesson03_set_operations/logs/lesson03.log`

Create the `logs` directory first. Run the script from the repository root so its relative spool path resolves correctly.

## Completion Checklist

- [ ] Environment and required tables verified.
- [ ] Overlapping book groups inspected.
- [ ] `UNION` and `UNION ALL` compared.
- [ ] `INTERSECT` and both directions of `MINUS` executed.
- [ ] Full-row duplicate semantics demonstrated.
- [ ] `NULL` behavior demonstrated.
- [ ] Category and stock exercises executed.
- [ ] All count assertions passed.
- [ ] No unexpected Oracle errors; existing data unchanged.

**Next:** Lesson 04 — Window Functions Basics.
