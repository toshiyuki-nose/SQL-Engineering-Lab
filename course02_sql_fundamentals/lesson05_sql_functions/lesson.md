# Lesson 05 — SQL Functions

> Learn how SQL functions transform values and help handle real-world data.

---

## Overview

In Lesson 04, we learned that SQL expressions can calculate new values.

For example:

```sql
price * stock
```

calculates the inventory value of a book.

We also introduced `NULL` and learned that missing values require special
handling.

SQL functions extend these ideas.

A function accepts one or more values, performs an operation, and returns a
result.

For example:

```sql
UPPER(title)
```

converts a title to uppercase.

```sql
ROUND(price * 1.10)
```

calculates a value and rounds the result.

```sql
NVL(subtitle, 'No subtitle')
```

provides an alternative value when `SUBTITLE` is `NULL`.

In this lesson, we continue using the existing `BOOKS` table.

No new table is required.

---

# 1. Learning Objectives

By the end of this lesson, you will be able to:

- understand the basic role of SQL functions,
- use character functions,
- use numeric functions,
- use functions to handle `NULL`,
- combine functions with expressions,
- use functions in `SELECT`,
- use functions in `WHERE`,
- use functions in `ORDER BY`,
- combine multiple functions in one query.

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

This lesson continues directly from Lesson 04.

The `BOOKS` table should contain:

```text
BOOK_ID
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

`SUBTITLE` should contain both non-NULL and NULL values.

No additional setup script is required.

Run:

```text
@lesson05.sql
```

---

# 3. What Is a SQL Function?

A SQL function takes input and returns a value.

Conceptually:

```text
input
  ↓
function
  ↓
result
```

For example:

```sql
UPPER(title)
```

might transform:

```text
SQL Fundamentals
```

into:

```text
SQL FUNDAMENTALS
```

The stored `TITLE` value is not changed.

The function transforms the value only for the query result.

---

# 4. Functions and Expressions

A function can be thought of as another way to create an expression.

For example:

```sql
price * 1.10
```

is an arithmetic expression.

This:

```sql
ROUND(price * 1.10)
```

combines an arithmetic expression with a function.

SQL allows expressions and functions to be combined to answer increasingly
useful questions.

---

# 5. Character Functions

Character functions operate on text values.

Common examples include:

```text
UPPER
LOWER
LENGTH
SUBSTR
```

---

## UPPER

`UPPER` converts character data to uppercase.

```sql
SELECT
    title,
    UPPER(title) AS upper_title
FROM books;
```

Example:

```text
SQL Fundamentals
        ↓
SQL FUNDAMENTALS
```

The original stored value is unchanged.

---

## LOWER

`LOWER` converts character data to lowercase.

```sql
SELECT
    title,
    LOWER(title) AS lower_title
FROM books;
```

Example:

```text
SQL Fundamentals
        ↓
sql fundamentals
```

---

## LENGTH

`LENGTH` returns the number of characters in a value.

```sql
SELECT
    title,
    LENGTH(title) AS title_length
FROM books;
```

This can be useful when examining data quality or display requirements.

---

## SUBSTR

`SUBSTR` extracts part of a character value.

```sql
SELECT
    title,
    SUBSTR(title, 1, 10) AS short_title
FROM books;
```

This means:

```text
start at character 1
return up to 10 characters
```

For example:

```text
SQL Fundamentals
        ↓
SQL Fundame
```

---

# 6. Numeric Functions

Functions can also operate on numeric values.

In this lesson, we use:

```text
ROUND
TRUNC
```

---

## ROUND

`ROUND` rounds a numeric value.

For example:

```sql
SELECT
    title,
    price,
    ROUND(price * 1.10) AS rounded_price
FROM books;
```

The expression:

```sql
price * 1.10
```

is evaluated and the result is passed to `ROUND`.

---

## ROUND with Decimal Places

The second argument can specify the number of decimal places.

```sql
ROUND(value, 2)
```

For example:

```sql
SELECT
    title,
    ROUND(price / 3, 2) AS price_per_part
FROM books;
```

This rounds the calculated result to two decimal places.

---

## TRUNC

`TRUNC` removes digits beyond the specified decimal position without rounding
them upward.

```sql
SELECT
    title,
    ROUND(price / 3, 2) AS rounded_value,
    TRUNC(price / 3, 2) AS truncated_value
FROM books;
```

Comparing these results helps demonstrate the difference between:

```text
ROUND
```

and:

```text
TRUNC
```

---

# 7. Handling NULL with NVL

Lesson 04 introduced `NULL`.

Some books in `BOOKS` do not have a subtitle.

For example:

```text
TITLE                         SUBTITLE
----------------------------  -----------------------------
SQL Fundamentals              A Practical Introduction...
Practical Machine Learning    NULL
```

Oracle provides `NVL` for replacing a `NULL` result with another value.

Syntax:

```sql
NVL(value, replacement)
```

Example:

```sql
SELECT
    title,
    NVL(subtitle, 'No subtitle') AS display_subtitle
FROM books;
```

Conceptually:

```text
SUBTITLE has a value
        ↓
use SUBTITLE

SUBTITLE is NULL
        ↓
use 'No subtitle'
```

This is useful when preparing data for reports and applications.

---

# 8. Handling NULL with COALESCE

`COALESCE` also helps handle missing values.

Example:

```sql
COALESCE(subtitle, title)
```

This means:

> Return the first non-NULL value.

If `SUBTITLE` exists, return it.

Otherwise, return `TITLE`.

```sql
SELECT
    book_id,
    title,
    subtitle,
    COALESCE(subtitle, title) AS display_name
FROM books;
```

Unlike Oracle-specific `NVL`, `COALESCE` is part of the SQL standard and can
accept more than two expressions.

For example:

```sql
COALESCE(value1, value2, value3)
```

returns the first non-NULL value.

---

# 9. Functions Can Be Nested

The result of one function can become the input of another function.

For example:

```sql
UPPER(NVL(subtitle, 'No subtitle'))
```

The inner function runs first:

```text
NVL
 ↓
replace NULL
 ↓
UPPER
 ↓
convert the result to uppercase
```

Example:

```sql
SELECT
    title,
    UPPER(NVL(subtitle, 'No subtitle')) AS display_subtitle
FROM books;
```

This is called nesting functions.

Nested functions are common in real SQL.

---

# 10. Functions in WHERE

Functions are not limited to the `SELECT` list.

They can also be used in conditions.

For example:

```sql
SELECT
    book_id,
    title
FROM books
WHERE UPPER(title) LIKE '%SQL%';
```

Here:

```text
TITLE
  ↓
UPPER
  ↓
LIKE '%SQL%'
```

The function transforms the value before the condition is evaluated.

This can be useful when a search should ignore differences between uppercase
and lowercase characters.

Performance considerations for functions in search conditions will be studied
later.

---

# 11. Functions in ORDER BY

Functions and calculated expressions can also be used when sorting.

For example:

```sql
SELECT
    book_id,
    title,
    LENGTH(title) AS title_length
FROM books
ORDER BY
    title_length DESC,
    book_id ASC;
```

This displays books with longer titles first.

The alias created in the `SELECT` list is used by `ORDER BY`.

---

# 12. Combining Functions and Expressions

Functions become especially useful when combined with expressions.

For example:

```sql
ROUND(price * stock, 2)
```

combines:

```text
PRICE
  ×
STOCK
  ↓
inventory value
  ↓
ROUND
```

The query might be:

```sql
SELECT
    book_id,
    title,
    ROUND(price * stock, 2) AS inventory_value
FROM books
WHERE stock > 0
ORDER BY inventory_value DESC;
```

This builds directly on the query patterns from Lesson 04.

---

# 13. Functions Do Not Modify Stored Data

Consider:

```sql
UPPER(title)
```

or:

```sql
NVL(subtitle, 'No subtitle')
```

These functions transform values in the query result.

They do not modify the stored values in `BOOKS`.

For example:

```sql
SELECT
    title,
    UPPER(title)
FROM books;
```

does not convert the stored title to uppercase.

This follows the same principle introduced with arithmetic expressions.

---

# 14. Building Function Queries Incrementally

Do not begin with a large nested expression.

Build the query step by step.

Start with:

```sql
SELECT
    title,
    subtitle
FROM books;
```

Then handle `NULL`:

```sql
SELECT
    title,
    NVL(subtitle, 'No subtitle') AS display_subtitle
FROM books;
```

Then transform the result:

```sql
SELECT
    title,
    UPPER(NVL(subtitle, 'No subtitle')) AS display_subtitle
FROM books;
```

A useful workflow remains:

```text
Write
  ↓
Execute
  ↓
Inspect
  ↓
Add one transformation
  ↓
Execute again
```

This is easier to debug than writing a complex expression all at once.

---

# 15. Exercises

## Exercise 1

Display every book title in uppercase.

Use:

```text
UPPER
```

---

## Exercise 2

Display every book title in lowercase.

Use:

```text
LOWER
```

---

## Exercise 3

Display:

```text
BOOK_ID
TITLE
TITLE_LENGTH
```

Calculate `TITLE_LENGTH` using `LENGTH`.

Show the longest titles first.

Use `BOOK_ID` as a tie-breaker.

---

## Exercise 4

Display the first 10 characters of every title.

Use:

```text
SUBSTR
```

---

## Exercise 5

Calculate:

```text
PRICE / 3
```

and display both:

```text
ROUND(..., 2)
TRUNC(..., 2)
```

Compare the results.

---

## Exercise 6

Display every book and its subtitle.

If the subtitle is `NULL`, display:

```text
No subtitle
```

Use `NVL`.

---

## Exercise 7

Use:

```text
COALESCE
```

to return:

```text
SUBTITLE
```

when it exists, otherwise:

```text
TITLE
```

---

## Exercise 8

Display subtitles in uppercase.

If a subtitle is missing, display:

```text
NO SUBTITLE
```

Build the result by nesting:

```text
UPPER
NVL
```

---

## Exercise 9

Find titles containing `SQL` using:

```sql
UPPER(title)
```

and:

```text
LIKE
```

---

## Exercise 10 — Business Question

The bookstore is preparing a simple catalog review.

Requirements:

- only books currently in stock,
- display `TITLE` in uppercase,
- display `SUBTITLE`,
- when `SUBTITLE` is NULL, display `No subtitle`,
- calculate `PRICE × STOCK` as `INVENTORY_VALUE`,
- round the inventory value to two decimal places,
- show the highest inventory value first,
- use `BOOK_ID` as a tie-breaker.

Translate the requirement into one SQL query.

---

# 16. Engineering Notes

## Functions transform values

A useful mental model is:

```text
stored value
    ↓
function
    ↓
transformed value
```

The transformed value normally exists only in the query result.

---

## NVL and COALESCE are related but different

Both can provide alternatives for `NULL`.

```sql
NVL(subtitle, 'No subtitle')
```

is a common Oracle pattern.

```sql
COALESCE(subtitle, title)
```

uses standard SQL semantics and can evaluate multiple alternatives.

We will prefer whichever communicates the intent most clearly.

---

## Functions can affect query performance

This condition is convenient:

```sql
WHERE UPPER(title) LIKE '%SQL%'
```

However, applying functions to columns in search conditions can affect how a
database accesses data.

Do not optimize prematurely in this lesson.

For now, understand the query behavior first.

Indexes and query performance will be explored later.

---

## Avoid unnecessary nesting

Functions can be nested:

```sql
UPPER(NVL(subtitle, 'No subtitle'))
```

but deeply nested expressions can become difficult to read.

Use functions because they communicate a transformation required by the
business logic, not simply because they are available.

---

# 17. Lesson Summary

In this lesson, we extended our SQL toolkit with functions.

You practiced:

```text
UPPER
LOWER
LENGTH
SUBSTR
ROUND
TRUNC
NVL
COALESCE
Nested functions
```

You also combined functions with concepts from previous lessons:

```text
Functions
    +
Expressions
    +
WHERE
    +
ORDER BY
```

Our query capabilities now look like:

```text
stored data
    ↓
SELECT
    ↓
expressions and functions
    ↓
WHERE
    ↓
ORDER BY
    ↓
useful information
```

---

# Next Lesson

Continue to:

```text
Lesson 06 — Aggregation and Grouping
```

So far, most queries have returned information about individual books.

In the next lesson, we will begin asking questions about sets of books:

```text
How many books are there?
What is the average price?
How much inventory exists?
How many books belong to each category?
```

This introduces:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
```

and moves us from row-level queries toward analytical SQL.