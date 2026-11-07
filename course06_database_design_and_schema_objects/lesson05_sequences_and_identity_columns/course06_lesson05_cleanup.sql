-- Course 06 / Lesson 05: Cleanup dedicated practice objects
-- WARNING: DROP TABLE/SEQUENCE permanently removes lesson data and definitions.
-- Run only as SQL_LAB in FREEPDB1. Missing objects are skipped.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100
SET TRIMSPOOL ON
COLUMN CONNECTED_USER FORMAT A20
COLUMN CONTAINER_NAME FORMAT A20
WHENEVER SQLERROR EXIT SQL.SQLCODE
PROMPT === Verify session ===
SELECT USER AS connected_user, SYS_CONTEXT('USERENV','CON_NAME') AS container_name FROM dual;
DECLARE
  PROCEDURE drop_if_exists(p_type VARCHAR2, p_name VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    IF p_type = 'TABLE' THEN
      SELECT COUNT(*) INTO l_count FROM user_tables WHERE table_name = p_name;
    ELSE
      SELECT COUNT(*) INTO l_count FROM user_sequences WHERE sequence_name = p_name;
    END IF;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('SKIP ' || p_name || ': not found');
    ELSE
      EXECUTE IMMEDIATE 'DROP ' || p_type || ' ' || p_name || CASE WHEN p_type = 'TABLE' THEN ' PURGE' ELSE '' END;
      DBMS_OUTPUT.PUT_LINE('DROP ' || p_name || ': completed');
    END IF;
  END;
BEGIN
  IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV','CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20005, 'Cleanup aborted: expected SQL_LAB in FREEPDB1');
  END IF;
  drop_if_exists('TABLE', 'C06L05_IDENTITY_ON_NULL');
  drop_if_exists('TABLE', 'C06L05_IDENTITY_DEFAULT');
  drop_if_exists('TABLE', 'C06L05_IDENTITY_ALWAYS');
  drop_if_exists('TABLE', 'C06L05_SEQUENCE_BOOKS');
  drop_if_exists('SEQUENCE', 'C06L05_BOOK_SEQ');
END;
/
PROMPT === Verify no Lesson 05 practice tables remain ===
SELECT table_name FROM user_tables WHERE table_name IN
('C06L05_IDENTITY_ON_NULL','C06L05_IDENTITY_DEFAULT','C06L05_IDENTITY_ALWAYS','C06L05_SEQUENCE_BOOKS');
PROMPT === Verify standalone sequence removed ===
SELECT sequence_name FROM user_sequences WHERE sequence_name = 'C06L05_BOOK_SEQ';
PROMPT === Cleanup complete (expected: no rows selected in both queries) ===
