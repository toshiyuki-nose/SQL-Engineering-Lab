# Lesson 02 — Filtering Rows

> Learn how to retrieve only the rows that match specific conditions.

---

## Overview

In Lesson 01, you learned how to choose which columns appear in a query result.

```text
SELECT → Which columns do I want?
FROM   → Where does the data come from?
```

However, every row in the table was still available to the query.

Real-world questions usually require another decision:

```text
Which rows do I need?
```

For example:

```text
Which books are in the Technology category?

Which books cost at least 3,000?

Which books are currently in stock?

Which books were published within a particular period?

Which titles contain the word SQL?
```

To answer these questions, SQL uses the `WHERE` clause.

This lesson also introduces the first table in the fictional **Book Store Database** used throughout later lessons.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Understand the purpose of `WHERE`
- Filter rows using comparison operators
- Combine conditions using `AND`
- Combine alternative conditions using `OR`
- Negate conditions using `NOT`
- Filter ranges using `BETWEEN`
- Match a list of values using `IN`
- Search character patterns using `LIKE`
- Understand `%` and `_` wildcards
- Build filtering conditions incrementally
- Translate business questions into SQL conditions

---

# Recommended Setup

Execute this lesson as:

```text
SQL_LAB @ FREEPDB1
```

Before beginning:

```text
Who am I?
Where am I?
What data am I querying?
```

In SQL*Plus:

```text
SHOW USER
SHOW CON_NAME
```

Expected environment:

```text
USER     : SQL_LAB
CON_NAME : FREEPDB1
```

---

# 1. Introducing the Book Store Database

Lesson 01 used the small `LEARNING_TOPICS` table created in Course 01.

Starting with Lesson 02, SQL-Engineering-Lab introduces a fictional Book Store Database.

The database will grow gradually.

```text
Course 02

BOOKS
  │
  ├── SELECT
  ├── WHERE
  ├── ORDER BY
  ├── Expressions
  ├── Functions
  └── Aggregation

Later Courses

BOOKS
  │
  ├── AUTHORS
  ├── CUSTOMERS
  ├── ORDERS
  └── ORDER_ITEMS
```

We will not create the entire database at once.

New tables and relationships will be introduced when they become useful for learning.

---

# 2. The BOOKS Table

The first table is:

```text
BOOKS
```

It represents books handled by the fictional bookstore.

| Column | Data Type | Description |
|---|---|---|
| `BOOK_ID` | `NUMBER` | Book identifier |
| `TITLE` | `VARCHAR2(100)` | Book title |
| `CATEGORY` | `VARCHAR2(30)` | Book category |
| `PRICE` | `NUMBER(8,2)` | Selling price |
| `STOCK` | `NUMBER` | Current inventory quantity |
| `PUBLISHED_YEAR` | `NUMBER(4)` | Publication year |

Example:

```text
BOOKS
│
├── BOOK_ID
├── TITLE
├── CATEGORY
├── PRICE
├── STOCK
└── PUBLISHED_YEAR
```

Run `setup.sql` before executing the main lesson script.

---

# 3. What Is WHERE?

A `WHERE` clause filters rows.

Basic syntax:

```sql
SELECT
    columns
FROM table
WHERE condition;
```

For example:

```sql
SELECT
    title,
    category
FROM books
WHERE category = 'Technology';
```

Conceptually:

```text
BOOKS
  │
  ▼
Check every row
  │
  ▼
CATEGORY = 'Technology' ?
  │
  ├── Yes → Include
  │
  └── No  → Exclude
```

The `WHERE` clause affects which rows appear in the result.

It does not delete rows from the table.

---

# 4. Comparison Operators

SQL provides comparison operators for constructing conditions.

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

---

## Equal To

Find Technology books:

```sql
SELECT
    book_id,
    title,
    category
FROM books
WHERE category = 'Technology';
```

The condition is:

```text
CATEGORY = 'Technology'
```

---

## Not Equal To

Find books that are not Technology books:

```sql
SELECT
    book_id,
    title,
    category
FROM books
WHERE category <> 'Technology';
```

---

## Numeric Comparisons

Find books priced at least 3,000:

```sql
SELECT
    title,
    price
FROM books
WHERE price >= 3000;
```

Find books priced below 2,000:

```sql
SELECT
    title,
    price
FROM books
WHERE price < 2000;
```

---

# 5. Character Values

Character values are written inside single quotation marks.

Correct:

```sql
WHERE category = 'Technology'
```

Incorrect:

```sql
WHERE category = Technology
```

The second form makes Oracle interpret `Technology` as an identifier rather than a character literal.

Also remember that character comparison is case-sensitive in ordinary Oracle SQL comparisons.

For example:

```text
Technology
```

and:

```text
technology
```

are different character values.

---

# 6. AND

`AND` requires multiple conditions to be true.

Suppose the business question is:

```text
Which Technology books cost at least 3,000?
```

SQL:

```sql
SELECT
    title,
    category,
    price
FROM books
WHERE category = 'Technology'
  AND price >= 3000;
```

Conceptually:

```text
Technology?
     AND
Price >= 3000?
     │
     ▼
Both must be true
```

---

# 7. OR

`OR` requires at least one condition to be true.

Question:

```text
Which books belong to Technology or Data Science?
```

SQL:

```sql
SELECT
    title,
    category
FROM books
WHERE category = 'Technology'
   OR category = 'Data Science';
```

Conceptually:

```text
Technology?
      OR
Data Science?
      │
      ▼
Either may be true
```

---

# 8. NOT

`NOT` reverses a condition.

For example:

```sql
SELECT
    title,
    category
FROM books
WHERE NOT category = 'Technology';
```

This asks for rows where:

```text
CATEGORY = 'Technology'
```

is not true.

For a simple comparison, this can also be written as:

```sql
WHERE category <> 'Technology'
```

`NOT` becomes particularly useful with conditions such as:

```text
NOT IN
NOT BETWEEN
NOT LIKE
```

---

# 9. BETWEEN

`BETWEEN` is useful for ranges.

Question:

```text
Which books were published between 2020 and 2024?
```

SQL:

```sql
SELECT
    title,
    published_year
FROM books
WHERE published_year BETWEEN 2020 AND 2024;
```

`BETWEEN` includes both boundary values.

Therefore:

```text
BETWEEN 2020 AND 2024
```

means:

```text
>= 2020
AND
<= 2024
```

---

# 10. IN

`IN` is useful when comparing one value against several possible values.

Instead of:

```sql
WHERE category = 'Technology'
   OR category = 'Data Science'
   OR category = 'Business'
```

you can write:

```sql
WHERE category IN (
    'Technology',
    'Data Science',
    'Business'
);
```

This is often easier to read.

---

# 11. LIKE

`LIKE` performs pattern matching on character data.

Suppose we want to find titles containing:

```text
SQL
```

We can write:

```sql
SELECT
    title
FROM books
WHERE title LIKE '%SQL%';
```

---

## Percent Wildcard

The `%` wildcard represents zero or more characters.

```text
SQL%
```

means:

```text
Starts with SQL
```

```text
%SQL
```

means:

```text
Ends with SQL
```

```text
%SQL%
```

means:

```text
Contains SQL
```

---

## Underscore Wildcard

The `_` wildcard represents exactly one character.

For example:

```sql
WHERE title LIKE 'SQL_101'
```

could match a value where exactly one character occurs between `SQL` and `101`.

The distinction is:

```text
% → zero or more characters
_ → exactly one character
```

---

# 12. Combining Conditions

Real business questions often contain several requirements.

For example:

```text
Find Technology or Data Science books
that cost no more than 4,000
and are currently in stock.
```

One possible query is:

```sql
SELECT
    title,
    category,
    price,
    stock
FROM books
WHERE category IN ('Technology', 'Data Science')
  AND price <= 4000
  AND stock > 0;
```

Read the condition step by step:

```text
Category is Technology or Data Science
                │
               AND
                │
Price is 4,000 or less
                │
               AND
                │
Stock is greater than zero
```

---

# 13. Operator Precedence and Parentheses

When `AND` and `OR` appear together, the meaning of a condition can become harder to read.

Consider:

```sql
WHERE category = 'Technology'
   OR category = 'Data Science'
  AND stock > 0
```

`AND` has higher precedence than `OR`.

Even when you know the precedence rules, parentheses make the intended logic clearer.

```sql
WHERE (
        category = 'Technology'
        OR category = 'Data Science'
      )
  AND stock > 0;
```

Better still, this particular condition can be simplified using `IN`:

```sql
WHERE category IN ('Technology', 'Data Science')
  AND stock > 0;
```

Readable SQL is preferable to unnecessarily clever SQL.

---

# 14. Building Filters Incrementally

Do not begin with the most complicated condition.

Start by inspecting the data:

```sql
SELECT *
FROM books;
```

Then ask one question:

```sql
SELECT *
FROM books
WHERE category = 'Technology';
```

Check the result.

Then add another condition:

```sql
SELECT *
FROM books
WHERE category = 'Technology'
  AND stock > 0;
```

Check again.

Then add another:

```sql
SELECT *
FROM books
WHERE category = 'Technology'
  AND stock > 0
  AND price <= 4000;
```

This creates the same engineering pattern introduced in Lesson 01:

```text
Write
  ↓
Execute
  ↓
Inspect
  ↓
Add a condition
  ↓
Execute again
```

---

# 15. Reading a Filtered Query

Consider:

```sql
SELECT
    title,
    price,
    stock
FROM books
WHERE price >= 2000
  AND stock > 0;
```

Read it as:

```text
What do I want?
    │
    ├── TITLE
    ├── PRICE
    └── STOCK
          │
          ▼
Where does it come from?
          │
          ▼
        BOOKS
          │
          ▼
Which rows?
          │
          ├── PRICE >= 2000
          └── STOCK > 0
```

In plain language:

```text
Retrieve the title, price, and stock
for books that cost at least 2,000
and currently have stock.
```

---

# 16. Exercises

Use the `BOOKS` table to answer the following questions.

---

## Exercise 1 — Technology Books

Retrieve:

```text
BOOK_ID
TITLE
CATEGORY
```

for books in the:

```text
Technology
```

category.

---

## Exercise 2 — Expensive Books

Retrieve:

```text
TITLE
PRICE
```

for books priced at least:

```text
3,000
```

---

## Exercise 3 — Books in Stock

Retrieve:

```text
TITLE
STOCK
```

for books where:

```text
STOCK > 0
```

---

## Exercise 4 — Multiple Conditions

Find Technology books that:

```text
cost at least 2,500
AND
have stock available
```

---

## Exercise 5 — Publication Range

Find books published from:

```text
2020 through 2024
```

Use `BETWEEN`.

---

## Exercise 6 — Multiple Categories

Find books belonging to:

```text
Technology
Data Science
Business
```

Use `IN`.

---

## Exercise 7 — Search Titles

Find titles containing:

```text
SQL
```

Use `LIKE`.

---

## Exercise 8 — Out of Stock

Find books where:

```text
STOCK = 0
```

What business meaning might this condition have?

---

## Exercise 9 — NOT

Find books that do not belong to:

```text
Technology
```

Try writing the condition in two ways:

```text
<>
```

and:

```text
NOT
```

Compare the results.

---

## Exercise 10 — Business Question

Write a query for this requirement:

```text
Find Technology or Data Science books
published between 2020 and 2025
that cost no more than 4,000
and have at least one item in stock.
```

Build the query incrementally rather than writing everything at once.

---

# 17. Engineering Notes

## WHERE Does Not Delete Rows

This query:

```sql
SELECT *
FROM books
WHERE stock = 0;
```

only filters the query result.

It does not remove books from the table.

Compare the concepts:

```text
WHERE in SELECT
      │
      ▼
Filter the result

DELETE
      │
      ▼
Modify stored data
```

Do not confuse filtering with data modification.

---

## Translate Requirements into Conditions

A useful SQL engineering habit is to break a requirement into smaller statements.

Requirement:

```text
Find Technology books
under or equal to 4,000
that are currently available.
```

Break it down:

```text
Technology
→ category = 'Technology'

4,000 or less
→ price <= 4000

Available
→ stock > 0
```

Then combine them:

```sql
WHERE category = 'Technology'
  AND price <= 4000
  AND stock > 0
```

The SQL becomes easier once the business requirement has been translated into explicit conditions.

---

## Prefer Readable Conditions

These are logically similar:

```sql
WHERE category = 'Technology'
   OR category = 'Data Science'
   OR category = 'Business'
```

and:

```sql
WHERE category IN (
    'Technology',
    'Data Science',
    'Business'
)
```

The second form communicates the intent more directly.

SQL should be written for humans as well as for the database.

---

# 18. Lesson Summary

In Lesson 01, you learned:

```text
Which columns?
      │
      ▼
SELECT
```

In Lesson 02, you added:

```text
Which rows?
      │
      ▼
WHERE
```

You practiced:

```text
=
<>
>
<
>=
<=

AND
OR
NOT

BETWEEN
IN
LIKE
```

A filtered query now has the basic structure:

```sql
SELECT
    columns
FROM table
WHERE condition;
```

The SQL query is becoming a more precise question about data.

---

# Next Lesson

Filtering determines:

```text
Which rows appear?
```

But the rows returned by a query do not automatically have a guaranteed presentation order.

The next question is:

```text
In what order should the result be displayed?
```

Continue to:

```text
Lesson 03 — Sorting Results
```

The next lesson introduces:

```text
ORDER BY
ASC
DESC
Multiple Sort Columns
```