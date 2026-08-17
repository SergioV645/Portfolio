CREATE TABLE empleado as SELECT * FROM hr.EMPLOYEES;

SELECT * FROM HR.EMPLOYEES;

CREATE OR REPLACE VIEW VW_EMPLEADO as
    SELECT FIRST_NAME as Nombre_Emp,
        HIRE_DATE as Fecha_Cont, 
        SALARY as Salario,
        EMAIL as Correo 
    FROM hr.employees
        WHERE DEPARTMENT_ID IN (80, 90, 100);


CREATE OR REPLACE VIEW VW_EMPLEADO as
    SELECT FIRST_NAME as Nombre_Emp,
        HIRE_DATE as Fecha_Cont, 
        SALARY as Salario,
        EMAIL as Correo 
    FROM hr.employees
        WHERE DEPARTMENT_ID IN (80, 90, 100);