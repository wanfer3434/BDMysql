USE henry;
-- LECTURE

-- subquerie

SELECT MIN(FechaIngreso)
FROM alumno;
-- Que alumno ingreso primero en Henry?

SELECT IdAlumno,Nombre, Apellido, FechaIngreso
FROM alumno
ORDER BY 4
LIMIT 1;
/*
UPDATE alumno
SET FechaIngreso = '2019-12-04'
WHERE IdAlumno = 8;
*/
SELECT Nombre, Apellido, FechaIngreso
FROM alumno
WHERE FechaIngreso = '2019-12-04';


-- COHORTES SIN ALUMNOS 
SELECT DISTINCT IdCohorte
FROM alumno;

SELECT *FROM alumno;
SELECT *FROM cohorte;

SELECT * FROM cohorte
WHERE IdCohorte NOT IN (SELECT DISTINCT IdCohorte FROM alumno);

-- Es lo mismo que :
SELECT *
FROM cohorte c LEFT JOIN alumno a
					ON(a.IdCohorte = c.IdCohorte)
WHERE a.IdCohorte is null;
SELECT * FROM alumno;

-- VISTAS
-- Los alumnos mayores al promedio de edad
-- CREATE VIEW nombre_vista AS Consulta
SELECT AVG(FechaNacimiento)FROM alumno;
SELECT AVG(TIMESTAMPDIFF(YEAR,FechaNacimiento,CURDATE()))FROM alumno;

CREATE VIEW alumnos_mayor_promedio AS
	SELECT Nombre, Apellido, TIMESTAMPDIFF(YEAR, FechaNacimiento,CURDATE()) AS EDAD
    FROM alumno
    WHERE TIMESTAMPDIFF(YEAR,FechaNacimiento,CURDATE()) > (SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento,CURDATE()))FROM alumno)
    ORDER BY 3 DESC;
SELECT Nombre, Apellido FROM alumnos_mayor_promedio;