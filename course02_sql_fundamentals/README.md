# Course 02 — SQL Fundamentals

> Learn how to retrieve, filter, transform, and summarize data using SQL.

---

## Overview

In Course 01, you built the Oracle environment used throughout **SQL-Engineering-Lab**.

You prepared:

- Oracle Database Free
- `FREEPDB1`
- The `SQL_LAB` learning user
- The `SQL_LAB` schema
- The `FREEPDB1_DATA` tablespace
- SQL*Plus and Oracle SQL Developer
- Your first database table

The environment is now ready.

In Course 02, the focus moves from:

```text
How is the database environment organized?
```

to:

```text
How can we retrieve and understand data using SQL?
```

This course introduces the fundamental SQL techniques used to explore and analyze data.

Rather than learning SQL statements as isolated syntax, you will follow a simple data exploration workflow:

```text
Retrieve Data
      │
      ▼
Filter Rows
      │
      ▼
Sort Results
      │
      ▼
Transform Values
      │
      ▼
Use Functions
      │
      ▼
Summarize Data
```

These techniques form the foundation for the more advanced SQL topics introduced later in SQL-Engineering-Lab.

---

# Learning Objectives

After completing this course, you will be able to:

- Retrieve data using `SELECT`
- Select specific columns from a table
- Use column aliases
- Remove duplicate values using `DISTINCT`
- Filter rows using `WHERE`
- Use comparison operators
- Combine conditions using logical operators
- Work with `NULL`
- Sort query results using `ORDER BY`
- Create expressions from existing columns
- Use common SQL functions
- Perform calculations using SQL
- Summarize data using aggregate functions
- Group data using `GROUP BY`
- Filter grouped results using `HAVING`
- Read SQL queries as a sequence of logical operations
- Build increasingly complex queries from simple components

---

# Course Structure

| Lesson | Topic |
|--------|-------|
| Lesson 01 | SELECT Basics |
| Lesson 02 | Filtering Rows |
| Lesson 03 | Sorting Results |
| Lesson 04 | Expressions and NULL |
| Lesson 05 | SQL Functions |
| Lesson 06 | Aggregation and Grouping |

---

# Learning Flow

Complete the lessons in order.

```text
SELECT Basics
      │
      ▼
Filtering Rows
      │
      ▼
Sorting Results
      │
      ▼
Expressions and NULL
      │
      ▼
SQL Functions
      │
      ▼
Aggregation and Grouping
```

Each lesson adds another capability to the same basic SQL workflow.

By the end of the course, you will be able to move from a simple table query to a useful summary of the data.

---

# Directory Structure

```text
course02_sql_fundamentals/

├── README.md
│
├── lesson01_select_basics/
│   ├── lesson.md
│   └── lesson01.sql
│
├── lesson02_filtering_rows/
│   ├── lesson.md
│   └── lesson02.sql
│
├── lesson03_sorting_results/
│   ├── lesson.md
│   └── lesson03.sql
│
├── lesson04_expressions_and_null/
│   ├── lesson.md
│   └── lesson04.sql
│
├── lesson05_sql_functions/
│   ├── lesson.md
│   └── lesson05.sql
│
└── lesson06_aggregation_and_grouping/
    ├── lesson.md
    └── lesson06.sql
```

Additional files such as `setup.sql`, `cleanup.sql`, or sample data scripts may be introduced when required by a lesson.

---

# Learning Environment

The environment created in Course 01 will continue to be used.

| Item | Value |
|------|-------|
| Database | Oracle Database Free |
| PDB | `FREEPDB1` |
| Learning User | `SQL_LAB` |
| Learning Schema | `SQL_LAB` |
| Default Tablespace | `FREEPDB1_DATA` |

Unless otherwise specified, exercises should be executed as:

```text
SQL_LAB @ FREEPDB1
```

---

# Working with SQL

Before beginning an exercise, verify the current session.

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

The working pattern introduced in Course 01 remains important:

```text
Who am I?
Where am I?
What can I do?
```

Even when the focus moves to SQL queries, session context remains part of database engineering.

---

# From Environment to Data

Course 01 focused mainly on database infrastructure and metadata.

```text
Database
   ↓
PDB
   ↓
User
   ↓
Schema
   ↓
Tablespace
   ↓
Table
```

Course 02 continues from the table.

```text
Table
   ↓
Columns
   ↓
Rows
   ↓
Conditions
   ↓
Expressions
   ↓
Functions
   ↓
Groups
   ↓
Information
```

The goal is no longer simply to confirm that data exists.

The goal is to ask useful questions about that data.

---

# The SQL Query Building Process

Throughout this course, queries will gradually become more expressive.

A simple query might begin as:

```sql
SELECT *
FROM learning_topics;
```

Then select only the required columns:

```sql
SELECT
    topic_name,
    status
FROM learning_topics;
```

Then filter the rows:

```sql
SELECT
    topic_name,
    status
FROM learning_topics
WHERE status = 'PLANNED';
```

Then sort the result:

```sql
SELECT
    topic_name,
    status
FROM learning_topics
WHERE status = 'PLANNED'
ORDER BY topic_name;
```

Later, queries will include expressions, functions, and aggregation.

The goal is to understand how each clause adds meaning to the query.

---

# Course Dataset Strategy

The `LEARNING_TOPICS` table created in Course 01 provides a small starting dataset.

It is useful for introducing basic SQL because its structure is simple and already familiar.

However, SQL-Engineering-Lab will gradually introduce richer sample data as the lessons progress.

The long-term learning model is:

```text
Simple Table
     │
     ▼
Multiple Business Tables
     │
     ▼
Relationships
     │
     ▼
More Realistic Queries
     │
     ▼
Database Engineering
```

Rather than replacing the dataset for every topic, sample data will be developed progressively so that later lessons can build on earlier ones.

---

# Sample Data Story

As SQL-Engineering-Lab grows, the exercises will introduce a small fictional business dataset.

The planned scenario is a **Book Store Database**.

It may eventually include objects such as:

```text
BOOKS
AUTHORS
CUSTOMERS
ORDERS
ORDER_ITEMS
CATEGORIES
```

This dataset will allow later courses to explore:

- Filtering
- Aggregation
- Joins
- Subqueries
- Data modification
- Constraints
- Views
- Indexes
- Transactions
- Query performance

The database will be introduced gradually.

Course 02 begins with simple data and focuses on SQL fundamentals.

---

# Lesson 01 — SELECT Basics

The first lesson introduces the foundation of SQL queries.

Topics include:

```text
SELECT
FROM
*
Column Selection
Column Aliases
DISTINCT
```

The main question is:

```text
What data do I want to retrieve?
```

---

# Lesson 02 — Filtering Rows

The second lesson introduces conditions.

Topics include:

```text
WHERE
=
<>
>
<
>=
<=
BETWEEN
IN
LIKE
AND
OR
NOT
```

The main question becomes:

```text
Which rows do I need?
```

---

# Lesson 03 — Sorting Results

The third lesson introduces result ordering.

Topics include:

```text
ORDER BY
ASC
DESC
Multiple Sort Columns
```

The main question becomes:

```text
In what order should the result be displayed?
```

---

# Lesson 04 — Expressions and NULL

The fourth lesson introduces calculated expressions and missing values.

Topics include:

```text
Arithmetic Expressions
Column Expressions
NULL
IS NULL
IS NOT NULL
```

The main question becomes:

```text
How should values be interpreted or calculated?
```

---

# Lesson 05 — SQL Functions

The fifth lesson introduces functions that transform values.

Topics include:

```text
Character Functions
Numeric Functions
Date Functions
Conversion Functions
NULL Functions
```

Examples include:

```text
UPPER
LOWER
LENGTH
ROUND
SYSDATE
TO_CHAR
TO_DATE
NVL
```

The main question becomes:

```text
How can SQL transform data into a more useful form?
```

---

# Lesson 06 — Aggregation and Grouping

The final lesson introduces data summarization.

Topics include:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
```

Instead of looking only at individual rows, you will begin asking questions about groups of rows.

Examples:

```text
How many records exist?

What is the average value?

How many records belong to each category?

Which groups meet a specific condition?
```

This represents an important transition from retrieving data to analyzing data.

---

# SQL as a Data Exploration Language

SQL is more than a collection of commands.

A query represents a question about data.

For example:

```sql
SELECT
    status,
    COUNT(*) AS topic_count
FROM learning_topics
GROUP BY status
ORDER BY status;
```

can be interpreted as:

```text
Take the learning topics
        ↓
Group them by status
        ↓
Count the rows in each group
        ↓
Display the result by status
```

Throughout SQL-Engineering-Lab, you should practice understanding both:

```text
SQL Syntax
```

and:

```text
The Question Being Asked
```

The second is often more important.

---

# Engineering Notes

When writing SQL, avoid immediately trying to build a large query.

Start with the simplest possible query.

```text
SELECT
   ↓
Check Result
   ↓
Add WHERE
   ↓
Check Result
   ↓
Add Expressions
   ↓
Check Result
   ↓
Add GROUP BY
   ↓
Check Result
```

Building and verifying a query incrementally makes SQL easier to understand and troubleshoot.

This approach will be used throughout SQL-Engineering-Lab.

---

# Expected Outcome

By the end of Course 02, you should be comfortable writing queries that:

```text
Retrieve
   +
Filter
   +
Sort
   +
Transform
   +
Summarize
```

data.

For example, you should be able to understand the structure of a query such as:

```sql
SELECT
    status,
    COUNT(*) AS topic_count
FROM learning_topics
WHERE created_at IS NOT NULL
GROUP BY status
HAVING COUNT(*) >= 1
ORDER BY topic_count DESC;
```

You do not need to memorize SQL syntax.

Instead, you should understand how each clause contributes to the question being asked.

---

# Next Course

After completing this course, continue to the next stage of SQL-Engineering-Lab.

The next course will expand beyond single-table queries and introduce more advanced relational SQL concepts.

Topics will include concepts such as:

```text
Multiple Tables
Relationships
Joins
Subqueries
```

Course 02 provides the SQL foundation required for those topics.