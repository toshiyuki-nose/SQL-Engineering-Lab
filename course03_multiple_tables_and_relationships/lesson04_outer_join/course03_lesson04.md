# Lesson 04 - OUTER JOIN

## Overview

In Lesson 03, we learned how to combine related rows using `INNER JOIN`.

For example:

```text
BOOKS
    |
    | CATEGORY_ID
    |
CATEGORIES
```

An `INNER JOIN` returns rows only when the JOIN condition matches.

However, real databases often contain rows that do not yet have related data.

Examples:

- a category exists, but no books belong to it yet
- an author exists, but no books are assigned to that author yet
- a customer exists, but has not placed an order
- a department exists, but has no employees

If we use only `INNER JOIN`, these unmatched rows disappear from the result.

To preserve them, we use an `OUTER JOIN`.

---

# Learning Objectives

After completing this lesson, you should be able to:

- understand the difference between `INNER JOIN` and `OUTER JOIN`
- use `LEFT OUTER JOIN`
- use `RIGHT OUTER JOIN`
- use `FULL OUTER JOIN`
- understand which side of a JOIN is preserved
- identify unmatched rows using `IS NULL`
- combine OUTER JOIN with aggregation
- understand why `COUNT(*)` and `COUNT(column)` can behave differently
- choose an appropriate JOIN based on the business question

---

# 1. INNER JOIN Review

The basic `INNER JOIN` syntax is:

```sql
SELECT
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id;
```

Conceptually:

```text
CATEGORIES                  BOOKS

Technology  <-------------  SQL Fundamentals
Technology  <-------------  SQL Query Practice
Data Science <------------  Python for Data Analysis

Reference
(no books)
```

With `INNER JOIN`, the unmatched `Reference` category does not appear.

```text
Only matching rows survive.
```

This is exactly what we want in many queries.

But not always.

---

# 2. Why OUTER JOIN?

Suppose the business question is:

> Show every category, including categories that currently contain no books.

An `INNER JOIN` cannot answer this completely because categories without books disappear.

We need:

```text
CATEGORIES
     |
     | preserve every category
     |
     +---- BOOKS
```

This is a typical use case for `LEFT OUTER JOIN`.

---

# 3. Lesson 04 Sample Data

The existing database already contains:

```text
CATEGORIES
BOOKS
AUTHORS
BOOK_AUTHORS
```

For this lesson, `setup.sql` adds:

```text
CATEGORIES

60  Reference
```

No books will use Category 60.

It also adds:

```text
AUTHORS

509  Noah Anderson
```

No row will be added to `BOOK_AUTHORS` for this author.

Therefore, we intentionally create two unmatched situations:

```text
CATEGORIES
└── Reference
    └── no BOOKS

AUTHORS
└── Noah Anderson
    └── no BOOK_AUTHORS
```

These rows make the behavior of OUTER JOIN visible.

---

# 4. LEFT OUTER JOIN

Basic syntax:

```sql
SELECT
    ...
FROM table_a a
LEFT OUTER JOIN table_b b
    ON a.key = b.key;
```

`LEFT OUTER JOIN` preserves every row from the table on the left.

For example:

```sql
SELECT
    c.category_name,
    b.title
FROM categories c
LEFT OUTER JOIN books b
    ON c.category_id = b.category_id;
```

Here:

```text
LEFT side  = CATEGORIES
RIGHT side = BOOKS
```

Therefore:

```text
All CATEGORIES are preserved.
```

If a category has no matching book, the columns from `BOOKS` become `NULL`.

Conceptually:

```text
CATEGORY_NAME   TITLE
--------------  ------------------------
Technology      SQL Fundamentals
Technology      SQL Query Practice
...
Reference       NULL
```

---

# 5. LEFT JOIN

The keyword `OUTER` is optional.

These two statements mean the same thing:

```sql
LEFT OUTER JOIN
```

and:

```sql
LEFT JOIN
```

In this lab, we will use both forms so that you can recognize them.

In practical SQL, `LEFT JOIN` is commonly used because it is shorter.

---

# 6. Finding Unmatched Rows

One of the most useful OUTER JOIN patterns is finding rows that do not have related data.

Example:

```sql
SELECT
    c.category_id,
    c.category_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
WHERE b.book_id IS NULL;
```

This means:

```text
Keep every category
        ↓
Try to find related books
        ↓
Keep only rows where no book was found
```

The expected result is:

```text
60  Reference
```

This pattern is frequently used for data-quality checks and operational queries.

---

# 7. RIGHT OUTER JOIN

`RIGHT OUTER JOIN` preserves every row from the right table.

Example:

```sql
SELECT
    b.title,
    c.category_name
FROM books b
RIGHT OUTER JOIN categories c
    ON b.category_id = c.category_id;
```

Here:

```text
LEFT side  = BOOKS
RIGHT side = CATEGORIES
```

Therefore all categories are preserved.

This produces conceptually the same preserved dataset as:

```sql
FROM categories c
LEFT JOIN books b
```

The difference is the direction in which the query is written.

---

# 8. LEFT JOIN vs RIGHT JOIN

These queries are logically equivalent for this relationship.

## LEFT JOIN

```sql
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
```

## RIGHT JOIN

```sql
FROM books b
RIGHT JOIN categories c
    ON b.category_id = c.category_id
```

Both preserve:

```text
CATEGORIES
```

In practice, queries are often easier to read when written using `LEFT JOIN`.

The important concept is not the keyword itself.

The important question is:

> Which table must be preserved?

---

# 9. FULL OUTER JOIN

`FULL OUTER JOIN` preserves unmatched rows from both sides.

Syntax:

```sql
SELECT
    ...
FROM table_a a
FULL OUTER JOIN table_b b
    ON a.key = b.key;
```

Conceptually:

```text
LEFT table matches RIGHT table
        → combined row

LEFT table has no match
        → LEFT row + NULL

RIGHT table has no match
        → NULL + RIGHT row
```

With the current Book Store schema, referential integrity prevents normal `BOOKS` rows from referencing nonexistent categories.

Therefore, the unmatched example naturally exists mainly on the `CATEGORIES` side.

Even so, `FULL OUTER JOIN` is important to understand because other database designs may contain valid unmatched rows on both sides.

---

# 10. OUTER JOIN and Authors

The same concept can be applied to authors.

Current relationship:

```text
AUTHORS
   |
   | 1
   |
   | N
BOOK_AUTHORS
```

If we run:

```sql
SELECT
    a.author_id,
    a.author_name,
    ba.book_id
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id;
```

every author is preserved.

The Lesson 04 author:

```text
509  Noah Anderson
```

has no related row in `BOOK_AUTHORS`.

Therefore:

```text
AUTHOR_ID   AUTHOR_NAME      BOOK_ID
---------   ---------------  -------
509         Noah Anderson    NULL
```

will appear.

---

# 11. Finding Authors without Books

We can combine `LEFT JOIN` and `IS NULL`.

```sql
SELECT
    a.author_id,
    a.author_name
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
WHERE ba.book_id IS NULL;
```

This answers:

> Which authors currently have no books assigned?

This pattern is highly practical.

---

# 12. OUTER JOIN with Three Tables

We can continue the relationship:

```text
AUTHORS
   |
   |
BOOK_AUTHORS
   |
   |
BOOKS
```

Example:

```sql
SELECT
    a.author_id,
    a.author_name,
    b.title
FROM authors a
LEFT JOIN book_authors ba
    ON a.author_id = ba.author_id
LEFT JOIN books b
    ON ba.book_id = b.book_id;
```

Because the JOIN chain starts from `AUTHORS` and uses `LEFT JOIN`, authors without books are still preserved.

---

# 13. OUTER JOIN with Aggregation

Suppose we want to count books in every category.

A first attempt might be:

```sql
SELECT
    c.category_name,
    COUNT(*) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY c.category_name;
```

There is an important issue.

For an unmatched category, the OUTER JOIN still produces one result row containing NULL values from `BOOKS`.

Therefore:

```sql
COUNT(*)
```

counts that result row.

For relationship counts, it is often better to count a column from the related table:

```sql
COUNT(b.book_id)
```

Example:

```sql
SELECT
    c.category_name,
    COUNT(b.book_id) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY c.category_name;
```

Now:

```text
Reference = 0
```

This distinction is extremely important when combining OUTER JOIN with aggregation.

---

# 14. COUNT(*) vs COUNT(column)

Remember:

```text
COUNT(*)
    counts rows

COUNT(column)
    counts non-NULL values in that column
```

With OUTER JOIN:

```text
Reference + NULL BOOK
```

is still one result row.

Therefore:

```text
COUNT(*)         = 1
COUNT(b.book_id) = 0
```

Lesson 04 demonstrates this difference directly.

---

# 15. INNER JOIN vs LEFT JOIN

Consider the question:

> Show categories and their books.

If we only care about categories that contain books:

```sql
INNER JOIN
```

is appropriate.

If we need every category, including empty categories:

```sql
LEFT JOIN
```

is appropriate.

The choice depends on the business requirement.

---

# 16. Practical Questions

OUTER JOIN is useful for questions such as:

```text
Which categories contain no books?

Which authors have no assigned books?

Which customers have never placed an order?

Which departments have no employees?

Which products have never been sold?

Which records are missing a related record?
```

These are common operational, analytical, and data-quality questions.

---

# 17. JOIN Selection

A useful mental model is:

```text
INNER JOIN
    Only matched rows

LEFT JOIN
    All left rows
    + matching right rows

RIGHT JOIN
    All right rows
    + matching left rows

FULL OUTER JOIN
    All rows from both sides
```

Before writing the JOIN, ask:

> Which rows must remain in the result even when there is no match?

That question usually tells you which JOIN to use.

---

# 18. Execution Log

This lesson follows the SQL-Engineering-Lab logging standard.

Run:

```sql
@setup.sql
```

to create the Lesson 04 sample data.

The setup execution is recorded in:

```text
logs/setup.log
```

Then run:

```sql
@lesson04.sql
```

The lesson execution is recorded in:

```text
logs/lesson04.log
```

The `logs` directory is excluded from Git using `.gitignore`.

---

# 19. Summary

In this lesson, you learned:

- the difference between matched and unmatched rows
- `LEFT OUTER JOIN`
- `LEFT JOIN`
- `RIGHT OUTER JOIN`
- `FULL OUTER JOIN`
- how to preserve rows without related data
- how to find unmatched rows using `IS NULL`
- how to use OUTER JOIN across multiple tables
- how to combine OUTER JOIN with aggregation
- the difference between `COUNT(*)` and `COUNT(column)`

The key idea is:

```text
INNER JOIN
    "Show me matching relationships."

OUTER JOIN
    "Also show me what does not have a relationship."
```

---

# Next Lesson

Lesson 05:

```text
Self Join
```

In the next lesson, we will learn how a table can be joined to itself.