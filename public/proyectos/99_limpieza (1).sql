-- =====================================================================
-- Bloque B — Optimización básica de consultas
-- 99_limpieza.sql — deja el esquema como estaba
-- =====================================================================

SET SERVEROUTPUT ON

BEGIN
  FOR t IN (SELECT table_name
              FROM user_tables
             WHERE table_name IN ('VENTA', 'CLIENTE', 'PRODUCTO')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE('Eliminada: ' || t.table_name);
  END LOOP;
END;
/

PURGE RECYCLEBIN;

SELECT table_name FROM user_tables ORDER BY table_name;
