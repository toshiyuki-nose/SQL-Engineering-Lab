# Course 06 — Database Design and Schema Objects

> **Design reliable relational structures. Build reusable Oracle schema objects.**

## Overview

Course 06 moves from writing SQL queries to designing the relational structures and schema objects that support them. Using the existing Book Store Database, this course introduces data modeling, normalization, integrity constraints, views, sequences, identity columns, and indexes.

The focus is on understanding **why a database is structured in a particular way**, not simply memorizing `CREATE` statements.

## Learning Objectives

By the end of this course, you should be able to:

- Identify entities, attributes, keys, and relationships in a relational model.
- Explain normalization through the first, second, and third normal forms.
- Choose and define constraints to protect data integrity.
- Create and use views to simplify and reuse queries.
- Compare Oracle sequences and identity columns for generating identifiers.
- Create basic indexes and explain their design trade-offs.
- Apply these concepts to a small, coherent schema design.

## Prerequisites

Complete Courses 01–05, including SQL fundamentals, joins, subqueries, DML, transactions, CTEs, and window functions.

The exercises assume the Oracle learning environment and Book Store Database established in earlier courses.

## Learning Environment

| Component | Configuration |
|---|---|
| Database | Oracle Database 23ai Free |
| Pluggable Database | `FREEPDB1` |
| Learning Schema | `SQL_LAB` |
| Sample Domain | Book Store Database |

Refer to [Oracle Environment](../docs/oracle_environment.md) for the established environment and schema inventory.

## Course Curriculum

| Lesson | Title | Key Topics | Status |
|---|---|---|---|
| 01 | Relational Database Design | Entities, attributes, keys, relationships, ER modeling | Planned |
| 02 | Database Normalization | Functional dependencies, 1NF, 2NF, 3NF | Planned |
| 03 | Constraints and Data Integrity | PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL | Planned |
| 04 | Views | CREATE VIEW, reusable queries, view considerations | Planned |
| 05 | Sequences and Identity Columns | CREATE SEQUENCE, NEXTVAL, identity columns | Planned |
| 06 | Indexes and Schema Design | B-tree indexes, composite indexes, design trade-offs | Planned |

Lesson materials and SQL exercises will be added incrementally after review and verification.

## Learning Approach

For each lesson:

1. Review the design concept and its purpose.
2. Examine examples based on the Book Store domain.
3. Write and execute SQL in Oracle.
4. Inspect schema definitions and verify expected behavior.
5. Complete exercises and record design decisions.

Where a lesson requires schema changes, review their impact on existing tables and data before execution. Prefer dedicated practice objects when experiments could disrupt earlier lessons.

## Scope and Boundaries

This course covers schema design and basic schema-object operations. Detailed execution-plan analysis, optimizer statistics, and SQL performance tuning are reserved for later courses.

## Completion Criteria

Course 06 is complete when all six lessons have documented explanations, reproducible Oracle exercises, expected results, and verified examples.

---

**Learn by executing. Verify what happens. Understand why it works.**
