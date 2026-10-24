# Lesson 06 — Aggregation and Grouping

> Learn how to summarize multiple rows and analyze groups of data.

---

## Overview

So far, most of our queries have focused on individual books.

For example:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE stock > 0
ORDER BY price DESC;
```

Each returned row represents one book.

But databases are also used to answer questions about collections of rows.

For example:

```text
How many books are in the catalog?

What is the average book price?

How many books belong to each category?

What is the total inventory value of each category?
```

To answer these questions, SQL provides aggregate functions.

In this lesson, we will use:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
```

This moves us from row-level retrieval toward analytical SQL.

---

# 1. Learning Objectives

By the end of this lesson, you will be able to:

- count rows using `COUNT`,
- calculate totals using `SUM`,
- calculate averages using `AVG`,
- find minimum and maximum values,
- understand the basic behavior of aggregate functions with `NULL`,
- group rows using `GROUP BY`,
- filter rows before aggregation using `WHERE`,
- filter groups after aggregation using `HAVING`,
- sort aggregated results,
- combine expressions with aggregate functions,
- translate analytical business questions into SQL.

---

# 2. Recommended Setup

Continue using:

```text
SQL_LAB @ FREEPDB1
```

Verify the current session:

```sql
SHOW USER
SHOW CON_NAME
```

Expected environment:

```text
SQL_LAB
FREEPDB1
```

This lesson continues directly from Lesson 05.

The existing `BOOKS` table is reused.

No additional setup is required.

Run:

```text
@lesson06.sql
```

---

# 3. From Rows to Summaries

Until now, we have mainly asked:

> Which books match this condition?

Aggregation allows us to ask:

> What can we learn about the books as a whole?

Compare these two queries.

Row-level query:

```sql
SELECT
    book_id,
    title,
    price
FROM books;
```

Aggregate query:

```sql
SELECT
    COUNT(*) AS book_count
FROM books;
```

The first query returns many book rows.

The second query summarizes those rows into one result.

Conceptually:

```text
BOOKS
  ↓
many rows
  ↓
aggregate function
  ↓
summary value
```

---

# 4. COUNT

`COUNT` counts rows or non-NULL values.

To count all rows:

```sql
SELECT
    COUNT(*) AS book_count
FROM books;
```

For our current dataset:

```text
BOOK_COUNT
----------
15
```

`COUNT(*)` is the common way to count rows.

---

# 5. COUNT and NULL

There is an important difference between:

```sql
COUNT(*)
```

and:

```sql
COUNT(subtitle)
```

`COUNT(*)` counts rows.

`COUNT(subtitle)` counts only rows where `SUBTITLE` is not `NULL`.

Our current `BOOKS` data contains:

```text
15 total books
7 books with subtitles
8 books without subtitles
```

Therefore:

```sql
SELECT
    COUNT(*) AS total_books,
    COUNT(subtitle) AS books_with_subtitle
FROM books;
```

returns:

```text
TOTAL_BOOKS    BOOKS_WITH_SUBTITLE
-----------    -------------------
15             7
```

This is an important property of aggregate functions.

---

# 6. SUM

`SUM` calculates a total.

For example, total stock:

```sql
SELECT
    SUM(stock) AS total_stock
FROM books;
```

Instead of returning one row for each book, SQL adds the stock values together.

We can also aggregate an expression.

From Lesson 04:

```sql
price * stock
```

represents inventory value for one book.

Therefore:

```sql
SUM(price * stock)
```

represents inventory value across multiple books.

Example:

```sql
SELECT
    SUM(price * stock) AS total_inventory_value
FROM books;
```

This demonstrates an important progression:

```text
price * stock
      ↓
value for one book

SUM(price * stock)
      ↓
value for many books
```

---

# 7. AVG

`AVG` calculates the average of numeric values.

Example:

```sql
SELECT
    AVG(price) AS average_price
FROM books;
```

We can combine it with a function from Lesson 05:

```sql
SELECT
    ROUND(AVG(price), 2) AS average_price
FROM books;
```

Here the processing is conceptually:

```text
PRICE values
    ↓
AVG
    ↓
average
    ↓
ROUND
    ↓
formatted result
```

---

# 8. MIN and MAX

`MIN` returns the smallest value.

`MAX` returns the largest value.

Example:

```sql
SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM books;
```

These functions are useful for understanding the range of data.

---

# 9. Multiple Aggregate Functions

Multiple summaries can be calculated in one query.

```sql
SELECT
    COUNT(*) AS book_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock
FROM books;
```

A single result row can therefore describe several characteristics of the
entire table.

---

# 10. GROUP BY

Aggregate functions become much more powerful when combined with `GROUP BY`.

Suppose we want:

> How many books belong to each category?

Without grouping:

```sql
SELECT
    COUNT(*) AS book_count
FROM books;
```

we get one count for the entire table.

With:

```sql
GROUP BY category
```

the rows are divided into groups.

Conceptually:

```text
BOOKS
  ↓
GROUP BY CATEGORY
  ↓
Business
Data Science
Environment
History
Technology
  ↓
COUNT each group
```

The query becomes:

```sql
SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category;
```

Now each result row represents one category rather than one book.

---

# 11. Grouping with Multiple Aggregates

We can calculate several measures for each category.

```sql
SELECT
    category,
    COUNT(*) AS book_count,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock
FROM books
GROUP BY category;
```

This begins to resemble a small analytical report.

Conceptually:

```text
Dimension
---------
CATEGORY

Measures
--------
BOOK_COUNT
AVERAGE_PRICE
TOTAL_STOCK
```

This distinction becomes increasingly important in analytics and BI.

---

# 12. Aggregating Expressions

Expressions from earlier lessons can also be aggregated.

For one book:

```sql
price * stock
```

For one category:

```sql
SUM(price * stock)
```

Example:

```sql
SELECT
    category,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category;
```

Now we can compare inventory value across categories.

---

# 13. WHERE Before Aggregation

`WHERE` filters rows before they are grouped and aggregated.

Suppose we want:

> Analyze only books that are currently in stock.

We first filter:

```sql
WHERE stock > 0
```

Then group the remaining rows:

```sql
GROUP BY category
```

Example:

```sql
SELECT
    category,
    COUNT(*) AS book_count,
    SUM(stock) AS total_stock
FROM books
WHERE stock > 0
GROUP BY category;
```

Conceptually:

```text
BOOKS
  ↓
WHERE stock > 0
  ↓
remaining rows
  ↓
GROUP BY category
  ↓
aggregate each group
```

---

# 14. HAVING

`WHERE` filters rows.

`HAVING` filters groups.

This distinction is fundamental.

Suppose we want:

> Show only categories containing at least three books.

The category does not have a `BOOK_COUNT` stored in the table.

That value exists only after aggregation.

Therefore:

```sql
HAVING COUNT(*) >= 3
```

is used.

Example:

```sql
SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category
HAVING COUNT(*) >= 3;
```

---

# 15. WHERE vs HAVING

A useful mental model is:

```text
WHERE
  ↓
filters individual rows

GROUP BY
  ↓
creates groups

aggregate functions
  ↓
calculate group results

HAVING
  ↓
filters those groups
```

For example:

```sql
SELECT
    category,
    COUNT(*) AS book_count
FROM books
WHERE stock > 0
GROUP BY category
HAVING COUNT(*) >= 2;
```

Here:

```text
WHERE stock > 0
```

removes out-of-stock books before grouping.

Then:

```text
HAVING COUNT(*) >= 2
```

removes categories that do not have at least two remaining books.

---

# 16. GROUP BY Rule

Consider:

```sql
SELECT
    category,
    COUNT(*)
FROM books
GROUP BY category;
```

`CATEGORY` appears in the `GROUP BY`.

This is necessary because `CATEGORY` is selected as a non-aggregated value.

A useful beginner rule is:

> When using `GROUP BY`, selected columns that are not aggregate expressions
> generally need to appear in the `GROUP BY`.

For example, this is conceptually incomplete:

```sql
SELECT
    category,
    title,
    COUNT(*)
FROM books
GROUP BY category;
```

There may be several titles inside one category.

SQL cannot simply choose one title to represent the group.

This distinction is central to understanding grouped queries.

---

# 17. Sorting Aggregated Results

`ORDER BY` can be used after aggregation.

For example:

```sql
SELECT
    category,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category
ORDER BY inventory_value DESC;
```

This answers:

> Which category currently represents the largest inventory value?

We are now combining concepts from several lessons:

```text
Expressions
Aggregate Functions
GROUP BY
ORDER BY
```

---

# 18. Clause Order

Our queries have gradually grown throughout Course 02.

A grouped query can now contain:

```sql
SELECT ...
FROM ...
WHERE ...
GROUP BY ...
HAVING ...
ORDER BY ...
```

The written order is:

```text
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
```

Each clause has a different responsibility:

```text
SELECT
    what to return

FROM
    where the data comes from

WHERE
    which rows participate

GROUP BY
    how rows are grouped

HAVING
    which groups remain

ORDER BY
    how the final result is sorted
```

---

# 19. Building Aggregate Queries Incrementally

As queries become more complex, build them gradually.

Start with the rows:

```sql
SELECT
    category,
    price,
    stock
FROM books;
```

Then group:

```sql
SELECT
    category,
    COUNT(*) AS book_count
FROM books
GROUP BY category;
```

Then add another measure:

```sql
SELECT
    category,
    COUNT(*) AS book_count,
    SUM(stock) AS total_stock
FROM books
GROUP BY category;
```

Then add inventory value:

```sql
SELECT
    category,
    COUNT(*) AS book_count,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category;
```

Then filter or sort as required.

Continue using:

```text
Write
  ↓
Execute
  ↓
Inspect
  ↓
Add one concept
  ↓
Execute again
```

---

# 20. Exercises

## Exercise 1

Count all books.

Use:

```text
COUNT(*)
```

---

## Exercise 2

Count books that have a subtitle.

Compare:

```text
COUNT(*)
COUNT(subtitle)
```

---

## Exercise 3

Calculate:

```text
minimum price
maximum price
average price
```

Round the average price to two decimal places.

---

## Exercise 4

Calculate the total number of books currently in stock.

Use:

```text
SUM(stock)
```

---

## Exercise 5

Calculate the total inventory value.

Use:

```text
SUM(price * stock)
```

---

## Exercise 6

Count books by category.

Display:

```text
CATEGORY
BOOK_COUNT
```

---

## Exercise 7

For each category, calculate:

```text
BOOK_COUNT
AVERAGE_PRICE
TOTAL_STOCK
```

---

## Exercise 8

For each category, calculate total inventory value.

Display the category with the largest inventory value first.

---

## Exercise 9

Analyze only books currently in stock.

For each category:

- count the books,
- calculate total stock,
- calculate total inventory value.

---

## Exercise 10 — Business Question

The bookstore wants a category-level inventory report.

Requirements:

- consider only books currently in stock,
- group books by `CATEGORY`,
- count books as `BOOK_COUNT`,
- calculate average price as `AVERAGE_PRICE`,
- round average price to two decimal places,
- calculate total stock as `TOTAL_STOCK`,
- calculate `SUM(PRICE * STOCK)` as `INVENTORY_VALUE`,
- include only categories with at least two in-stock books,
- show the largest inventory value first,
- use `CATEGORY` as the final tie-breaker.

Translate the requirement into one SQL query.

---

# 21. Engineering Notes

## Aggregation changes the meaning of a result row

Before grouping:

```text
one result row
    =
one book
```

After:

```sql
GROUP BY category
```

one result row represents:

```text
one category
```

Always understand what one row of your result represents.

---

## COUNT(*) and COUNT(column) are different

```sql
COUNT(*)
```

counts rows.

```sql
COUNT(subtitle)
```

counts non-NULL `SUBTITLE` values.

This difference matters whenever nullable columns are involved.

---

## WHERE and HAVING solve different problems

Use:

```text
WHERE
```

to filter source rows.

Use:

```text
HAVING
```

to filter aggregated groups.

Do not treat them as interchangeable.

---

## Aggregation connects SQL to analytics

A query such as:

```sql
SELECT
    category,
    SUM(price * stock) AS inventory_value
FROM books
GROUP BY category;
```

contains two broad concepts:

```text
CATEGORY
    → how the data is divided

INVENTORY_VALUE
    → what is measured
```

These ideas later appear repeatedly in analytical systems, reporting, and BI.

---

# 22. Lesson Summary

In this lesson, we moved from row-level SQL to summary-level SQL.

You practiced:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
```

You also combined aggregation with concepts from previous lessons:

```text
Expressions
Functions
WHERE
GROUP BY
HAVING
ORDER BY
```

The full Course 02 progression is now:

```text
SELECT
   ↓
WHERE
   ↓
ORDER BY
   ↓
Expressions and NULL
   ↓
Functions
   ↓
Aggregation and Grouping
```

You can now move from raw table rows to useful summarized information.

---

# Course 02 Complete

You have completed:

```text
Course 02 — SQL Fundamentals
```

The course covered:

```text
Retrieve
Filter
Sort
Transform
Handle NULL
Use Functions
Summarize
Group
```

The next stage moves beyond a single table.

---

# Next Course

Continue to the next course:

```text
Multiple Tables and Relationships
```

The Book Store Database will expand beyond `BOOKS`.

Future topics will include:

```text
Relationships
Primary Keys
Foreign Keys
Multiple Tables
JOIN
Subqueries
```

Instead of asking questions about only books, we will begin connecting books
to other business entities.