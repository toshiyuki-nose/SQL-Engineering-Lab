# Lesson 01 — SELECT Basics

> Learn how to retrieve data from a table using the SELECT statement.

---

## Overview

In Course 01, you created your first table:

```text
LEARNING_TOPICS
```

and inserted sample data into it.

The database environment is ready, the table exists, and the data has been stored.

Now the focus changes from:

```text
Creating database objects
```

to:

```text
Reading data
```

The most fundamental SQL statement for reading data is:

```sql
SELECT
```

In this lesson, you will learn how to retrieve all columns, select specific columns, change the order of displayed columns, assign aliases, and retrieve unique values.

The goal is not to build complex queries yet.

The goal is to understand the basic structure of a SQL query.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Understand the basic purpose of `SELECT`
- Retrieve all columns from a table
- Retrieve specific columns
- Control the order of columns in query results
- Assign aliases to result columns
- Remove duplicate values using `DISTINCT`
- Read a basic `SELECT ... FROM ...` statement
- Verify the database session before executing SQL

---

# Recommended Setup

This lesson uses the Oracle environment created in Course 01.

Execute the exercises as:

```text
SQL_LAB @ FREEPDB1
```

The main table used in this lesson is:

```text
LEARNING_TOPICS
```

Its structure is:

| Column | Data Type | Description |
|---|---|---|
| `TOPIC_ID` | `NUMBER` | Identifier for the learning topic |
| `TOPIC_NAME` | `VARCHAR2(100)` | Name of the learning topic |
| `STATUS` | `VARCHAR2(20)` | Current learning status |
| `CREATED_AT` | `DATE` | Date and time when the row was created |

The sample data created in Course 01 contains topics such as:

```text
SQL Basics
SELECT
Filtering
Sorting
Joins
```

---

# 1. Verify the Session

Before querying the table, verify your current Oracle session.

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

You can also verify the current schema:

```sql
SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;
```

Expected result:

```text
CURRENT_USER    CONTAINER_NAME    CURRENT_SCHEMA
--------------- ----------------- ---------------
SQL_LAB         FREEPDB1          SQL_LAB
```

The habit introduced in Course 01 still applies:

```text
Who am I?
Where am I?
What can I see?
```

Even when working with simple queries, knowing the current session context helps prevent confusion.

---

# 2. What Is SELECT?

`SELECT` is used to retrieve data from the database.

A basic query has two important parts:

```sql
SELECT column
FROM table;
```

Conceptually:

```text
SELECT → What data do I want to see?

FROM   → Where does the data come from?
```

For example:

```sql
SELECT topic_name
FROM learning_topics;
```

can be read as:

```text
Retrieve TOPIC_NAME
from the LEARNING_TOPICS table.
```

SQL is easier to understand when you read the statement as a question about data rather than as a collection of keywords.

---

# 3. SELECT All Columns

The simplest way to inspect a table is to retrieve all its columns.

```sql
SELECT *
FROM learning_topics;
```

The asterisk:

```text
*
```

means:

```text
all columns
```

Therefore:

```sql
SELECT *
FROM learning_topics;
```

means:

```text
Retrieve all columns
from LEARNING_TOPICS.
```

The result contains:

```text
TOPIC_ID
TOPIC_NAME
STATUS
CREATED_AT
```

for every row currently stored in the table.

---

## When Is SELECT * Useful?

`SELECT *` is convenient when exploring a small or unfamiliar table.

For example:

```sql
SELECT *
FROM learning_topics;
```

quickly shows both the structure of the result and the stored values.

However, applications and production queries usually benefit from selecting only the columns that are actually required.

Instead of:

```sql
SELECT *
FROM learning_topics;
```

you may eventually prefer:

```sql
SELECT
    topic_id,
    topic_name
FROM learning_topics;
```

This makes the intended output explicit.

For learning and quick investigation, however, `SELECT *` is very useful.

---

# 4. SELECT Specific Columns

You do not need to retrieve every column.

Specify the columns you want after `SELECT`.

```sql
SELECT
    topic_id,
    topic_name
FROM learning_topics;
```

This query returns only:

```text
TOPIC_ID
TOPIC_NAME
```

The other columns still exist in the table.

They are simply not included in this query result.

This distinction is important:

```text
Table
│
├── TOPIC_ID
├── TOPIC_NAME
├── STATUS
└── CREATED_AT

        ↓ SELECT

Query Result
│
├── TOPIC_ID
└── TOPIC_NAME
```

A `SELECT` query does not remove the other columns from the table.

It determines which columns appear in the result.

---

# 5. Column Order

The order of columns in the result is determined by the order in which they are written in the `SELECT` list.

For example:

```sql
SELECT
    topic_id,
    topic_name,
    status
FROM learning_topics;
```

returns the columns in this order:

```text
TOPIC_ID
TOPIC_NAME
STATUS
```

But this query:

```sql
SELECT
    status,
    topic_name,
    topic_id
FROM learning_topics;
```

returns:

```text
STATUS
TOPIC_NAME
TOPIC_ID
```

The table itself has not changed.

Only the presentation of the query result has changed.

This illustrates an important idea:

```text
Table Structure
      ≠
Query Result Structure
```

A SQL query can present stored data in a form that is useful for a particular purpose.

---

# 6. Column Aliases

Sometimes the original column name is not the best label for a query result.

SQL allows you to assign an alias to a result column.

For example:

```sql
SELECT
    topic_name AS topic,
    status AS learning_status
FROM learning_topics;
```

The result column names become:

```text
TOPIC
LEARNING_STATUS
```

The original table columns are still:

```text
TOPIC_NAME
STATUS
```

The aliases only affect the query result.

---

## AS Keyword

The `AS` keyword makes an alias easy to recognize.

```sql
SELECT
    topic_name AS topic
FROM learning_topics;
```

Oracle also allows the alias without `AS`:

```sql
SELECT
    topic_name topic
FROM learning_topics;
```

Both forms work for column aliases.

In SQL-Engineering-Lab, we will generally use `AS` when it improves readability.

---

## Aliases with Spaces

An alias can contain spaces when it is enclosed in double quotation marks.

```sql
SELECT
    topic_name AS "Topic Name",
    status AS "Learning Status"
FROM learning_topics;
```

The output headings become:

```text
Topic Name
Learning Status
```

Quoted identifiers are case-sensitive and require more careful handling, so simple aliases are usually easier to work with in SQL code.

For example:

```sql
topic_name AS topic
```

is generally simpler than:

```sql
topic_name AS "Topic Name"
```

Use descriptive aliases when they make the result easier to understand.

---

# 7. DISTINCT

A column may contain the same value in multiple rows.

For example:

```sql
SELECT status
FROM learning_topics;
```

may return:

```text
READY
PLANNED
PLANNED
PLANNED
PLANNED
```

If you only want to know which different status values exist, use `DISTINCT`.

```sql
SELECT DISTINCT
    status
FROM learning_topics;
```

The result becomes conceptually:

```text
READY
PLANNED
```

`DISTINCT` removes duplicate rows from the query result.

It does not modify the data stored in the table.

---

## DISTINCT with Multiple Columns

`DISTINCT` can also be used with multiple columns.

For example:

```sql
SELECT DISTINCT
    status,
    topic_name
FROM learning_topics;
```

In this case, Oracle evaluates the combination of:

```text
STATUS + TOPIC_NAME
```

Two result rows are duplicates only when the selected values are the same across the complete selected combination.

Therefore, `DISTINCT` applies to the result row produced by the `SELECT` list, not independently to each column.

---

# 8. Reading a SELECT Statement

Consider this query:

```sql
SELECT
    topic_name AS topic,
    status AS learning_status
FROM learning_topics;
```

Read it from the perspective of the data question.

```text
What do I want?
    │
    ├── TOPIC_NAME
    └── STATUS
          │
          ▼
Where does it come from?
          │
          ▼
    LEARNING_TOPICS
```

Or in plain language:

```text
Retrieve the topic name and learning status
from the LEARNING_TOPICS table.
```

The SQL syntax is:

```text
SELECT
    ↓
Columns

FROM
    ↓
Table
```

This basic structure will remain at the center of much more advanced SQL.

Later lessons will add additional clauses.

```text
SELECT
FROM
WHERE
ORDER BY
GROUP BY
HAVING
```

But the fundamental question remains:

```text
What data do I want,
and where does it come from?
```

---

# 9. Building Queries Incrementally

When learning SQL, avoid trying to write a complicated query immediately.

Start with something simple.

```sql
SELECT *
FROM learning_topics;
```

Verify the result.

Then select only the required columns.

```sql
SELECT
    topic_id,
    topic_name
FROM learning_topics;
```

Verify again.

Then add aliases if useful.

```sql
SELECT
    topic_id AS id,
    topic_name AS topic
FROM learning_topics;
```

This creates a useful working pattern:

```text
Write
  ↓
Execute
  ↓
Inspect
  ↓
Change
  ↓
Execute Again
```

This incremental approach becomes increasingly important as SQL queries become more complex.

---

# 10. Exercises

Complete the following exercises using `LEARNING_TOPICS`.

Do not use `WHERE` or `ORDER BY` yet.

Those concepts will be introduced in later lessons.

---

## Exercise 1 — Retrieve Everything

Retrieve all columns from `LEARNING_TOPICS`.

Expected query structure:

```text
SELECT *
FROM ...
```

---

## Exercise 2 — Retrieve Topic Names

Display only:

```text
TOPIC_NAME
```

from `LEARNING_TOPICS`.

---

## Exercise 3 — Retrieve Multiple Columns

Display:

```text
TOPIC_ID
TOPIC_NAME
STATUS
```

---

## Exercise 4 — Change the Display Order

Display the columns in this order:

```text
STATUS
TOPIC_NAME
TOPIC_ID
```

Compare the result with Exercise 3.

Did the underlying table structure change?

---

## Exercise 5 — Use Aliases

Display:

```text
TOPIC_NAME
STATUS
```

using these aliases:

```text
TOPIC
LEARNING_STATUS
```

---

## Exercise 6 — Find Unique Status Values

Display the unique values stored in:

```text
STATUS
```

Use:

```text
DISTINCT
```

How many different status values currently exist?

---

## Exercise 7 — Read the Query

Explain this query in plain language:

```sql
SELECT DISTINCT
    status
FROM learning_topics;
```

Try to describe:

```text
What is being retrieved?

Where does the data come from?

What does DISTINCT change?
```

---

# 11. Engineering Notes

## SELECT Does Not Modify Data

The queries in this lesson retrieve data.

For example:

```sql
SELECT *
FROM learning_topics;
```

does not change the table.

This is fundamentally different from statements such as:

```text
INSERT
UPDATE
DELETE
```

which modify stored data.

You will work with data modification statements in a later course.

---

## Result Sets Are Not Tables

A query produces a result set.

For example:

```sql
SELECT
    topic_name,
    status
FROM learning_topics;
```

produces a result containing two columns.

That does not mean a new table has been created.

Conceptually:

```text
Stored Table
     │
     ▼
SELECT Query
     │
     ▼
Result Set
```

The query result is a representation of the data requested by the SQL statement.

---

## Column Selection Is Intent

Compare:

```sql
SELECT *
FROM learning_topics;
```

with:

```sql
SELECT
    topic_name,
    status
FROM learning_topics;
```

The second query communicates more clearly what information is actually needed.

As queries and tables become larger, explicitly selecting required columns becomes increasingly useful for:

- Readability
- Maintainability
- Understanding query intent
- Avoiding unnecessary data retrieval

A good SQL query should communicate its purpose to both the database and the person reading the code.

---

## SQL Keywords and Formatting

SQL keywords are not generally case-sensitive.

For example:

```sql
select topic_name
from learning_topics;
```

and:

```sql
SELECT topic_name
FROM learning_topics;
```

represent the same SQL statement.

In SQL-Engineering-Lab, SQL keywords will generally be written in uppercase:

```sql
SELECT
FROM
WHERE
ORDER BY
```

while table and column names will generally be written in lowercase:

```sql
learning_topics
topic_name
status
```

This is a formatting convention for readability.

It does not change the meaning of the query.

---

# 12. Lesson Summary

In this lesson, you learned the foundation of SQL data retrieval.

The basic structure is:

```sql
SELECT
    columns
FROM table;
```

You learned how to:

```text
Retrieve all columns
        │
        ▼
Select specific columns
        │
        ▼
Control column order
        │
        ▼
Assign aliases
        │
        ▼
Retrieve distinct values
```

The key concepts are:

```text
SELECT   → What do I want to retrieve?

FROM     → Where does the data come from?

*        → All columns

AS       → Give a result column another name

DISTINCT → Remove duplicate result rows
```

Most importantly, a `SELECT` query should be understood as a question about data.

---

# Next Lesson

In this lesson, every row in `LEARNING_TOPICS` was available to the query.

But in real analysis, we rarely need every row.

We may want questions such as:

```text
Which topics are still PLANNED?

Which records meet a particular condition?

Which values fall within a certain range?

Which names match a pattern?
```

To answer those questions, we need to filter rows.

Continue to:

```text
Lesson 02 — Filtering Rows
```

The next lesson introduces:

```text
WHERE
Comparison Operators
AND
OR
NOT
BETWEEN
IN
LIKE
```