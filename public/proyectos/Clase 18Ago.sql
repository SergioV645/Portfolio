   SELECT d.department_name
   FROM HR.DEPARTMENTS d
   LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
   WHERE e.employee_id IS NULL;

--############################################################################

   SELECT d.department_name, e.last_name
    FROM HR.DEPARTMENTS d
    LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
    WHERE e.salary > 5000;
 