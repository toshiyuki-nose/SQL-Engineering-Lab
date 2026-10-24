# Course 05 — Advanced SQL Queries

## Overview

Build on the Book Store Database developed in Courses 01–04. This course focuses on writing expressive, maintainable, read-only analytical queries in Oracle Database Free.

## Prerequisites

- Courses 01–04 completed.
- Connect to the `SQL_LAB` schema in PDB `FREEPDB1`.
- Tables: `BOOKS`, `CATEGORIES`, `AUTHORS`, `BOOK_AUTHORS`.
- Execute scripts from the repository root using SQL*Plus.

## Curriculum

| Lesson | Title | Topics |
| --- | --- | --- |
| 01 | CASE Expressions | Searched/simple CASE, NULL handling, classification, conditional aggregation |
| 02 | Common Table Expressions | WITH clause, readable multi-stage queries |
| 03 | Set Operations | UNION, UNION ALL, INTERSECT, MINUS |
| 04 | Window Functions Basics | OVER, PARTITION BY, ROW_NUMBER, RANK |
| 05 | Advanced Window Functions | LAG, LEAD, running totals, moving aggregates |
| 06 | Query Refactoring | Readability, correctness, maintainability, comparisons |

## Working Method

1. Read each lesson's `courseNN_lessonNN.md`.
2. Execute `lessonNN.sql` in SQL*Plus.
3. Review the generated `logs/lessonNN.log` file.
4. Verify results and answer the practice questions.
5. Review the lesson before committing changes to GitHub.

Execution logs are intentionally excluded from Git tracking.

## Database Safety

Course 05 exercises are designed as read-only SELECT queries. Avoid modifying the shared Book Store Database while running these lessons.

## References

- *Learn SQL in 24 Hours: The Complete Beginner's Guide* — Aniket Jain
- *SQL実践入門*
- Oracle Database SQL Language Reference

All explanations and exercises are independently written for this repository.
