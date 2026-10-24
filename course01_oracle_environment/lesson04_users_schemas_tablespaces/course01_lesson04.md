# Lesson 04 — Users, Schemas, and Tablespaces

> Understand the Oracle learning environment from both the user and administrator perspectives.

---

# Overview

In Lesson 02, you created the `SQL_LAB` user with the following statement:

```sql
CREATE USER SQL_LAB
IDENTIFIED BY sql_lab
DEFAULT TABLESPACE FREEPDB1_DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FREEPDB1_DATA;
```

You also granted the following privileges:

```sql
GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE VIEW,
    CREATE SEQUENCE
TO SQL_LAB;
```

At that point, the goal was to build a working Oracle environment.

Now it is time to understand what that environment actually means.

In this lesson, you will examine:

- Users
- Schemas
- Tablespaces
- Quotas
- System privileges
- Object privileges
- Roles
- Oracle data dictionary views

Unlike the previous lessons, this lesson uses **two SQL*Plus sessions at the same time**.

You will inspect the same Oracle environment from two different perspectives:

```text
SQL_LAB @ FREEPDB1
        │
        └── User Perspective

SYS @ FREEPDB1
        │
        └── Administrator Perspective
```

This makes it easier to understand what a normal database user can see and what an administrator can see.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Explain the purpose of an Oracle user
- Explain the relationship between a user and a schema
- Understand what a tablespace is
- Understand tablespace quotas
- Distinguish between system privileges and object privileges
- Explain the basic purpose of roles
- Use `USER_*` data dictionary views
- Use `DBA_*` data dictionary views
- Compare user and administrator perspectives
- Verify the current user and container before inspecting the database
- Explain the environment created in Lesson 02

---

# Recommended Setup

For this lesson, it is recommended to open **two SQL*Plus terminals** at the same time.

Use one terminal as `SQL_LAB` and the other as `SYS`.

| Terminal | User | Container | Perspective |
|----------|------|-----------|-------------|
| Terminal A | SQL_LAB | FREEPDB1 | User |
| Terminal B | SYS | FREEPDB1 | Administrator |

Keep both terminals open throughout the lesson.

---

# Terminal A — SQL_LAB

Connect directly to FREEPDB1.

```text
sqlplus sql_lab/sql_lab@localhost:1521/FREEPDB1
```

Verify the session.

```text
SHOW USER
SHOW CON_NAME
```

Expected environment:

```text
USER     : SQL_LAB
CON_NAME : FREEPDB1
```

---

# Terminal B — SYS

Open another terminal.

Connect as SYSDBA.

```text
sqlplus / as sysdba
```

Verify the session.

```text
SHOW USER
SHOW CON_NAME
```

A SYSDBA connection may initially connect to:

```text
CDB$ROOT
```

If necessary, switch to FREEPDB1.

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
```

Verify the environment again.

```text
SHOW USER
SHOW CON_NAME
```

For this lesson, Terminal B should be:

```text
USER     : SYS
CON_NAME : FREEPDB1
```

---

# Who Am I? Where Am I?

Before inspecting Oracle Database, always establish your current context.

Two questions are especially important:

```text
Who am I?
Where am I?
```

In SQL*Plus, check them with:

```text
SHOW USER
SHOW CON_NAME
```

For this lesson:

```text
Terminal A
SQL_LAB @ FREEPDB1

Terminal B
SYS @ FREEPDB1
```

The same SQL statement may behave differently depending on the connected user and container.

Throughout this lesson, if a result is unexpected, return to these two commands first.

---

# Oracle User

An Oracle user is an account used to authenticate and interact with Oracle Database.

The learning user created in Lesson 02 is:

```text
SQL_LAB
```

Creating a user does not automatically give that user permission to perform every database operation.

Privileges must be granted separately.

For example:

```sql
GRANT CREATE SESSION TO SQL_LAB;
```

`CREATE SESSION` allows `SQL_LAB` to connect to the database.

Conceptually:

```text
User
  +
Privileges
  =
What the account is allowed to do
```

---

# Oracle Schema

A schema is a logical collection of database objects owned by a user.

Schema objects include:

- Tables
- Views
- Sequences
- Indexes

When `SQL_LAB` owns an object, that object belongs to the `SQL_LAB` schema.

For example:

```text
SQL_LAB.SAMPLE_TABLE
```

can be read as:

```text
SQL_LAB       → Schema
SAMPLE_TABLE  → Object
```

---

# User and Schema

A user and a schema are closely related in Oracle, but they represent different concepts.

| Concept | Meaning |
|---------|---------|
| User | Account used for authentication and authorization |
| Schema | Collection of database objects owned by the user |

For the learning environment:

```text
User
SQL_LAB
   │
   └── owns
          │
          ▼
Schema
SQL_LAB
```

The user connects to Oracle Database.

The schema represents the objects owned by that user.

---

# Current User and Current Schema

In Terminal A, execute:

```sql
SELECT
    USER AS current_user,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;
```

Expected values:

```text
CURRENT_USER   = SQL_LAB
CURRENT_SCHEMA = SQL_LAB
```

The values are currently the same, but they represent different concepts.

```text
USER
    → Who am I connected as?

CURRENT_SCHEMA
    → Which schema is used to resolve unqualified object names?
```

---

# Oracle Data Dictionary

Oracle maintains metadata about the database in the **data dictionary**.

This metadata includes information about:

- Users
- Tablespaces
- Privileges
- Roles
- Tables
- Views
- Other database objects

Oracle provides different data dictionary views depending on the perspective.

For this lesson, two families are especially important:

```text
USER_*
DBA_*
```

---

# USER_* Views

`USER_*` views describe information related to the current user.

They are useful when `SQL_LAB` wants to inspect its own environment.

Examples:

| View | Purpose |
|------|---------|
| `USER_USERS` | Current user configuration |
| `USER_TS_QUOTAS` | Current user's tablespace quotas |
| `USER_SYS_PRIVS` | Current user's system privileges |
| `USER_ROLE_PRIVS` | Roles granted to the current user |
| `USER_OBJECTS` | Objects owned by the current user |

These views will be queried from:

```text
Terminal A
SQL_LAB @ FREEPDB1
```

---

# DBA_* Views

`DBA_*` views provide an administrator-level view of database metadata.

Examples:

| View | Purpose |
|------|---------|
| `DBA_USERS` | Database users |
| `DBA_TS_QUOTAS` | Tablespace quotas |
| `DBA_SYS_PRIVS` | System privilege grants |
| `DBA_ROLE_PRIVS` | Role grants |
| `DBA_OBJECTS` | Database objects |

These views require appropriate privileges.

They will be queried from:

```text
Terminal B
SYS @ FREEPDB1
```

---

# Two Perspectives

Throughout this lesson, you will compare equivalent information using both perspectives.

| SQL_LAB Perspective | SYS Perspective | Information |
|---------------------|-----------------|-------------|
| `USER_USERS` | `DBA_USERS` | User configuration |
| `USER_TS_QUOTAS` | `DBA_TS_QUOTAS` | Tablespace quota |
| `USER_SYS_PRIVS` | `DBA_SYS_PRIVS` | System privileges |
| `USER_ROLE_PRIVS` | `DBA_ROLE_PRIVS` | Roles |
| `USER_OBJECTS` | `DBA_OBJECTS` | Objects |

Conceptually:

```text
                    FREEPDB1
                       │
          ┌────────────┴────────────┐
          │                         │
 SQL_LAB @ FREEPDB1          SYS @ FREEPDB1
          │                         │
          ▼                         ▼
       USER_*                    DBA_*
          │                         │
          └───────────┬─────────────┘
                      │
                      ▼
             Same Environment
          Different Perspectives
```

---

# Inspect the User Configuration

## Terminal A — SQL_LAB

Execute:

```sql
SELECT
    username,
    default_tablespace,
    temporary_tablespace
FROM user_users;
```

The verified SQL-Engineering-Lab environment returns:

```text
USERNAME        DEFAULT_TABLESPACE   TEMPORARY_TABLESPACE
--------------- -------------------- --------------------
SQL_LAB         FREEPDB1_DATA        TEMP
```

---

## Terminal B — SYS

Execute:

```sql
SELECT
    username,
    account_status,
    default_tablespace,
    temporary_tablespace
FROM dba_users
WHERE username = 'SQL_LAB';
```

The verified environment returns:

```text
USERNAME   ACCOUNT_STATUS   DEFAULT_TABLESPACE   TEMPORARY_TABLESPACE
---------- ---------------- -------------------- --------------------
SQL_LAB    OPEN             FREEPDB1_DATA        TEMP
```

Both queries describe the same `SQL_LAB` user.

The administrator view contains additional information such as the account status.

---

# Tablespaces

A tablespace is a logical storage unit used by Oracle Database.

Database objects ultimately require storage.

A simplified structure is:

```text
Oracle Database
      │
      ▼
Tablespace
      │
      ▼
Datafile
```

The main learning tablespace used by SQL-Engineering-Lab is:

```text
FREEPDB1_DATA
```

When `SQL_LAB` was created, the following clause was specified:

```sql
DEFAULT TABLESPACE FREEPDB1_DATA
```

This defines the default permanent tablespace for the user.

---

# Temporary Tablespace

`SQL_LAB` was also created with:

```sql
TEMPORARY TABLESPACE TEMP
```

The temporary tablespace provides temporary work space used by Oracle during certain database operations.

For the current learning environment:

```text
FREEPDB1_DATA
    → Permanent learning objects

TEMP
    → Temporary work space
```

---

# Tablespace Quota

A tablespace assignment and a tablespace quota are different concepts.

The default tablespace tells Oracle where objects should normally be stored.

A quota controls how much space the user is allowed to allocate in that tablespace.

In Lesson 02, you specified:

```sql
QUOTA UNLIMITED ON FREEPDB1_DATA
```

This allows `SQL_LAB` to allocate space in the learning tablespace without a user-specific quota limit.

---

# Inspect the Tablespace Quota

## Terminal A — SQL_LAB

Execute:

```sql
SELECT
    tablespace_name,
    bytes,
    max_bytes
FROM user_ts_quotas;
```

Verified result:

```text
TABLESPACE_NAME      BYTES   MAX_BYTES
-------------------- ------- ---------
FREEPDB1_DATA        0       -1
```

---

## Terminal B — SYS

Execute:

```sql
SELECT
    tablespace_name,
    username,
    bytes,
    max_bytes
FROM dba_ts_quotas
WHERE username = 'SQL_LAB';
```

Verified result:

```text
TABLESPACE_NAME   USERNAME   BYTES   MAX_BYTES
----------------- ---------- ------- ---------
FREEPDB1_DATA     SQL_LAB    0       -1
```

The value:

```text
MAX_BYTES = -1
```

represents the unlimited quota configured for `SQL_LAB`.

At the time of this verification, `BYTES` is `0`, meaning no quota-accounted space is currently allocated to the user in the tablespace.

---

# System Privileges

System privileges define database-level operations that a user is allowed to perform.

`SQL_LAB` currently has four directly granted system privileges:

```text
CREATE SEQUENCE
CREATE SESSION
CREATE TABLE
CREATE VIEW
```

---

# Inspect System Privileges

## Terminal A — SQL_LAB

Execute:

```sql
SELECT
    privilege
FROM user_sys_privs
ORDER BY privilege;
```

Verified result:

```text
CREATE SEQUENCE
CREATE SESSION
CREATE TABLE
CREATE VIEW
```

---

## Terminal B — SYS

Execute:

```sql
SELECT
    privilege
FROM dba_sys_privs
WHERE grantee = 'SQL_LAB'
ORDER BY privilege;
```

The result should contain the same four privileges.

---

# What Do These Privileges Mean?

| Privilege | Purpose |
|-----------|---------|
| `CREATE SESSION` | Connect to Oracle Database |
| `CREATE TABLE` | Create tables in the user's schema |
| `CREATE VIEW` | Create views in the user's schema |
| `CREATE SEQUENCE` | Create sequences in the user's schema |

These privileges were granted individually in Lesson 02.

This follows the SQL-Engineering-Lab approach of granting only the privileges currently required by the learning environment.

---

# Roles

A role is a named collection of privileges.

Instead of granting many privileges individually to multiple users, privileges can be grouped into a role.

Conceptually:

```text
Privileges
    │
    ▼
   Role
    │
    ▼
   User
```

At this point, `SQL_LAB` does not have any directly granted roles.

---

# Inspect Roles

## Terminal A — SQL_LAB

Execute:

```sql
SELECT
    granted_role
FROM user_role_privs
ORDER BY granted_role;
```

Verified result:

```text
no rows selected
```

---

## Terminal B — SYS

Execute:

```sql
SELECT
    granted_role
FROM dba_role_privs
WHERE grantee = 'SQL_LAB'
ORDER BY granted_role;
```

The administrator perspective also confirms that no roles are currently granted to `SQL_LAB`.

---

# Object Privileges

System privileges and object privileges are different.

A system privilege answers:

```text
What type of database operation can this user perform?
```

An object privilege answers:

```text
What can this user do with a specific object?
```

For example, if another schema owns a table named `BOOKS`, its owner could grant:

```sql
GRANT SELECT ON books TO SQL_LAB;
```

This would allow `SQL_LAB` to query that specific table.

Common object privileges include:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`

Object privileges will become more important later when SQL-Engineering-Lab introduces multiple objects and access patterns.

---

# Inspect Schema Objects

Oracle also provides data dictionary views for inspecting database objects.

## Terminal A — SQL_LAB

Execute:

```sql
SELECT
    object_name,
    object_type
FROM user_objects
ORDER BY object_type, object_name;
```

This shows objects owned by the current `SQL_LAB` schema.

---

## Terminal B — SYS

Execute:

```sql
SELECT
    object_name,
    object_type
FROM dba_objects
WHERE owner = 'SQL_LAB'
ORDER BY object_type, object_name;
```

This allows the administrator to inspect objects owned by `SQL_LAB`.

Again, both queries examine the same schema from different perspectives.

---

# Understanding the Lesson 02 CREATE USER Statement

We can now return to the statement used in Lesson 02.

```sql
CREATE USER SQL_LAB
IDENTIFIED BY sql_lab
DEFAULT TABLESPACE FREEPDB1_DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FREEPDB1_DATA;
```

Each clause now has a clear purpose.

| Definition | Meaning |
|------------|---------|
| `CREATE USER SQL_LAB` | Create the database user |
| `IDENTIFIED BY ...` | Define authentication credentials |
| `DEFAULT TABLESPACE FREEPDB1_DATA` | Define the default permanent tablespace |
| `TEMPORARY TABLESPACE TEMP` | Define the temporary tablespace |
| `QUOTA UNLIMITED ON FREEPDB1_DATA` | Allow space allocation in the learning tablespace |

Then:

```sql
GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE VIEW,
    CREATE SEQUENCE
TO SQL_LAB;
```

defines the operations the user is currently allowed to perform.

The environment can now be visualized as:

```text
FREEPDB1
│
├── Tablespaces
│      │
│      ├── FREEPDB1_DATA
│      │      └── SQL_LAB quota: UNLIMITED
│      │
│      └── TEMP
│
└── User
       └── SQL_LAB
            │
            ├── Schema: SQL_LAB
            │
            ├── Default Tablespace: FREEPDB1_DATA
            │
            ├── Temporary Tablespace: TEMP
            │
            └── System Privileges
                   ├── CREATE SESSION
                   ├── CREATE TABLE
                   ├── CREATE VIEW
                   └── CREATE SEQUENCE
```

---

# When a Query Fails

During database work, a query may fail even when the SQL itself appears correct.

For example, `SQL_LAB` does not have permission to query administrator-level views such as:

```text
DBA_USERS
DBA_TS_QUOTAS
```

Attempting to access such a view without sufficient privileges may result in an error such as:

```text
ORA-00942
```

Do not immediately assume that the database object or user is missing.

First verify:

```text
Who am I?
Where am I?
What am I allowed to see?
```

Use:

```text
SHOW USER
SHOW CON_NAME
```

Then consider whether you should be using a `USER_*` view or an administrator-level `DBA_*` view.

This simple troubleshooting pattern is useful throughout Oracle database engineering.

---

# Recommended Working Pattern

When investigating an Oracle environment, use the following sequence.

```text
1. Who am I?
       │
       └── SHOW USER
              │
              ▼
2. Where am I?
       │
       └── SHOW CON_NAME
              │
              ▼
3. What can I see?
       │
       ├── USER_*   → User perspective
       │
       └── DBA_*    → Administrator perspective
              │
              ▼
4. Compare the actual environment
```

For this lesson, keeping both terminals open makes this process much easier.

---

# Exercises

Complete the following exercises using both SQL*Plus terminals.

1. Open Terminal A as `SQL_LAB @ FREEPDB1`.
2. Open Terminal B as `SYS @ FREEPDB1`.
3. Verify `SHOW USER` and `SHOW CON_NAME` in both terminals.
4. Compare `USER_USERS` and `DBA_USERS`.
5. Compare `USER_TS_QUOTAS` and `DBA_TS_QUOTAS`.
6. Compare `USER_SYS_PRIVS` and `DBA_SYS_PRIVS`.
7. Compare `USER_ROLE_PRIVS` and `DBA_ROLE_PRIVS`.
8. Compare `USER_OBJECTS` and `DBA_OBJECTS`.
9. Identify the default and temporary tablespaces for `SQL_LAB`.
10. Identify the tablespace quota for `SQL_LAB`.
11. List the system privileges granted to `SQL_LAB`.
12. Confirm whether `SQL_LAB` currently has any roles.
13. Explain the difference between a user and a schema.
14. Explain the difference between a system privilege and an object privilege.
15. Explain why `SQL_LAB` cannot normally query `DBA_USERS`.

---

# Engineering Notes

Oracle troubleshooting often depends on context.

Before investigating users, objects, privileges, or storage, establish:

```text
Who am I?
Where am I?
What can I see?
```

A query that succeeds as:

```text
SYS @ FREEPDB1
```

may fail as:

```text
SQL_LAB @ FREEPDB1
```

because the two users have different privileges.

Likewise, a SYSDBA session connected to one container may expose a different administrative context than a session working inside another container.

Do not assume your session context.

Verify it.

For SQL-Engineering-Lab, the recommended approach for administrative lessons is:

```text
Terminal A
SQL_LAB @ FREEPDB1
        │
        └── Understand the user perspective

Terminal B
SYS @ FREEPDB1
        │
        └── Understand the administrator perspective
```

Comparing both perspectives helps turn Oracle's security and metadata model into something you can observe directly rather than memorize.

---

# Summary

In this lesson, you learned:

- An Oracle user represents a database account.
- A schema represents the objects owned by a user.
- Users and schemas are closely related but represent different concepts.
- Tablespaces provide logical storage for database objects.
- `FREEPDB1_DATA` is the default permanent tablespace for `SQL_LAB`.
- `TEMP` is the temporary tablespace for `SQL_LAB`.
- Tablespace quotas control space allocation.
- `SQL_LAB` has an unlimited quota on `FREEPDB1_DATA`.
- System privileges define database operations a user can perform.
- Object privileges control access to specific objects.
- Roles group privileges.
- `USER_*` views provide the current user's perspective.
- `DBA_*` views provide an administrator perspective.
- `SHOW USER` and `SHOW CON_NAME` should be checked whenever session context is important.
- Two simultaneous SQL*Plus sessions make user and administrator behavior easier to compare.

You can now explain the Oracle environment created in Lesson 02 instead of simply using it.

---

# Next Lesson

**Lesson 05 — Creating Your First Database Objects**

In the next lesson, you will use the `SQL_LAB` schema to create database objects and observe how users, schemas, tablespaces, privileges, and storage work together in practice.