# Course 03 — Multiple Tables and Relationships

> Learn how relational databases connect data across multiple tables.

---

## Overview

In Course 02, you learned how to retrieve, filter, transform, sort, and summarize
data stored in a single table.

The main table was:

```text
BOOKS
```

Using this table, you practiced:

```text
SELECT
WHERE
ORDER BY
Expressions
NULL
SQL Functions
Aggregate Functions
GROUP BY
HAVING
```

By the end of Course 02, you were able to write analytical queries such as:

```sql
SELECT
    category,
    COUNT(*) AS book_count,
    ROUND(AVG(price), 2) AS average_price,
    SUM(stock) AS total_stock,
    SUM(price * stock) AS inventory_value
FROM books
WHERE stock > 0
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY
    inventory_value DESC,
    category ASC;
```

However, real database systems rarely consist of only one table.

A bookstore needs to manage information about:

```text
Books
Authors
Categories
Customers
Orders
Order Items
```

Storing all of this information in a single table would create duplication,
inconsistency, and maintenance problems.

Course 03 introduces the relational model used to organize this information
across multiple tables.

The focus moves from:

```text
Querying one table
```

to:

```text
Designing relationships
        ↓
Connecting tables
        ↓
Querying related data
```

---

# Learning Objectives

After completing this course, you will be able to:

- Understand why relational databases use multiple tables
- Understand entities and relationships
- Understand primary keys
- Understand foreign keys
- Understand one-to-many relationships
- Understand many-to-many relationships
- Create related tables
- Define foreign key constraints
- Understand referential integrity
- Read basic relationship diagrams
- Combine tables using `INNER JOIN`
- Understand how unmatched rows behave
- Use outer joins
- Join three or more tables
- Use table aliases effectively
- Understand the difference between joins and subqueries
- Write basic subqueries
- Translate business relationships into SQL queries

---

# Course Structure

| Lesson | Topic |
|--------|-------|
| Lesson 01 | Relational Database Basics |
| Lesson 02 | Creating Related Tables |
| Lesson 03 | INNER JOIN |
| Lesson 04 | OUTER JOIN |
| Lesson 05 | Multiple Table Joins |
| Lesson 06 | Subqueries |

---

# Learning Flow

Complete the lessons in order.

```text
Relational Database Basics
            │
            ▼
Creating Related Tables
            │
            ▼
INNER JOIN
            │
            ▼
OUTER JOIN
            │
            ▼
Multiple Table Joins
            │
            ▼
Subqueries
```

Each lesson expands the same Book Store Database introduced in Course 02.

The database itself will grow together with the lessons.

---

# Directory Structure

```text
course03_multiple_tables_and_relationships/
│
├── README.md
│
├── lesson01_relational_database_basics/
│   ├── lesson.md
│   └── lesson01.sql
│
├── lesson02_creating_related_tables/
│   ├── lesson.md
│   ├── setup.sql
│   └── lesson02.sql
│
├── lesson03_inner_join/
│   ├── lesson.md
│   └── lesson03.sql
│
├── lesson04_outer_join/
│   ├── lesson.md
│   └── lesson04.sql
│
├── lesson05_multiple_table_joins/
│   ├── lesson.md
│   └── lesson05.sql
│
└── lesson06_subqueries/
    ├── lesson.md
    └── lesson06.sql
```

Additional setup or cleanup scripts may be introduced when required by a
lesson.

---

# Learning Environment

The Oracle environment created in Course 01 continues to be used.

| Item | Value |
|------|-------|
| Database | Oracle Database 23ai Free |
| PDB | `FREEPDB1` |
| Learning User | `SQL_LAB` |
| Learning Schema | `SQL_LAB` |
| Default Tablespace | `FREEPDB1_DATA` |
| SQL Client | SQL*Plus / Oracle SQL Developer |

Unless otherwise specified, exercises should be executed as:

```text
SQL_LAB @ FREEPDB1
```

Before beginning an exercise, verify the current session.

```text
SHOW USER
SHOW CON_NAME
```

Expected environment:

```text
USER     : SQL_LAB
CON_NAME : FREEPDB1
```

When administrative operations are required, a separate terminal may be opened
using:

```text
SYS @ FREEPDB1
```

Keeping separate terminals for the learning user and administrative user makes
the current execution context easier to understand.

---

# Continuing the Book Store Database

Course 02 introduced the first table in the Book Store Database:

```text
BOOKS
```

The table currently contains information such as:

```text
BOOK_ID
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

This was sufficient for learning single-table SQL.

However, some of this information represents independent business concepts.

For example:

```text
Book
Author
Category
```

These concepts should not necessarily be stored as repeated text inside one
large table.

Course 03 begins separating these concepts into related tables.

---

# From One Table to Multiple Tables

Imagine storing the author's name directly in `BOOKS`.

```text
BOOKS

BOOK_ID | TITLE                    | AUTHOR
--------+--------------------------+----------------
1001    | SQL Fundamentals         | Alice Johnson
1002    | Advanced SQL Engineering | Alice Johnson
1003    | Database Design Basics   | Alice Johnson
```

The author name would be repeated.

If the author's information changed, several rows might need to be updated.

Instead, relational databases allow us to separate the information.

```text
AUTHORS

AUTHOR_ID | AUTHOR_NAME
----------+----------------
1         | Alice Johnson
```

and:

```text
BOOKS

BOOK_ID | TITLE                    | AUTHOR_ID
--------+--------------------------+----------
1001    | SQL Fundamentals         | 1
1002    | Advanced SQL Engineering | 1
1003    | Database Design Basics   | 1
```

Now the relationship is represented using an identifier.

This is one of the central ideas of relational database design.

---

# Entities

An entity represents a business concept about which the database stores
information.

Examples in the Book Store Database include:

```text
BOOK
AUTHOR
CATEGORY
CUSTOMER
ORDER
```

Entities are commonly represented by tables.

For example:

```text
Entity
  ↓
BOOK
  ↓
BOOKS table
```

Each row represents an instance of that entity.

---

# Primary Keys

A primary key uniquely identifies a row.

The existing `BOOKS` table already uses:

```text
BOOK_ID
```

as its primary key.

Conceptually:

```text
BOOKS
----------------------------
BOOK_ID  ← Primary Key
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

No two books should have the same `BOOK_ID`.

Primary keys allow other tables to refer to a specific row reliably.

---

# Foreign Keys

A foreign key represents a relationship with another table.

For example:

```text
AUTHORS
----------------
AUTHOR_ID  PK
AUTHOR_NAME
```

and:

```text
BOOKS
----------------
BOOK_ID    PK
TITLE
AUTHOR_ID  FK
```

The relationship becomes:

```text
AUTHORS
   │
   │ AUTHOR_ID
   │
   └──────────────< BOOKS
                       AUTHOR_ID
```

`BOOKS.AUTHOR_ID` refers to:

```text
AUTHORS.AUTHOR_ID
```

The database can enforce this relationship using a foreign key constraint.

---

# Referential Integrity

A foreign key helps prevent invalid relationships.

Suppose:

```text
AUTHORS

AUTHOR_ID
---------
1
2
3
```

Then a book should not normally reference:

```text
AUTHOR_ID = 999
```

if author `999` does not exist.

A foreign key constraint allows Oracle to enforce this rule.

Conceptually:

```text
BOOKS.AUTHOR_ID
       │
       ▼
Does this AUTHOR_ID exist in AUTHORS?
       │
       ├── Yes → relationship allowed
       │
       └── No  → relationship rejected
```

This is called referential integrity.

---

# One-to-Many Relationships

A common relationship is:

```text
One Author
    ↓
Many Books
```

Conceptually:

```text
AUTHORS
   1
   │
   │
   N
 BOOKS
```

One author can be related to multiple books.

This type of relationship is called:

```text
One-to-Many
```

Foreign keys are commonly used to represent this relationship.

---

# Many-to-Many Relationships

Some relationships are more complex.

A book can have multiple authors.

An author can also write multiple books.

Therefore:

```text
BOOKS
  N
  │
  │
  N
AUTHORS
```

represents a many-to-many relationship.

Relational databases normally represent this using an intermediate table.

For example:

```text
BOOKS
   │
   │
   └──< BOOK_AUTHORS >──┐
                        │
                     AUTHORS
```

The intermediate table might contain:

```text
BOOK_AUTHORS

BOOK_ID
AUTHOR_ID
```

Each row represents one relationship between a book and an author.

This pattern will become important as the Book Store Database becomes more
realistic.

---

# Planned Book Store Model

During Course 03, the Book Store Database will begin moving toward a structure
such as:

```text
CATEGORIES
     │
     │
     └────< BOOKS
              │
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

Conceptually:

```text
CATEGORIES
----------
CATEGORY_ID
CATEGORY_NAME


BOOKS
-----
BOOK_ID
TITLE
CATEGORY_ID
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE


AUTHORS
-------
AUTHOR_ID
AUTHOR_NAME


BOOK_AUTHORS
------------
BOOK_ID
AUTHOR_ID
```

The exact model will be introduced gradually.

We will not create the entire final database at once.

Each new object will be introduced when its purpose becomes clear.

---

# Why Build the Database Gradually?

A common mistake when learning databases is to begin with a large schema before
understanding why each table exists.

SQL-Engineering-Lab uses a different approach.

```text
Business Requirement
        ↓
Identify Entity
        ↓
Create Table
        ↓
Define Key
        ↓
Create Relationship
        ↓
Insert Data
        ↓
Query the Relationship
```

This allows database structure and SQL syntax to be learned together.

The goal is not only to learn:

```text
How do I write a JOIN?
```

but also:

```text
Why are these tables joined in the first place?
```

---

# Lesson 01 — Relational Database Basics

The first lesson introduces the concepts behind multiple-table databases.

Topics include:

```text
Entities
Tables
Rows
Primary Keys
Foreign Keys
Relationships
Referential Integrity
One-to-Many
Many-to-Many
```

The main question is:

```text
Why do relational databases divide information into multiple tables?
```

This lesson focuses primarily on understanding and inspecting relationships
before building more database objects.

---

# Lesson 02 — Creating Related Tables

The second lesson begins expanding the Book Store Database.

You will create additional tables and relationships.

Topics include:

```text
CREATE TABLE
PRIMARY KEY
FOREIGN KEY
REFERENCES
Constraints
Referential Integrity
```

You will also verify the relationships using Oracle metadata.

The main question becomes:

```text
How does Oracle enforce relationships between tables?
```

---

# Lesson 03 — INNER JOIN

Once related tables exist, we need a way to retrieve information from them
together.

This lesson introduces:

```text
INNER JOIN
JOIN ... ON
Table Aliases
Qualified Column Names
```

For example:

```sql
SELECT
    b.title,
    a.author_name
FROM books b
JOIN book_authors ba
    ON b.book_id = ba.book_id
JOIN authors a
    ON ba.author_id = a.author_id;
```

Instead of reading one table in isolation, SQL follows relationships between
tables.

The main question becomes:

```text
How can related rows be combined into one result?
```

---

# Lesson 04 — OUTER JOIN

An `INNER JOIN` returns matching relationships.

But real data often contains rows without matching data.

For example:

```text
A book may not yet have an author relationship.

An author may exist before any books are registered.
```

This lesson introduces:

```text
LEFT OUTER JOIN
RIGHT OUTER JOIN
FULL OUTER JOIN
```

The main question becomes:

```text
What should happen when related data does not exist?
```

Understanding unmatched rows is essential for reliable reporting and data
analysis.

---

# Lesson 05 — Multiple Table Joins

Real queries often require more than two tables.

For example:

```text
BOOKS
  ↓
BOOK_AUTHORS
  ↓
AUTHORS
```

or:

```text
CATEGORIES
  ↓
BOOKS
  ↓
BOOK_AUTHORS
  ↓
AUTHORS
```

This lesson combines several relationships in one query.

Topics include:

```text
Multiple JOINs
Table Aliases
Join Conditions
Column Qualification
Reading Multi-Table Queries
```

The goal is to learn how to follow a relationship path through a relational
schema.

---

# Lesson 06 — Subqueries

Joins are not the only way to use information from multiple sets of data.

A query can also contain another query.

For example:

```sql
SELECT
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);
```

The inner query calculates:

```text
Average Book Price
```

The outer query then asks:

```text
Which books cost more than that average?
```

This lesson introduces:

```text
Subqueries
Single-Row Subqueries
Multiple-Row Subqueries
IN with Subqueries
Basic Correlated Subquery Concepts
```

The main question becomes:

```text
How can the result of one query be used by another query?
```

---

# JOINs and Subqueries

JOINs and subqueries solve related but different problems.

A simplified mental model is:

```text
JOIN
  ↓
Combine related rows

Subquery
  ↓
Use one query result inside another query
```

For example:

```text
JOIN
----
Show each book together with its author.

Subquery
--------
Show books priced above the average book price.
```

As SQL becomes more advanced, the same business problem may sometimes be
expressed in multiple ways.

At this stage, the goal is to understand each technique clearly before
comparing alternatives.

---

# Reading Relationship Diagrams

Throughout Course 03, diagrams will become increasingly important.

For example:

```text
CATEGORIES
    │
    │ 1
    │
    │ N
  BOOKS
    │
    │ N
    │
    │ N
 AUTHORS
```

However, a many-to-many relationship requires an intermediate table:

```text
CATEGORIES
     │
     │
     └────< BOOKS
              │
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

When reading a relationship diagram, ask:

```text
What does each table represent?

What uniquely identifies each row?

Which columns connect the tables?

What relationship exists between the entities?
```

These questions are often more important than memorizing JOIN syntax.

---

# Query Development Workflow

The incremental workflow used in Course 02 continues.

Do not begin with a large multi-table query.

Start by inspecting each table.

```sql
SELECT *
FROM books;
```

Then inspect the related table.

```sql
SELECT *
FROM authors;
```

Then verify the relationship data.

```sql
SELECT *
FROM book_authors;
```

Finally, introduce the join.

```text
Inspect Table A
      ↓
Inspect Table B
      ↓
Identify PK / FK
      ↓
Write JOIN condition
      ↓
Execute
      ↓
Inspect result
      ↓
Add another table
```

This makes relationship problems much easier to troubleshoot.

---

# Working with Multiple SQL*Plus Sessions

Course 03 continues the working pattern introduced earlier.

When administrative verification is useful, keep separate terminals open.

For example:

```text
Terminal 1
----------
SQL_LAB @ FREEPDB1

Purpose:
Create learning objects
Insert sample data
Execute lesson queries
Test relationships


Terminal 2
----------
SYS @ FREEPDB1

Purpose:
Inspect database metadata
Verify users and objects
Perform administrative checks when required
```

Always verify:

```text
Who am I?

Which container am I using?

Which schema am I working with?
```

before performing database operations.

---

# Engineering Perspective

Relationships are not simply a SQL syntax feature.

They represent rules about the data.

For example:

```text
A BOOK_AUTHOR relationship must refer to an existing BOOK.

A BOOK_AUTHOR relationship must refer to an existing AUTHOR.
```

These are business rules represented in database structure.

A database engineer therefore needs to understand both:

```text
SQL
```

and:

```text
Data Relationships
```

Course 03 begins connecting these two perspectives.

---

# Expected Outcome

By the end of Course 03, you should be able to look at a small relational model
such as:

```text
CATEGORIES
     │
     └────< BOOKS
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

and understand:

```text
What each table represents

Which columns are primary keys

Which columns are foreign keys

How the tables are related

How Oracle enforces those relationships

How to retrieve related information using JOIN

How unmatched rows affect query results

How to follow relationships across multiple tables

How subqueries can use the results of other queries
```

The goal is to move from:

```text
I can query a table.
```

to:

```text
I can understand and query a relational data model.
```

---

# Course Progression

The SQL-Engineering-Lab progression now becomes:

```text
Course 01
Oracle Environment
      │
      ▼
Course 02
SQL Fundamentals
      │
      ▼
Course 03
Multiple Tables and Relationships
```

Course 01 established:

```text
Where SQL runs
```

Course 02 established:

```text
How to query data
```

Course 03 establishes:

```text
How data is related
```

This forms the foundation for more advanced database engineering topics later
in SQL-Engineering-Lab.

---

# Next Step

Begin with:

```text
Lesson 01 — Relational Database Basics
```

Before creating additional tables, we will first examine the relational
concepts that determine how those tables should be designed.

The database will then grow one relationship at a time.