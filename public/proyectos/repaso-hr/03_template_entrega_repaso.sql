-- =====================================================================
-- Universidad El Bosque - Bases de Datos 2
-- Taller de repaso: SQL avanzado aplicado sobre el esquema HR
-- Archivo: 03_template_entrega_repaso.sql
--
-- INSTRUCCIONES
--   1. Renombren este archivo como R_SQLAV_Apellido1_Apellido2.sql
--   2. Completen el encabezado con los nombres de los dos integrantes.
--   3. Escriban cada consulta en el bloque que le corresponde. NO cambien
--      el orden de los bloques: el orden es criterio de calificacion.
--   4. Cada consulta debe llevar su comentario de justificacion en el
--      espacio marcado. Una consulta correcta sin justificacion se
--      califica en nivel basico.
--   5. Generen el spool y conviertanlo a PDF como
--      R_Evidencias_Apellido1_Apellido2.pdf
--
-- RECORDATORIO: el taller es de SOLO LECTURA. No ejecuten INSERT,
-- UPDATE, DELETE ni DDL sobre el esquema HR.
-- =====================================================================

-- =====================================================================
-- ENCABEZADO
-- =====================================================================
-- Integrante 1 (nombre completo):
-- Integrante 2 (nombre completo):
-- Fecha:
-- =====================================================================

SET LINESIZE 200
SET PAGESIZE 200
SET TRIMSPOOL ON
SET SQLBLANKLINES ON

-- Si trabajan desde un usuario distinto de HR, descomenten la linea:
-- ALTER SESSION SET CURRENT_SCHEMA = HR;

-- SPOOL R_Evidencias_Apellido1_Apellido2.txt


-- =====================================================================
-- BLOQUE A - VERIFICACION DE CASOS BORDE DEL ESQUEMA   (enunciado 6.1)
-- Columnas obligatorias: caso_borde, empleados_afectados, descripcion
-- Debe devolver exactamente cuatro filas.
-- =====================================================================
PROMPT
PROMPT ===== A. CASOS BORDE DEL ESQUEMA =====

-- Consulta:


-- Justificacion (por que cada uno de estos cuatro casos rompe consultas
-- escritas de forma ingenua):


-- =====================================================================
-- BLOQUE B - REUNIONES INTERNAS Y EXTERNAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- B.1 Inventario completo de departamentos                (enunciado 6.2)
-- Columnas obligatorias: department_id, department_name, city,
--   country_name, employee_count, avg_salary
-- Regla: employee_count = 0 en los departamentos vacios.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== B.1 INVENTARIO DE DEPARTAMENTOS =====

-- Consulta:


-- Justificacion (por que COUNT(*) da el valor incorrecto aqui):


-- ---------------------------------------------------------------------
-- B.2 Cadena de mando                                     (enunciado 6.3)
-- Columnas obligatorias: employee_id, employee_name, job_title,
--   manager_id, manager_name, department_name
-- Regla: el empleado 100 debe aparecer con manager_name nulo.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== B.2 CADENA DE MANDO =====

-- Consulta:


-- Justificacion (tipo de reunion usada y que pasa con INNER JOIN):


-- ---------------------------------------------------------------------
-- B.3 Contraste entre la condicion en ON y en WHERE       (enunciado 6.4)
-- Columnas obligatorias: variante, filas_devueltas, explicacion
-- Ejecuten las dos variantes y registren el conteo de cada una.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== B.3 VARIANTE CON LA CONDICION EN ON =====

-- Consulta variante ON:


PROMPT
PROMPT ===== B.3 VARIANTE CON LA CONDICION EN WHERE =====

-- Consulta variante WHERE:


-- Regla general derivada de la diferencia (una sola frase):


-- =====================================================================
-- BLOQUE C - TRATAMIENTO DE VALORES NULOS
-- =====================================================================

-- ---------------------------------------------------------------------
-- C.1 Diagnostico de nulos y compensacion total           (enunciado 6.5)
-- Columnas obligatorias: employee_id, last_name, department_id, salary,
--   commission_pct, total_compensation, es_jefe
-- Reglas: total_compensation nunca nulo; es_jefe con SI / NO resuelto
--   mediante NOT EXISTS.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== C.1 DIAGNOSTICO DE NULOS =====

-- Consulta:


PROMPT
PROMPT ===== C.2 EVIDENCIA DEL COMPORTAMIENTO DE NOT IN =====

-- Consulta con NOT IN que devuelve el conjunto vacio (dejenla visible):


-- Justificacion (por que NOT IN devuelve vacio y por que NOT EXISTS no):


-- =====================================================================
-- BLOQUE D - AGREGACION Y FILTRADO DE GRUPOS
-- =====================================================================

-- ---------------------------------------------------------------------
-- D.1 Agregacion con filtrado de grupos                   (enunciado 6.6)
-- Columnas obligatorias: department_id, department_name, employee_count,
--   avg_salary, min_salary, max_salary, salary_mass, empleados_recientes
-- Reglas: mas de 5 empleados y promedio > 6000; empleados_recientes
--   cuenta solo los contratados despues del 01-ENE-2005 mediante
--   agregacion condicional, sin afectar a employee_count.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== D.1 AGREGACION CON FILTRADO DE GRUPOS =====

-- Consulta:


-- Justificacion (por que el criterio de mas de 5 empleados no puede ir
-- en WHERE):


-- =====================================================================
-- BLOQUE E - SUBCONSULTAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- E.1 Comparacion contra el promedio del departamento     (enunciado 6.7)
-- Columnas obligatorias: employee_id, last_name, department_id, salary,
--   dept_avg_salary, diff_vs_avg, pct_vs_avg
-- Entregar DOS versiones equivalentes.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== E.1 VERSION CON SUBCONSULTA CORRELACIONADA =====

-- Consulta:


PROMPT
PROMPT ===== E.2 VERSION CON EXPRESION COMUN DE TABLA =====

-- Consulta:


PROMPT
PROMPT ===== E.3 PLANES DE EJECUCION =====

-- EXPLAIN PLAN FOR
-- <peguen aqui la version correlacionada>;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- EXPLAIN PLAN FOR
-- <peguen aqui la version con CTE>;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- Justificacion (que columna produce la correlacion y que diferencia se
-- observa entre los dos planes):


-- =====================================================================
-- BLOQUE F - OPERACIONES DE CONJUNTOS
-- =====================================================================

-- ---------------------------------------------------------------------
-- F.1 Movilidad interna                                   (enunciado 6.8)
-- Columnas obligatorias: employee_id, last_name, movilidad_status
-- movilidad_status: CON HISTORIAL / SIN HISTORIAL
-- Resolver con INTERSECT y MINUS, y contrastar con NOT EXISTS.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== F.1 MOVILIDAD CON INTERSECT Y MINUS =====

-- Consulta:


PROMPT
PROMPT ===== F.2 VERSION EQUIVALENTE CON NOT EXISTS =====

-- Consulta:


-- Justificacion (como tratan los nulos las operaciones de conjuntos
-- frente al operador de igualdad):


-- =====================================================================
-- BLOQUE G - EXPRESIONES COMUNES DE TABLA Y RECURSION
-- =====================================================================

-- ---------------------------------------------------------------------
-- G.1 Jerarquia organizacional                            (enunciado 6.9)
-- Columnas obligatorias: employee_id, last_name, manager_id, nivel,
--   ruta_jerarquica
-- Reglas: CTE recursiva, caso base en el empleado sin jefe,
--   ruta_jerarquica concatenada desde la raiz.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== G.1 JERARQUIA ORGANIZACIONAL =====

-- Consulta:


-- Justificacion (caso base, paso recursivo, que pasa si UNION ALL se
-- reemplaza por UNION, y como se controlaria un ciclo en los datos):


-- =====================================================================
-- BLOQUE H - FUNCIONES DE VENTANA
-- =====================================================================

-- ---------------------------------------------------------------------
-- H.1 Posicionamiento salarial por departamento          (enunciado 6.10)
-- Columnas obligatorias: employee_id, last_name, department_id, salary,
--   rn, rk, drk, prev_salary, delta_prev, salary_running_total,
--   dept_avg_salary, pct_vs_dept_avg
-- Reglas: prev_salary y delta_prev con LAG sobre hire_date, sin dejar
--   nulos en la primera fila de cada particion.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== H.1 POSICIONAMIENTO SALARIAL =====

-- Consulta:


-- Justificacion (departamento con salarios empatados elegido, diferencia
-- entre rn, rk y drk sobre esas filas concretas, y marco de ventana que
-- aplica Oracle por defecto cuando el OVER lleva ORDER BY sin ROWS ni
-- RANGE):


-- ---------------------------------------------------------------------
-- H.2 Tres mejor pagados de cada departamento            (enunciado 6.11)
-- Columnas obligatorias: department_id, department_name, employee_id,
--   last_name, salary, drk
-- Regla: no se acepta filtrar el alias de la funcion de ventana en el
--   WHERE de la misma consulta.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== H.2 TOP 3 POR DEPARTAMENTO =====

-- Consulta:


-- Justificacion (en que momento del orden logico se calculan las
-- funciones de ventana y por que eso obliga a envolver la consulta):


-- =====================================================================
-- BLOQUE I - DEPURACION DE CONSULTAS DEFECTUOSAS        (enunciado 6.12)
-- Para cada una de las cinco consultas del archivo
-- 02_consultas_defectuosas.sql: ejecuten la version defectuosa, dejen su
-- salida visible, documenten el diagnostico y escriban la version
-- corregida ejecutada.
-- =====================================================================

-- ---------------------------------------------------------------------
-- I.1 Departamentos con cantidad de empleados, incluidos los vacios
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.1 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

-- Error detectado:
-- Mecanismo:

PROMPT
PROMPT ===== I.1 CORREGIDA =====
-- Consulta corregida:


-- ---------------------------------------------------------------------
-- I.2 Empleados que no trabajan en los departamentos 10, 20 ni 30
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.2 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

-- Error detectado:
-- Mecanismo:

PROMPT
PROMPT ===== I.2 CORREGIDA =====
-- Consulta corregida:


-- ---------------------------------------------------------------------
-- I.3 Departamentos en Estados Unidos con cantidad de empleados
--     ATENCION: esta consulta tiene DOS errores distintos.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.3 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

-- Error detectado 1:
-- Error detectado 2:
-- Mecanismo:

PROMPT
PROMPT ===== I.3 CORREGIDA =====
-- Consulta corregida:


-- ---------------------------------------------------------------------
-- I.4 Empleado mejor pagado de cada departamento
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.4 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

-- Error detectado:
-- Mecanismo:

PROMPT
PROMPT ===== I.4 CORREGIDA =====
-- Consulta corregida:


-- ---------------------------------------------------------------------
-- I.5 Promedio de comision contando como cero a quien no la recibe
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.5 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

-- Error detectado:
-- Mecanismo:

PROMPT
PROMPT ===== I.5 CORREGIDA =====
-- Consulta corregida:


-- =====================================================================
-- COMENTARIOS FINALES DE JUSTIFICACION TECNICA
-- Respondan en dos o tres parrafos:
--   - Cual de los cuatro casos borde del esquema causo mas errores en su
--     propio trabajo y por que.
--   - En que ejercicio eligieron funcion de ventana en vez de GROUP BY, y
--     que se habria perdido con la otra opcion.
--   - Que consulta del bloque I les costo mas diagnosticar y como
--     llegaron al mecanismo del error.
-- =====================================================================

--
--
--

-- SPOOL OFF

-- =====================================================================
-- FIN DE LA ENTREGA
-- =====================================================================
