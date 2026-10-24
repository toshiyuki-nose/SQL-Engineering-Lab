# Lesson 02 — Creating Related Tables

> Create related tables and enforce relationships using primary keys and foreign keys.

---

# Overview

In Lesson 01, we examined the existing `BOOKS` table and learned the concepts
behind relational database design.

The current structure contains:

```text
BOOKS
----------------
BOOK_ID          PK
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

The `CATEGORY` column currently stores category names directly.

For example:

```text
Technology
Data Science
Business
History
Environment
```

These values are repeated across multiple book rows.

In this lesson, we will begin transforming the Book Store Database into a
relational model.

We will introduce:

```text
CATEGORIES
AUTHORS
BOOK_AUTHORS
```

and create real relationships using Oracle constraints.

By the end of the lesson, the model will look like:

```text
CATEGORIES
     │
     │ 1
     │
     N
   BOOKS
     │
     │
     └────< BOOK_AUTHORS >──── AUTHORS
```

This lesson moves from relational concepts to actual database implementation.

---

# 1. Learning Objectives

After completing this lesson, you will be able to:

- Create tables with primary keys
- Add a new column to an existing table
- Migrate existing data into a related table
- Create foreign key constraints
- Understand parent and child tables
- Create a junction table
- Create a composite primary key
- Understand referential integrity
- Verify constraints using Oracle metadata
- Test valid and invalid relationships
- Understand how Oracle protects relational consistency

---

# 2. Learning Environment

Execute this lesson as:

```text
SQL_LAB @ FREEPDB1
```

Verify the session before making schema changes:

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

Unlike Lesson 01, this lesson modifies the Book Store Database.

---

# 3. Starting Point

At the beginning of this lesson:

```text
BOOKS
----------------
BOOK_ID          PK
TITLE
CATEGORY
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

The table contains 15 books and five category values:

```text
Business
Data Science
Environment
History
Technology
```

Currently, category names are stored directly in every book row.

For example:

```text
BOOK_ID | TITLE                    | CATEGORY
--------+--------------------------+-------------
1001    | SQL Fundamentals         | Technology
1002    | Advanced SQL Engineering | Technology
1003    | Database Design Basics   | Technology
```

Our first goal is to separate category information from `BOOKS`.

---

# 4. Create CATEGORIES

We will create:

```text
CATEGORIES
----------------
CATEGORY_ID      PK
CATEGORY_NAME
```

The sample category identifiers will be:

```text
10  Technology
20  Data Science
30  Business
40  History
50  Environment
```

The identifiers deliberately use intervals of 10.

This makes the sample data easy to read and leaves room for additional
categories if the learning dataset is expanded later.

The table is created using:

```sql
CREATE TABLE categories (
    category_id    NUMBER,
    category_name  VARCHAR2(30) NOT NULL,

    CONSTRAINT pk_categories
        PRIMARY KEY (category_id),

    CONSTRAINT uq_categories_name
        UNIQUE (category_name)
);
```

There are two important constraints:

```text
PK_CATEGORIES
    → CATEGORY_ID must uniquely identify a category

UQ_CATEGORIES_NAME
    → CATEGORY_NAME cannot be duplicated
```

---

# 5. Populate CATEGORIES

The five existing category values are inserted into the new table.

```text
CATEGORY_ID | CATEGORY_NAME
------------+--------------
10          | Technology
20          | Data Science
30          | Business
40          | History
50          | Environment
```

At this stage, both representations temporarily exist:

```text
BOOKS.CATEGORY
```

and:

```text
CATEGORIES.CATEGORY_NAME
```

This temporary duplication allows us to migrate the existing data safely.

---

# 6. Add CATEGORY_ID to BOOKS

Next, add:

```text
CATEGORY_ID
```

to the existing `BOOKS` table.

At first, the new column is nullable.

Conceptually:

```text
BOOKS
----------------
BOOK_ID          PK
TITLE
CATEGORY
CATEGORY_ID      ← new
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

Why not immediately make it `NOT NULL`?

Because existing rows do not yet contain `CATEGORY_ID` values.

The safe sequence is:

```text
Add column
    ↓
Populate existing rows
    ↓
Verify migration
    ↓
Apply stronger constraints
```

---

# 7. Migrate Existing Category Data

The existing text values are mapped to the new category identifiers.

Conceptually:

```text
BOOKS.CATEGORY
      │
      │ match by name
      ▼
CATEGORIES.CATEGORY_NAME
      │
      ▼
CATEGORIES.CATEGORY_ID
      │
      ▼
BOOKS.CATEGORY_ID
```

After migration:

```text
BOOK_ID | CATEGORY     | CATEGORY_ID
--------+--------------+------------
1001    | Technology   | 10
1002    | Technology   | 10
1004    | Data Science | 20
...
```

At this point, both the old and new representations can be compared before the
old column is removed.

---

# 8. Add the Foreign Key

Once every book has a valid `CATEGORY_ID`, we create:

```text
FK_BOOKS_CATEGORY
```

The relationship becomes:

```text
CATEGORIES.CATEGORY_ID
          │
          │
          └────< BOOKS.CATEGORY_ID
```

SQL:

```sql
ALTER TABLE books
ADD CONSTRAINT fk_books_category
    FOREIGN KEY (category_id)
    REFERENCES categories (category_id);
```

Now Oracle can enforce the relationship.

---

# 9. Make CATEGORY_ID Required

Every book in this learning model must belong to a category.

After migration and verification, we can change:

```text
CATEGORY_ID
```

to:

```text
NOT NULL
```

using:

```sql
ALTER TABLE books
MODIFY category_id NOT NULL;
```

The order matters.

If we attempted this before populating existing rows, the migration would be
more difficult.

---

# 10. Remove the Old CATEGORY Column

After confirming that:

```text
BOOKS.CATEGORY_ID
```

correctly references:

```text
CATEGORIES.CATEGORY_ID
```

the old text column is no longer necessary.

We can remove:

```text
BOOKS.CATEGORY
```

using:

```sql
ALTER TABLE books
DROP COLUMN category;
```

The model becomes:

```text
CATEGORIES
----------------
CATEGORY_ID      PK
CATEGORY_NAME

        1
        │
        │
        N

BOOKS
----------------
BOOK_ID          PK
TITLE
CATEGORY_ID      FK
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE
```

---

# 11. Create AUTHORS

Next, create an independent entity:

```text
AUTHORS
----------------
AUTHOR_ID        PK
AUTHOR_NAME
```

For this learning database, sample authors will be created specifically for the
fictional Book Store dataset.

The purpose is not to model real publishing metadata.

The purpose is to learn relationships.

---

# 12. Why Not Put AUTHOR_ID Directly in BOOKS?

If every book could have exactly one author, we could create:

```text
BOOKS.AUTHOR_ID
```

However, books can have multiple authors.

Also, one author can write multiple books.

Therefore:

```text
BOOKS ↔ AUTHORS
```

is a many-to-many relationship.

A single foreign key in `BOOKS` cannot represent this cleanly.

---

# 13. Create BOOK_AUTHORS

To represent the many-to-many relationship, create a junction table:

```text
BOOK_AUTHORS
----------------
BOOK_ID
AUTHOR_ID
```

Both columns are foreign keys.

```text
BOOK_AUTHORS.BOOK_ID
    → BOOKS.BOOK_ID

BOOK_AUTHORS.AUTHOR_ID
    → AUTHORS.AUTHOR_ID
```

The pair also forms the primary key:

```text
PRIMARY KEY (
    BOOK_ID,
    AUTHOR_ID
)
```

This is called a:

```text
Composite Primary Key
```

because the key consists of more than one column.

---

# 14. Composite Primary Key

Consider:

```text
BOOK_ID | AUTHOR_ID
--------+----------
1001    | 501
1002    | 501
1002    | 502
```

Each individual value may appear multiple times.

For example:

```text
BOOK_ID 1002
```

appears twice because the book has two authors.

Likewise, an author can appear for several books.

But the same relationship:

```text
1002 + 501
```

should not be stored twice.

Therefore the combination:

```text
BOOK_ID + AUTHOR_ID
```

uniquely identifies a relationship.

---

# 15. Parent and Child Relationships

After creating the new tables, we have several relationships.

### Categories and Books

```text
CATEGORIES
    1
    │
    N
  BOOKS
```

Parent:

```text
CATEGORIES
```

Child:

```text
BOOKS
```

---

### Books and Book Authors

```text
BOOKS
   1
   │
   N
BOOK_AUTHORS
```

Parent:

```text
BOOKS
```

Child:

```text
BOOK_AUTHORS
```

---

### Authors and Book Authors

```text
AUTHORS
   1
   │
   N
BOOK_AUTHORS
```

Parent:

```text
AUTHORS
```

Child:

```text
BOOK_AUTHORS
```

Together these two one-to-many relationships represent the many-to-many
relationship between books and authors.

---

# 16. Referential Integrity

Once foreign keys exist, Oracle protects the relationships.

For example, suppose no category exists with:

```text
CATEGORY_ID = 999
```

Then Oracle should reject a book that attempts to reference category `999`.

Similarly, if no author exists with:

```text
AUTHOR_ID = 999
```

Oracle should reject:

```text
BOOK_AUTHORS.AUTHOR_ID = 999
```

This is referential integrity in action.

---

# 17. Testing Invalid Relationships

An important part of database engineering is not only testing successful data.

We should also deliberately verify that invalid data is rejected.

For example:

```sql
INSERT INTO book_authors (
    book_id,
    author_id
)
VALUES (
    1001,
    999
);
```

If author `999` does not exist, Oracle should reject the row.

This is a successful test of the constraint.

The SQL statement fails, but the database rule succeeds.

That distinction is important.

---

# 18. Testing the Composite Primary Key

We should also verify that the same book-author relationship cannot be inserted
twice.

If this relationship already exists:

```text
BOOK_ID   = 1001
AUTHOR_ID = 501
```

then attempting to insert the same pair again should fail.

Oracle should reject it because of:

```text
PK_BOOK_AUTHORS
```

Again:

```text
SQL statement fails
        ↓
Constraint works correctly
        ↓
Test succeeds
```

---

# 19. Inspecting Relationships with Oracle Metadata

We can inspect the new constraints using:

```text
USER_CONSTRAINTS
USER_CONS_COLUMNS
```

For example:

```sql
SELECT
    table_name,
    constraint_name,
    constraint_type,
    status
FROM user_constraints
WHERE table_name IN (
    'CATEGORIES',
    'BOOKS',
    'AUTHORS',
    'BOOK_AUTHORS'
)
ORDER BY
    table_name,
    constraint_name;
```

We should now see constraint types including:

```text
P = Primary Key
R = Foreign Key
U = Unique
C = Check / NOT NULL related constraints
```

---

# 20. Inspecting Foreign Key Targets

For a foreign key, Oracle stores information about the referenced constraint.

This allows us to investigate relationships from metadata rather than relying
only on documentation.

Conceptually:

```text
FK_BOOKS_CATEGORY
        │
        ▼
PK_CATEGORIES
```

and:

```text
FK_BOOK_AUTHORS_BOOK
        │
        ▼
PK_BOOKS
```

and:

```text
FK_BOOK_AUTHORS_AUTHOR
        │
        ▼
PK_AUTHORS
```

This is especially useful when investigating unfamiliar schemas.

---

# 21. Final Model

After setup, the Book Store Database should look like:

```text
CATEGORIES
----------------
CATEGORY_ID      PK
CATEGORY_NAME    UQ

        1
        │
        │
        N

BOOKS
----------------
BOOK_ID          PK
TITLE
CATEGORY_ID      FK
PRICE
STOCK
PUBLISHED_YEAR
SUBTITLE

        1
        │
        │
        N

BOOK_AUTHORS
----------------
BOOK_ID          PK, FK
AUTHOR_ID        PK, FK

        N
        │
        │
        1

AUTHORS
----------------
AUTHOR_ID        PK
AUTHOR_NAME
```

Another way to visualize it:

```text
CATEGORIES
     │
     └────< BOOKS
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

---

# 22. Exercises

## Exercise 1

Inspect all four tables:

```text
CATEGORIES
BOOKS
AUTHORS
BOOK_AUTHORS
```

Use:

```sql
DESCRIBE
```

---

## Exercise 2

Find all primary key constraints using:

```text
USER_CONSTRAINTS
```

Identify:

```text
PK_CATEGORIES
PK_BOOKS
PK_AUTHORS
PK_BOOK_AUTHORS
```

---

## Exercise 3

Find all foreign key constraints.

Identify:

```text
FK_BOOKS_CATEGORY
FK_BOOK_AUTHORS_BOOK
FK_BOOK_AUTHORS_AUTHOR
```

---

## Exercise 4

Inspect:

```text
PK_BOOK_AUTHORS
```

using `USER_CONS_COLUMNS`.

Verify that it contains:

```text
Position 1 → BOOK_ID
Position 2 → AUTHOR_ID
```

---

## Exercise 5

Attempt to create a `BOOK_AUTHORS` relationship using an author that does not
exist.

Observe Oracle rejecting the row.

Explain why the error is desirable.

---

## Exercise 6

Attempt to insert the same book-author relationship twice.

Observe the primary key preventing duplicate relationships.

---

## Exercise 7

Draw the relationship:

```text
CATEGORIES
     │
     └────< BOOKS
              │
              └────< BOOK_AUTHORS >──── AUTHORS
```

For each connection, identify:

```text
Parent
Child
Primary Key
Foreign Key
Relationship Type
```

---

# 23. Engineering Notes

## Do not destroy old data before verifying migration

When changing a schema, avoid:

```text
Drop old representation
        ↓
Hope the migration worked
```

Prefer:

```text
Create new representation
        ↓
Migrate data
        ↓
Compare old and new
        ↓
Create constraints
        ↓
Verify
        ↓
Remove obsolete structure
```

This is why `BOOKS.CATEGORY` is not dropped immediately.

---

## Constraints are executable data rules

Documentation may say:

```text
Every book must have a valid category.
```

A foreign key turns that statement into a rule Oracle can enforce.

That is much stronger than relying only on application code or human
discipline.

---

## Failed SQL can represent a successful test

When intentionally testing a constraint:

```text
ORA error
```

does not necessarily mean the lesson failed.

If invalid data was supposed to be rejected, the error demonstrates that the
database is working correctly.

Always distinguish:

```text
Unexpected Error
```

from:

```text
Expected Constraint Violation
```

---

# 24. Lesson Summary

In this lesson, you moved from relational concepts to actual database
relationships.

You created and worked with:

```text
CATEGORIES
BOOKS
AUTHORS
BOOK_AUTHORS
```

You learned how to use:

```text
PRIMARY KEY
FOREIGN KEY
REFERENCES
UNIQUE
Composite Primary Key
```

You also learned how Oracle enforces:

```text
Entity Integrity
Referential Integrity
Relationship Uniqueness
```

The Book Store Database is now a relational model rather than a single-table
dataset.

---

# Next Lesson

Continue to:

```text
Lesson 03 — INNER JOIN
```

The database now contains related information across several tables.

The next question is:

```text
How do we retrieve that information together?
```

In Lesson 03, we will use:

```text
INNER JOIN
JOIN ... ON
Table Aliases
Qualified Column Names
```

to follow the relationships created in this lesson.