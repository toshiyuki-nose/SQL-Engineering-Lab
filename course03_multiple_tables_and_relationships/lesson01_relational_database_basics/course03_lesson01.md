# Lesson 01 — Relational Database Basics

> Understand how relational databases organize data using tables, keys, and relationships.

---

# Overview

In Course 02, we worked mainly with one table:

```text
BOOKS
```

Using this table, we learned how to:

```text
Retrieve
Filter
Sort
Transform
Aggregate
```

However, real database systems rarely store all business information in one
table.

A bookstore may need to manage:

```text
Books
Authors
Categories
Customers
Orders
```

These are different business concepts.

Relational databases organize these concepts into separate tables and connect
them using relationships.

Before writing `JOIN` queries, we need to understand how these relationships
are represented.

This lesson introduces the fundamental concepts behind relational database
design.

---

# 1. Learning Objectives

After completing this lesson, you will be able to:

- Understand the concept of an entity
- Understand how entities are represented by tables
- Understand rows and columns
- Understand primary keys
- Understand foreign keys
- Understand referential integrity
- Understand one-to-many relationships
- Understand many-to-many relationships
- Understand why junction tables are used
- Inspect table and constraint metadata in Oracle
- Read a simple relational database diagram

---

# 2. Learning Environment

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
USER
----
SQL_LAB

CON_NAME
--------
FREEPDB1
```

This lesson uses the `BOOKS` table created during Course 02.

No new tables are created in this lesson.

---

# 3. From Business Concepts to Tables

Consider a bookstore.

The business manages several types of information:

```text
Books
Authors
Categories
Customers
Orders
```

Each of these represents a separate concept.

In database design, such a concept is commonly called an:

```text
Entity
```

For example:

```text
Business Concept
      ↓
     Book
      ↓
    Entity
      ↓
BOOKS Table
```

A table stores information about instances of an entity.

---

# 4. Rows and Columns

Consider the existing `BOOKS` table.

```text
BOOKS

BOOK_ID
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

Each column represents an attribute of a book.

For example:

```text
BOOK_ID         → identifier
TITLE           → book title
CATEGORY        → category
PRICE           → selling price
STOCK           → current stock
PUBLISHED_YEAR  → publication year
SUBTITLE        → optional subtitle
```

Each row represents one book.

Conceptually:

```text
BOOKS
│
├── Row → Book 1001
├── Row → Book 1002
├── Row → Book 1003
└── ...
```

This leads to an important mental model:

```text
Table
  ↓
Entity Type

Row
  ↓
One Entity Instance

Column
  ↓
Entity Attribute
```

---

# 5. Inspecting BOOKS

Oracle provides commands and data dictionary views that allow us to inspect
database objects.

Start with:

```sql
DESCRIBE books
```

This shows the columns and data types of the table.

We can also query:

```sql
SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'BOOKS';
```

`USER_TABLES` contains information about tables owned by the current user.

Because we are connected as:

```text
SQL_LAB
```

the query shows tables owned by the `SQL_LAB` schema.

---

# 6. Primary Keys

A primary key uniquely identifies a row in a table.

The `BOOKS` table uses:

```text
BOOK_ID
```

as its primary key.

Conceptually:

```text
BOOKS
--------------------------
BOOK_ID          PK
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

For example:

```text
BOOK_ID
-------
1001
1002
1003
...
```

Each value identifies one specific book.

A primary key must not contain duplicate values.

It also cannot contain `NULL`.

---

# 7. Primary Key Constraint

In Course 02, the primary key was defined using:

```sql
CONSTRAINT pk_books PRIMARY KEY (book_id)
```

The constraint has a name:

```text
PK_BOOKS
```

Oracle stores information about constraints in data dictionary views.

For objects owned by the current user, we can inspect:

```text
USER_CONSTRAINTS
USER_CONS_COLUMNS
```

For example:

```sql
SELECT
    constraint_name,
    constraint_type,
    table_name,
    status
FROM user_constraints
WHERE table_name = 'BOOKS';
```

For Oracle constraints:

```text
P = Primary Key
R = Referential / Foreign Key
U = Unique
C = Check
```

The `BOOKS` table should contain the primary key constraint:

```text
PK_BOOKS
```

---

# 8. Inspecting Primary Key Columns

`USER_CONSTRAINTS` tells us that a constraint exists.

`USER_CONS_COLUMNS` tells us which columns belong to that constraint.

Example:

```sql
SELECT
    constraint_name,
    table_name,
    column_name,
    position
FROM user_cons_columns
WHERE table_name = 'BOOKS'
ORDER BY
    constraint_name,
    position;
```

For the primary key, we should find:

```text
PK_BOOKS
    ↓
BOOK_ID
```

This is useful when inspecting database schemas that you did not design
yourself.

---

# 9. Why Do We Need Keys?

Imagine identifying books only by title.

For example:

```text
Database Design Basics
```

A title is meaningful to humans, but it may not always be guaranteed to be
unique.

Instead, we use an identifier:

```text
BOOK_ID = 1003
```

This gives the database a stable way to identify the row.

Conceptually:

```text
Human-readable value
TITLE
    ↓
Useful for display

Stable identifier
BOOK_ID
    ↓
Useful for relationships
```

Keys become especially important when multiple tables are introduced.

---

# 10. The Problem with Repeated Data

The current `BOOKS` table contains:

```text
CATEGORY
```

as text.

For example:

```text
BOOK_ID | TITLE                     | CATEGORY
--------+---------------------------+-------------
1001    | SQL Fundamentals          | Technology
1002    | Advanced SQL Engineering  | Technology
1003    | Database Design Basics    | Technology
```

The value:

```text
Technology
```

appears repeatedly.

For our small learning table, this is easy to understand.

But imagine a much larger system containing thousands of books.

Repeated descriptive values can create maintenance problems.

For example, inconsistent values might appear:

```text
Technology
technology
Tech
TECHNOLOGY
```

These values may represent the same business concept but are stored
differently.

---

# 11. Separating an Entity

Instead of storing the category name repeatedly, we could create a separate
table.

Conceptually:

```text
CATEGORIES

CATEGORY_ID | CATEGORY_NAME
------------+--------------
10          | Technology
20          | Data Science
30          | Business
40          | History
50          | Environment
```

Then `BOOKS` could store:

```text
BOOK_ID | TITLE                    | CATEGORY_ID
--------+--------------------------+------------
1001    | SQL Fundamentals         | 10
1002    | Advanced SQL Engineering | 10
1003    | Database Design Basics   | 10
```

Now:

```text
CATEGORY_ID = 10
```

refers to:

```text
Technology
```

stored in `CATEGORIES`.

---

# 12. Foreign Keys

A foreign key is a column, or group of columns, that refers to a key in another
table.

For example:

```text
CATEGORIES
----------------
CATEGORY_ID   PK
CATEGORY_NAME


BOOKS
----------------
BOOK_ID       PK
TITLE
CATEGORY_ID   FK
```

The relationship is:

```text
CATEGORIES.CATEGORY_ID
          │
          │
          └────< BOOKS.CATEGORY_ID
```

`BOOKS.CATEGORY_ID` would be a foreign key.

---

# 13. Parent and Child Tables

In a foreign key relationship, we often describe the tables as:

```text
Parent Table
Child Table
```

For example:

```text
CATEGORIES
    │
    │ parent
    │
    └────< BOOKS
             child
```

`CATEGORIES` contains the referenced row.

`BOOKS` contains the foreign key.

Therefore:

```text
CATEGORIES = Parent

BOOKS = Child
```

One category can be related to many books.

---

# 14. One-to-Many Relationships

The relationship between categories and books is:

```text
One Category
      ↓
Many Books
```

This is called:

```text
One-to-Many
```

and can be represented as:

```text
CATEGORIES
     1
     │
     │
     N
   BOOKS
```

For example:

```text
Technology
   │
   ├── SQL Fundamentals
   ├── Advanced SQL Engineering
   ├── Database Design Basics
   └── SQL Query Practice
```

One category is associated with several books.

---

# 15. Referential Integrity

Suppose the following categories exist:

```text
CATEGORY_ID
-----------
10
20
30
40
50
```

Now imagine trying to create a book with:

```text
CATEGORY_ID = 999
```

If category `999` does not exist, the relationship would be invalid.

A foreign key constraint allows Oracle to prevent this.

Conceptually:

```text
BOOKS.CATEGORY_ID = 999
          │
          ▼
Search CATEGORIES
          │
          ▼
CATEGORY_ID 999 exists?
          │
     ┌────┴────┐
    YES        NO
     │          │
  Accept      Reject
```

This protection is called:

```text
Referential Integrity
```

---

# 16. Foreign Key Constraints

A foreign key can be defined conceptually as:

```sql
CONSTRAINT fk_books_category
    FOREIGN KEY (category_id)
    REFERENCES categories (category_id)
```

We will create real foreign key constraints in Lesson 02.

For now, focus on the relationship:

```text
Child Column
BOOKS.CATEGORY_ID

        ↓ references

Parent Column
CATEGORIES.CATEGORY_ID
```

---

# 17. Authors Are More Complicated

Categories provide a straightforward one-to-many example.

Authors introduce another problem.

A book may have:

```text
one author
```

but it may also have:

```text
multiple authors
```

At the same time, one author may write multiple books.

Therefore:

```text
One Book
   ↓
Many Authors

One Author
   ↓
Many Books
```

This creates a:

```text
Many-to-Many Relationship
```

---

# 18. Many-to-Many Relationships

Conceptually:

```text
BOOKS
  N
  │
  │
  N
AUTHORS
```

Relational databases normally resolve this using an intermediate table.

For example:

```text
BOOKS
   │
   │
   └────< BOOK_AUTHORS >──── AUTHORS
```

`BOOK_AUTHORS` represents the relationship itself.

---

# 19. Junction Tables

An intermediate table used to represent a many-to-many relationship is often
called a:

```text
Junction Table
```

or:

```text
Associative Table
```

For example:

```text
BOOK_AUTHORS

BOOK_ID
AUTHOR_ID
```

Sample data might look like:

```text
BOOK_ID | AUTHOR_ID
--------+----------
1001    | 501
1002    | 501
1002    | 502
```

This means:

```text
Book 1001
    → Author 501

Book 1002
    → Author 501
    → Author 502
```

The relationship itself is represented as rows.

---

# 20. Keys in a Junction Table

A junction table normally contains foreign keys to both related tables.

Conceptually:

```text
BOOKS
BOOK_ID PK
   │
   │
   ▼
BOOK_AUTHORS
BOOK_ID   FK
AUTHOR_ID FK
   ▲
   │
   │
AUTHORS
AUTHOR_ID PK
```

The pair:

```text
BOOK_ID
AUTHOR_ID
```

can also be used together to identify one relationship uniquely.

This is an example of a key consisting of multiple columns.

We will explore these structures practically as the Book Store Database grows.

---

# 21. Current Model vs Future Model

At the beginning of Course 03, our database still looks approximately like:

```text
BOOKS
----------------
BOOK_ID PK
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

During this course, it will begin evolving toward:

```text
CATEGORIES
     │
     └────< BOOKS
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

This evolution is intentional.

We will not create the entire model in one step.

Instead:

```text
Understand
    ↓
Design
    ↓
Create
    ↓
Verify
    ↓
Query
```

---

# 22. Reading a Relationship Diagram

Consider:

```text
CATEGORIES
     │
     └────< BOOKS
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

Ask four questions.

### Question 1

What does each table represent?

```text
CATEGORIES
    → book categories

BOOKS
    → books

AUTHORS
    → authors

BOOK_AUTHORS
    → relationships between books and authors
```

### Question 2

What identifies each entity?

```text
CATEGORIES.CATEGORY_ID

BOOKS.BOOK_ID

AUTHORS.AUTHOR_ID
```

### Question 3

Which columns connect tables?

For example:

```text
BOOKS.CATEGORY_ID
        ↓
CATEGORIES.CATEGORY_ID
```

### Question 4

What type of relationship exists?

For example:

```text
CATEGORIES → BOOKS
One-to-Many

BOOKS ↔ AUTHORS
Many-to-Many
```

These questions make JOIN queries much easier to understand later.

---

# 23. Inspecting Oracle Metadata

A database engineer should be able to inspect an existing database rather than
relying only on design documents.

Useful Oracle views include:

```text
USER_TABLES
USER_TAB_COLUMNS
USER_CONSTRAINTS
USER_CONS_COLUMNS
```

These answer different questions.

| View | Question |
|---|---|
| `USER_TABLES` | Which tables do I own? |
| `USER_TAB_COLUMNS` | Which columns do my tables contain? |
| `USER_CONSTRAINTS` | Which constraints exist? |
| `USER_CONS_COLUMNS` | Which columns participate in constraints? |

We will use these views throughout Course 03.

---

# 24. Inspecting the Current Schema

List the current tables:

```sql
SELECT
    table_name
FROM user_tables
ORDER BY table_name;
```

Inspect the columns of `BOOKS`:

```sql
SELECT
    column_id,
    column_name,
    data_type,
    nullable
FROM user_tab_columns
WHERE table_name = 'BOOKS'
ORDER BY column_id;
```

Inspect its constraints:

```sql
SELECT
    constraint_name,
    constraint_type,
    status
FROM user_constraints
WHERE table_name = 'BOOKS'
ORDER BY constraint_name;
```

Then inspect the columns participating in constraints:

```sql
SELECT
    constraint_name,
    column_name,
    position
FROM user_cons_columns
WHERE table_name = 'BOOKS'
ORDER BY
    constraint_name,
    position;
```

This is the beginning of schema investigation.

---

# 25. Engineering Perspective

A relationship is not simply something used by a `JOIN`.

It represents a rule about the data.

For example:

```text
A book belongs to a valid category.
```

can become a database rule:

```text
BOOKS.CATEGORY_ID
must reference
CATEGORIES.CATEGORY_ID
```

Similarly:

```text
A BOOK_AUTHORS row must refer to an existing book.
```

can be enforced using a foreign key.

This is an important shift in perspective:

```text
SQL Querying
     +
Database Structure
     +
Data Rules
```

Together, these form relational database engineering.

---

# 26. Exercises

## Exercise 1

Verify your session.

Answer:

```text
Which user am I connected as?

Which PDB am I using?

Which schema is active?
```

---

## Exercise 2

Inspect `BOOKS`.

Identify:

```text
Primary Key
Nullable Columns
Data Types
```

---

## Exercise 3

Use Oracle metadata to find the primary key constraint on `BOOKS`.

Identify:

```text
Constraint Name
Constraint Type
Constraint Status
```

---

## Exercise 4

Find which column belongs to the primary key.

Expected concept:

```text
PK_BOOKS
    ↓
BOOK_ID
```

---

## Exercise 5

Look at the current `CATEGORY` column.

Consider the following question:

```text
Why might CATEGORY eventually become a separate table?
```

Think about:

```text
Repeated values
Consistency
Relationships
Maintenance
```

---

## Exercise 6

Consider the relationship:

```text
CATEGORIES
     1
     │
     N
   BOOKS
```

Identify:

```text
Parent Table
Child Table
Primary Key
Potential Foreign Key
```

---

## Exercise 7

Consider:

```text
BOOKS
   │
   └────< BOOK_AUTHORS >──── AUTHORS
```

Explain why `BOOK_AUTHORS` is necessary if:

```text
One book can have multiple authors

and

One author can write multiple books
```

---

# 27. Lesson Summary

In this lesson, you learned the concepts behind relational database design.

You learned:

```text
Entity
Table
Row
Column
Primary Key
Foreign Key
Parent Table
Child Table
Referential Integrity
One-to-Many
Many-to-Many
Junction Table
```

You also began inspecting Oracle metadata using:

```text
USER_TABLES
USER_TAB_COLUMNS
USER_CONSTRAINTS
USER_CONS_COLUMNS
```

The key idea is:

```text
Tables do not exist independently.

Relationships give structure and meaning to the data.
```

---

# Next Lesson

Continue to:

```text
Lesson 02 — Creating Related Tables
```

In the next lesson, we will move from concepts to implementation.

We will begin expanding the Book Store Database and create real relationships
using:

```text
PRIMARY KEY
FOREIGN KEY
REFERENCES
```

Then we will deliberately test what happens when valid and invalid
relationships are inserted.

This will allow us to see referential integrity enforced by Oracle itself.