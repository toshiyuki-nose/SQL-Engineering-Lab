# Course 06 — Lesson 02: Database Normalization

> **Reduce redundancy. Preserve dependencies. Design for consistent updates.**

## 1. Overview

Normalization is the process of organizing relational data to reduce unnecessary duplication and avoid anomalies when rows are inserted, updated, or deleted. This lesson uses a deliberately denormalized Book Store example, separate from the existing `BOOKS`, `AUTHORS`, `CATEGORIES`, and `BOOK_AUTHORS` tables.

**Learning environment:** Oracle Database 23ai Free / `FREEPDB1` / `SQL_LAB`.

## 2. Learning Objectives

By the end of this lesson, you should be able to:

- Explain insertion, update, and deletion anomalies.
- Identify functional dependencies and candidate keys.
- Distinguish first, second, and third normal forms (1NF–3NF).
- Decompose a denormalized relation into related tables.
- Verify a normalized design with Oracle SQL and constraints.

## 3. Why Normalize?

Imagine a table that repeats a book title and author name for every book-author association:

| BOOK_ID | TITLE | CATEGORY_ID | CATEGORY_NAME | AUTHOR_ID | AUTHOR_NAME |
|---:|---|---:|---|---:|---|
| 1001 | Database Basics | 10 | Technology | 201 | A. Writer |
| 1001 | Database Basics | 10 | Technology | 202 | B. Editor |
| 1002 | SQL Practice | 10 | Technology | 201 | A. Writer |

This table can suffer from:

- **Update anomaly:** changing a category name requires updating every associated row.
- **Insertion anomaly:** a new category cannot be recorded independently of a book association.
- **Deletion anomaly:** deleting the last book association for a category may remove the only record of that category.

These are *design* problems, not SQL syntax errors.

## 4. Functional Dependencies

A functional dependency `X → Y` means that whenever two rows agree on `X`, they must agree on `Y`.

For the example, assume these business rules:

- `BOOK_ID → TITLE, CATEGORY_ID`
- `CATEGORY_ID → CATEGORY_NAME`
- `AUTHOR_ID → AUTHOR_NAME`
- `(BOOK_ID, AUTHOR_ID)` identifies a unique book-author association.

The candidate key for the association relation is `(BOOK_ID, AUTHOR_ID)`. `TITLE` depends on only `BOOK_ID`, not the entire composite key. `CATEGORY_NAME` depends transitively on `BOOK_ID` through `CATEGORY_ID`.

**Important:** Functional dependencies are determined by business rules, not reliably inferred from a few sample rows.

## 5. First Normal Form (1NF)

A relation in **1NF** has attributes with single, indivisible values within the chosen data model, rather than repeating groups such as `AUTHOR_1`, `AUTHOR_2`, or comma-separated author IDs.

Instead of storing `AUTHOR_IDS = '201,202'` in one column, represent associations as separate rows. 1NF alone does **not** eliminate repeated titles or category names.

## 6. Second Normal Form (2NF)

A relation is in **2NF** when it is in 1NF and every non-prime attribute is fully functionally dependent on every candidate key; there are no partial dependencies on a proper subset of a candidate key.

In the example, `(BOOK_ID, AUTHOR_ID)` is the composite key. `TITLE` depends on `BOOK_ID` alone and `AUTHOR_NAME` on `AUTHOR_ID` alone. Move book and author attributes into their own tables, leaving the association table with the two keys.

A relation with only single-attribute candidate keys cannot have a partial dependency on a composite candidate key.

## 7. Third Normal Form (3NF)

A relation is in **3NF** when it is in 2NF and, for every nontrivial functional dependency `X → A`, either `X` is a superkey or `A` is a prime attribute (part of some candidate key).

For the book example, `BOOK_ID → CATEGORY_ID → CATEGORY_NAME` is a transitive dependency. Store category details in `CATEGORIES` and reference them from `BOOKS`.

A practical resulting design is:

```text
CATEGORIES (CATEGORY_ID PK, CATEGORY_NAME)
    1 ───────< N
BOOKS (BOOK_ID PK, TITLE, CATEGORY_ID FK)
    1 ───────< N
BOOK_AUTHORS (BOOK_ID PK/FK, AUTHOR_ID PK/FK)
    N >─────── 1
AUTHORS (AUTHOR_ID PK, AUTHOR_NAME)
```

This mirrors the core relationships explored in Lesson 01. Actual production design can require additional attributes and business constraints.

## 8. Hands-on: Dedicated Practice Objects

Use `course06_lesson02.sql` to create *separate practice tables* with the prefix `C06L02_`:

- `C06L02_FLAT`: deliberately redundant 1NF association data.
- `C06L02_CATEGORIES`: normalized category lookup.
- `C06L02_BOOKS`: normalized book details.
- `C06L02_AUTHORS`: normalized author details.
- `C06L02_BOOK_AUTHORS`: normalized many-to-many associations.

The script inserts three sample associations, checks their contents, and compares the flat and normalized representations. It does **not** modify the established Book Store tables.

**Execution policy:** Run the SQL once in `SQL_LAB` after reviewing the DDL. The script is not rerunnable without dropping or renaming the `C06L02_` objects. Do not run it against another schema unintentionally.

### Expected results

- `C06L02_FLAT` contains **3 rows**.
- `C06L02_CATEGORIES` contains **1 row**.
- `C06L02_BOOKS` contains **2 rows**.
- `C06L02_AUTHORS` contains **2 rows**.
- `C06L02_BOOK_AUTHORS` contains **3 rows**.
- A join across the normalized tables reconstructs the same three book-author associations.

## 9. Exercises

1. Explain which attributes in the flat table depend on only one part of its composite key.
2. Explain why `CATEGORY_NAME` belongs in the category table rather than the book table under the stated business rules.
3. Write a query to count authors per book using the normalized practice tables.
4. Describe an insertion anomaly and a deletion anomaly in the flat design.
5. Identify what would change if the business allowed a book to belong to multiple categories.

## 10. Engineering Notes

- Normalization follows business rules and functional dependencies; sample data alone is insufficient.
- Normalization and indexing solve different problems. Index design is covered in Lesson 06.
- Decomposition should preserve the ability to reconstruct intended facts through joins; avoid accidental data loss or spurious combinations.
- Constraints enforce selected integrity rules; normalization alone does not automatically enforce them.
- Denormalization may be appropriate for measured performance needs, but should be a deliberate trade-off.
- Oracle DDL issues implicit commits. Run this lesson only in the intended practice schema.

## 11. Review Checklist

- [ ] I can describe all three anomaly types.
- [ ] I can identify the composite candidate key and the functional dependencies.
- [ ] I can explain 1NF, 2NF, and 3NF using the Book Store example.
- [ ] I executed the SQL and verified the expected row counts.
- [ ] I compared the reconstructed normalized result with the flat sample.
- [ ] I recorded the execution log under `logs/`.

## 12. Next Lesson

**Lesson 03 — Constraints and Data Integrity:** enforce business rules with primary keys, foreign keys, unique constraints, check constraints, and nullability.
