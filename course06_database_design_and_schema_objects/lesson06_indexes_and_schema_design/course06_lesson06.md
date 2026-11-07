# Course 06 — Lesson 06: Indexes and Schema Design

> **Index for a workload, not for every column.**

## 1. Overview

Indexes help Oracle find candidate rows without necessarily scanning an entire table. However, they consume storage and introduce maintenance work for INSERT, UPDATE, and DELETE. This lesson closes Course 06 by practicing index creation, inspecting index metadata, and documenting design decisions for a small Book Store schema.

**Scope:** Only `C06L06_` practice objects are created. Existing `BOOKS`, `AUTHORS`, `BOOK_AUTHORS`, and `CATEGORIES` are not modified. The lesson uses small datasets, so it **does not claim** that Oracle will choose an index access path or that a query will run faster.

## 2. Learning Objectives

- Explain why indexes can improve selective lookups and why they have a write/storage cost.
- Create ordinary B-tree indexes and composite indexes.
- Distinguish a unique constraint from a unique index.
- Explain the importance of leading columns in a composite index.
- Inspect indexes using `USER_INDEXES` and `USER_IND_COLUMNS`.
- Explain why primary-key and unique constraints can already be backed by indexes.
- Recommend indexes based on realistic predicates, joins, and sorting requirements.

## 3. Prerequisites and Environment

- Course 06 Lessons 01–05 completed.
- Oracle Database 23ai Free; PDB `FREEPDB1`; schema `SQL_LAB`.
- SQL*Plus connection and permission to create tables and indexes.

`course06_lesson06.sql` is a **first-run script**. If objects already exist, review and run `course06_lesson06_cleanup.sql` before rerunning. Cleanup irreversibly drops only the named lesson objects and their data.

## 4. Index Fundamentals

An index stores searchable key values with references to rows. A conventional Oracle B-tree index is a general-purpose choice for equality and range predicates. Oracle's optimizer decides whether to use an index or another access path based on costs, statistics, and the query.

Indexes are not free: each extra index consumes space and must be maintained when indexed data changes. Avoid indexing every column indiscriminately.

### 4.1 Primary keys and unique indexes

`PRIMARY KEY` and `UNIQUE` are **integrity constraints**, while indexes are **access structures**. Oracle normally uses an index to enforce these constraints; the backing index can be unique or nonunique depending on circumstances. Creating an additional index on the same key is often redundant.

### 4.2 Composite indexes

An index on `(category_id, price)` can support predicates on the leading `category_id` and may be useful for queries that filter by category and then price. A predicate on `price` alone does not generally benefit from the same leading-column access pattern. This is a design principle, **not a promise about optimizer behavior**; Oracle has other access strategies.

### 4.3 Selectivity and query patterns

A useful design begins with actual workload: WHERE predicates, join keys, ORDER BY, frequency, row counts, and write volume. For tiny practice tables, full scans are often entirely reasonable.

## 5. Practice Schema

```text
C06L06_CATEGORIES
  CATEGORY_ID (PK)
  CATEGORY_NAME (NOT NULL, UNIQUE)
       |
       | 1-to-many
       v
C06L06_BOOKS
  BOOK_ID (PK)
  TITLE (NOT NULL)
  CATEGORY_ID (FK)
  PRICE (CHECK >= 0)
  STOCK (CHECK >= 0)
  PUBLISHED_YEAR
```

### Index design choices

| Index | Columns | Rationale |
|---|---|---|
| `IDX_C06L06_BOOK_TITLE` | `TITLE` | Lookups by exact title |
| `IDX_C06L06_BOOK_CAT_PRICE` | `CATEGORY_ID, PRICE` | Category filters and price ranges within a category |
| `IDX_C06L06_BOOK_YEAR` | `PUBLISHED_YEAR` | Year-based reporting filters (illustrative; workload-dependent) |

The primary-key and unique constraints also have supporting index structures. We do **not** create another index on `BOOK_ID` or `CATEGORY_NAME`.

## 6. Hands-on Workflow

Run `course06_lesson06.sql` after checking the connection and reviewing its DDL.

1. **Query 00:** Confirm the current user and PDB.
2. **Step 01:** Create two practice tables with integrity constraints.
3. **Step 02:** Insert six books and three categories; commit.
4. **Query 01:** Inspect the indexes created for key constraints.
5. **Step 03:** Create a title index, a composite category/price index, and a publication-year index.
6. **Query 02:** Inspect `USER_INDEXES` and ordered index columns in `USER_IND_COLUMNS`.
7. **Query 03:** Run a category/price range query and a title lookup.
8. **Query 04:** Verify base-table row counts and explain the index choices.

### Expected row counts

| Table | Rows |
|---|---:|
| `C06L06_CATEGORIES` | 3 |
| `C06L06_BOOKS` | 6 |

### Expected indexes

Three explicitly named `IDX_C06L06_` indexes plus the indexes Oracle uses to support the PK/UNIQUE constraints. The metadata query for explicitly named indexes should return **three indexes**, with **four index-column rows** (1 + 2 + 1).

## 7. Inspecting Metadata

- `USER_INDEXES`: index name, uniqueness, type, status, and related attributes.
- `USER_IND_COLUMNS`: indexed column names and their order (`COLUMN_POSITION`).
- `USER_CONSTRAINTS`: constraints and their supporting `INDEX_NAME` where applicable.

A `VALID` index status means the index is usable; it does **not** establish that a particular query used it.

## 8. Design Exercises

1. Why is another index on `BOOK_ID` likely redundant?
2. Which query shape motivates `(CATEGORY_ID, PRICE)`?
3. Why might an index on `PRICE` alone require a different design?
4. When could `PUBLISHED_YEAR` be a poor index choice?
5. What extra costs arise from indexing a frequently updated column?
6. What information would you collect before proposing indexes for a production Book Store database?

## 9. Engineering Notes

- Indexes do not replace foreign keys or other integrity constraints.
- A foreign-key column is not automatically indexed just because it references a primary key; assess its query and DML workload.
- Use `EXPLAIN PLAN` or runtime execution-plan tools when performance analysis is in scope, and interpret plans in the context of table size and statistics. This lesson focuses on schema-object design, not performance benchmarking.
- Do not infer that an index improved performance solely because `CREATE INDEX` succeeded.
- DDL commits implicitly in Oracle. Run experiments in the dedicated lesson namespace.

## 10. Execution and Cleanup

From the `lesson06_indexes_and_schema_design` directory in SQL*Plus:

```sql
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
SPOOL logs/course06_lesson06_execution.log REPLACE
@course06_lesson06.sql
SPOOL OFF
```

For cleanup **only when needed**:

```sql
SPOOL logs/course06_lesson06_cleanup.log REPLACE
@course06_lesson06_cleanup.sql
SPOOL OFF
```

## 11. Completion Criteria

- Both practice tables and all six books exist.
- Three explicit indexes are created successfully.
- Index metadata shows the intended column order.
- Sample SELECT statements return the expected rows.
- You can justify index choices and explain write/storage trade-offs.

## 12. Course 06 Wrap-up

Course 06 covered relational design, normalization, constraints, views, sequences/identity columns, and indexes. The central engineering lesson is to design for **correctness, maintainability, and a known workload**, and to verify database behavior rather than assume it.

---

**Learn by executing. Verify what happens. Understand why it works.**
