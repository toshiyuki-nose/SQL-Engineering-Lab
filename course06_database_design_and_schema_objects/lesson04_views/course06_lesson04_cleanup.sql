-- Course 06 / Lesson 04: cleanup (DESTRUCTIVE)
-- Drops ONLY C06L04_ lesson views and tables, including all practice rows.
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
PROMPT === Verify session ===
SELECT USER AS connected_user, SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name FROM dual;
DECLARE
  PROCEDURE drop_if_exists(p_type VARCHAR2, p_name VARCHAR2) IS
    l_count NUMBER;
  BEGIN
    IF p_type = 'VIEW' THEN
      SELECT COUNT(*) INTO l_count FROM user_views WHERE view_name = p_name;
    ELSE
      SELECT COUNT(*) INTO l_count FROM user_tables WHERE table_name = p_name;
    END IF;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('SKIP ' || p_name || ': not found');
    ELSE
      EXECUTE IMMEDIATE 'DROP ' || p_type || ' ' || p_name || CASE WHEN p_type = 'TABLE' THEN ' PURGE' ELSE '' END;
      DBMS_OUTPUT.PUT_LINE('DROP ' || p_name || ': completed');
    END IF;
  END;
BEGIN
  IF USER <> 'SQL_LAB' OR SYS_CONTEXT('USERENV', 'CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Cleanup aborted: expected SQL_LAB in FREEPDB1');
  END IF;
  drop_if_exists('VIEW', 'C06L04_V_READ_ONLY_BOOKS');
  drop_if_exists('VIEW', 'C06L04_V_TECHNOLOGY_BOOKS');
  drop_if_exists('VIEW', 'C06L04_V_CATEGORY_SUMMARY');
  drop_if_exists('VIEW', 'C06L04_V_BOOK_DETAILS');
  drop_if_exists('TABLE', 'C06L04_BOOKS');
  drop_if_exists('TABLE', 'C06L04_CATEGORIES');
END;
/
PROMPT === Verify no lesson objects remain (expected: no rows) ===
SELECT object_name, object_type FROM user_objects
WHERE object_name LIKE 'C06L04\_%' ESCAPE '\'
ORDER BY object_type, object_name;
PROMPT === Cleanup complete ===
