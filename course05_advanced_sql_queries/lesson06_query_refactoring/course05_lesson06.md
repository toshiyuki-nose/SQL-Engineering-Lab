# Course 05 — Lesson 06: Query Refactoring

## Learning objectives

By the end of this lesson, you will be able to:

1. Explain why readable SQL is easier to maintain and review.
2. Replace repeated expressions with clearly named Common Table Expressions (CTEs).
3. Separate filtering, aggregation, ranking, and presentation into logical stages.
4. Avoid accidental row multiplication when joining detail and summary data.
5. Validate that a refactored query produces the same results as its original form.

## Prerequisites

- Oracle Database Free with the `SQL_LAB` schema in `FREEPDB1`.
- The existing `BOOKS` and `CATEGORIES` tables from the Book Store Database.
- Familiarity with `JOIN`, `CASE`, `GROUP BY`, CTEs, and window functions.

All examples are **read-only**. Execute `lesson06.sql` from the repository root in SQL*Plus. The script creates a spool log at `course05_advanced_sql_queries/lesson06_query_refactoring/logs/lesson06.log`.

## Refactoring principles

- **Name each stage for its responsibility.** For example, `category_metrics` calculates totals, while `ranked_books` assigns ranks.
- **Keep filters intentional.** Filtering before or after a window calculation can change its meaning.
- **Choose the correct grain.** Book-level rows and category-level rows have different granularities; aggregate before joining when appropriate.
- **Use deterministic tie-breakers.** Add `book_id` to a `ROW_NUMBER` ordering so equal prices have a stable result.
- **Test equivalence.** Compare both directions using `MINUS`, and compare row counts when duplicates could matter.

## Guided exercises

| Step | Exercise | Key idea |
|---|---|---|
| 1 | Verify the schema | Safe prerequisites |
| 2 | Original category summary | Baseline query |
| 3 | Refactored category summary | Named CTE stages |
| 4 | Compare original and refactored summaries | `MINUS` in both directions |
| 5 | Original book-level report | Correlated subquery and `CASE` |
| 6 | Refactored book-level report | Window functions and CTEs |
| 7 | Compare report results | Row counts and two-way `MINUS` |
| 8 | Refactor category top-book selection | Ranking with `ROW_NUMBER` |
| 9 | Verify top-book output | One book per nonempty category |
| 10 | Automated validation | Raise an error if equivalence fails |

## Notes

`MINUS` removes duplicates, so it is not by itself sufficient to prove bag/multiset equivalence. The lesson also compares row counts and grouped row multiplicities in its final validation.

The `BOOKS` table permits nullable values in some columns. Comparisons use set operators or null-safe logic where appropriate.

## Review checklist

- [ ] The script reaches `Lesson 06 completed`.
- [ ] No `ORA-` or `SP2-` errors occur.
- [ ] Both `MINUS` directions report zero differences.
- [ ] Original and refactored book reports return the same number of rows.
- [ ] The final PL/SQL block prints `Validation passed`.
- [ ] No persistent data is modified.

## Next milestone

After reviewing the SQL*Plus log, Course 05 — Advanced SQL Queries will be complete. Then review the course README and the overall learning roadmap before starting the next course.
