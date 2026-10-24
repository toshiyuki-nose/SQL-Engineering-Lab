# Lesson 06 - Subqueries

## Overview

A subquery is a query written inside another SQL statement.

So far, we have retrieved data by:

- selecting rows from a table
- filtering rows with `WHERE`
- aggregating data
- joining multiple related tables

A subquery gives us another way to build SQL queries.

For example:

> Find books whose price is higher than the average book price.

First, we can calculate the average price:

```sql
SELECT AVG(price)
FROM books;
```

Then we can use that result inside another query:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);
```

The inner query:

```sql
SELECT AVG(price)
FROM books
```

is the subquery.

The outer query uses the result returned by the subquery.

---

# Learning Objectives

After completing this lesson, you should be able to:

- understand what a subquery is
- identify an outer query and an inner query
- use a single-row subquery
- use aggregate functions inside subqueries
- use multi-row subqueries
- use `IN` with a subquery
- use `EXISTS`
- use `NOT EXISTS`
- understand correlated subqueries
- compare subqueries with JOIN-based solutions
- choose an appropriate query structure for a business question

---

# 1. Basic Structure

A subquery is enclosed in parentheses.

Basic pattern:

```sql
SELECT ...
FROM ...
WHERE column operator (
    SELECT ...
    FROM ...
);
```

Example:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);
```

Conceptually:

```text
Outer Query
│
│  SELECT books
│
└── Subquery
       │
       └── Calculate average price
```

The subquery produces a value that is used by the outer query.

---

# 2. Outer Query and Inner Query

Consider:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);
```

The outer query is:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (...);
```

The inner query is:

```sql
SELECT AVG(price)
FROM books;
```

It is often useful to execute the inner query independently first.

This helps us understand what value the outer query will receive.

---

# 3. Single-Row Subquery

A single-row subquery returns one row.

For example:

```sql
SELECT AVG(price)
FROM books;
```

returns one value.

Therefore it can be used with comparison operators such as:

```text
=
<>
>
>=
<
<=
```

Example:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);
```

This asks:

> Which books are more expensive than the average book?

---

# 4. Aggregate Functions in Subqueries

Aggregate functions are commonly used in subqueries.

Examples include:

```text
AVG
MIN
MAX
COUNT
SUM
```

For example:

```sql
SELECT
    book_id,
    title,
    price
FROM books
WHERE price = (
    SELECT MAX(price)
    FROM books
);
```

The subquery calculates:

```text
maximum price
```

The outer query retrieves the book or books with that price.

---

# 5. Why Not Hard-Code the Value?

Suppose the maximum price is currently:

```text
4500
```

We could write:

```sql
WHERE price = 4500
```

But this assumes that 4500 will always be the maximum.

Instead:

```sql
WHERE price = (
    SELECT MAX(price)
    FROM books
)
```

asks the database to calculate the current maximum.

If the data changes, the query still works.

---

# 6. Multi-Row Subqueries

Not every subquery returns one row.

For example:

```sql
SELECT category_id
FROM categories
WHERE category_name IN (
    'Technology',
    'Data Science'
);
```

This may return multiple category IDs.

A multi-row result cannot normally be compared using:

```sql
=
```

Instead, operators such as:

```text
IN
```

can be used.

---

# 7. IN with a Subquery

Example:

```sql
SELECT
    book_id,
    title,
    category_id
FROM books
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE category_name IN (
        'Technology',
        'Data Science'
    )
);
```

The inner query determines the category IDs.

The outer query retrieves books belonging to those categories.

Conceptually:

```text
CATEGORIES
    │
    │ find IDs for
    │ Technology / Data Science
    ▼
category_id values
    │
    ▼
BOOKS
```

---

# 8. Subquery Using a Related Table

A subquery can also use another related table.

For example:

> Find books that have an author relationship.

```sql
SELECT
    book_id,
    title
FROM books
WHERE book_id IN (
    SELECT book_id
    FROM book_authors
);
```

The inner query returns book IDs from:

```text
BOOK_AUTHORS
```

The outer query retrieves the corresponding books.

---

# 9. EXISTS

`EXISTS` checks whether a subquery returns at least one row.

Basic pattern:

```sql
WHERE EXISTS (
    SELECT ...
)
```

Example:

```sql
SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
);
```

For each book, SQL checks whether a matching row exists in `BOOK_AUTHORS`.

If a match exists:

```text
TRUE
```

and the book is returned.

---

# 10. Why SELECT 1 in EXISTS?

You will often see:

```sql
SELECT 1
FROM ...
```

inside `EXISTS`.

The actual selected value is not important.

`EXISTS` only asks:

> Did the subquery return at least one row?

Therefore:

```sql
SELECT 1
```

is commonly used to make the intention clear.

---

# 11. NOT EXISTS

`NOT EXISTS` does the opposite.

It returns rows for which the subquery finds no match.

Example:

```sql
SELECT
    a.author_id,
    a.author_name
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.author_id = a.author_id
);
```

This asks:

> Which authors are not associated with any book?

From Lesson 04, we intentionally have an author without a book relationship.

Therefore this query gives us a useful real example.

---

# 12. Correlated Subqueries

Consider:

```sql
SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
);
```

Notice:

```sql
ba.book_id = b.book_id
```

The inner query refers to:

```text
b.book_id
```

from the outer query.

This is called a:

```text
Correlated Subquery
```

The inner query is related to the current row being evaluated by the outer query.

---

# 13. Conceptual Execution of a Correlated Subquery

Conceptually, we can think of it like this:

```text
Outer row:
BOOK_ID = 1001

    ↓

Check BOOK_AUTHORS:
Does BOOK_ID = 1001 exist?

    ↓

YES → return the book
NO  → do not return the book
```

Then SQL evaluates another outer row.

This mental model is useful for understanding correlated subqueries.

The database optimizer may internally execute the query differently.

---

# 14. Correlated Aggregate Subquery

Correlated subqueries can also contain aggregate functions.

For example:

> Find books whose price is greater than the average price of books in the same category.

```sql
SELECT
    b.book_id,
    b.title,
    b.category_id,
    b.price
FROM books b
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.category_id = b.category_id
);
```

The subquery calculates an average for the category of the current book.

Conceptually:

```text
Current book
    │
    ▼
Current CATEGORY_ID
    │
    ▼
Calculate average price
for that category
    │
    ▼
Compare current book price
with category average
```

This is more powerful than comparing every book with one global average.

---

# 15. Global Average vs Category Average

These two questions are different.

## Global Average

> Is this book more expensive than the average of all books?

```sql
WHERE price > (
    SELECT AVG(price)
    FROM books
)
```

## Category Average

> Is this book more expensive than the average within its own category?

```sql
WHERE b.price > (
    SELECT AVG(b2.price)
    FROM books b2
    WHERE b2.category_id = b.category_id
)
```

The second query is correlated with the current book.

---

# 16. Subquery and JOIN

Sometimes the same business question can be answered using either a subquery or a JOIN.

For example:

> Find books that have an author relationship.

Using `IN`:

```sql
SELECT
    book_id,
    title
FROM books
WHERE book_id IN (
    SELECT book_id
    FROM book_authors
);
```

Using `EXISTS`:

```sql
SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
);
```

Using `JOIN`:

```sql
SELECT DISTINCT
    b.book_id,
    b.title
FROM books b
INNER JOIN book_authors ba
    ON b.book_id = ba.book_id;
```

All three approaches can express the relationship.

However, their structure communicates the question differently.

---

# 17. Relationship Retrieval vs Existence Testing

A useful way to think about the difference is:

Use a JOIN when you need columns from both tables.

For example:

```text
Book Title
Author Name
```

requires data from:

```text
BOOKS
AUTHORS
```

A JOIN is natural.

Use `EXISTS` when the question is primarily:

> Does a related row exist?

For example:

```text
Find books that have at least one author.
```

The outer result only needs book information.

`EXISTS` expresses that requirement clearly.

---

# 18. NOT EXISTS and Missing Relationships

Lesson 04 used `LEFT JOIN` and `IS NULL` to find missing relationships.

Example concept:

```sql
LEFT JOIN book_authors ...
WHERE ba.book_id IS NULL
```

`NOT EXISTS` provides another way to express the same type of question:

```sql
SELECT
    a.author_id,
    a.author_name
FROM authors a
WHERE NOT EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.author_id = a.author_id
);
```

Both techniques are important.

The purpose of this lesson is not to declare one universally better.

Instead, learn to recognize both patterns.

---

# 19. Nested Logic

Subqueries allow SQL to express questions in layers.

For example:

```text
Find books

    where the category is one of

        the categories whose names are
        Technology or Data Science
```

SQL:

```sql
SELECT
    book_id,
    title
FROM books
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE category_name IN (
        'Technology',
        'Data Science'
    )
);
```

Reading SQL from the inside outward can make these queries easier to understand.

---

# 20. Debugging Subqueries

When a subquery becomes difficult to understand, execute it independently.

Instead of immediately running:

```sql
SELECT ...
FROM books
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE ...
);
```

first run:

```sql
SELECT category_id
FROM categories
WHERE ...;
```

Check:

```text
What rows are returned?
How many rows?
Can NULL appear?
Is this a single-row or multi-row result?
```

Then place it inside the outer query.

This is similar to building JOIN queries incrementally.

---

# 21. Common Mistake - Multiple Rows with =

Suppose a subquery returns:

```text
10
20
```

This is not appropriate:

```sql
WHERE category_id = (
    SELECT category_id
    ...
)
```

because `=` expects one value.

For multiple values, use an appropriate multi-row operator such as:

```sql
IN
```

Example:

```sql
WHERE category_id IN (
    SELECT category_id
    ...
)
```

---

# 22. Common Mistake - Forgetting Correlation

Consider an `EXISTS` query.

Incorrect:

```sql
SELECT
    b.book_id,
    b.title
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
);
```

If `BOOK_AUTHORS` contains any rows at all, the subquery exists for every book.

The intended relationship is missing.

Correct:

```sql
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    WHERE ba.book_id = b.book_id
)
```

The correlation connects the inner query to the current outer row.

---

# 23. Common Mistake - Hard-Coding Derived Values

Avoid manually calculating a value and embedding it permanently.

Instead of:

```sql
WHERE price > 2860
```

prefer:

```sql
WHERE price > (
    SELECT AVG(price)
    FROM books
)
```

when the business rule actually means:

```text
above the current average price
```

The query should express the rule, not merely today's result.

---

# 24. Practical Business Questions

Subqueries allow us to express useful questions such as:

```text
Which books cost more than the overall average?

Which books have the maximum price?

Which books belong to selected categories?

Which books have at least one author?

Which authors have no books?

Which books cost more than the average book
within their own category?
```

These are increasingly close to real analytical SQL requirements.

---

# 25. Execution Log

This lesson follows the SQL-Engineering-Lab logging standard.

Run:

```sql
@lesson06.sql
```

SQL*Plus output is written to:

```text
logs/lesson06.log
```

The `logs` directory is excluded from Git.

---

# 26. Summary

In this lesson, you learned:

- subquery fundamentals
- outer queries and inner queries
- single-row subqueries
- aggregate subqueries
- multi-row subqueries
- `IN`
- `EXISTS`
- `NOT EXISTS`
- correlated subqueries
- correlated aggregate subqueries
- subqueries compared with JOINs
- how to debug subqueries incrementally

The key idea is:

```text
A subquery allows one query
to provide information
used by another query.
```

Another useful question when designing SQL is:

```text
Do I need data from the related table?

or

Do I only need to know whether
a related row exists?
```

That distinction can help you choose between a JOIN and an existence-oriented subquery.

---

# Course 03 Complete

With this lesson, Course 03 is complete.

You have progressed from:

```text
Relational Database Basics
        ↓
Creating Related Tables
        ↓
INNER JOIN
        ↓
OUTER JOIN
        ↓
Multiple Table Joins
        ↓
Subqueries
```

You now have the foundation required to write queries across a relational database rather than querying isolated tables.