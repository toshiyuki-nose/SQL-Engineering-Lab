# Oracle Environment

This document describes the Oracle Database environment used throughout **SQL-Engineering-Lab**.

It records the database architecture, learning schemas, database objects, and verification procedures used to develop and test the SQL lessons.

The environment documentation should be reviewed and updated whenever the database configuration or learning schema changes.

---

## 1. Environment Summary

| Item | Value |
|---|---|
| Database Product | Oracle Database 23ai Free |
| Database Version | 23.6.0.24.10 (initial inventory) |
| Operating System | Windows |
| Container Database (CDB) | FREE |
| Learning PDB | FREEPDB1 |
| Primary Learning Schema | SQL_LAB |
| SQL Client | SQL*Plus |
| GUI Client | Oracle SQL Developer |
| Character Set | AL32UTF8 (initial inventory) |
| NCHAR Character Set | AL16UTF16 (initial inventory) |

The database version, host name, and character-set information above were recorded in the initial environment inventory. They have not been independently reverified during the latest SQL_LAB inventory.

---

## 2. Database Architecture

```text
Oracle Database 23ai Free
│
└── CDB: FREE
    ├── CDB$ROOT
    ├── PDB$SEED
    └── PDB: FREEPDB1
        ├── FREEPDB1ADMIN
        ├── FREEPDB1USER01
        └── SQL_LAB
            ├── Book Store Database
            │   ├── BOOKS
            │   ├── CATEGORIES
            │   ├── AUTHORS
            │   └── BOOK_AUTHORS
            └── Additional Learning Tables
                ├── LEARNING_TOPICS
                └── SAMPLE_TABLE
```

The **FREEPDB1** pluggable database is the primary learning environment for SQL-Engineering-Lab.

The **SQL_LAB** schema is the dedicated schema used for the course exercises.

### Container Information

| Container | Status | Purpose |
|---|---|---|
| CDB$ROOT | READ WRITE (initial inventory) | Root container |
| PDB$SEED | READ ONLY (initial inventory) | Template database |
| FREEPDB1 | READ WRITE (initial inventory) | Learning environment |

The latest SQL*Plus verification confirmed that the active connection was to `FREEPDB1`.

---

## 3. Database Users and Schemas

| User / Schema | Purpose | Status |
|---|---|---|
| FREEPDB1ADMIN | Database administration | Existing |
| FREEPDB1USER01 | Previous learning exercises | Existing |
| SQL_LAB | SQL-Engineering-Lab exercises | Active — verified |

SQL_LAB is used to create, query, modify, and manage the database objects used throughout the SQL courses.

### Verify the Current User and Container

```sql
SHOW USER;
SHOW CON_NAME;
```

Expected values when connected to the dedicated learning schema:

```text
USER: SQL_LAB
CON_NAME: FREEPDB1
```

---

## 4. Tablespaces

The following tablespaces were recorded in the initial environment inventory.

| Tablespace | Purpose |
|---|---|
| SYSTEM | System objects |
| SYSAUX | Auxiliary system objects |
| TEMP | Temporary objects |
| UNDOTBS1 | Undo data |
| USERS | General user objects |
| FREEPDB1_DATA | Learning objects |

The latest inventory confirmed that all six SQL_LAB tables are stored in `FREEPDB1_DATA`.

```sql
SELECT
    table_name,
    tablespace_name
FROM user_tables
ORDER BY table_name;
```

---

## 5. SQL Clients

The following clients are documented for this repository.

| Tool | Purpose |
|---|---|
| SQL*Plus | Command-line SQL execution and verification |
| Oracle SQL Developer | GUI-based database development and inspection |

SQL*Plus is used to execute and verify the SQL examples throughout the courses.

### Connection Example

```powershell
sqlplus sql_lab@localhost:1521/FREEPDB1
```

The connection prompts for the SQL_LAB password.

Connection details may need to be adjusted if the database listener or service configuration changes.

---

## 6. SQL_LAB Schema Inventory

The latest inventory confirmed the following database objects.

| Object Type | Count |
|---|---:|
| Tables | 6 |
| Indexes | 5 |
| Total Objects | 11 |

The schema also contains 11 enabled constraints associated with the Book Store Database.

Constraints are database metadata and are not included in the `USER_OBJECTS` total shown above.

### Tables

| Table | Purpose | Row Count |
|---|---|---:|
| BOOKS | Book information | 15 |
| CATEGORIES | Book category master | 6 |
| AUTHORS | Author master | 9 |
| BOOK_AUTHORS | Book-to-author relationships | 16 |
| LEARNING_TOPICS | Additional learning table | Not collected |
| SAMPLE_TABLE | Additional learning table | Not collected |

The row counts represent the values observed during the latest inventory and may change as exercises are executed.

### Verify Database Objects

```sql
SELECT
    object_type,
    COUNT(*) AS object_count
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
```

---

## 7. Book Store Database

The **Book Store Database** is the primary sample data model used in SQL-Engineering-Lab.

It supports exercises involving filtering, joins, aggregation, subqueries, data manipulation, transactions, and advanced SQL queries.

### 7.1 Tables and Columns

#### CATEGORIES

| Column | Data Type | Nullable |
|---|---|---|
| CATEGORY_ID | NUMBER | No |
| CATEGORY_NAME | VARCHAR2(30) | No |

#### AUTHORS

| Column | Data Type | Nullable |
|---|---|---|
| AUTHOR_ID | NUMBER | No |
| AUTHOR_NAME | VARCHAR2(100) | No |

#### BOOKS

| Column | Data Type | Nullable |
|---|---|---|
| BOOK_ID | NUMBER | No |
| TITLE | VARCHAR2(100) | Yes |
| PRICE | NUMBER | Yes |
| STOCK | NUMBER | Yes |
| PUBLISHED_YEAR | NUMBER | Yes |
| SUBTITLE | VARCHAR2(100) | Yes |
| CATEGORY_ID | NUMBER | No |

#### BOOK_AUTHORS

| Column | Data Type | Nullable |
|---|---|---|
| BOOK_ID | NUMBER | No |
| AUTHOR_ID | NUMBER | No |

The data types and nullability values above were verified using `USER_TAB_COLUMNS`.

### 7.2 Relationships

The Book Store Database uses the following relationships:

- One category can be associated with multiple books.
- Each book references a category.
- A book can have multiple authors.
- An author can be associated with multiple books.
- The BOOK_AUTHORS table implements the many-to-many relationship between BOOKS and AUTHORS.

```text
CATEGORIES (1)
    │
    └── (N) BOOKS (1)
                │
                └── (N) BOOK_AUTHORS (N)
                            │
                            └── (1) AUTHORS
```

### 7.3 Primary Keys

| Table | Constraint |
|---|---|
| CATEGORIES | PK_CATEGORIES |
| AUTHORS | PK_AUTHORS |
| BOOKS | PK_BOOKS |
| BOOK_AUTHORS | PK_BOOK_AUTHORS |

### 7.4 Foreign Keys

| Table | Constraint |
|---|---|
| BOOKS | FK_BOOKS_CATEGORY |
| BOOK_AUTHORS | FK_BOOK_AUTHORS_BOOK |
| BOOK_AUTHORS | FK_BOOK_AUTHORS_AUTHOR |

### 7.5 Unique and Check Constraints

| Table | Constraint | Type |
|---|---|---|
| CATEGORIES | UQ_CATEGORIES_NAME | Unique |
| CATEGORIES | SYS_C008457 | Check |
| BOOKS | SYS_C008461 | Check |
| AUTHORS | SYS_C008462 | Check |

The detailed check conditions were not collected during this inventory. The generated `SYS_C...` constraints may represent column-level `NOT NULL` enforcement.

All 11 constraints were reported as `ENABLED`.

### 7.6 Indexes

| Table | Index | Uniqueness |
|---|---|---|
| AUTHORS | PK_AUTHORS | UNIQUE |
| BOOKS | PK_BOOKS | UNIQUE |
| BOOK_AUTHORS | PK_BOOK_AUTHORS | UNIQUE |
| CATEGORIES | PK_CATEGORIES | UNIQUE |
| CATEGORIES | UQ_CATEGORIES_NAME | UNIQUE |

No additional indexes were reported in the latest SQL_LAB inventory.

---

## 8. Additional Learning Tables

Two additional tables exist in the SQL_LAB schema.

### LEARNING_TOPICS

| Column | Data Type | Nullable |
|---|---|---|
| TOPIC_ID | NUMBER | Yes |
| TOPIC_NAME | VARCHAR2(100) | Yes |
| STATUS | VARCHAR2(20) | Yes |
| CREATED_AT | DATE | Yes |

### SAMPLE_TABLE

| Column | Data Type | Nullable |
|---|---|---|
| ID | NUMBER | Yes |

No constraints were reported for these two tables.

These tables are documented separately from the Book Store Database.

---

## 9. Other Existing Learning Schemas

The initial environment inventory also documented objects in other schemas.

### FREEPDB1ADMIN

| Object Type | Count |
|---|---:|
| Sequence | 1 |

### FREEPDB1USER01

| Object Type | Count |
|---|---:|
| Tables | 4 |
| Indexes | 4 |
| Sequences | 1 |

Tables recorded in the initial inventory:

- RESERVATIONS
- SHOPS
- SPORTS_MASTER
- SPORT_CATEGORY_MASTER

These objects predate the SQL-Engineering-Lab project.

Their current state was not reverified during the latest SQL_LAB inventory.

---

## 10. Environment Verification

The following read-only SQL statements can be used to verify the learning environment.

### Current User and PDB

```sql
SHOW USER;
SHOW CON_NAME;
```

### Tables

```sql
SELECT table_name
FROM user_tables
ORDER BY table_name;
```

### Objects

```sql
SELECT
    object_type,
    COUNT(*) AS object_count
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
```

### Constraints

```sql
SELECT
    table_name,
    constraint_name,
    constraint_type,
    status
FROM user_constraints
ORDER BY table_name, constraint_name;
```

### Indexes

```sql
SELECT
    table_name,
    index_name,
    uniqueness
FROM user_indexes
ORDER BY table_name, index_name;
```

### Book Store Data Counts

```sql
SELECT 'BOOKS' AS table_name, COUNT(*) AS row_count
FROM books
UNION ALL
SELECT 'CATEGORIES', COUNT(*)
FROM categories
UNION ALL
SELECT 'AUTHORS', COUNT(*)
FROM authors
UNION ALL
SELECT 'BOOK_AUTHORS', COUNT(*)
FROM book_authors;
```

All verification queries in this section are read-only.

---

## 11. Future Development

The SQL_LAB schema may be extended as additional courses are introduced.

Potential future components include:

- Views and materialized views
- Sequences and additional database objects
- Execution plan examples
- Performance test tables
- SQL tuning exercises
- Additional indexes for performance analysis

These are potential extensions, not verified existing components.

---

## 12. Repository Usage

| Environment | Purpose |
|---|---|
| FREEPDB1 / SQL_LAB | Main SQL-Engineering-Lab environment |

Whenever possible, lessons should be executed and verified using the documented learning environment.

Database changes introduced by exercises should be reviewed before the environment inventory is updated.

SQL execution logs may be retained locally according to the repository's logging and Git ignore conventions.

---

## 13. Change History

| Date | Description |
|---|---|
| 2026-07-26 | Initial Oracle environment inventory created. |
| 2026-10-24 | Updated SQL_LAB schema inventory after Course 05; documented tables, relationships, constraints, indexes, and row counts. |
