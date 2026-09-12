# Lesson 04 — Expressions and NULL

> Learn how to calculate new values and represent missing information in SQL.

---

## Overview

In the previous lessons, we learned how to:

```text
SELECT     → choose columns
WHERE      → choose rows
ORDER BY   → control result order
```

We can now retrieve the data we need and control how the result is displayed.

The next step is to calculate values that are not directly stored in the
table.

For example, the `BOOKS` table contains:

```text
PRICE
STOCK
```

From those two stored values, we can calculate:

```text
PRICE × STOCK
```

to obtain the value of the current inventory.

SQL expressions allow us to calculate and construct values while executing a
query.

This lesson also introduces `NULL`.

Real-world databases frequently contain information that is unknown, missing,
or not applicable.

Understanding `NULL` is therefore essential for writing correct SQL.

---

# 1. Learning Objectives

By the end of this lesson, you will be able to:

- create arithmetic expressions,
- calculate values from multiple columns,
- assign aliases to calculated values,
- concatenate character values,
- understand the basic meaning of `NULL`,
- find rows using `IS NULL`,
- find rows using `IS NOT NULL`,
- understand why `= NULL` does not work,
- understand how `NULL` affects expressions,
- combine expressions with `WHERE` and `ORDER BY`.

---

# 2. Continuing the Book Store Database

This lesson continues directly from Lesson 03.

We keep the existing:

```text
BOOKS
```

table and extend it slightly.

A new column is added:

```text
SUBTITLE
```

Not every book has a subtitle.

This gives us a natural example of optional information.

Conceptually:

```text
BOOKS
├── BOOK_ID
├── TITLE
├── SUBTITLE       ← new
├── CATEGORY
├── PRICE
├── STOCK
└── PUBLISHED_YEAR
```

Some rows will contain a subtitle.

Other rows will contain no subtitle.

Those missing values will be represented by `NULL`.

---

# 3. Recommended Setup

Connect to:

```text
SQL_LAB @ FREEPDB1
```

Verify the session:

```sql
SHOW USER
SHOW CON_NAME
```

Expected environment:

```text
SQL_LAB
FREEPDB1
```

The `BOOKS` table from Lesson 02 and Lesson 03 must already exist.

Run:

```text
@setup.sql
```

once before starting the lesson.

The setup script:

1. keeps the existing `BOOKS` table,
2. adds `SUBTITLE`,
3. adds subtitles to selected books,
4. intentionally leaves other subtitles as `NULL`.

Then run:

```text
@lesson04.sql
```

---

# 4. What Is an Expression?

An expression produces a value.

For example:

```sql
price * 1.10
```

takes the stored value in `PRICE` and calculates another value.

```sql
SELECT
    title,
    price,
    price * 1.10 AS price_with_tax
FROM books;
```

The calculated value does not need to exist as a physical column in the table.

Conceptually:

```text
stored value
PRICE = 2800
     ↓
expression
2800 × 1.10
     ↓
query result
3080
```

This is one of the major strengths of SQL.

The database can calculate values while retrieving data.

---

# 5. Arithmetic Expressions

Common arithmetic operators include:

| Operator | Meaning |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |

For example:

```sql
SELECT
    title,
    price,
    price + 500 AS hypothetical_price
FROM books;
```

or:

```sql
SELECT
    title,
    price,
    stock,
    price * stock AS inventory_value
FROM books;
```

The second expression answers a useful bookstore question:

> What is the value of the current inventory for each book?

---

# 6. Expressions Do Not Modify Stored Data

Consider:

```sql
SELECT
    title,
    price,
    price + 500 AS hypothetical_price
FROM books;
```

The expression calculates a value in the query result.

It does not update `PRICE`.

The table still contains the original value.

This distinction is important:

```text
Expression
    ↓
calculates a result

UPDATE
    ↓
changes stored data
```

Data modification will be explored separately in later lessons.

---

# 7. Aliases for Calculated Values

Calculated expressions should usually have meaningful names.

Without an alias:

```sql
SELECT
    price * stock
FROM books;
```

the result heading is based on the expression itself.

Instead:

```sql
SELECT
    price * stock AS inventory_value
FROM books;
```

gives the result a clear name:

```text
INVENTORY_VALUE
```

Aliases help communicate what a calculated value means.

---

# 8. Character Concatenation

Expressions are not limited to numbers.

Oracle uses:

```text
||
```

for character concatenation.

For example:

```sql
SELECT
    title || ' - ' || category AS book_description
FROM books;
```

A result might look like:

```text
SQL Fundamentals - Technology
```

Multiple stored values can therefore be combined into one display value.

Another example:

```sql
SELECT
    title || ' (' || published_year || ')' AS book_description
FROM books;
```

might produce:

```text
SQL Fundamentals (2022)
```

---

# 9. What Is NULL?

`NULL` represents the absence of a value.

It can mean that information is:

- unknown,
- missing,
- not supplied,
- not applicable.

For example, some books have subtitles and some do not.

```text
TITLE                         SUBTITLE
----------------------------  -----------------------------------
SQL Fundamentals              A Practical Introduction...
Practical Machine Learning    NULL
```

`NULL` is not the same thing as:

```text
0
```

It is also not the same thing as a normal text value such as:

```text
'NULL'
```

Think of `NULL` as:

> No value is currently present here.

---

# 10. Finding NULL Values

A normal equality comparison is not used to test for `NULL`.

This is incorrect:

```sql
WHERE subtitle = NULL
```

Instead, use:

```sql
WHERE subtitle IS NULL
```

Example:

```sql
SELECT
    book_id,
    title,
    subtitle
FROM books
WHERE subtitle IS NULL;
```

This returns books that do not currently have a subtitle.

---

# 11. Finding Non-NULL Values

Use:

```sql
IS NOT NULL
```

to find rows where a value exists.

```sql
SELECT
    book_id,
    title,
    subtitle
FROM books
WHERE subtitle IS NOT NULL;
```

The two basic patterns are therefore:

```text
IS NULL
    → value is missing

IS NOT NULL
    → value is present
```

---

# 12. Why Does `= NULL` Not Work?

SQL uses special logic for missing information.

A comparison such as:

```sql
subtitle = NULL
```

does not evaluate to ordinary `TRUE`.

The database cannot say that a value is equal to an unknown or missing value
using the normal equality operator.

Therefore:

```sql
WHERE subtitle = NULL
```

does not find the rows you might expect.

Use:

```sql
WHERE subtitle IS NULL
```

instead.

This is one of the most important rules when working with nullable data.

---

# 13. NULL in Arithmetic Expressions

Suppose a calculation contains a missing value.

Conceptually:

```text
2800 - unknown
```

The database cannot determine the result.

Therefore, arithmetic involving `NULL` normally produces `NULL`.

For example:

```sql
SELECT
    price,
    price - NULL AS calculated_price
FROM books;
```

The calculated result is `NULL`.

This behavior becomes especially important when real tables contain nullable
numeric columns.

---

# 14. NULL and Character Concatenation in Oracle

Oracle has some database-specific behavior around character values and `NULL`.

For example:

```sql
SELECT
    title || ' - ' || subtitle AS book_description
FROM books;
```

If `SUBTITLE` is `NULL`, Oracle's character concatenation behavior may still
produce the non-null portions of the expression rather than making the entire
result `NULL`.

Also, Oracle currently treats a zero-length character string as `NULL`.

These behaviors are worth remembering when working specifically with Oracle.

Later lessons will introduce functions that make handling missing values more
explicit.

---

# 15. Combining Previous Lessons

We can now combine everything learned so far.

Suppose we want:

> Books currently in stock, with the largest inventory value first.

Translate the requirement.

```text
books currently in stock
        ↓
WHERE stock > 0

inventory value
        ↓
price * stock

largest first
        ↓
ORDER BY inventory_value DESC
```

The query becomes:

```sql
SELECT
    book_id,
    title,
    price,
    stock,
    price * stock AS inventory_value
FROM books
WHERE stock > 0
ORDER BY inventory_value DESC;
```

This combines concepts from multiple lessons:

```text
SELECT
    ↓
Expressions
    ↓
FROM
    ↓
WHERE
    ↓
ORDER BY
```

---

# 16. Expressions as Business Logic

Expressions become more useful when they represent something meaningful.

For example:

```sql
price * stock
```

is not merely a multiplication exercise.

In the Book Store Database it represents:

```text
inventory value
```

This distinction matters.

Good SQL is not just syntactically correct.

It should express the meaning of the business requirement clearly.

---

# 17. Exercises

## Exercise 1

Display:

```text
TITLE
PRICE
PRICE_WITH_TAX
```

Calculate `PRICE_WITH_TAX` as:

```text
PRICE × 1.10
```

---

## Exercise 2

Calculate the inventory value of every book.

Use:

```text
PRICE × STOCK
```

and name the result:

```text
INVENTORY_VALUE
```

---

## Exercise 3

Display the books with the highest inventory value first.

---

## Exercise 4

Create a display value in this format:

```text
TITLE - CATEGORY
```

using concatenation.

---

## Exercise 5

Find all books that do not have a subtitle.

---

## Exercise 6

Find all books that have a subtitle.

---

## Exercise 7

Try:

```sql
WHERE subtitle = NULL
```

Compare the result with:

```sql
WHERE subtitle IS NULL
```

Explain why the results are different.

---

## Exercise 8

Find books that:

- belong to `Technology` or `Data Science`,
- are currently in stock.

Calculate their inventory value and display the highest value first.

---

## Exercise 9

Find books without a subtitle that are currently in stock.

Display:

```text
BOOK_ID
TITLE
CATEGORY
PRICE
STOCK
```

---

## Exercise 10 — Business Question

The bookstore wants to identify books that may need subtitle information added
to the catalog.

Requirements:

- `SUBTITLE` is missing,
- the book is currently in stock,
- calculate `PRICE × STOCK` as `INVENTORY_VALUE`,
- show the highest inventory value first,
- use `BOOK_ID` as a tie-breaker.

Translate the requirement into one SQL query.

---

# 18. Engineering Notes

## NULL is not zero

These values have different meanings:

```text
STOCK = 0
```

means:

> The known stock quantity is zero.

But:

```text
STOCK = NULL
```

would mean:

> The stock quantity is not known or not present.

Do not treat them as equivalent.

---

## NULL is not the text `'NULL'`

This:

```sql
subtitle IS NULL
```

tests for the absence of a value.

This:

```sql
subtitle = 'NULL'
```

tests whether the column literally contains the four characters:

```text
N U L L
```

They are completely different conditions.

---

## Give expressions meaningful aliases

Prefer:

```sql
price * stock AS inventory_value
```

over leaving a business calculation unnamed.

The alias communicates why the expression exists.

---

## Keep calculations close to their meaning

When reading:

```sql
price * stock AS inventory_value
```

another engineer can understand both:

```text
how the value is calculated
```

and:

```text
what the value represents
```

Readable SQL communicates intent.

---

# 19. Lesson Summary

In this lesson, the `BOOKS` table evolved from:

```text
BOOK_ID
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
```

to:

```text
BOOK_ID
TITLE
SUBTITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
```

We intentionally introduced optional data so that the database now contains
both:

```text
known values
NULL values
```

You practiced:

```text
Arithmetic expressions
Column aliases
Character concatenation
NULL
IS NULL
IS NOT NULL
NULL in expressions
WHERE + expressions + ORDER BY
```

Our SQL toolkit has now grown to:

```text
SELECT
    ↓
Expressions
    ↓
FROM
    ↓
WHERE
    ↓
ORDER BY
```

---

# Next Lesson

Continue to:

```text
Lesson 05 — SQL Functions
```

The next lesson will build directly on the expressions introduced here.

We will use SQL functions to transform values and handle data more
effectively, including more practical ways to work with `NULL`.