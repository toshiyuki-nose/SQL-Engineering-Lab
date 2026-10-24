# Lesson 05 - Multiple Table Joins

## Overview

In the previous lessons, we learned the foundations of joining relational tables.

Lesson 03 introduced:

```text
INNER JOIN
```

Lesson 04 introduced:

```text
LEFT JOIN
RIGHT JOIN
FULL OUTER JOIN
```

We are now ready to combine these concepts into larger queries.

Real database queries often require information stored across several tables.

For example, the Book Store Database stores:

```text
CATEGORIES
BOOKS
BOOK_AUTHORS
AUTHORS
```

If we want to answer:

> Which books belong to each category, who wrote them, and which books are currently in stock?

we need information from multiple tables.

This lesson focuses on building and understanding queries that join several related tables.

---

# Learning Objectives

After completing this lesson, you should be able to:

- follow relationships across multiple tables
- join three or more tables
- understand JOIN paths
- combine multiple `INNER JOIN` operations
- combine `INNER JOIN` and `LEFT JOIN`
- select columns from multiple tables
- filter multi-table results
- sort multi-table results
- aggregate data after multiple joins
- understand how one-to-many and many-to-many relationships affect result rows
- recognize row multiplication caused by joins
- use `COUNT(DISTINCT ...)` when appropriate
- build practical multi-table queries step by step

---

# 1. Current Relational Model

The Book Store Database currently contains four related tables.

```text
CATEGORIES
------------
CATEGORY_ID PK
CATEGORY_NAME
     |
     | 1
     |
     | N
BOOKS
------------
BOOK_ID PK
TITLE
CATEGORY_ID FK
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
     |
     | 1
     |
     | N
BOOK_AUTHORS
------------
BOOK_ID   PK, FK
AUTHOR_ID PK, FK
     |
     | N
     |
     | 1
AUTHORS
------------
AUTHOR_ID PK
AUTHOR_NAME
```

This gives us the relationship path:

```text
CATEGORIES
     ↓
   BOOKS
     ↓
BOOK_AUTHORS
     ↓
  AUTHORS
```

A query can follow this path to reconstruct information distributed across the database.

---

# 2. Thinking in JOIN Paths

Before writing a multi-table query, identify:

1. What information do we need?
2. Which table contains each piece of information?
3. How are those tables connected?

Suppose we need:

```text
Book title
Category name
Author name
Price
Stock
```

The source tables are:

```text
BOOKS
    TITLE
    PRICE
    STOCK

CATEGORIES
    CATEGORY_NAME

AUTHORS
    AUTHOR_NAME
```

However, `BOOKS` and `AUTHORS` are not directly connected.

The relationship path is:

```text
BOOKS
    ↓ BOOK_ID
BOOK_AUTHORS
    ↓ AUTHOR_ID
AUTHORS
```

Therefore `BOOK_AUTHORS` must participate in the query even if we do not display any of its columns.

This is an important relational database concept:

> A table may be necessary for establishing a relationship even when none of its columns appear in the final SELECT list.

---

# 3. Start with Two Tables

A good way to build a complex JOIN is incrementally.

Start with:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id;
```

Relationship:

```text
CATEGORIES
     ↓
   BOOKS
```

Once this works, add the next relationship.

---

# 4. Add the Junction Table

To reach authors, first join `BOOK_AUTHORS`.

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    ba.author_id
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;
```

Now the query follows:

```text
CATEGORIES
     ↓
   BOOKS
     ↓
BOOK_AUTHORS
```

The `AUTHOR_ID` tells us which author is associated with each book.

---

# 5. Add AUTHORS

The final relationship is:

```text
BOOK_AUTHORS.AUTHOR_ID
        =
AUTHORS.AUTHOR_ID
```

The complete query becomes:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id;
```

Now one result can contain information originating from four tables.

---

# 6. Why Table Aliases Matter

Without aliases, a four-table JOIN becomes difficult to read.

For example:

```sql
SELECT
    books.title,
    categories.category_name,
    authors.author_name
FROM books
INNER JOIN categories
    ON books.category_id = categories.category_id
INNER JOIN book_authors
    ON books.book_id = book_authors.book_id
INNER JOIN authors
    ON book_authors.author_id = authors.author_id;
```

Using aliases:

```text
b  = BOOKS
c  = CATEGORIES
ba = BOOK_AUTHORS
a  = AUTHORS
```

makes the query much easier to follow:

```sql
SELECT
    b.title,
    c.category_name,
    a.author_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id;
```

For multi-table queries, consistent aliases are especially useful.

---

# 7. Result Rows Follow Relationships

A JOIN does not necessarily return one row per book.

Consider:

```text
BOOKS

1002  Advanced SQL Engineering
```

Suppose `BOOK_AUTHORS` contains:

```text
BOOK_ID   AUTHOR_ID
-------   ---------
1002      501
1002      502
```

After joining with `AUTHORS`, the result contains:

```text
BOOK_ID   TITLE                       AUTHOR_NAME
-------   --------------------------  -----------
1002      Advanced SQL Engineering    Alex Morgan
1002      Advanced SQL Engineering    Maya Chen
```

The book appears twice because it has two author relationships.

This is not duplicate data caused by SQL.

It represents two different relationships.

---

# 8. Row Multiplication

This behavior is important when joining one-to-many relationships.

Consider:

```text
BOOKS
  1
  |
  N
BOOK_AUTHORS
```

A book with:

```text
1 author
```

produces one joined row.

A book with:

```text
2 authors
```

produces two joined rows.

Therefore:

```text
Number of BOOKS rows
```

and:

```text
Number of JOIN result rows
```

may be different.

This is sometimes called row multiplication.

Understanding it is essential before performing aggregation.

---

# 9. COUNT(*) after Multiple Joins

Suppose we execute:

```sql
SELECT
    COUNT(*) AS joined_rows
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;
```

This counts:

```text
book-author relationships
```

It does not necessarily count unique books.

If one book has two authors, that book contributes two result rows.

---

# 10. COUNT(DISTINCT ...)

To count unique books after a many-to-many JOIN, we can use:

```sql
COUNT(DISTINCT b.book_id)
```

Example:

```sql
SELECT
    COUNT(*) AS relationship_count,
    COUNT(DISTINCT b.book_id) AS book_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;
```

These numbers answer different questions:

```text
COUNT(*)
    How many book-author relationships exist?

COUNT(DISTINCT b.book_id)
    How many different books appear?
```

The distinction is important.

---

# 11. Multi-Table JOIN with WHERE

After the tables are connected, normal filtering rules still apply.

Example:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name,
    b.price,
    b.stock
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE c.category_name = 'Technology'
  AND b.stock > 0;
```

The JOINs establish relationships.

The `WHERE` clause filters the resulting data.

---

# 12. Multi-Table JOIN with ORDER BY

The result can also be sorted using columns from different tables.

```sql
ORDER BY
    c.category_name,
    b.title,
    a.author_name;
```

This can produce a report-like structure:

```text
Category
    Book
        Author
```

---

# 13. Combining INNER JOIN and LEFT JOIN

Not every JOIN in a query needs to use the same JOIN type.

Suppose we want:

> Show every category, including categories without books.

We begin with:

```sql
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
```

But books may also have authors.

We can continue:

```sql
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
```

Complete example:

```sql
SELECT
    c.category_name,
    b.title,
    a.author_name
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id;
```

Because the JOIN chain preserves `CATEGORIES`, the empty `Reference` category remains visible.

---

# 14. Why JOIN Type Propagation Matters

Consider:

```sql
FROM categories c
LEFT JOIN books b
    ON ...
INNER JOIN book_authors ba
    ON ...
```

The first `LEFT JOIN` preserves categories without books.

However, for an empty category:

```text
BOOK_ID = NULL
```

The following `INNER JOIN` to `BOOK_AUTHORS` cannot find a match.

The row may therefore disappear.

If the requirement is:

> Preserve every category through the entire JOIN chain

we generally need to continue preserving the optional relationship:

```sql
LEFT JOIN books
LEFT JOIN book_authors
LEFT JOIN authors
```

This is an important concept in multi-table OUTER JOIN queries.

---

# 15. Aggregating Multiple Tables

We can count books by category while preserving empty categories.

```sql
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;
```

Why use:

```sql
COUNT(DISTINCT b.book_id)
```

instead of:

```sql
COUNT(*)
```

?

Because one book may have multiple authors.

Without `DISTINCT`, the same book could be counted multiple times after joining through `BOOK_AUTHORS`.

---

# 16. Counting Authors by Category

Multiple joins allow us to answer more complex questions.

For example:

> How many different authors are represented in each category?

```sql
SELECT
    c.category_name,
    COUNT(DISTINCT a.author_id) AS author_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY c.category_name
ORDER BY c.category_name;
```

This query crosses four tables.

---

# 17. Aggregate Business Information

We can combine several aggregate functions.

For example:

```sql
SELECT
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count,
    COUNT(DISTINCT a.author_id) AS author_count,
    AVG(b.price) AS average_price,
    SUM(b.stock) AS total_stock
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY c.category_name;
```

However, this introduces an important issue.

If a book has multiple authors, the book row can appear multiple times after the JOIN.

That means:

```text
SUM(b.stock)
AVG(b.price)
```

may be affected by row multiplication.

This is why understanding the grain of a query is important.

---

# 18. Query Grain

The grain describes:

> What does one result row represent?

Examples:

```text
BOOKS
    one row = one book

BOOK_AUTHORS
    one row = one book-author relationship

BOOKS JOIN BOOK_AUTHORS
    one row = one book-author relationship
```

Before aggregating, ask:

> What does one row represent after all JOINs have been applied?

This question helps prevent incorrect totals.

---

# 19. Build Complex Queries Incrementally

When writing a large JOIN, avoid writing everything at once.

A safer workflow is:

```text
Step 1
BOOKS

Step 2
BOOKS + CATEGORIES

Step 3
BOOKS + CATEGORIES + BOOK_AUTHORS

Step 4
BOOKS + CATEGORIES + BOOK_AUTHORS + AUTHORS

Step 5
Add WHERE

Step 6
Add GROUP BY / HAVING if necessary

Step 7
Add ORDER BY
```

At each step, inspect:

```text
row count
key columns
NULL values
relationship behavior
```

This makes debugging much easier.

---

# 20. Practical Query

Suppose the requirement is:

> Show all Technology and Data Science books that are in stock, including their category, author, price, and stock.

Required tables:

```text
BOOKS
CATEGORIES
BOOK_AUTHORS
AUTHORS
```

Query:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name,
    b.price,
    b.stock
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id
WHERE c.category_name IN (
    'Technology',
    'Data Science'
)
AND b.stock > 0
ORDER BY
    c.category_name,
    b.title,
    a.author_name;
```

This combines concepts from both Course 02 and Course 03.

---

# 21. Practical Reporting Query

Another requirement:

> Show every category and the number of books and authors represented in that category, including empty categories.

Query:

```sql
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT b.book_id) AS book_count,
    COUNT(DISTINCT a.author_id) AS author_count
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
LEFT JOIN book_authors ba
    ON b.book_id = ba.book_id
LEFT JOIN authors a
    ON ba.author_id = a.author_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_id;
```

The `Reference` category should remain in the result with:

```text
BOOK_COUNT   = 0
AUTHOR_COUNT = 0
```

---

# 22. Common Mistakes

## Mistake 1 - Missing JOIN Condition

Incorrect:

```sql
FROM books b
JOIN categories c
```

A relationship condition must be defined.

Use:

```sql
ON b.category_id = c.category_id
```

---

## Mistake 2 - Joining the Wrong Columns

Incorrect relationship:

```sql
ON b.book_id = c.category_id
```

Correct relationship:

```sql
ON b.category_id = c.category_id
```

Always follow the actual PK/FK relationship.

---

## Mistake 3 - Forgetting the Junction Table

`BOOKS` and `AUTHORS` do not have a direct relationship.

Incorrect mental model:

```text
BOOKS → AUTHORS
```

Actual relationship:

```text
BOOKS
  ↓
BOOK_AUTHORS
  ↓
AUTHORS
```

---

## Mistake 4 - Assuming One Result Row Equals One Book

After joining `BOOK_AUTHORS`, one book may produce multiple rows.

Always understand the grain of the result.

---

## Mistake 5 - Using COUNT(*) without Understanding the JOIN

After multiple joins:

```sql
COUNT(*)
```

counts result rows.

It does not automatically mean:

```text
number of books
```

Use the column and aggregation that match the business question.

---

# 23. Execution Log

This lesson follows the SQL-Engineering-Lab logging standard.

Run:

```sql
@lesson05.sql
```

SQL*Plus output is written to:

```text
logs/lesson05.log
```

The log contains:

- execution date and time
- current user
- current container
- SQL statements
- query results
- row counts
- lesson completion information

The `logs` directory is excluded from Git.

---

# 24. Summary

In this lesson, you learned:

- how to follow a JOIN path
- how to join three and four tables
- why junction tables are necessary
- how aliases improve multi-table SQL
- how relationship cardinality affects result rows
- row multiplication
- `COUNT(*)` vs `COUNT(DISTINCT ...)`
- how to combine `INNER JOIN` and `LEFT JOIN`
- how JOIN type affects later JOINs
- query grain
- how to build complex queries incrementally
- how to construct practical relational queries

The key idea is:

```text
Do not begin by asking:

    "How many JOINs do I need?"

Begin by asking:

    "What information do I need,
     where is it stored,
     and how are those tables related?"
```

---

# Next Lesson

Lesson 06:

```text
Subqueries
```

In the next lesson, we will learn how the result of one query can be used by another query.