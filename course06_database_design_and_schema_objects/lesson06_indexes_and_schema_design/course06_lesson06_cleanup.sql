-- Course 06 - Lesson 06: Cleanup
-- WARNING: permanently removes C06L06_ practice tables and their data.
-- The three explicitly created indexes are dropped with C06L06_BOOKS.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
COLUMN CONNECTED_USER FORMAT A20
COLUMN CONTAINER_NAME FORMAT A20
COLUMN TABLE_NAME FORMAT A25
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT === Verify cleanup session ===
SELECT USER AS connected_user, SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name FROM dual;

DECLARE
  PROCEDURE drop_practice_table(p_name IN VARCHAR2) IS
    l_exists NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_exists FROM user_tables WHERE table_name = p_name;
    IF l_exists = 0 THEN
      DBMS_OUTPUT.PUT_LINE('SKIP ' || p_name || ': table does not exist');
    ELSE
      EXECUTE IMMEDIATE 'DROP TABLE ' || p_name || ' PURGE';
      DBMS_OUTPUT.PUT_LINE('DROP ' || p_name || ': completed');
    END IF;
  END;
BEGIN
  IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20006, 'Cleanup aborted: expected SQL_LAB in FREEPDB1');
  END IF;
  drop_practice_table('C06L06_BOOKS');
  drop_practice_table('C06L06_CATEGORIES');
END;
/

PROMPT === Verify no Lesson 06 practice objects remain ===
SELECT table_name FROM user_tables
WHERE table_name IN ('C06L06_BOOKS', 'C06L06_CATEGORIES')
ORDER BY table_name;
SELECT index_name FROM user_indexes
WHERE index_name LIKE 'IDX_C06L06_%'
ORDER BY index_name;
PROMPT === Cleanup complete: expected no rows in both queries ===
