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
-- Integrante 1 (nombre completo): Liseth Natalia Vergel Rodriguez
-- Integrante 2 (nombre completo): Sergio Andres Valderrama Velez
-- Fecha:
-- =====================================================================

SET LINESIZE 200
SET PAGESIZE 200
SET TRIMSPOOL ON
SET SQLBLANKLINES ON

-- Si trabajan desde un usuario distinto de HR, descomenten la linea:
-- ALTER SESSION SET CURRENT_SCHEMA = HR;

-- SPOOL C:\Users\liset\OneDrive\Natalia_Rodriguez\DocumentosUEB\UEB\SemestreCinco\BD2\R_Evidencias_Vergel_Valderrama.txt
SPOOL "C:\Users\sergi\Documents\2026 - 2\BDD2\Taller Repaso HR\R_Evidencias_Vergel_Valderrama.txt"

-- =====================================================================
-- BLOQUE A - VERIFICACION DE CASOS BORDE DEL ESQUEMA   (enunciado 6.1)
-- Columnas obligatorias: caso_borde, empleados_afectados, descripcion
-- Debe devolver exactamente cuatro filas.
-- =====================================================================
PROMPT
PROMPT ===== A. CASOS BORDE DEL ESQUEMA =====

-- Consulta:

SELECT caso_borde, empleados_afectados, descripcion
FROM (
    SELECT 'Empleado sin jefe' AS caso_borde,
           (SELECT COUNT(*) FROM employees WHERE manager_id IS NULL) AS empleados_afectados,
           'Empleados cuyo manager_id es NULL: no tienen jefe registrado' AS descripcion
    FROM dual
    UNION ALL
    SELECT 'Empleado sin departamento',
            (SELECT COUNT(*) FROM employees WHERE department_id IS NULL),
           'Empleados cuyo department_id es NULL'
    FROM dual
    UNION ALL
    SELECT 'Empleados sin comision',
           (SELECT COUNT(*) FROM employees WHERE commission_pct IS NULL),
           'Empleados cuyo commission_pct es NULL'
    FROM dual
    UNION ALL
    SELECT 'Departamentos sin empleados',
           (SELECT COUNT(*) FROM departments d
            WHERE NOT EXISTS (SELECT 1 FROM employees e
            WHERE e.department_id = d.department_id)),
           'Departamentos sin ningun empleado asociado'
    FROM dual
) resultado;

-- Justificacion (por que cada uno de estos cuatro casos rompe consultas
-- escritas de forma ingenua):

-- Estos cuatro casos rompen consultas escritas sin pensar en nulos porque:
--
-- Sin jefe / sin departamento: un INNER JOIN los excluye sin avisar, ya 
-- que NULL = algo nunca es verdadero en SQL.
-- Sin comisión: AVG() ignora los NULL, así que el promedio sale más alto 
-- de lo real si no se cuentan como 0.
-- Departamentos sin empleados: con INNER JOIN no aparecen; hace falta 
-- LEFT JOIN y COUNT(e.employee_id) en vez de COUNT(*) para que muestren 0.
--
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

SELECT   d.department_id,
         d.department_name,
         l.city,
         c.country_name,
         COUNT(e.employee_id) AS employee_count,
         ROUND(AVG(e.salary), 2) AS avg_salary
FROM     departments d
LEFT     JOIN locations l  ON d.location_id = l.location_id
LEFT     JOIN countries c  ON l.country_id   = c.country_id
LEFT     JOIN employees e  ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name, l.city, c.country_name
ORDER BY d.department_id;

-- Justificacion (por que COUNT(*) da el valor incorrecto aqui):
--
-- Usamos LEFT JOIN desde departments para que no se pierda ningún 
-- departamento, ni siquiera los vacíos. COUNT(*) estaría mal porque 
-- cuenta filas, y un departamento vacío igual genera 1 fila 
-- (con todo en NULL) por el LEFT JOIN; eso daría employee_count = 1 
-- en vez de 0. COUNT(e.employee_id) sí da 0, porque COUNT de una 
-- columna ignora los NULL, y no hay ningún employee_id que contar ahí.
--
-- ---------------------------------------------------------------------
-- B.2 Cadena de mando                                     (enunciado 6.3)
-- Columnas obligatorias: employee_id, employee_name, job_title,
--   manager_id, manager_name, department_name
-- Regla: el empleado 100 debe aparecer con manager_name nulo.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== B.2 CADENA DE MANDO =====

-- Consulta:

SELECT   e.employee_id,
         e.first_name || ' ' || e.last_name  AS employee_name,
         j.job_title,
         e.manager_id,
         m.first_name || ' ' || m.last_name  AS manager_name,
         d.department_name
FROM     employees e
LEFT     JOIN employees   m ON e.manager_id    = m.employee_id
LEFT     JOIN jobs        j ON e.job_id        = j.job_id
LEFT     JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- Justificacion (tipo de reunion usada y que pasa con INNER JOIN):

-- Usamos un auto-LEFT JOIN (la tabla employees unida consigo misma) 
-- porque cada empleado tiene un jefe que también es un empleado. 
-- Es LEFT JOIN y no INNER JOIN porque el empleado 100 no tiene jefe 
-- (manager_id es NULL); con INNER JOIN ese empleado desaparecería 
--del resultado, porque no hay ningún employee_id igual a NULL.
--
-- ---------------------------------------------------------------------
-- B.3 Contraste entre la condicion en ON y en WHERE       (enunciado 6.4)
-- Columnas obligatorias: variante, filas_devueltas, explicacion
-- Ejecuten las dos variantes y registren el conteo de cada una.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== B.3 VARIANTE CON LA CONDICION EN ON =====

-- Consulta variante ON:

SELECT   d.department_name, e.last_name, e.salary
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id 
AND e.salary > 10000
ORDER BY d.department_name;

PROMPT
PROMPT ===== B.3 VARIANTE CON LA CONDICION EN WHERE =====

-- Consulta variante WHERE:

SELECT   d.department_name, e.last_name, e.salary
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id
WHERE    e.salary > 10000
ORDER BY d.department_name;

PROMPT
PROMPT ===== B.3 RESUMEN COMPARATIVO (variante, filas_devueltas, explicacion) =====

-- Consulta:

SELECT   'ON' AS variante,
         COUNT(*) AS filas_devueltas,
         'Filtro en ON: se aplica antes de unir, conserva todos los departamentos' AS explicacion
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id AND e.salary > 10000
UNION ALL
SELECT   'WHERE',
         COUNT(*),
         'Filtro en WHERE: se aplica despues de unir, elimina los NULL y degrada el LEFT JOIN a INNER JOIN'
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id
WHERE    e.salary > 10000;

-- Regla general derivada de la diferencia (una sola frase):
-- Un filtro sobre la tabla externa puesto en ON se aplica antes 
-- de unir y no borra departamentos (LEFT JOIN se mantiene "externo"); 
-- el mismo filtro puesto en WHERE se aplica después de unir y elimina 
-- las filas con NULL, así que el LEFT JOIN termina comportándose como 
-- un INNER JOIN.
-- 
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

SELECT   e.employee_id,
         e.last_name,
         e.department_id,
         e.salary,
         e.commission_pct,
         e.salary + (e.salary * NVL(e.commission_pct, 0))  AS total_compensation,
         CASE WHEN NOT EXISTS (SELECT 1 FROM employees m WHERE m.manager_id = e.employee_id)
              THEN 'NO' ELSE 'SI'
         END AS es_jefe
FROM     employees e
ORDER BY e.employee_id;

PROMPT
PROMPT ===== C.2 EVIDENCIA DEL COMPORTAMIENTO DE NOT IN =====

-- Consulta con NOT IN que devuelve el conjunto vacio (dejenla visible):

SELECT   employee_id, last_name
FROM     employees
WHERE    employee_id NOT IN (SELECT manager_id FROM employees);

-- Justificacion (por que NOT IN devuelve vacio y por que NOT EXISTS no):
--
-- La consulta devuelve 0 filas porque la subconsulta devuelve una lista 
-- que contiene un valor NULL. Al usar NOT IN, la comparación contra un NULL 
-- evalúa toda la condición como UNKNOWN para todas las filas, impidiendo que 
-- se devuelva cualquier registro. En cambio, NOT EXISTS evalúa fila por fila 
-- de forma lógica, por lo que los valores NULL no anulan la condición.
--
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

SELECT   d.department_id,
         d.department_name,
         COUNT(e.employee_id)      AS employee_count,
         ROUND(AVG(e.salary), 2)   AS avg_salary,
         MIN(e.salary)             AS min_salary,
         MAX(e.salary)             AS max_salary,
         SUM(e.salary)             AS salary_mass,
         SUM(CASE WHEN e.hire_date > DATE '2005-01-01' THEN 1 ELSE 0 END) AS empleados_recientes
FROM     departments d
JOIN     employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING   COUNT(e.employee_id) > 5 AND AVG(e.salary) > 6000
ORDER BY d.department_id;

-- Justificacion (por que el criterio de mas de 5 empleados no puede ir
-- en WHERE):
--
-- El criterio de "más de 5 empleados" no puede ir en WHERE porque este 
-- filtra filas individuales antes de agrupar; por eso se usa HAVING, 
-- que filtra los grupos ya calculados por el GROUP BY.
--
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

SELECT   e.employee_id,
         e.last_name,
         e.department_id,
         e.salary,
         ROUND((SELECT AVG(e2.salary)
                FROM employees e2
                WHERE e2.department_id = e.department_id), 2)  AS dept_avg_salary,
         ROUND(e.salary - (SELECT AVG(e2.salary)
                FROM employees e2
                WHERE e2.department_id = e.department_id), 2)  AS diff_vs_avg,
         ROUND((e.salary / (SELECT AVG(e2.salary)
                FROM employees e2
                WHERE e2.department_id = e.department_id) - 1) * 100, 2) AS pct_vs_avg
FROM     employees e
ORDER BY e.department_id, e.employee_id;

PROMPT
PROMPT ===== E.2 VERSION CON EXPRESION COMUN DE TABLA =====

-- Consulta:

WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM   employees
    GROUP BY department_id
)
SELECT   e.employee_id,
         e.last_name,
         e.department_id,
         e.salary,
         ROUND(da.avg_salary, 2)                           AS dept_avg_salary,
         ROUND(e.salary - da.avg_salary, 2)                AS diff_vs_avg,
         ROUND((e.salary / da.avg_salary - 1) * 100, 2)    AS pct_vs_avg
FROM     employees e
JOIN     dept_avg da ON e.department_id = da.department_id
ORDER BY e.department_id, e.employee_id;

PROMPT
PROMPT ===== E.3 PLANES DE EJECUCION =====

-- EXPLAIN PLAN FOR
-- <peguen aqui la version correlacionada>;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT   e.employee_id, e.last_name, e.department_id, e.salary,
         (SELECT AVG(e2.salary) FROM employees e2 
WHERE e2.department_id = e.department_id) AS dept_avg_salary
FROM     employees e;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- EXPLAIN PLAN FOR
-- <peguen aqui la version con CTE>;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary FROM employees 
    GROUP BY department_id
)
SELECT e.employee_id, e.last_name, e.department_id, e.salary, da.avg_salary
FROM employees e JOIN dept_avg da ON e.department_id = da.department_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Justificacion (que columna produce la correlacion y que diferencia se
-- observa entre los dos planes):
--
-- La correlación surge por la igualdad e2.department_id = e.department_id, 
-- que obliga a la subconsulta a evaluarse una vez por cada empleado 
-- (fila externa). Esto genera múltiples accesos a la tabla employees, 
-- aumentando el costo. En cambio, la versión con CTE es más eficiente 
-- porque calcula el promedio una sola vez por departamento y luego lo 
-- vincula mediante un JOIN.
--
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

SELECT employee_id, last_name, 'CON HISTORIAL' AS movilidad_status
FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM employees
    INTERSECT
    SELECT employee_id FROM job_history
)
UNION ALL
SELECT employee_id, last_name, 'SIN HISTORIAL' AS movilidad_status
FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM employees
    MINUS
    SELECT employee_id FROM job_history
)
ORDER BY movilidad_status, employee_id;

PROMPT
PROMPT ===== F.2 VERSION EQUIVALENTE CON NOT EXISTS =====

-- Consulta:

SELECT   e.employee_id,
         e.last_name,
         CASE WHEN EXISTS (SELECT 1 FROM job_history jh 
         WHERE jh.employee_id = e.employee_id)
              THEN 'CON HISTORIAL' ELSE 'SIN HISTORIAL'
         END AS movilidad_status
FROM     employees e
ORDER BY movilidad_status, e.employee_id;

-- Justificacion (como tratan los nulos las operaciones de conjuntos
-- frente al operador de igualdad):
-- 
-- INTERSECT y MINUS comparan filas completas usando una lógica donde 
-- dos NULL se consideran iguales entre sí (a diferencia del operador =,
-- donde NULL = NULL da UNKNOWN, no verdadero). Por eso estas operaciones 
-- de conjuntos son "seguras" con nulos, mientras que comparar con = directamente 
-- puede dar resultados inesperados. Aun así, aquí no afecta porque employee_id 
-- nunca es NULL.
-- 
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

WITH jerarquia (employee_id, last_name, manager_id, nivel, ruta_jerarquica) 
AS (
    SELECT employee_id, last_name, manager_id, 1 AS nivel,
           CAST(last_name AS VARCHAR2(4000)) AS ruta_jerarquica
    FROM   employees
    WHERE  manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.last_name, e.manager_id, j.nivel + 1,
           j.ruta_jerarquica || ' > ' || e.last_name
    FROM   employees e
    JOIN   jerarquia j ON e.manager_id = j.employee_id
)
SELECT employee_id, last_name, manager_id, nivel, ruta_jerarquica
FROM   jerarquia
ORDER BY nivel, employee_id;

-- Justificacion (caso base, paso recursivo, que pasa si UNION ALL se
-- reemplaza por UNION, y como se controlaria un ciclo en los datos):
-- 
-- El caso base es el empleado con manager_id IS NULL (la raíz). El paso 
-- recursivo une cada empleado con la jerarquía ya construida, buscando 
-- quién es su jefe y así va bajando de nivel en nivel. Se usa UNION ALL 
-- porque UNION eliminaría duplicados comparando filas completas, lo cual 
-- es más lento. Si hubiera un ciclo en los datos (A es jefe de B y B es 
-- jefe de A), la recursión nunca terminaría; en Oracle esto se controla 
-- con la cláusula CYCLE dentro del WITH, que detecta cuándo una fila se 
-- repite y detiene la recursión.
-- 
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

SELECT   employee_id,
         last_name,
         department_id,
         salary,
         ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC)  AS rn,
         RANK()       OVER (PARTITION BY department_id ORDER BY salary DESC)  AS rk,
         DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC)  AS drk,
         NVL(LAG(salary) OVER (PARTITION BY department_id ORDER BY hire_date), salary) AS prev_salary,
         NVL(salary - LAG(salary) OVER (PARTITION BY department_id ORDER BY hire_date), 0) AS delta_prev,
         SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_date
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS salary_running_total,
         ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) AS dept_avg_salary,
         ROUND((salary / AVG(salary) OVER (PARTITION BY department_id) - 1) * 100, 2) AS pct_vs_dept_avg
FROM     employees
ORDER BY department_id, salary DESC;

-- Justificacion (departamento con salarios empatados elegido, diferencia
-- entre rn, rk y drk sobre esas filas concretas, y marco de ventana que
-- aplica Oracle por defecto cuando el OVER lleva ORDER BY sin ROWS ni
-- RANGE):
--
-- El departamento 50 (Shipping) tiene varios salarios repetidos, por 
-- ejemplo dos empleados en 2.500. Ahí se nota la diferencia: ROW_NUMBER 
-- les da números distintos consecutivos (por ejemplo 5 y 6) aunque empaten; 
-- RANK les da el mismo puesto (por ejemplo 5 y 5) pero salta el siguiente 
-- número (pasa a 7); DENSE_RANK también los empata en 5, pero el siguiente 
-- sigue en 6, sin saltos. Para prev_salary/delta_prev usamos NVL porque la 
-- primera fila de cada partición no tiene una fila anterior, y LAG devolvería 
-- NULL ahí; con NVL la dejamos igual a su propio salario (delta 0) en vez de 
-- nula. Cuando OVER lleva ORDER BY sin especificar ROWS/RANGE, Oracle aplica 
-- por defecto RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, que es la base 
-- de por qué salary_running_total se va acumulando fila a fila en vez de sumar 
-- todo el departamento de una vez.
--
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

SELECT   department_id, department_name, employee_id, last_name, salary, drk
FROM (
    SELECT   d.department_id,
             d.department_name,
             e.employee_id,
             e.last_name,
             e.salary,
             DENSE_RANK() OVER (PARTITION BY d.department_id ORDER BY e.salary DESC) AS drk
    FROM     departments d
    JOIN     employees e ON d.department_id = e.department_id
)
WHERE    drk <= 3
ORDER BY department_id, drk;

-- Justificacion (en que momento del orden logico se calculan las
-- funciones de ventana y por que eso obliga a envolver la consulta):
-- 
-- En el orden lógico de evaluación de SQL, las funciones de ventana 
-- se calculan después del WHERE y del GROUP BY, casi al final (junto 
-- con el SELECT), y antes del ORDER BY. Por eso no se puede filtrar 
-- el alias drk en el WHERE de la misma consulta: en ese momento drk 
-- todavía no existe. Hay que calcularlo primero en una subconsulta 
-- (o CTE) y luego filtrar por él en una consulta externa.
--
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

SELECT   d.department_name, COUNT(*) AS employee_count
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY d.department_name;

-- Error detectado: Los departamentos vacíos muestran employee_count = 1 
-- en vez de 0.
-- Mecanismo: COUNT(*) cuenta filas y el LEFT JOIN igual genera 1 fila 
-- (con todo NULL) por cada departamento sin empleados. Contar filas no 
-- es lo mismo que contar empleados.

PROMPT
PROMPT ===== I.1 CORREGIDA =====
-- Consulta corregida:

SELECT   d.department_name, COUNT(e.employee_id) AS employee_count
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY d.department_name;

-- ---------------------------------------------------------------------
-- I.2 Empleados que no trabajan en los departamentos 10, 20 ni 30
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.2 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

SELECT last_name, department_id
FROM   employees
WHERE  department_id NOT IN (10, 20, 30)
ORDER  BY department_id, last_name;

-- Error detectado: Los empleados sin departamento (department_id IS NULL) 
-- no aparecen, aunque técnicamente "no trabajan en 10, 20 ni 30".
-- Mecanismo: NOT IN compara department_id contra la lista fija (10,20,30); 
-- esto no involucra ningún NULL de la lista, así que aquí sí funciona para 
-- los que tienen department_id, pero un department_id NULL nunca cumple 
-- ninguna comparación (NULL NOT IN (...) es UNKNOWN), entonces esas filas 
-- se pierden.

PROMPT
PROMPT ===== I.2 CORREGIDA =====
-- Consulta corregida:

SELECT last_name, department_id
FROM   employees
WHERE  department_id NOT IN (10, 20, 30)
   OR  department_id IS NULL
ORDER  BY department_id, last_name;

-- ---------------------------------------------------------------------
-- I.3 Departamentos en Estados Unidos con cantidad de empleados
--     ATENCION: esta consulta tiene DOS errores distintos.
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.3 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

SELECT   d.department_name, COUNT(*) AS employee_count
FROM     departments d
LEFT     JOIN employees e ON d.department_id = e.department_id
LEFT     JOIN locations l ON d.location_id   = l.location_id
WHERE    l.country_id = 'US'
GROUP BY d.department_name
ORDER BY d.department_name;

-- Error detectado 1: Usa COUNT(*) en vez de COUNT(e.employee_id), 
-- igual que en I.1.
-- Error detectado 2: El WHERE l.country_id = 'US' convierte el 
-- LEFT JOIN con employees en un INNER JOIN de facto, porque filtra 
-- después de unir; esto elimina los departamentos de EE.UU. que no 
-- tienen empleados.
-- Mecanismo: Poner una condición de la tabla externa en WHERE en vez 
-- de ON descarta las filas con NULL generadas por el LEFT JOIN, 
-- perdiendo departamentos vacíos.

PROMPT
PROMPT ===== I.3 CORREGIDA =====
-- Consulta corregida:

SELECT   d.department_name, COUNT(e.employee_id) AS employee_count
FROM     departments d
LEFT     JOIN locations l ON d.location_id = l.location_id
LEFT     JOIN employees e ON d.department_id = e.department_id
WHERE    l.country_id = 'US'
GROUP BY d.department_name
ORDER BY d.department_name;

-- ---------------------------------------------------------------------
-- I.4 Empleado mejor pagado de cada departamento
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.4 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

SELECT   department_id, last_name, MAX(salary) AS max_salary
FROM     employees
GROUP BY department_id, last_name
ORDER BY department_id, max_salary DESC;

-- Error detectado: Devuelve varias filas por departamento (una por cada 
-- last_name distinto), no solo el mejor pagado.
-- Mecanismo: Agrupar por department_id, last_name hace que cada empleado 
-- (con apellido distinto) forme su propio grupo, así que MAX(salary) solo 
-- calcula el máximo dentro de ese grupo de una sola persona; no compara 
-- contra los demás del departamento.

PROMPT
PROMPT ===== I.4 CORREGIDA =====
-- Consulta corregida:

SELECT   department_id, last_name, salary
FROM (
    SELECT department_id, last_name, salary,
           RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rk
    FROM   employees
)
WHERE    rk = 1
ORDER BY department_id;

-- ---------------------------------------------------------------------
-- I.5 Promedio de comision contando como cero a quien no la recibe
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== I.5 DEFECTUOSA =====
-- (peguen la consulta defectuosa)

SELECT AVG(commission_pct) AS promedio_comision
FROM   employees;

-- Error detectado: El promedio sale más alto de lo real.
-- Mecanismo: AVG() ignora automáticamente los valores NULL, entonces 
-- solo promedia entre los empleados que sí tienen comisión, en vez de 
-- tratar a los demás como 0.

PROMPT
PROMPT ===== I.5 CORREGIDA =====
-- Consulta corregida:

SELECT AVG(NVL(commission_pct, 0)) AS promedio_comision
FROM   employees;

-- ---------------------------------------------------------------------
-- Cuadro de diagnostico del Bloque I
-- Columnas obligatorias: consulta_id, enunciado, error_detectado,
--   mecanismo, evidencia_correccion
-- ---------------------------------------------------------------------
PROMPT
PROMPT ===== CUADRO DE DIAGNOSTICO BLOQUE I =====

-- Consulta:

SELECT 'I.1' AS consulta_id,
       'Departamentos con cantidad de empleados, incluidos los vacios' AS enunciado,
       'Departamentos vacios muestran employee_count = 1 en vez de 0' AS error_detectado,
       'COUNT(*) cuenta filas; el LEFT JOIN igual genera 1 fila con NULL por departamento vacio' AS mecanismo,
       'Corregido con COUNT(e.employee_id), que ignora los NULL' AS evidencia_correccion
FROM dual
UNION ALL
SELECT 'I.2',
       'Empleados que no trabajan en los departamentos 10, 20 ni 30',
       'Los empleados sin departamento (department_id IS NULL) no aparecen',
       'NULL NOT IN (...) evalua UNKNOWN, asi que esas filas nunca cumplen la condicion',
       'Corregido agregando OR department_id IS NULL'
FROM dual
UNION ALL
SELECT 'I.3',
       'Departamentos en Estados Unidos con cantidad de empleados',
       'Dos errores: COUNT(*) en vez de COUNT(e.employee_id); y se pierden departamentos de EE.UU. sin empleados',
       'COUNT(*) cuenta filas NULL del LEFT JOIN; ademas el WHERE sobre la tabla externa degrada el LEFT JOIN a INNER JOIN',
       'Corregido con COUNT(e.employee_id) y manteniendo el filtro de pais sobre locations, no sobre employees'
FROM dual
UNION ALL
SELECT 'I.4',
       'Empleado mejor pagado de cada departamento',
       'Devuelve varias filas por departamento en vez de solo el mejor pagado',
       'GROUP BY department_id, last_name crea un grupo por cada empleado, no por departamento',
       'Corregido con RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) y filtro rk = 1 en consulta externa'
FROM dual
UNION ALL
SELECT 'I.5',
       'Promedio de comision contando como cero a quien no la recibe',
       'El promedio sale mas alto de lo real',
       'AVG() ignora los NULL, promediando solo entre quienes tienen comision',
       'Corregido con AVG(NVL(commission_pct, 0))'
FROM dual;

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

-- Caso Borde: El caso que más nos generó problemas fue el de los 
-- departamentos sin empleados, en el bloque B.1: usar COUNT(*) en vez de 
-- COUNT(e.employee_id) mostraba 1 fila en vez de 0. Es fácil de pasar por 
-- alto porque la consulta corre sin error, solo da un dato incorrecto.
--
-- Ventana en vez de GROUP BY: Usamos función de ventana en los bloques H.1 
-- y H.2 en vez de GROUP BY porque necesitábamos conservar el detalle de cada 
-- empleado mientras lo comparábamos con su departamento. Con GROUP BY se habría 
-- perdido esa información: solo se obtiene el salario máximo, sin saber a qué 
-- empleado pertenece.
--
-- Bloque I: La consulta que más nos costó diagnosticar fue la I.2, por el 
-- comportamiento de NOT IN con nulos: los empleados sin departamento no aparecían, 
-- porque NULL nunca cumple una comparación. Nos dimos cuenta al comparar el conteo 
-- de filas contra el total esperado y ver que no coincidía.
--
SPOOL OFF

-- =====================================================================
-- FIN DE LA ENTREGA
-- =====================================================================