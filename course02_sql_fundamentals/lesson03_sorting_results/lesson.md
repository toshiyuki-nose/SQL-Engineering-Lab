# Lesson 03 — Sorting Results

> Learn how to control the order of query results using `ORDER BY`.

---

## Overview

In Lesson 02, we learned how to use the `WHERE` clause to select only the rows
that match specific conditions.

However, retrieving the correct rows is only part of a query.

In many situations, we also need to control the order in which those rows are
displayed.

For example, a bookstore may want to:

- display books from lowest price to highest price,
- show the newest books first,
- show books by category and then by price,
- find books that match a condition and sort the results.

SQL provides the `ORDER BY` clause for this purpose.

In this lesson, we continue using the `BOOKS` table created in Lesson 02.

---

## Learning Objectives

By the end of this lesson, you will be able to:

- understand the purpose of `ORDER BY`,
- sort query results in ascending order,
- sort query results in descending order,
- sort by multiple columns,
- combine `WHERE` and `ORDER BY`,
- sort by a column that is not displayed,
- understand how SQL evaluates the order of query clauses,
- understand why row order should not be assumed without `ORDER BY`.

---

# 1. Recommended Setup

Connect to:

```text
SQL_LAB @ FREEPDB1
```

Before starting, verify the current session.

```sql
SHOW USER
SHOW CON_NAME
```

The expected environment is:

```text
USER
----
SQL_LAB

CON_NAME
--------
FREEPDB1
```

This lesson uses the `BOOKS` table created in Lesson 02.

The table should contain 15 rows.

```sql
SELECT COUNT(*)
FROM books;
```

Expected result:

```text
15
```

---

# 2. Why Do We Need ORDER BY?

Consider the following query:

```sql
SELECT
    book_id,
    title,
    price
FROM books;
```

This query retrieves rows from the `BOOKS` table.

However, the query does **not** specify how those rows should be ordered.

Even if Oracle appears to return the rows in `BOOK_ID` order, that order should
not be treated as guaranteed.

If the order of the result matters, specify it explicitly.

```sql
SELECT
    book_id,
    title,
    price
FROM books
ORDER BY book_id;
```

A useful rule is:

> If the order matters, use `ORDER BY`.

---

# 3. Ascending Order

The default sort direction is ascending.

```sql
SELECT
    title,
    price
FROM books
ORDER BY price;
```

This sorts books from the lowest price to the highest price.

The same query can be written explicitly with `ASC`.

```sql
SELECT
    title,
    price
FROM books
ORDER BY price ASC;
```

These two queries are equivalent.

```text
ORDER BY price
```

and:

```text
ORDER BY price ASC
```

`ASC` means **ascending**.

For numeric values:

```text
small → large
```

For character values, Oracle sorts according to the applicable character
sorting rules.

---

# 4. Descending Order

Use `DESC` to reverse the sort direction.

```sql
SELECT
    title,
    price
FROM books
ORDER BY price DESC;
```

The most expensive books appear first.

`DESC` means **descending**.

For numeric values:

```text
large → small
```

This is useful when looking for:

- highest prices,
- newest years,
- largest quantities,
- highest scores,
- latest values.

---

# 5. Sorting Character Values

`ORDER BY` can also sort character columns.

For example:

```sql
SELECT
    book_id,
    title,
    category
FROM books
ORDER BY category;
```

This sorts the result using the values in `CATEGORY`.

The exact ordering of character data depends on Oracle's sorting and
linguistic settings.

For this lesson, the important idea is that `ORDER BY` is not limited to
numeric columns.

---

# 6. Sorting by Publication Year

Suppose the bookstore wants to display newer books first.

```sql
SELECT
    title,
    published_year
FROM books
ORDER BY published_year DESC;
```

Books published in later years appear before older books.

This is a common pattern in real systems.

For example:

```text
news articles      → newest first
orders             → latest first
products           → highest price first
inventory          → lowest stock first
```

The meaning of the sort depends on the business question.

---

# 7. Sorting by Multiple Columns

Sometimes one column is not enough.

Suppose we want to:

1. group books by category,
2. within each category, display cheaper books first.

We can specify multiple columns.

```sql
SELECT
    title,
    category,
    price
FROM books
ORDER BY
    category ASC,
    price ASC;
```

Oracle first sorts by `CATEGORY`.

When multiple rows have the same category, Oracle then sorts those rows by
`PRICE`.

Conceptually:

```text
CATEGORY
    ↓
PRICE
```

The columns are evaluated from left to right.

---

# 8. Different Sort Directions

Each sort column can have its own direction.

For example:

```sql
SELECT
    title,
    category,
    published_year
FROM books
ORDER BY
    category ASC,
    published_year DESC;
```

This means:

1. sort categories in ascending order,
2. within each category, show newer books first.

The sort direction belongs to each individual expression in the `ORDER BY`
clause.

---

# 9. Combining WHERE and ORDER BY

Lesson 02 introduced `WHERE`.

Now we can combine filtering and sorting.

Suppose we want:

> Technology books that are currently in stock, with the cheapest books shown
> first.

```sql
SELECT
    book_id,
    title,
    price,
    stock
FROM books
WHERE category = 'Technology'
  AND stock > 0
ORDER BY price ASC;
```

The important idea is:

```text
WHERE
    ↓
select the rows

ORDER BY
    ↓
sort the result
```

`WHERE` determines **which rows** are returned.

`ORDER BY` determines **how those rows are displayed**.

---

# 10. Clause Order

When writing a basic query, the clauses appear in a specific order.

```sql
SELECT
    ...
FROM
    ...
WHERE
    ...
ORDER BY
    ...;
```

For example:

```sql
SELECT
    title,
    category,
    price
FROM books
WHERE price >= 2500
ORDER BY price DESC;
```

The written structure is:

```text
SELECT
FROM
WHERE
ORDER BY
```

This ordering is part of SQL syntax.

Do not write:

```sql
SELECT
    title,
    price
FROM books
ORDER BY price DESC
WHERE price >= 2500;
```

That clause order is invalid.

---

# 11. Sorting by a Column Not in SELECT

The column used for sorting does not always have to appear in the displayed
result.

For example:

```sql
SELECT
    book_id,
    title
FROM books
ORDER BY published_year DESC;
```

The result displays:

```text
BOOK_ID
TITLE
```

but Oracle uses `PUBLISHED_YEAR` to determine the order.

This can be useful when a column is needed for processing but does not need to
be shown to the user.

For learning and debugging, however, displaying the sort column can often make
the query easier to understand.

---

# 12. Sorting by Column Alias

A column alias defined in the `SELECT` list can also be referenced by
`ORDER BY`.

```sql
SELECT
    title,
    price AS book_price
FROM books
ORDER BY book_price DESC;
```

Here:

```text
PRICE
```

is displayed as:

```text
BOOK_PRICE
```

and the alias is used for sorting.

This becomes especially useful later when queries contain expressions and
functions.

---

# 13. Sorting by Column Position

SQL also allows the position of a selected column to be used in `ORDER BY`.

For example:

```sql
SELECT
    title,
    category,
    price
FROM books
ORDER BY 3 DESC;
```

Here:

```text
1 = TITLE
2 = CATEGORY
3 = PRICE
```

Therefore:

```sql
ORDER BY 3 DESC
```

means:

```sql
ORDER BY price DESC
```

Although this syntax is compact, it can make queries harder to understand.

If the `SELECT` list changes, the meaning of the position may also change.

For this repository, prefer explicit column names or aliases when readability
matters.

---

# 14. ORDER BY Does Not Change the Table

`ORDER BY` changes the presentation of the query result.

It does **not** rearrange rows physically inside the table.

For example:

```sql
SELECT
    title,
    price
FROM books
ORDER BY price DESC;
```

does not modify the `BOOKS` table.

Like the `SELECT` and `WHERE` operations used so far, this is a read operation.

---

# 15. Deterministic Ordering

Consider:

```sql
SELECT
    title,
    published_year
FROM books
ORDER BY published_year DESC;
```

Several books may have the same `PUBLISHED_YEAR`.

For example, multiple books may have been published in 2022.

`ORDER BY published_year DESC` determines the order between different years,
but it does not fully define the order between rows with the same year.

If a completely predictable order is required, add another sort column.

```sql
SELECT
    book_id,
    title,
    published_year
FROM books
ORDER BY
    published_year DESC,
    book_id ASC;
```

Now `BOOK_ID` acts as a tie-breaker.

This is an important engineering principle:

> When deterministic ordering matters, define enough sort keys to resolve ties.

---

# 16. Building Sorting Queries Incrementally

As queries become more complex, build them step by step.

Start with the data:

```sql
SELECT
    title,
    category,
    price
FROM books;
```

Add the filter:

```sql
SELECT
    title,
    category,
    price
FROM books
WHERE category IN ('Technology', 'Data Science');
```

Then add the sort:

```sql
SELECT
    title,
    category,
    price
FROM books
WHERE category IN ('Technology', 'Data Science')
ORDER BY price ASC;
```

A useful workflow is:

```text
Write
  ↓
Execute
  ↓
Inspect
  ↓
Add a condition or sort
  ↓
Execute again
```

This makes query behavior easier to understand and debug.

---

# 17. Exercises

Use the `BOOKS` table to write each query.

## Exercise 1

Display all books from the lowest price to the highest price.

---

## Exercise 2

Display all books from the highest price to the lowest price.

---

## Exercise 3

Display the newest books first.

Use:

```text
PUBLISHED_YEAR
```

---

## Exercise 4

Display books by category.

Within each category, display books from the lowest price to the highest price.

---

## Exercise 5

Find all `Data Science` books and display the most expensive book first.

---

## Exercise 6

Find books that are currently in stock.

Display the books with the lowest stock first.

---

## Exercise 7

Find books priced at `2500` or more.

Display the highest-priced books first.

---

## Exercise 8

Display:

```text
BOOK_ID
TITLE
```

but sort the result by `PUBLISHED_YEAR` from newest to oldest.

---

## Exercise 9

Use a column alias for `PRICE` and sort using that alias.

---

## Exercise 10 — Business Question

The bookstore wants to review books in the `Technology` and `Data Science`
categories.

Requirements:

- only books currently in stock,
- only books published between 2020 and 2025,
- group the result by category,
- within each category, show the newest books first,
- when multiple books have the same publication year, use `BOOK_ID` as the
  tie-breaker.

Translate the business requirement into one SQL query.

---

# 18. Engineering Notes

## Do not rely on implicit row order

A table should not be treated as if its rows have a guaranteed display order.

Without `ORDER BY`, the database is free to return rows in an order determined
by its execution strategy.

---

## Sort only when order matters

Sorting requires database work.

In real systems, unnecessary sorting can increase query cost, especially when
large result sets are involved.

Use `ORDER BY` when the result requires a defined order.

Query performance will be explored in later courses.

---

## Use explicit sort keys

This:

```sql
ORDER BY price DESC
```

usually communicates intent more clearly than:

```sql
ORDER BY 3 DESC
```

Readable SQL is easier to maintain.

---

## Think in business questions

Do not begin with syntax alone.

Start with a requirement such as:

```text
Show Technology books that are in stock,
with the cheapest books first.
```

Then translate it:

```text
Technology
    → WHERE category = 'Technology'

in stock
    → AND stock > 0

cheapest first
    → ORDER BY price ASC
```

SQL becomes easier to design when each part of the requirement is translated
into an explicit condition or operation.

---

# 19. Lesson Summary

In this lesson, you learned how to control the order of query results.

You practiced:

```text
ORDER BY
ASC
DESC
Multiple sort columns
WHERE + ORDER BY
Column aliases
Column positions
Tie-breakers
```

The main query flow is now:

```text
SELECT
    ↓
FROM
    ↓
WHERE
    ↓
ORDER BY
```

After Lessons 01–03, you can now answer three fundamental questions:

```text
Which columns do I need?
        ↓
SELECT

Which rows do I need?
        ↓
WHERE

In what order do I need them?
        ↓
ORDER BY
```

---

# Next Lesson

Continue to:

```text
Lesson 04 — Expressions and NULL
```

The next lesson will move beyond simply selecting stored values.

We will begin transforming values with expressions and learn how SQL handles
missing information with `NULL`.