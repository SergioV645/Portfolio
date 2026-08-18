SELECT d.department_name
    FROM HR.DEPARTMENTS d
        LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
            WHERE e.employee_id IS NULL;

--############################################################################

SELECT d.department_name, e.last_name
    FROM HR.DEPARTMENTS d
        LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
            WHERE e.salary > 5000;
 
--############################################################################

SELECT COUNT(*) AS Filas,
       COUNT(commission_pct) AS con_comision,
       AVG(commission_pct) AS prom_real
       FROM HR.EMPLOYEES; 

SELECT SUM(commission_pct)
    FROM HR.EMPLOYEES;

SELECT SUM(commission_pct) / COUNT(commission_pct)*0 AS prom_real
    FROM HR.EMPLOYEES;    

SELECT SUM(commission_pct)
    FROM HR.EMPLOYEES
    WHERE commission_pct IS NOT NULL;

--############################################################################

SELECT e.last_name,
    (SELECT COUNT(*)
     FROM HR.EMPLOYEES c
        WHERE c.department_id = e.department_id) AS compañeros
        FROM HR.EMPLOYEES e;

SELECT first_name, COUNT(1)
    FROM HR.EMPLOYEES
        WHERE department_id IN (SELECT department_id
                                FROM HR.EMPLOYEES
                                 WHERE last_name = 'King')
                                 
        GROUP BY first_name;

--############################################################################

WITH jerarquia(employee_id, last_name, manager_id, nivel) AS (
    SELECT employee_id, last_name, manager_id, 1 FROM HR.EMPLOYEES
        WHERE manager_id IS NULL
    UNION ALL
        SELECT e.employee_id, e.last_name, e.manager_id, j.NIVEL + 1
            FROM HR.EMPLOYEES e JOIN jerarquia j ON e.manager_id = j.employee_id
)
CYCLE employee_id SET es_ciclo TO 'Y' DEFAULT 'N' 
SELECT LAST_NAME, NIVEL, es_ciclo FROM jerarquia;

--############################################################################

SELECT department_id, SUM (salary) AS Nomina,
    SUM (SUM(salary)) OVER () as nomina_total
        FROM HR.EMPLOYEES
            GROUP BY department_id;

--############################################################################

SELECT last_name, salary,
       SUM (salary) OVER ( ORDER BY salary
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) As acum_rows,
       SUM (salary) OVER (ORDER BY salary
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) As acum_range
FROM HR.EMPLOYEES
    WHERE DEPARTMENT_ID = 90
        ORDER BY SALARY;