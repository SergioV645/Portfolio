-- =====================================================================
-- Optimización básica de consultas — Oracle 19c
-- 00_setup.sql : crea las tablas de la clase y las llena
--
-- Ejecutar completo, una sola vez, antes de la sesión.  ~20 segundos.
-- Requiere: CREATE TABLE, CREATE INDEX y cuota en el tablespace.
-- =====================================================================

SET TIMING ON
SET LINESIZE 200
SET PAGESIZE 100

-- Limpieza previa (no falla si aún no existen)
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
             WHERE table_name IN ('VENTA', 'CLIENTE', 'PRODUCTO')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------
CREATE TABLE producto (
  id_producto  NUMBER        NOT NULL,
  nombre       VARCHAR2(60)  NOT NULL,
  categoria    VARCHAR2(20)  NOT NULL,
  CONSTRAINT pk_producto PRIMARY KEY (id_producto)
);

CREATE TABLE cliente (
  id_cliente  NUMBER        NOT NULL,
  documento   VARCHAR2(15)  NOT NULL,   -- texto, aunque parezca número
  nombre      VARCHAR2(60)  NOT NULL,   -- viene en mayúsculas y minúsculas
  ciudad      VARCHAR2(30)  NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

CREATE TABLE venta (
  id_venta     NUMBER        NOT NULL,
  fecha_venta  DATE          NOT NULL,  -- lleva hora
  id_cliente   NUMBER        NOT NULL,
  id_producto  NUMBER        NOT NULL,
  canal        VARCHAR2(10)  NOT NULL,  -- solo 2 valores distintos
  valor        NUMBER(12,2)  NOT NULL,
  CONSTRAINT pk_venta PRIMARY KEY (id_venta)
);

-- ---------------------------------------------------------------------
-- Datos
-- ---------------------------------------------------------------------
INSERT /*+ APPEND */ INTO producto (id_producto, nombre, categoria)
SELECT level,
       'Producto ' || TO_CHAR(level, 'FM000'),
       CASE MOD(level, 4) WHEN 0 THEN 'HOGAR' WHEN 1 THEN 'TECNOLOGIA'
                          WHEN 2 THEN 'ROPA'  ELSE 'DEPORTE' END
  FROM dual CONNECT BY level <= 500;
COMMIT;

-- Uno de cada 50 clientes se apellida García: la mitad 'GARCIA', la otra 'Garcia'.
INSERT /*+ APPEND */ INTO cliente (id_cliente, documento, nombre, ciudad)
SELECT level,
       TO_CHAR(1000000 + level),
       CASE MOD(level, 50) WHEN 0 THEN 'GARCIA'
                           WHEN 1 THEN 'Garcia'
                           ELSE 'Apellido' || TO_CHAR(MOD(level, 2000), 'FM0000') END,
       CASE MOD(level, 4) WHEN 0 THEN 'BOGOTA' WHEN 1 THEN 'MEDELLIN'
                          WHEN 2 THEN 'CALI'   ELSE 'BARRANQUILLA' END
  FROM dual CONNECT BY level <= 20000;
COMMIT;

-- 300.000 ventas: suficiente para que se note la diferencia en el plan.
INSERT /*+ APPEND */ INTO venta (id_venta, fecha_venta, id_cliente, id_producto, canal, valor)
SELECT level,
       DATE '2024-01-01' + MOD(level, 500) + (MOD(level, 86400) / 86400),
       MOD(level, 20000) + 1,
       MOD(level, 500) + 1,
       CASE MOD(level, 2) WHEN 0 THEN 'WEB' ELSE 'TIENDA' END,
       ROUND(DBMS_RANDOM.VALUE(20000, 2000000), -2)
  FROM dual CONNECT BY level <= 300000;
COMMIT;

-- Llaves foráneas. Ojo: en Oracle una llave foránea NO crea índice.
ALTER TABLE venta ADD CONSTRAINT fk_venta_cliente
  FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente);
ALTER TABLE venta ADD CONSTRAINT fk_venta_producto
  FOREIGN KEY (id_producto) REFERENCES producto (id_producto);

-- Estadísticas al día para empezar.
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'PRODUCTO', cascade => TRUE);
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'CLIENTE',  cascade => TRUE);
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'VENTA',    cascade => TRUE);
END;
/

-- ---------------------------------------------------------------------
-- Verificación
-- ---------------------------------------------------------------------
SELECT 'PRODUCTO' AS tabla, COUNT(*) AS filas FROM producto
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM cliente
UNION ALL SELECT 'VENTA',   COUNT(*) FROM venta;

-- Por ahora los únicos índices son los de las llaves primarias.
SELECT table_name, index_name FROM user_indexes
 WHERE table_name IN ('VENTA','CLIENTE','PRODUCTO') ORDER BY 1, 2;

PROMPT
PROMPT ==================================================
PROMPT  Listo. Continúe con 01_demos.sql
PROMPT ==================================================

SELECT table_name 
FROM user_tables
ORDER BY table_name;

DROP TABLE RESERVA CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE INCIDENCIA CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE AERONAVE CASCADE CONSTRAINTS;
