# Course 04 — Data Manipulation and Transactions

Learn how to modify data safely in Oracle Database Free using the Book Store Database developed in earlier courses.

## Learning objectives

By completing this course, you will be able to:

- Insert, update, and delete records using Oracle SQL.
- Use `MERGE` to synchronize existing and new records.
- Explain the behavior of `COMMIT`, `ROLLBACK`, and `SAVEPOINT`.
- Understand primary key, foreign key, and `NOT NULL` constraints.
- Verify the number of affected rows with `SQL%ROWCOUNT`.
- Use transaction boundaries and validation queries to reduce the risk of unintended changes.

## Lessons

| Lesson | Topic | Focus |
| --- | --- | --- |
| 01 | INSERT Basics | Insert records and validate results |
| 02 | UPDATE Statements | Update selected rows and verify changes |
| 03 | DELETE Statements | Delete selected rows and restore data with rollback |
| 04 | MERGE and Upsert | Update matching rows and insert missing rows using an inline source catalog |
| 05 | Transactions and COMMIT / ROLLBACK | Compare full rollback, savepoint rollback, and committed changes |
| 06 | Data Integrity and Safe DML Practices | Validate constraints and affected-row counts using safe DML |

All six lessons were executed and reviewed in SQL*Plus against the `SQL_LAB` schema in `FREEPDB1`.

## Prerequisites

- Complete Course 01–03 and prepare the Book Store Database.
- Connect to Oracle Database Free using SQL*Plus as `SQL_LAB` on `FREEPDB1`.
- Ensure `CATEGORIES` contains `CATEGORY_ID = 60` (`Reference`).
- Run each script from the repository root in a dedicated session with no unrelated uncommitted work.

Example connection (PowerShell):

```powershell
cd E:\SQL\SQL-Engineering-Lab
sqlplus sql_lab@localhost:1521/FREEPDB1
```

Example lesson execution (SQL*Plus):

```sql
@course04_data_manipulation_and_transactions/lesson06_data_integrity_and_safe_dml_practices/lesson06.sql
```

## Database safety and cleanup

Most exercises use reserved training IDs and roll back their changes. **Lesson 05 intentionally demonstrates `COMMIT`**, then explicitly deletes and commits the practice record. **Lesson 06 creates and drops a dedicated table** (`LESSON06_REQUIRED_TITLE`) to test `NOT NULL` without changing the existing `BOOKS` definition. Oracle DDL causes implicit commits and cannot be undone with `ROLLBACK`.

Lesson 04's external catalog is an **inline view** built with `SELECT`, `UNION ALL`, and `DUAL`, not a physical staging table.

Check the execution output and the final cleanup queries before proceeding to the next lesson. If a script stops unexpectedly, review the log before rerunning; a committed practice record or a temporary table may remain.

## Repository conventions

Each lesson includes a Markdown explanation (`lesson.md`) and an executable SQL script (`lessonNN.sql`). SQL*Plus execution logs are stored locally in `logs/` and excluded from Git by `.gitignore`.

## Completion criteria

- All six SQL scripts execute without unexpected SQL errors.
- Expected constraint violations are caught and validated.
- All training records are cleaned up after the exercises.
- Lesson 06's dedicated practice table is removed.
- Documentation and scripts are reviewed before committing to the repository.
