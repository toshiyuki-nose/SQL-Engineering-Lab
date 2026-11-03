# Course 06 — Lesson 01: Relational Database Design

> **Understand the data model before changing the database.**

## 1. Learning Objectives

By the end of this lesson, you should be able to:

- Distinguish entities, attributes, and relationships.
- Explain the purpose of primary keys, foreign keys, and candidate keys.
- Interpret one-to-many and many-to-many relationships.
- Describe how an associative table resolves a many-to-many relationship.
- Inspect the actual Oracle schema using data dictionary views.
- Sketch an ER model based on verified database metadata.

## 2. Prerequisites and Environment

- Courses 01–05 completed.
- Oracle Database 23ai Free, PDB `FREEPDB1`.
- Connect as `SQL_LAB` (or a user with appropriate access to its objects).
- Existing Book Store tables: `CATEGORIES`, `BOOKS`, `AUTHORS`, `BOOK_AUTHORS`.

**Safety:** This lesson contains read-only queries. Do not drop, alter, or repopulate the existing tables.

## 3. What Is Relational Database Design?

Relational database design translates business concepts into tables, columns, keys, and integrity rules. Good design makes data understandable, minimizes unnecessary duplication, and makes relationships explicit.

A useful starting sequence is:

1. Identify the business concepts that must be represented.
2. List their attributes.
3. Choose stable identifiers.
4. Define relationships and cardinalities.
5. Decide which integrity rules the database should enforce.
6. Verify the design against realistic questions and sample data.

Normalization is covered in Lesson 02. This lesson focuses on recognizing and describing the model.

## 4. Entities and Attributes

An **entity** represents a concept worth storing, such as a book or an author. An **attribute** describes that concept, such as a title or a name. A relational table commonly represents an entity type; a row represents an instance.

For the Book Store domain, the intended concepts are:

| Entity | Meaning |
|---|---|
| `CATEGORIES` | Classification of books |
| `BOOKS` | Books managed by the store |
| `AUTHORS` | Authors associated with books |
| `BOOK_AUTHORS` | Associations between books and authors |

Do not assume a particular column name or data type from this conceptual description. Run **Query 02** in the companion SQL script to inspect the actual columns.

## 5. Keys and Referential Integrity

A **candidate key** is a minimal set of attributes that uniquely identifies a row. A **primary key (PK)** is the candidate key selected as the principal identifier. A **foreign key (FK)** references a primary key or another eligible unique key in a parent table.

A primary key prevents duplicate identifiers and disallows null key values. A foreign key prevents non-null references to parent key values that do not exist, subject to the constraint's enabled/validated state. Foreign-key columns are not automatically `NOT NULL`.

A database may use a single-column key or a composite key. The actual PK/FK definitions must be verified rather than inferred from table names.

Run **Queries 03–05** to inspect key constraints and their columns.

## 6. Relationships and Cardinality

**Cardinality** describes how many instances of one entity may be related to another:

- **One-to-one (1:1):** each instance is associated with at most one instance on the other side.
- **One-to-many (1:N):** one parent may be associated with many child rows.
- **Many-to-many (M:N):** each side may be associated with many instances of the other.

In the Book Store domain, the intended relationships are:

- One category can classify many books; each book is intended to have a category.
- One book can have multiple authors; one author can contribute to multiple books.
- `BOOK_AUTHORS` acts as an **associative table**, representing the book–author associations as two relationships to the parent tables.

These are **conceptual expectations**, not proof of the deployed schema's exact constraints or optionality. For example, whether a book must have a category depends on the relevant column's nullability and constraints. Check the metadata before labeling a relationship mandatory.

### Conceptual ER sketch

```text
CATEGORIES (1) ──── (N) BOOKS
                          |
                          | (1)
                          |
                          | (N)
                     BOOK_AUTHORS
                          | (N)
                          |
                          | (1)
                       AUTHORS
```

The sketch expresses the intended model. **Query 05** identifies the actual FK links in Oracle. An ER diagram should ultimately reflect those verified definitions.

## 7. Inspecting the Oracle Data Dictionary

Oracle exposes schema metadata through data dictionary views. In this lesson, use:

| View | What it tells you |
|---|---|
| `USER_TABLES` | Tables owned by the connected user |
| `USER_TAB_COLUMNS` | Column names, types, and nullability |
| `USER_CONSTRAINTS` | Constraint types, status, and referenced keys |
| `USER_CONS_COLUMNS` | Columns participating in constraints |

Constraint type codes used here:

- `P` — primary key
- `R` — referential (foreign key)
- `U` — unique constraint
- `C` — check constraint (which may include NOT NULL enforcement)

The companion script `course06_lesson01.sql` provides ordered, read-only inspection queries. When connected as `SQL_LAB`, the `USER_*` views describe that user's schema. If connected as another user, use appropriately filtered `ALL_*` views instead.

## 8. Hands-on Exercises

Execute the companion SQL file one query at a time, recording your observations.

### Exercise 01 — Inventory the tables

Run **Query 01**. Confirm that the four Book Store tables are present. If any are missing, stop and verify your connection and schema before continuing.

### Exercise 02 — Identify the attributes

Run **Query 02**. For each table, record its column names, data types, and whether nulls are allowed. Identify likely business attributes and identifier columns.

### Exercise 03 — Verify the keys

Run **Queries 03 and 04**. Record each table's primary key and any unique keys. Which keys use more than one column? Do not assume that `BOOK_AUTHORS` has a composite PK: check the result.

### Exercise 04 — Trace the relationships

Run **Query 05**. For each FK, write down the child table and column(s), the referenced parent table and column(s), and the constraint status. Compare these findings with the conceptual ER sketch.

### Exercise 05 — Explore actual associations

Run **Query 06** to count rows in each table. Run **Query 07** to count associations per book. Observe whether the sample data contains books with multiple authors. The absence of such a row in sample data does not disprove the M:N model.

### Exercise 06 — Draw an ER diagram

Using the verified PKs, FKs, and nullability, draw an ER diagram of the four tables. Include:

- Table names and key columns.
- Parent–child links.
- One-to-many cardinality where supported by the FKs.
- Optionality only where supported by the actual schema rules.

**Deliverable:** a short design note or ER diagram describing the deployed Book Store schema. No DDL is required.

## 9. Verification Checklist

- [ ] Connected to `FREEPDB1` as `SQL_LAB`.
- [ ] Located the four Book Store tables.
- [ ] Inspected their columns and nullability.
- [ ] Identified actual PK and unique constraints.
- [ ] Identified actual FK relationships and referenced columns.
- [ ] Distinguished conceptual expectations from verified schema rules.
- [ ] Created an ER sketch based on observed metadata.

## 10. Engineering Notes

- **Model before coding.** A query can be syntactically correct while reflecting a misunderstanding of the relationships.
- **Do not infer constraints from names.** A column ending in `_ID` is not necessarily an enforced FK.
- **Separate cardinality from optionality.** A relationship can be 1:N while its FK is nullable.
- **Inspect composite keys carefully.** Column order matters for documenting multi-column constraints.
- **Distinguish metadata from sample data.** A sample of 15 books cannot prove every business rule.
- **Avoid unnecessary schema changes.** Inspect first; make design changes in later lessons using reviewed practice objects.

## 11. Review Questions

1. What is the difference between an entity and an attribute?
2. Why is a primary key important?
3. What does a foreign key enforce, and what does it *not* guarantee about null values?
4. Why might a many-to-many relationship need an associative table?
5. How would you verify that a supposed FK is actually defined in Oracle?
6. What additional information is needed to determine whether a relationship is mandatory?

## 12. Next Lesson

**Lesson 02 — Database Normalization** examines functional dependencies and the first three normal forms, building on the model identified here.

---

**Learn by executing. Verify what happens. Understand why it works.**
