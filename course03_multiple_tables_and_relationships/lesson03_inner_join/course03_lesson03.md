# Lesson 03 - INNER JOIN

## Overview

In Lesson 02, we created relationships between multiple tables.

The Book Store Database now contains the following structure:

```text
CATEGORIES
    CATEGORY_ID PK
         |
         | 1
         |
         | N
BOOKS
    BOOK_ID     PK
    CATEGORY_ID FK
         |
         | 1
         |
         | N
BOOK_AUTHORS
    BOOK_ID     PK, FK
    AUTHOR_ID   PK, FK
         |
         | N
         |
         | 1
AUTHORS
    AUTHOR_ID PK
```

Until now, most queries in this lab have retrieved data from one table.

However, relational databases usually store related information across multiple tables.

For example:

- `BOOKS` stores book information.
- `CATEGORIES` stores category names.
- `AUTHORS` stores author names.
- `BOOK_AUTHORS` connects books and authors.

To retrieve meaningful information from these related tables, we use `JOIN`.

This lesson introduces the most fundamental JOIN operation:

**INNER JOIN**

---

## Learning Objectives

After completing this lesson, you should be able to:

- understand why JOIN is necessary
- understand the basic syntax of `INNER JOIN`
- connect two tables using primary key and foreign key columns
- use table aliases
- retrieve columns from multiple tables
- join three tables
- understand how a junction table participates in a JOIN
- join `BOOKS`, `BOOK_AUTHORS`, and `AUTHORS`
- combine JOIN with `WHERE`
- combine JOIN with `ORDER BY`
- combine JOIN with aggregation

---

# 1. Why Do We Need JOIN?

Consider the current `BOOKS` table.

Conceptually, it contains data such as:

```text
BOOK_ID   TITLE                       CATEGORY_ID
--------  --------------------------  -----------
1001      SQL Fundamentals                     10
1004      Python for Data Analysis              20
1007      Business Analytics                    30
```

`CATEGORY_ID` tells us which category each book belongs to.

However, the value:

```text
10
```

is not very meaningful by itself.

The category name is stored in another table:

```text
CATEGORIES

CATEGORY_ID   CATEGORY_NAME
-----------   ----------------
10            Technology
20            Data Science
30            Business
40            History
50            Environment
```

The relationship is:

```text
BOOKS.CATEGORY_ID
        |
        +------ CATEGORIES.CATEGORY_ID
```

By joining these tables, we can produce:

```text
BOOK_ID   TITLE                       CATEGORY_NAME
--------  --------------------------  -------------
1001      SQL Fundamentals            Technology
1004      Python for Data Analysis    Data Science
1007      Business Analytics          Business
```

This is one of the central ideas of relational databases.

---

# 2. INNER JOIN

The basic syntax is:

```sql
SELECT
    table1.column_name,
    table2.column_name
FROM table1
INNER JOIN table2
    ON table1.key_column = table2.key_column;
```

The `ON` clause defines how the tables are related.

For the Book Store Database:

```sql
SELECT
    books.title,
    categories.category_name
FROM books
INNER JOIN categories
    ON books.category_id = categories.category_id;
```

The relationship used here is:

```text
BOOKS.CATEGORY_ID
        =
CATEGORIES.CATEGORY_ID
```

---

# 3. INNER JOIN Returns Matching Rows

An `INNER JOIN` returns rows for which the JOIN condition matches.

Conceptually:

```text
BOOKS                        CATEGORIES

CATEGORY_ID                  CATEGORY_ID
-----------                  -----------
10  -----------------------> 10
20  -----------------------> 20
30  -----------------------> 30
```

Only matching relationships appear in the result.

This behavior becomes especially important when we later study:

- `LEFT JOIN`
- `RIGHT JOIN`
- `FULL OUTER JOIN`

---

# 4. Table Aliases

Writing full table names repeatedly can make SQL difficult to read.

Instead of:

```sql
SELECT
    books.title,
    categories.category_name
FROM books
INNER JOIN categories
    ON books.category_id = categories.category_id;
```

we can use aliases:

```sql
SELECT
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id;
```

In this example:

```text
b = BOOKS
c = CATEGORIES
```

Aliases become particularly useful when joining three or more tables.

---

# 5. Joining BOOKS and CATEGORIES

The first relationship we will query is:

```text
CATEGORIES
     1
     |
     N
BOOKS
```

SQL:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id;
```

This allows us to retrieve the descriptive category name instead of only the category ID.

---

# 6. JOIN with WHERE

`JOIN` can be combined with the filtering techniques learned in Course 02.

Example:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
WHERE c.category_name = 'Technology';
```

The operations have different purposes:

```text
JOIN
    connects related tables

WHERE
    filters the resulting rows
```

---

# 7. JOIN with ORDER BY

JOIN results can also be sorted.

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    b.price
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
ORDER BY
    c.category_name,
    b.price DESC;
```

The SQL concepts learned in Course 02 continue to work with multi-table queries.

---

# 8. Joining Books and Authors

The relationship between books and authors is different.

A book can have multiple authors.

An author can write multiple books.

Therefore:

```text
BOOKS N ---- M AUTHORS
```

This many-to-many relationship is implemented using:

```text
BOOK_AUTHORS
```

The physical model is:

```text
BOOKS
   1
   |
   N
BOOK_AUTHORS
   N
   |
   1
AUTHORS
```

Therefore, retrieving book titles and author names requires three tables.

---

# 9. Three-Table JOIN

The JOIN path is:

```text
BOOKS
   |
   | BOOK_ID
   |
BOOK_AUTHORS
   |
   | AUTHOR_ID
   |
AUTHORS
```

SQL:

```sql
SELECT
    b.book_id,
    b.title,
    a.author_name
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
INNER JOIN authors a
    ON ba.author_id = a.author_id;
```

This is the first three-table JOIN in SQL-Engineering-Lab.

---

# 10. Why BOOK_AUTHORS Is Necessary

Suppose a book has two authors.

For example:

```text
BOOK_ID 1002
```

has two relationships:

```text
BOOK_ID   AUTHOR_ID
-------   ---------
1002      501
1002      502
```

After joining with `AUTHORS`, the result becomes conceptually:

```text
BOOK_ID   TITLE                       AUTHOR_NAME
-------   --------------------------  -----------
1002      Advanced SQL Engineering    Alex Morgan
1002      Advanced SQL Engineering    Maya Chen
```

The book appears once for each related author.

This is expected behavior.

---

# 11. Joining All Four Tables

We can continue the relationship path and retrieve:

- book
- category
- author

in a single query.

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

Relationship path:

```text
CATEGORIES
     |
     |
BOOKS
     |
     |
BOOK_AUTHORS
     |
     |
AUTHORS
```

This query demonstrates how normalized tables can be reconstructed into useful business information.

---

# 12. JOIN with Aggregation

JOIN can also be combined with aggregation.

For example, count books by category:

```sql
SELECT
    c.category_name,
    COUNT(*) AS book_count
FROM books b
INNER JOIN categories c
    ON b.category_id = c.category_id
GROUP BY c.category_name
ORDER BY c.category_name;
```

This combines concepts from Course 02 with relational queries from Course 03.

---

# 13. Count Authors per Book

The junction table also allows us to count relationships.

```sql
SELECT
    b.book_id,
    b.title,
    COUNT(ba.author_id) AS author_count
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id
GROUP BY
    b.book_id,
    b.title
ORDER BY b.book_id;
```

For a book with two authors:

```text
AUTHOR_COUNT = 2
```

This demonstrates an important idea:

> Aggregation can be performed over relationships as well as over individual tables.

---

# 14. Logical Query Structure

A useful way to read a JOIN query is:

```text
FROM
    Choose the starting table

JOIN
    Connect another table

ON
    Define the relationship

WHERE
    Filter rows

GROUP BY
    Create groups

HAVING
    Filter groups

SELECT
    Define the output columns

ORDER BY
    Sort the final result
```

This conceptual order is useful when reading increasingly complex SQL.

---

# 15. Practical Example

Suppose we want to answer:

> Which Technology or Data Science books are in stock, and who wrote them?

We need:

```text
BOOKS
    title
    stock
    category_id

CATEGORIES
    category_name

BOOK_AUTHORS
    book_id
    author_id

AUTHORS
    author_name
```

The query becomes:

```sql
SELECT
    b.book_id,
    b.title,
    c.category_name,
    a.author_name,
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

This is much closer to the type of query used in real database applications and analytics systems.

---

# 16. Execution Log

Starting with Course 03, SQL-Engineering-Lab records SQL*Plus execution output using `SPOOL`.

Running:

```sql
@lesson03.sql
```

creates:

```text
logs/lesson03.log
```

The log records:

- execution date and time
- database user
- container
- SQL statements
- query results
- row counts
- completion information

This provides a persistent execution record even when the SQL*Plus terminal output becomes too long to review.

---

# 17. Summary

In this lesson, you learned:

- why JOIN is necessary in relational databases
- `INNER JOIN`
- JOIN conditions using `ON`
- table aliases
- two-table JOINs
- three-table JOINs
- joining through a junction table
- four-table JOINs
- JOIN with `WHERE`
- JOIN with `ORDER BY`
- JOIN with `GROUP BY`
- aggregation over relationships

The key idea is:

```text
Relationships stored in the database
            ↓
          JOIN
            ↓
Useful combined information
```

---

# Next Lesson

Lesson 04:

```text
OUTER JOIN
```

In the next lesson, we will investigate what happens when related rows do **not** exist and learn how to preserve unmatched rows using outer joins.