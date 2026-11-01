# SQL-Engineering-Lab

> **Learn SQL. Design Databases. Engineer Better Queries.**

A hands-on SQL and database engineering learning project built around **Oracle Database 23ai Free**.

---

## Overview

**SQL-Engineering-Lab** is a structured learning repository for practicing SQL through real database exercises.

Rather than focusing on syntax alone, the project emphasizes writing, executing, verifying, and improving SQL in an Oracle environment. As the curriculum progresses, it will also cover database design, execution plans, and performance tuning.

The goal is simple:

> **Become a database engineer, not just someone who can write SQL.**

---

## Learning Progress

**Courses 01–05 are complete: 29 lessons in total.**

| Course | Subject | Lessons | Status |
|---|---|---:|---|
| [01](course01_oracle_environment/) | Oracle Environment | 5 | Complete |
| [02](course02_sql_fundamentals/) | SQL Fundamentals | 6 | Complete |
| [03](course03_multiple_tables_and_relationships/) | Multiple Tables and Relationships | 6 | Complete |
| [04](course04_data_manipulation_and_transactions/) | Data Manipulation and Transactions | 6 | Complete |
| [05](course05_advanced_sql_queries/) | Advanced SQL Queries | 6 | Complete |
| 06 | Next course — scope to be defined | — | Planned |

The curriculum will continue to grow as new courses are designed and verified.

---

## Completed Curriculum

### Course 01 — Oracle Environment

Establish an Oracle learning environment and understand its core components.

- Oracle Database overview
- Connecting to FREEPDB1
- SQL clients
- Users, schemas, and tablespaces
- First database objects

[Explore Course 01](course01_oracle_environment/)

### Course 02 — SQL Fundamentals

Build a foundation in querying and analyzing relational data.

- SELECT basics
- Filtering rows
- Sorting results
- Expressions and NULL
- SQL functions
- Aggregation and grouping

[Explore Course 02](course02_sql_fundamentals/)

### Course 03 — Multiple Tables and Relationships

Understand relationships and retrieve information across tables.

- Relational database basics
- Creating related tables
- INNER JOIN
- OUTER JOIN
- Multiple-table joins
- Subqueries

[Explore Course 03](course03_multiple_tables_and_relationships/)

### Course 04 — Data Manipulation and Transactions

Learn how to modify data while protecting consistency and integrity.

- INSERT statements
- UPDATE statements
- DELETE statements
- MERGE and upsert
- Transactions, COMMIT, and ROLLBACK
- Data integrity and safe DML practices

[Explore Course 04](course04_data_manipulation_and_transactions/)

### Course 05 — Advanced SQL Queries

Develop more expressive, maintainable SQL queries.

- CASE expressions
- Common Table Expressions (CTEs)
- Set operations
- Window function basics
- Advanced window functions
- Query refactoring

[Explore Course 05](course05_advanced_sql_queries/)

---

## Learning Environment

| Component | Configuration |
|---|---|
| Database | Oracle Database 23ai Free |
| Container Database | FREE |
| Pluggable Database | FREEPDB1 |
| Learning Schema | SQL_LAB |
| Command-line Client | SQL*Plus |
| GUI Client | Oracle SQL Developer |

The **SQL_LAB** schema contains the Book Store Database used in the exercises, alongside additional learning tables.

The Book Store Database includes four related tables:

- **CATEGORIES** — book categories
- **BOOKS** — book records
- **AUTHORS** — author records
- **BOOK_AUTHORS** — relationships between books and authors

For the verified schema inventory, tables, constraints, indexes, and environment checks, see [Oracle Environment](docs/oracle_environment.md).

---

## Repository Structure

The following tree highlights the established course directories and the environment documentation. It is not an exhaustive listing of every file.

```text
SQL-Engineering-Lab/
├── README.md
├── .gitattributes
├── course01_oracle_environment/
├── course02_sql_fundamentals/
├── course03_multiple_tables_and_relationships/
├── course04_data_manipulation_and_transactions/
├── course05_advanced_sql_queries/
└── docs/
    └── oracle_environment.md
```

Each completed course contains lesson materials and supporting SQL exercises. Lesson documentation follows the naming convention `courseNN_lessonNN.md`.

---

## Learning Workflow

The exercises emphasize a repeatable, hands-on process:

1. Read the lesson and understand the objective.
2. Write or review the SQL statements.
3. Execute the SQL in Oracle Database.
4. Inspect the results and verify the expected behavior.
5. Compare alternative approaches where appropriate.
6. Complete the exercises and review the engineering notes.

As later courses introduce performance engineering, this workflow will expand to include execution-plan analysis and SQL tuning.

---

## Future Roadmap

Potential future topics include:

- Relational database design and normalization
- Views, sequences, and indexes
- Execution plans and AUTOTRACE
- Oracle Optimizer and optimizer statistics
- SQL performance tuning
- PL/SQL, procedures, functions, packages, and triggers
- Materialized views and partitioning
- Database security and operations
- An end-to-end database engineering project

These topics are **planned possibilities**, not completed course content. Course 06 and subsequent course structures will be defined as the project progresses.

---

## References

This repository draws inspiration from SQL learning resources and Oracle documentation. Its lesson materials, examples, exercises, and engineering notes are developed for the Oracle learning environment.

Recommended references:

- *Learn SQL in 24 Hours: The Complete Beginner's Guide*
- *SQL実践入門*
- [Oracle Database Documentation](https://docs.oracle.com/en/database/)

---

## Project Principle

**Learn by executing. Verify what happens. Understand why it works.**
