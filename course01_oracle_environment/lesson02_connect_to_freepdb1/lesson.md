# Lesson 02 — Connect to FREEPDB1

> Connect to Oracle Database Free, prepare the learning environment, and verify your connection.

---

# Overview

In the previous lesson, you learned the basic concepts of Oracle Database.

In this lesson, you will prepare the Oracle environment used throughout **SQL-Engineering-Lab**.

You will connect to the **FREEPDB1** pluggable database, create a dedicated learning user, and verify that your environment is ready for the remaining courses.

By the end of this lesson, you will have a fully functional Oracle environment for SQL development.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Connect to Oracle Database Free
- Connect to the FREEPDB1 pluggable database
- Create a dedicated learning user
- Grant the required privileges
- Connect as the learning user
- Verify the current database environment

---

# Prerequisites

Before starting this lesson, make sure:

- Oracle Database Free is running.
- FREEPDB1 is open.
- SQL*Plus is available.
- You can connect as SYSDBA.

---

# Step 1 — Connect as SYSDBA

Open SQL*Plus.

```text
sqlplus / as sysdba
```

Verify that you are connected.

```sql
SELECT USER
FROM dual;
```

Expected output

```
USER
----
SYS
```

---

# Step 2 — Switch to FREEPDB1

Move to the learning pluggable database.

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
```

Verify the current container.

```sql
SHOW CON_NAME
```

Expected output

```
CON_NAME
--------
FREEPDB1
```

---

# Step 3 — Create the Learning User

Create the user used throughout SQL-Engineering-Lab.

```sql
CREATE USER SQL_LAB
IDENTIFIED BY sql_lab
DEFAULT TABLESPACE FREEPDB1_DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FREEPDB1_DATA;
```

---

# Step 4 — Grant Required Privileges

Grant the minimum privileges required for this course.

```sql
GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE VIEW,
    CREATE SEQUENCE
TO SQL_LAB;
```

Additional privileges will be granted in later courses only when needed.

---

# Step 5 — Connect as SQL_LAB

Exit SQL*Plus.

```text
EXIT
```

Reconnect using the learning user.

```text
sqlplus sql_lab/sql_lab@localhost:1521/FREEPDB1
```

If the connection succeeds, SQL*Plus displays:

```text
SQL>
```

---

# Step 6 — Verify the Environment

Verify the current user.

```sql
SELECT USER
FROM dual;
```

Expected output

```
USER
--------
SQL_LAB
```

---

Verify the current container.

```sql
SELECT SYS_CONTEXT('USERENV','CON_NAME')
FROM dual;
```

Expected output

```
FREEPDB1
```

---

Verify the current schema.

```sql
SELECT SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
FROM dual;
```

Expected output

```
SQL_LAB
```

---

Verify the database name.

```sql
SELECT SYS_CONTEXT('USERENV','DB_NAME')
FROM dual;
```

Expected output

```
FREE
```

---

Verify the service name.

```sql
SELECT SYS_CONTEXT('USERENV','SERVICE_NAME')
FROM dual;
```

Expected output

```
freepdb1
```

---

# Understanding the Results

After completing the verification, you should know the answers to the following questions.

| Question | Expected Result |
|-----------|-----------------|
| Which database am I using? | FREE |
| Which pluggable database am I connected to? | FREEPDB1 |
| Which user am I logged in as? | SQL_LAB |
| Which schema is active? | SQL_LAB |
| Which service am I connected to? | freepdb1 |

These checks should become part of your normal workflow before executing SQL.

---

# Common Connection Problems

## ORA-01017

Invalid username or password.

Check:

- Username
- Password
- Case sensitivity

---

## ORA-12514

Service name not found.

Check:

- Listener is running.
- FREEPDB1 is registered.
- The service name is correct.

---

## ORA-12154

Unable to resolve the connect identifier.

Check:

- Connection string
- Network configuration
- Service name

---

# Summary

In this lesson, you:

- Connected to Oracle Database Free
- Switched to FREEPDB1
- Created the SQL_LAB user
- Granted the required privileges
- Connected as SQL_LAB
- Verified the Oracle environment

The learning environment is now ready for the remaining courses.

---

# Exercises

Complete the following tasks.

1. Connect as SYSDBA.
2. Switch to FREEPDB1.
3. Create the SQL_LAB user.
4. Grant the required privileges.
5. Connect as SQL_LAB.
6. Execute every verification query.
7. Record the results.

---

# Engineering Notes

Professional database engineers always verify their environment before executing SQL.

Before creating objects or modifying data, confirm:

- The current database
- The current pluggable database
- The connected user
- The active schema

Verifying your environment takes only a few seconds but can prevent many costly mistakes.

---

# Next Lesson

**Lesson 03 — SQL Clients**

In the next lesson, you will learn how to use SQL*Plus and Oracle SQL Developer efficiently throughout this repository.