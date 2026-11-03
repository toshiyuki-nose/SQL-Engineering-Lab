-- Course 06 / Lesson 03: Cleanup practice tables
-- Scope: C06L03_REVIEWS, C06L03_BOOKS, C06L03_CATEGORIES only.
-- WARNING: DROP TABLE permanently removes the practice data and table definitions.
-- Run as SQL_LAB in FREEPDB1 after reviewing the target names.
-- This script is repeatable: missing tables are skipped.

SET SERVEROUTPUT ON
SET FEEDBACK ON
SET ECHO ON
SET LINESIZE 180

WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === Verify session and cleanup target ===
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

PROMPT === Drop Lesson 03 practice tables (children first) ===
DECLARE
    PROCEDURE drop_practice_table(p_table_name IN VARCHAR2) IS
        l_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO l_exists
        FROM user_tables
        WHERE table_name = p_table_name;

        IF l_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('SKIP ' || p_table_name || ': table does not exist');
        ELSE
            EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name || ' PURGE';
            DBMS_OUTPUT.PUT_LINE('DROP ' || p_table_name || ': completed');
        END IF;
    END;
BEGIN
    IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1' THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Cleanup aborted: expected SQL_LAB in FREEPDB1.');
    END IF;

    drop_practice_table('C06L03_REVIEWS');
    drop_practice_table('C06L03_BOOKS');
    drop_practice_table('C06L03_CATEGORIES');
END;
/

PROMPT === Verify no Lesson 03 practice tables remain ===
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'C06L03_REVIEWS',
    'C06L03_BOOKS',
    'C06L03_CATEGORIES'
)
ORDER BY table_name;

PROMPT === Cleanup complete (expected: no rows selected) ===
-- End of script. SQL*Plus remains open on success.
