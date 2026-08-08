# Lesson 03 — SQL Clients

> Learn how to work with Oracle Database using SQL*Plus and Oracle SQL Developer.

---

# Overview

In the previous lesson, you created the `SQL_LAB` user and connected to the `FREEPDB1` pluggable database.

You now have a working Oracle environment.

The next step is to understand the tools used to interact with that environment.

Throughout **SQL-Engineering-Lab**, two SQL clients will be used:

- SQL*Plus
- Oracle SQL Developer

Both tools can execute SQL, but they are useful for different kinds of work.

In this lesson, you will learn the basic role of each client and establish the workflow used throughout this repository.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Explain what a SQL client is
- Connect to FREEPDB1 using SQL*Plus
- Connect to FREEPDB1 using Oracle SQL Developer
- Execute SQL statements using both clients
- Use basic SQL*Plus commands
- Understand the difference between SQL statements and SQL*Plus commands
- Choose the appropriate client for different tasks
- Understand the SQL-Engineering-Lab development workflow

---

# What is a SQL Client?

Oracle Database runs as a database server.

To interact with the database, you use a client application.

A SQL client allows you to:

- Connect to Oracle Database
- Execute SQL statements
- View query results
- Run SQL scripts
- Inspect database objects
- Manage your database session

In this repository, we will primarily use SQL*Plus and Oracle SQL Developer.

---

# SQL*Plus

SQL*Plus is Oracle's command-line interface for Oracle Database.

It allows you to connect to the database and execute SQL directly from a terminal.

Example:

```text
sqlplus sql_lab/sql_lab@localhost:1521/FREEPDB1
```

After connecting successfully, the SQL*Plus prompt appears.

```text
SQL>
```

You can now execute SQL.

```sql
SELECT USER
FROM dual;
```

Expected result:

```text
USER
--------
SQL_LAB
```

---

# Basic SQL*Plus Commands

SQL*Plus provides commands that help you interact with your Oracle session.

These commands are different from SQL statements.

## SHOW USER

Display the currently connected user.

```text
SHOW USER
```

Example:

```text
ユーザーは"SQL_LAB"です。
```

---

## SHOW CON_NAME

Display the current Oracle container.

```text
SHOW CON_NAME
```

Expected result:

```text
CON_NAME
------------------------------
FREEPDB1
```

---

## DESCRIBE

Display the structure of a database object.

For example:

```text
DESCRIBE dual
```

`DESCRIBE` will become especially useful after you begin creating tables.

The short form can also be used.

```text
DESC dual
```

---

## Running a SQL Script

SQL*Plus can execute SQL stored in a file.

For example:

```text
@lesson03.sql
```

You can also specify a path.

```text
@E:\SQL\SQL-Engineering-Lab\course01_oracle_environment\lesson03_sql_clients\lesson03.sql
```

This feature is important throughout SQL-Engineering-Lab because executable SQL examples are stored as `.sql` files.

---

## SPOOL

SQL*Plus can save terminal output to a file.

Start recording:

```text
SPOOL output.txt
```

Execute SQL:

```sql
SELECT USER
FROM dual;
```

Stop recording:

```text
SPOOL OFF
```

This is useful when you want to preserve execution results for verification or troubleshooting.

The `oracle_environment.sql` utility used by this repository is an example of this approach.

---

## EXIT

Disconnect from Oracle Database and close SQL*Plus.

```text
EXIT
```

---

# SQL Statements vs. SQL*Plus Commands

It is important to understand that SQL and SQL*Plus are not the same thing.

For example:

```sql
SELECT USER
FROM dual;
```

is a SQL statement executed by Oracle Database.

However:

```text
SHOW USER
```

is a SQL*Plus command interpreted by the SQL*Plus client.

Other examples include:

| Command | Type |
|---------|------|
| `SELECT` | SQL |
| `CREATE TABLE` | SQL |
| `INSERT` | SQL |
| `UPDATE` | SQL |
| `SHOW USER` | SQL*Plus |
| `DESCRIBE` | SQL*Plus |
| `SPOOL` | SQL*Plus |
| `SET` | SQL*Plus |
| `EXIT` | SQL*Plus |

This distinction becomes important when moving SQL between different client applications.

---

# Oracle SQL Developer

Oracle SQL Developer is a graphical development environment for Oracle Database.

Unlike SQL*Plus, SQL Developer provides a graphical interface for:

- Writing SQL
- Executing queries
- Viewing results
- Browsing database objects
- Inspecting tables and views
- Editing and testing SQL interactively

For SQL-Engineering-Lab, SQL Developer will primarily be used as the development and experimentation environment.

---

# Connect Using SQL Developer

Create a connection using the SQL-Engineering-Lab environment.

Use the following settings:

| Item | Value |
|------|-------|
| Connection Name | SQL-Engineering-Lab |
| Username | SQL_LAB |
| Password | Your SQL_LAB password |
| Hostname | localhost |
| Port | 1521 |
| Connection Type | Basic |
| Service Name | FREEPDB1 |

Test the connection.

If the test succeeds, connect to the database.

---

# Verify the SQL Developer Connection

Open a SQL Worksheet and execute:

```sql
SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema,
    SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
    SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name
FROM dual;
```

For the SQL-Engineering-Lab environment, the expected values are:

| Item | Expected Value |
|------|----------------|
| User | SQL_LAB |
| Container | FREEPDB1 |
| Current Schema | SQL_LAB |
| Database Name | FREEPDB1 |
| Service Name | freepdb1 |

The same Oracle environment should be visible regardless of whether you use SQL*Plus or SQL Developer.

---

# SQL*Plus vs. SQL Developer

Both tools communicate with the same Oracle Database.

However, they will serve different roles throughout this repository.

| Task | Preferred Tool |
|------|----------------|
| Interactive SQL development | SQL Developer |
| Exploring query results | SQL Developer |
| Browsing database objects | SQL Developer |
| Testing SELECT statements | SQL Developer |
| Building complex queries | SQL Developer |
| Environment administration | SQL*Plus |
| Running `.sql` scripts | SQL*Plus |
| Reproducing lesson scripts | SQL*Plus |
| Capturing output with SPOOL | SQL*Plus |
| Final lesson verification | SQL*Plus |

This is not a strict technical limitation.

Many of these tasks can be performed using either client.

The distinction is a development convention used by SQL-Engineering-Lab.

---

# SQL-Engineering-Lab Workflow

From this point forward, lessons in this repository will generally follow this workflow.

```text
Define the lesson topic
          │
          ▼
Experiment in SQL Developer
          │
          ▼
Validate the SQL
          │
          ▼
Document the concepts in lesson.md
          │
          ▼
Organize executable SQL in lessonXX.sql
          │
          ▼
Run the complete script in SQL*Plus
          │
          ▼
Verify the expected results
```

SQL Developer acts as the **development workspace**.

SQL*Plus acts as the **reproducibility and verification environment**.

The repository itself remains the source of truth for finalized SQL.

---

# Working with SQL Files

SQL written during experimentation should eventually be stored in the repository.

For example:

```text
lesson03_sql_clients/
├── lesson.md
└── lesson03.sql
```

The roles are different:

| File | Purpose |
|------|---------|
| `lesson.md` | Explain concepts, procedures, and expected results |
| `lesson03.sql` | Store executable and reproducible SQL |

SQL Developer worksheets should be treated as temporary working areas rather than permanent project artifacts.

Finalized SQL should be stored in `.sql` files and managed in the repository.

---

# Verify Both Clients

Before completing this lesson, verify the environment from both SQL clients.

Execute:

```sql
SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;
```

Run the query once using:

1. SQL*Plus
2. Oracle SQL Developer

Both should identify:

```text
SQL_LAB
FREEPDB1
SQL_LAB
```

This confirms that both clients are working against the same learning environment.

---

# Exercises

Complete the following tasks.

1. Connect to FREEPDB1 as `SQL_LAB` using SQL*Plus.
2. Execute `SHOW USER`.
3. Execute `SHOW CON_NAME`.
4. Execute `DESCRIBE dual`.
5. Execute a `SELECT` statement from `dual`.
6. Connect to FREEPDB1 as `SQL_LAB` using Oracle SQL Developer.
7. Execute the same `SELECT` statement using a SQL Worksheet.
8. Compare the results from both clients.
9. Execute a `.sql` file using SQL*Plus.
10. Use `SPOOL` to save SQL*Plus output to a text file.

---

# Engineering Notes

A database engineer should not depend entirely on a graphical interface.

GUI tools such as SQL Developer are excellent for exploring data and developing queries interactively.

Command-line tools such as SQL*Plus are valuable for repeatable execution, automation, troubleshooting, and environments where graphical tools may not be available.

Learning to work comfortably with both provides a stronger foundation for database engineering.

For SQL-Engineering-Lab, remember the following principle:

```text
SQL Developer → Develop and Experiment

SQL*Plus      → Execute and Verify

Repository    → Preserve and Reproduce
```

---

# Summary

In this lesson, you learned:

- What a SQL client is
- How SQL*Plus interacts with Oracle Database
- Basic SQL*Plus commands
- The difference between SQL and SQL*Plus commands
- How Oracle SQL Developer is used
- How to verify the same environment using both clients
- How SQL*Plus and SQL Developer will be used throughout SQL-Engineering-Lab
- Why finalized SQL should be stored in the repository

You now have both the Oracle environment and the development tools required for the remaining lessons.

---

# Next Lesson

**Lesson 04 — Users, Schemas, and Tablespaces**

In the next lesson, you will examine the Oracle concepts already used to create `SQL_LAB` and learn how users, schemas, tablespaces, quotas, and privileges work together.