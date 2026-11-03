# Course 06 — Lesson 03: Constraints and Data Integrity

> **Define valid data once. Let the database enforce the rules.**

## 1. Overview

Relational database design is not complete when tables and relationships are drawn. A database must also enforce rules that prevent invalid, inconsistent, or duplicate data. In Oracle, **constraints** provide declarative data-integrity checks.

This lesson builds three dedicated practice tables in the Book Store domain. You will insert valid rows, deliberately attempt invalid operations, and inspect Oracle's responses.

**Scope:** The script creates only `C06L03_` practice objects in the `SQL_LAB` schema. It does not modify the existing `BOOKS`, `AUTHORS`, `BOOK_AUTHORS`, or `CATEGORIES` tables.

## 2. Learning Objectives

By the end of this lesson, you should be able to:

- Explain entity integrity, referential integrity, and domain integrity.
- Define `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, and `NOT NULL` constraints.
- Distinguish a primary key from a unique constraint.
- Interpret common Oracle constraint errors.
- Inspect constraint metadata using Oracle data dictionary views.
- Explain the impact of constraints on insert, update, and delete operations.

## 3. Prerequisites and Environment

- Course 06 Lessons 01 and 02 completed.
- Oracle Database 23ai Free, PDB `FREEPDB1`, schema `SQL_LAB`.
- Privileges to create tables in the learning schema.
- SQL*Plus or Oracle SQL Developer.

**Important:** `course06_lesson03.sql` is a **first-run setup script**, not an idempotent migration. Running it again after successful creation will cause name-collision errors. It includes `WHENEVER SQLERROR EXIT SQL.SQLCODE` to stop SQL*Plus if an unexpected error occurs. Oracle DDL commits implicitly, so a partial setup may require manual inspection before retrying.

## 4. Why Constraints Matter

Consider a Book Store system. Without constraints, an application might store a book with a negative price, assign a nonexistent category, or create two categories with the same identifier.

Constraints move these rules into the database so that they apply regardless of which application or SQL client writes the data.

Three related ideas:

- **Entity integrity:** each row can be identified using a valid primary key.
- **Referential integrity:** a foreign-key value must match a referenced key, unless the foreign key is nullable and the value is `NULL`.
- **Domain integrity:** values must satisfy applicable type, nullability, and business rules.

## 5. Constraint Types

| Constraint | Purpose | Lesson example |
|---|---|---|
| `PRIMARY KEY` | Uniquely identifies each row; disallows `NULL` | `C06L03_BOOKS.BOOK_ID` |
| `FOREIGN KEY` | Protects references to parent rows | `C06L03_BOOKS.CATEGORY_ID` |
| `UNIQUE` | Prevents duplicate non-null key values | `C06L03_BOOKS.ISBN` |
| `CHECK` | Enforces a predicate on row values | `PRICE >= 0`, `RATING BETWEEN 1 AND 5` |
| `NOT NULL` | Requires a non-null value | `C06L03_BOOKS.TITLE` |

### 5.1 PRIMARY KEY versus UNIQUE

A table has at most one primary-key constraint, which can contain multiple columns. A table can have multiple unique constraints. In Oracle, a single-column `UNIQUE` constraint generally permits multiple `NULL` values; use `NOT NULL` as well when a value is required.

### 5.2 FOREIGN KEY behavior

The practice tables use the default restrictive behavior: deleting a parent row that is still referenced by child rows is rejected. Oracle also supports explicit referential actions such as `ON DELETE CASCADE` and `ON DELETE SET NULL`; those are not enabled here.

### 5.3 CHECK and NULL

A `CHECK` condition rejects rows when the condition is **false**. If it evaluates to **unknown** because of `NULL`, the check does not reject the row. Combine `CHECK` with `NOT NULL` when the value must exist.

## 6. Practice Data Model

```text
C06L03_CATEGORIES
  CATEGORY_ID (PK)
  CATEGORY_NAME (NOT NULL, UNIQUE)
         |
         | 1-to-many
         v
C06L03_BOOKS
  BOOK_ID (PK)
  TITLE (NOT NULL)
  ISBN (UNIQUE; nullable)
  PRICE (NOT NULL, CHECK >= 0)
  STOCK (NOT NULL, CHECK >= 0)
  CATEGORY_ID (FK, NOT NULL)
         |
         | 1-to-many
         v
C06L03_REVIEWS
  REVIEW_ID (PK)
  BOOK_ID (FK, NOT NULL)
  RATING (NOT NULL, CHECK 1..5)
```

The model is intentionally small so that each constraint can be tested independently.

## 7. Hands-on SQL Workflow

Open `course06_lesson03.sql` and review the statements before execution.

1. **Query 00:** Confirm that the session uses `SQL_LAB` and `FREEPDB1`.
2. **Step 01:** Create the three dedicated practice tables.
3. **Step 02:** Insert valid categories, books, and a review; commit the sample data.
4. **Query 01:** Inspect constraints in `USER_CONSTRAINTS`.
5. **Step 03:** Execute eight intentionally invalid statements inside a PL/SQL block. Each should print `PASS` with the expected Oracle error number.
6. **Query 02:** Confirm that invalid operations did not change the valid row counts.
7. **Query 03:** Read the valid book/category records.

### Expected row counts

| Table | Rows |
|---|---:|
| `C06L03_CATEGORIES` | 2 |
| `C06L03_BOOKS` | 2 |
| `C06L03_REVIEWS` | 1 |

### Expected constraint failures

| Test | Oracle error |
|---|---|
| Duplicate primary key | `ORA-00001` |
| Duplicate unique category name | `ORA-00001` |
| Duplicate unique ISBN | `ORA-00001` |
| Missing parent category | `ORA-02291` |
| Negative price | `ORA-02290` |
| Invalid rating | `ORA-02290` |
| Missing required title | `ORA-01400` |
| Delete referenced parent | `ORA-02292` |

The PL/SQL block catches **only the expected error code** for each test. An unexpected error is re-raised and should be investigated. A `PASS` line means the attempted invalid operation was correctly rejected; it does not mean the invalid row was inserted.

## 8. Inspecting Metadata

`USER_CONSTRAINTS` exposes constraint type, status, and validation state. Its `CONSTRAINT_TYPE` codes include:

- `P`: primary key
- `R`: referential (foreign key)
- `U`: unique key
- `C`: check condition (including `NOT NULL` constraints)

Use `USER_CONS_COLUMNS` to identify the columns associated with each constraint. For foreign keys, `R_CONSTRAINT_NAME` identifies the referenced key constraint.

## 9. Exercises

1. Identify the primary key of each practice table.
2. Explain why `C06L03_BOOKS.CATEGORY_ID = 999` is rejected.
3. Explain why a negative `PRICE` fails, and why `NOT NULL` is also needed.
4. Compare the behavior of `PRIMARY KEY` and `UNIQUE` for `NULL` values.
5. Explain what would happen if a referenced category were deleted.
6. **Design exercise (no execution required):** propose a `CHECK` rule to restrict `STOCK` to a reasonable maximum and discuss the business assumption behind that limit.

## 10. Engineering Notes

- Constraints should express stable business invariants, not merely application-screen validation.
- Name constraints explicitly to make diagnostics and maintenance easier.
- Constraints protect integrity, but do not replace authorization, transaction design, or application-level error handling.
- `CHECK` constraints are evaluated per row; cross-table rules usually need other design approaches.
- Avoid disabling constraints just to make test data load successfully.
- Oracle DDL generally commits implicitly. Use dedicated objects for experiments and review cleanup carefully.
- The sample uses an ISBN-like string for demonstration; it is not an implementation of a real ISBN validator.

## 11. Completion Criteria

This lesson is complete when:

- All three practice tables exist with the intended constraints.
- Valid sample rows are committed.
- All eight negative tests report the expected error codes.
- The final row counts are 2, 2, and 1.
- You can explain how each constraint protects the Book Store model.

## 12. Next Lesson

**Lesson 04 — Views:** create reusable query interfaces without duplicating the underlying data.

---

**Learn by executing. Verify what happens. Understand why it works.**
