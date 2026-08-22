# Lesson 05 — Creating Your First Database Objects

> Create your first database objects and complete the SQL-Engineering-Lab environment.

---

# Overview

Throughout Course 01, you prepared and explored the Oracle environment used by **SQL-Engineering-Lab**.

You learned how Oracle Database Free is organized, connected to `FREEPDB1`, created the `SQL_LAB` learning user, used SQL clients, and examined users, schemas, tablespaces, quotas, and privileges.

Now it is time to use that environment.

In this lesson, you will create your first table in the `SQL_LAB` schema and insert data into it.

The goal is not yet to study SQL querying in depth.

Instead, the goal is to connect everything you learned in Course 01:

```text
Oracle Database
      │
      ▼
FREEPDB1
      │
      ▼
SQL_LAB User
      │
      ▼
SQL_LAB Schema
      │
      ▼
FREEPDB1_DATA
      │
      ▼
LEARNING_TOPICS Table
      │
      ▼
Sample Data
```

By the end of this lesson, the SQL-Engineering-Lab environment will be ready for **Course 02 — SQL Fundamentals**.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Create a table in the `SQL_LAB` schema
- Understand basic table and column definitions
- Insert rows into a table
- Commit database changes
- Query data from a table
- Inspect objects owned by the current schema
- Inspect table metadata
- Understand where the table belongs logically and physically
- Remove learning objects using `DROP TABLE`
- Explain how the Course 01 environment works as a complete system

---

# Recommended Setup

For the main exercises in this lesson, use:

```text
Terminal A
SQL_LAB @ FREEPDB1
```

Most operations will be performed by `SQL_LAB`.

If you want to inspect the same objects from an administrator perspective, keep the SYS terminal from Lesson 04 available:

```text
Terminal B
SYS @ FREEPDB1
```

The main workflow is:

```text
SQL_LAB
   │
   ├── Create
   ├── Insert
   ├── Query
   └── Inspect
```

SYS is optional for additional verification.

---

# Verify the Session

Before creating any database object, verify your current session.

Execute in Terminal A:

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

Expected values:

```text
CURRENT_USER   = SQL_LAB
CONTAINER_NAME = FREEPDB1
CURRENT_SCHEMA = SQL_LAB
```

Remember the working pattern introduced in Lesson 04:

```text
Who am I?
Where am I?
What can I do?
```

Before modifying the database, always establish your session context.

---

# Before Creating the Table

In Lesson 04, you inspected the objects owned by `SQL_LAB` using:

```sql
SELECT
    object_name,
    object_type
FROM user_objects
ORDER BY object_type, object_name;
```

Before continuing, verify the current state of the schema.

For this lesson, the table created below should not already exist.

The object we will create is:

```text
LEARNING_TOPICS
```

If you are repeating this lesson, use the provided `cleanup.sql` script before starting again.

---

# Our First Table

The first official table created in SQL-Engineering-Lab will be:

```text
LEARNING_TOPICS
```

This table represents topics that will be studied throughout the SQL learning journey.

The initial design is:

| Column | Data Type | Purpose |
|--------|-----------|---------|
| `TOPIC_ID` | `NUMBER` | Unique identifier |
| `TOPIC_NAME` | `VARCHAR2(100)` | Learning topic |
| `STATUS` | `VARCHAR2(20)` | Learning status |
| `CREATED_AT` | `DATE` | Creation date |

Example data:

| TOPIC_ID | TOPIC_NAME | STATUS |
|---------:|------------|--------|
| 1 | SQL Basics | READY |
| 2 | SELECT | PLANNED |
| 3 | Filtering | PLANNED |
| 4 | Sorting | PLANNED |
| 5 | Joins | PLANNED |

This small dataset will connect Course 01 with the SQL exercises that begin in Course 02.

---

# CREATE TABLE

Create the table as `SQL_LAB`.

```sql
CREATE TABLE learning_topics (
    topic_id    NUMBER,
    topic_name  VARCHAR2(100),
    status      VARCHAR2(20),
    created_at  DATE
);
```

This statement creates a table named:

```text
LEARNING_TOPICS
```

Because the connected user is `SQL_LAB`, the table belongs to the `SQL_LAB` schema.

Its fully qualified name is:

```text
SQL_LAB.LEARNING_TOPICS
```

---

# Understanding the Table Definition

The table contains four columns.

## TOPIC_ID

```sql
topic_id NUMBER
```

`NUMBER` stores numeric values.

For this table, `TOPIC_ID` identifies each learning topic.

---

## TOPIC_NAME

```sql
topic_name VARCHAR2(100)
```

`VARCHAR2` stores variable-length character data.

The value `100` specifies the maximum length in the column's declared length semantics.

Example:

```text
SQL Basics
```

---

## STATUS

```sql
status VARCHAR2(20)
```

This column stores the current learning status.

Example values:

```text
READY
PLANNED
COMPLETED
```

---

## CREATED_AT

```sql
created_at DATE
```

Oracle's `DATE` data type stores date and time information to the second.

In this lesson, it will record when the sample row was created.

---

# What Happened When CREATE TABLE Ran?

The statement:

```sql
CREATE TABLE learning_topics (
    topic_id    NUMBER,
    topic_name  VARCHAR2(100),
    status      VARCHAR2(20),
    created_at  DATE
);
```

looks simple, but it connects several concepts from Course 01.

```text
SQL_LAB
   │
   ├── has CREATE TABLE privilege
   │
   ▼
Creates LEARNING_TOPICS
   │
   ▼
SQL_LAB Schema
   │
   ├── owns the table
   │
   ▼
Default Tablespace
   │
   ▼
FREEPDB1_DATA
```

Lesson 02 gave `SQL_LAB` the ability to create tables:

```sql
GRANT CREATE TABLE TO SQL_LAB;
```

Lesson 02 also configured:

```sql
DEFAULT TABLESPACE FREEPDB1_DATA
QUOTA UNLIMITED ON FREEPDB1_DATA
```

Those settings now become relevant in practice.

---

# Verify the Created Object

Use the data dictionary to confirm that the table exists.

```sql
SELECT
    object_name,
    object_type
FROM user_objects
WHERE object_name = 'LEARNING_TOPICS';
```

Expected result:

```text
OBJECT_NAME       OBJECT_TYPE
----------------- -----------
LEARNING_TOPICS   TABLE
```

You can also inspect the user's tables:

```sql
SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'LEARNING_TOPICS';
```

The expected tablespace is:

```text
FREEPDB1_DATA
```

This connects the table you just created with the tablespace configured earlier in Course 01.

---

# Inspect the Table Definition

SQL*Plus provides the `DESCRIBE` command.

Execute:

```text
DESCRIBE learning_topics
```

You should see the columns defined earlier:

```text
TOPIC_ID
TOPIC_NAME
STATUS
CREATED_AT
```

`DESCRIBE` is useful for quickly inspecting the structure of a table.

---

# Insert Sample Data

Now insert several rows.

```sql
INSERT INTO learning_topics (
    topic_id,
    topic_name,
    status,
    created_at
)
VALUES (
    1,
    'SQL Basics',
    'READY',
    SYSDATE
);
```

Add additional learning topics:

```sql
INSERT INTO learning_topics
VALUES (2, 'SELECT', 'PLANNED', SYSDATE);

INSERT INTO learning_topics
VALUES (3, 'Filtering', 'PLANNED', SYSDATE);

INSERT INTO learning_topics
VALUES (4, 'Sorting', 'PLANNED', SYSDATE);

INSERT INTO learning_topics
VALUES (5, 'Joins', 'PLANNED', SYSDATE);
```

At this stage, do not worry about mastering every part of the `INSERT` syntax.

Data manipulation will be covered in more detail in later courses.

For now, the purpose is to place real data inside the environment you created.

---

# COMMIT

After inserting the rows, execute:

```sql
COMMIT;
```

`COMMIT` makes the current transaction's changes permanent.

Conceptually:

```text
INSERT
INSERT
INSERT
   │
   ▼
Uncommitted Changes
   │
   ▼
COMMIT
   │
   ▼
Committed Changes
```

Transaction control will be explored in greater detail later in SQL-Engineering-Lab.

For this lesson, remember:

```text
INSERT changes data.

COMMIT confirms the transaction.
```

---

# Query the Data

Now retrieve the rows.

```sql
SELECT
    topic_id,
    topic_name,
    status,
    created_at
FROM learning_topics
ORDER BY topic_id;
```

You should see five learning topics.

This is the first dataset created specifically for SQL-Engineering-Lab.

The `SELECT` statement will become one of the main subjects of Course 02.

For now, use it simply to verify that the data exists.

---

# Table, Schema, and Tablespace

You can now observe the complete relationship.

```text
FREEPDB1
│
├── Tablespace
│      └── FREEPDB1_DATA
│
└── User / Schema
       └── SQL_LAB
              │
              └── LEARNING_TOPICS
                     │
                     ├── TOPIC_ID
                     ├── TOPIC_NAME
                     ├── STATUS
                     └── CREATED_AT
```

These concepts describe different aspects of the same environment.

```text
User
    → Who connects and performs operations?

Schema
    → Who owns the object?

Tablespace
    → Where is the object's segment logically stored?

Table
    → How is the data organized?

Rows
    → What data is stored?
```

---

# Verify the Tablespace

Execute:

```sql
SELECT
    table_name,
    tablespace_name
FROM user_tables
WHERE table_name = 'LEARNING_TOPICS';
```

Expected result:

```text
TABLE_NAME        TABLESPACE_NAME
----------------- ----------------
LEARNING_TOPICS   FREEPDB1_DATA
```

Now the setting from Lesson 02:

```sql
DEFAULT TABLESPACE FREEPDB1_DATA
```

has a visible result.

---

# Optional Administrator Verification

If Terminal B from Lesson 04 is still open as:

```text
SYS @ FREEPDB1
```

you can inspect the same table from the administrator perspective.

First verify the session:

```text
SHOW USER
SHOW CON_NAME
```

Then execute:

```sql
SELECT
    owner,
    object_name,
    object_type
FROM dba_objects
WHERE owner = 'SQL_LAB'
  AND object_name = 'LEARNING_TOPICS';
```

You can also inspect the table:

```sql
SELECT
    owner,
    table_name,
    tablespace_name
FROM dba_tables
WHERE owner = 'SQL_LAB'
  AND table_name = 'LEARNING_TOPICS';
```

This continues the two-terminal working pattern introduced in Lesson 04:

```text
SQL_LAB @ FREEPDB1
        │
        └── USER_* perspective

SYS @ FREEPDB1
        │
        └── DBA_* perspective
```

---

# Cleaning Up the Environment

Database engineering exercises should be repeatable.

For this reason, Lesson 05 includes a separate cleanup script.

The basic cleanup operation is:

```sql
DROP TABLE learning_topics PURGE;
```

This removes the table.

After cleanup, verify:

```sql
SELECT
    object_name,
    object_type
FROM user_objects
WHERE object_name = 'LEARNING_TOPICS';
```

No rows should be returned.

You can then execute the Lesson 05 exercises again from the beginning.

---

# Why Keep cleanup.sql Separate?

The main lesson creates and uses the learning environment.

Cleanup serves a different purpose:

```text
lesson05.sql
    │
    └── Build and verify

cleanup.sql
    │
    └── Reset
```

Keeping cleanup separate makes the lesson repeatable without automatically deleting the work you just created.

This pattern will be useful in later SQL-Engineering-Lab exercises as environments become more complex.

---

# Course 01 Environment

At this point, the pieces introduced throughout Course 01 work together.

```text
Oracle Database 23ai Free
│
└── FREEPDB1
     │
     ├── Tablespace
     │      └── FREEPDB1_DATA
     │
     └── SQL_LAB
            │
            ├── Schema: SQL_LAB
            │
            ├── Temporary Tablespace: TEMP
            │
            ├── Quota: UNLIMITED on FREEPDB1_DATA
            │
            ├── System Privileges
            │      ├── CREATE SESSION
            │      ├── CREATE TABLE
            │      ├── CREATE VIEW
            │      └── CREATE SEQUENCE
            │
            └── Database Objects
                   └── LEARNING_TOPICS
```

The Oracle environment is no longer just a database installation.

It is now a working SQL learning environment.

---

# Exercises

Complete the following exercises as `SQL_LAB @ FREEPDB1`.

1. Verify the current user and container.
2. Create the `LEARNING_TOPICS` table.
3. Inspect the table using `USER_OBJECTS`.
4. Inspect the table using `USER_TABLES`.
5. Use `DESCRIBE` to inspect its columns.
6. Insert the five sample rows.
7. Execute `COMMIT`.
8. Query all rows from `LEARNING_TOPICS`.
9. Verify that the table uses `FREEPDB1_DATA`.
10. Explain why `SQL_LAB` is able to create this table.
11. Explain the relationship between `SQL_LAB`, the `SQL_LAB` schema, `LEARNING_TOPICS`, and `FREEPDB1_DATA`.
12. Optionally inspect the same table as `SYS @ FREEPDB1`.
13. Run `cleanup.sql`.
14. Verify that `LEARNING_TOPICS` has been removed.
15. Run the lesson again to confirm that the environment is repeatable.

---

# Engineering Notes

Creating a table requires more than knowing the `CREATE TABLE` syntax.

Several parts of the database environment must already be in place.

For this lesson:

```text
Correct Container
      +
Valid User
      +
CREATE TABLE Privilege
      +
Tablespace
      +
Tablespace Quota
      =
Successful Table Creation
```

These components were prepared and verified throughout Course 01.

This is why environment verification matters.

When an operation fails, do not look only at the SQL statement.

Ask:

```text
Who am I?

Where am I?

What privileges do I have?

Which schema owns the object?

Which tablespace is being used?
```

The environment is part of the SQL engineering problem.

---

# Summary

In this lesson, you learned how to:

- Create a table
- Define basic columns and data types
- Inspect schema objects
- Inspect table metadata
- Insert sample data
- Commit changes
- Query the inserted data
- Verify the table's tablespace
- Inspect the same object from user and administrator perspectives
- Remove an object
- Reset an exercise environment

More importantly, you connected the concepts introduced throughout Course 01:

```text
Database
   ↓
PDB
   ↓
User
   ↓
Schema
   ↓
Privileges
   ↓
Tablespace / Quota
   ↓
Table
   ↓
Data
```

You now have a working environment for learning SQL.

---

# Course 01 Complete

You have completed:

**Course 01 — Oracle Environment**

During this course, you:

- Explored the basic Oracle Database architecture
- Connected to `FREEPDB1`
- Created the `SQL_LAB` learning user
- Used SQL*Plus and Oracle SQL Developer
- Learned about users and schemas
- Examined tablespaces and quotas
- Examined privileges and roles
- Compared `USER_*` and `DBA_*` data dictionary views
- Created your first database table
- Inserted your first learning dataset
- Verified the complete Oracle learning environment

The foundation is now ready.

---

# Next Course

**Course 02 — SQL Fundamentals**

In the next course, you will begin working with SQL in depth.

The focus will move from:

```text
How is the Oracle environment organized?
```

to:

```text
How do we retrieve and work with data using SQL?
```

The database environment built in Course 01 will serve as the foundation for the lessons that follow.