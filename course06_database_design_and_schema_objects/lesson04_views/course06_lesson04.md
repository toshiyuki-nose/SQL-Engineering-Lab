# Course 06 — Lesson 04: Views

> **Expose reusable query interfaces without duplicating the underlying data.**

## 1. Overview

A **view** is a named SQL query stored in the database. A conventional Oracle view does not independently store the result rows; it reads from its underlying tables when queried. Views can simplify joins, provide stable interfaces, and limit which columns or rows a consumer can see. A view is **not** by itself a security boundary: privileges and schema ownership still matter.

This lesson uses dedicated `C06L04_` tables and views in `SQL_LAB`. Existing Book Store Database objects are not modified.

## 2. Learning Objectives

By the end of this lesson, you should be able to:

- Explain a view and distinguish it from a table and a materialized view.
- Create a join view with `CREATE VIEW`.
- Build a category summary view using `GROUP BY`.
- Change a view with `CREATE OR REPLACE VIEW`.
- Explain when a simple view is updatable and why join/aggregate views have restrictions.
- Demonstrate `WITH CHECK OPTION` and `WITH READ ONLY`.
- Inspect view metadata and clean up lesson objects safely.

## 3. Environment and Safety

| Item | Value |
|---|---|
| Oracle | Oracle Database 23ai Free |
| PDB | `FREEPDB1` |
| Schema | `SQL_LAB` |
| Practice objects | `C06L04_` prefix only |

Files:

- `course06_lesson04.md` — explanation and review tasks
- `course06_lesson04.sql` — first-run practice script
- `course06_lesson04_cleanup.sql` — optional destructive cleanup for this lesson only

**Important:** The practice SQL is a **first-run script**. It creates tables and views, and it will fail with `ORA-00955` if the objects already exist. Inspect the objects and use the separate cleanup script before a deliberate rerun. Oracle DDL commits implicitly. Cleanup deletes lesson data and cannot be undone with `ROLLBACK`.

## 4. What Is a View?

```sql
CREATE VIEW c06l04_v_book_details AS
SELECT b.book_id, b.title, c.category_name, b.price
FROM c06l04_books b
JOIN c06l04_categories c ON c.category_id = b.category_id;
```

A consumer can then write:

```sql
SELECT * FROM c06l04_v_book_details;
```

The join definition is centralized in one schema object. The view stores the query definition, **not a separate copy of the underlying book rows**.

### Tables, views, and materialized views

| Object | Main characteristic |
|---|---|
| Table | Stores rows |
| View | Stores a query definition; typically reads current base-table data |
| Materialized view | Stores query results and requires a refresh strategy; out of scope for this lesson |

## 5. Practice Data Model

```text
C06L04_CATEGORIES (CATEGORY_ID PK, CATEGORY_NAME)
        | 1-to-many
        v
C06L04_BOOKS (BOOK_ID PK, TITLE, CATEGORY_ID FK, PRICE, STOCK)
```

Sample rows:

| BOOK_ID | TITLE | CATEGORY | PRICE | STOCK |
|---:|---|---|---:|---:|
| 1001 | Database Fundamentals | Technology | 35.50 | 8 |
| 1002 | SQL Practice | Technology | 28.00 | 4 |
| 1003 | Short Stories | Literature | 18.00 | 6 |

Two categories and three books are inserted and committed.

## 6. Joining Tables Through a View

`C06L04_V_BOOK_DETAILS` joins book and category tables. The result has three rows, one per book. The `CATEGORY_NAME` column is exposed without requiring every consumer to write the join.

A view can make a common query easier to maintain, but it does not guarantee better performance. The optimizer evaluates the query and its underlying objects; detailed execution plans belong in a later course.

## 7. Aggregate Views

`C06L04_V_CATEGORY_SUMMARY` groups books by category and calculates:

- `BOOK_COUNT` — number of books
- `TOTAL_STOCK` — sum of units in stock
- `INVENTORY_VALUE` — sum of `PRICE * STOCK`

Expected output:

| CATEGORY_NAME | BOOK_COUNT | TOTAL_STOCK | INVENTORY_VALUE |
|---|---:|---:|---:|
| Technology | 2 | 12 | 396.00 |
| Literature | 1 | 6 | 108.00 |

The view uses a `LEFT JOIN` to retain categories even when they have no books. `NVL` converts `NULL` aggregate results to zero where appropriate.

**Design note:** Aggregate views are not generally directly updatable like simple single-table views.

## 8. CREATE OR REPLACE VIEW

The script first creates `C06L04_V_BOOK_DETAILS` with four columns. It then replaces the definition to add `STOCK`:

```sql
CREATE OR REPLACE VIEW c06l04_v_book_details AS
SELECT b.book_id, b.title, c.category_name, b.price, b.stock
FROM c06l04_books b
JOIN c06l04_categories c ON c.category_id = b.category_id;
```

`CREATE OR REPLACE` changes the view definition without first explicitly dropping the view. Dependent objects may be affected by definition changes; review dependencies before changing views in production.

## 9. Updatable Views

A simple view based on a single table can often support `UPDATE`, subject to Oracle's rules. The script creates:

```sql
CREATE VIEW c06l04_v_technology_books AS
SELECT book_id, title, category_id, price, stock
FROM c06l04_books
WHERE category_id = 10
WITH CHECK OPTION CONSTRAINT ck_c06l04_tech_view;
```

An update to `PRICE` for book 1001 is applied through this view and then **rolled back to a savepoint**. The base table should show `35.50` again after the rollback.

### WITH CHECK OPTION

This clause rejects an insert or update through the view if the resulting row would no longer satisfy the view predicate. Attempting to change book 1001 from category 10 to category 20 through this view should raise `ORA-01402`. The script catches that **expected** error and prints `PASS`.

### WITH READ ONLY

`C06L04_V_READ_ONLY_BOOKS` is defined with `WITH READ ONLY`. An attempted update should raise `ORA-42399`; the script checks that expected error and prints `PASS`.

A read-only view prevents DML through that view; it does **not** prevent authorized changes to the underlying table through other routes.

## 10. Inspecting View Metadata

The script queries `USER_VIEWS` to list lesson views and their read-only status. Additional useful Oracle dictionary views include:

- `USER_OBJECTS` — object names and types
- `USER_TAB_COLUMNS` — exposed columns and data types
- `USER_UPDATABLE_COLUMNS` — updatability metadata for view columns
- `USER_DEPENDENCIES` — dependencies between schema objects

A stored view definition may be inspected through dictionary metadata or a tool such as SQL Developer.

## 11. Hands-on Workflow

1. **Query 00:** Verify `SQL_LAB` / `FREEPDB1`.
2. **Step 01:** Create two base tables and insert sample data.
3. **Step 02:** Create and query a join view.
4. **Step 03:** Create and query an aggregate view.
5. **Step 04:** Replace the join view to add `STOCK`.
6. **Steps 05–06:** Update through a simple view and roll back.
7. **Step 07:** Confirm `WITH CHECK OPTION` rejects a category change.
8. **Steps 08–09:** Confirm `WITH READ ONLY` rejects an update.
9. **Queries 01–02:** Inspect views and verify base-table data is unchanged.

### Expected outcomes

| Check | Expected |
|---|---|
| Practice base tables | 2 |
| Practice views | 4 |
| Categories | 2 rows |
| Books | 3 rows |
| Join view | 3 rows |
| Aggregate view | 2 rows |
| `WITH CHECK OPTION` negative test | `PASS ... ORA-01402` |
| `WITH READ ONLY` negative test | `PASS ... ORA-42399` |
| Book 1001 final price | `35.50` |

## 12. Run with SQL*Plus

From PowerShell, open the lesson directory and connect:

```powershell
cd E:\SQL\SQL-Engineering-Lab\course06_database_design_and_schema_objects\lesson04_views
sqlplus sql_lab@localhost:1521/FREEPDB1
```

At the `SQL>` prompt:

```sql
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
SPOOL logs/course06_lesson04_execution.log REPLACE
@course06_lesson04.sql
SPOOL OFF
```

**Log encoding:** On a Japanese Windows SQL*Plus installation, the log may be encoded as CP932. If the Japanese status messages look garbled in a UTF-8 editor, reopen the original file as Shift_JIS/CP932 before converting it. Do not overwrite the original log with incorrectly decoded text.

## 13. Cleanup and Rerun

The cleanup script removes **only** four `C06L04_V_` views and two `C06L04_` tables, in dependency-safe order. It checks that the session is `SQL_LAB` / `FREEPDB1`, skips missing objects, and verifies that no matching lesson objects remain.

```sql
SPOOL logs/course06_lesson04_cleanup.log REPLACE
@course06_lesson04_cleanup.sql
SPOOL OFF
```

After reviewing the cleanup output, run the main SQL script again if needed. **Do not run cleanup against objects you wish to retain.**

## 14. Review Exercises

1. Explain the difference between a table, a view, and a materialized view.
2. Why is a join view useful when multiple reports need the same columns?
3. Why is the category summary view not a straightforward candidate for `UPDATE`?
4. Explain why `WITH CHECK OPTION` rejected the category change.
5. Explain why `WITH READ ONLY` does not make the base table immutable.
6. Use `USER_TAB_COLUMNS` to list the columns of `C06L04_V_BOOK_DETAILS` after replacement.
7. Explain how changing the view definition might affect downstream applications.

## 15. Completion Criteria

The lesson is complete when all four views are created, both expected negative tests report `PASS`, row counts and the restored price match expectations, and you can explain the role and limitations of each view.

## 16. Next Lesson

**Lesson 05 — Sequences and Identity Columns:** generating identifiers safely in Oracle.

---

**Learn by executing. Verify what happens. Understand why it works.**
