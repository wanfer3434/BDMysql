USE checkpoint_m2;

SELECT * FROM producto;

SELECT COUNT(*) FROM venta;

SELECT * FROM canal_venta;

/*
La dirección desea saber que tipo de producto tiene la segunda mayor venta en 2015 (Tabla "producto", campo Tipo = Tipo de producto).
venta = precio * cantidad

*/

SELECT *, precio * cantidad, IdProducto
FROM venta
WHERE YEAR(Fecha) = 2015
ORDER BY 1 DESC; -- 42763

SELECT *
FROM producto
WHERE IdProducto = 42763;

SELECT SUM(Precio * cantidad), IdProducto
FROM venta
WHERE YEAR(Fecha) = 2015
GROUP BY IdProducto
ORDER BY 1 DESC; -- 42811

SELECT * 
FROM producto
WHERE IdProducto = 42811;

-- JOINS

SELECT SUM(v.Precio * v.cantidad), p.Tipo
FROM venta v INNER JOIN producto p 
		ON (v.IdProducto = p.IdProducto)
WHERE YEAR(v.Fecha) = 2015
GROUP BY p.Tipo
ORDER BY 1 DESC;

SELECT v.Precio * v.Cantidad, v.IdProducto, p.Tipo
FROM venta v INNER JOIN producto p
		ON (v.IdProducto = p.IdProducto)
WHERE Year(v.Fecha) = 2015
ORDER BY 1 DESC;

SELECT *
FROM producto
WHERE Concepto LIKE'EPSON COPYFAX 2000';



-- LECTURE

-- VARIABLE DEFINIDA POR EL USUARIO
SET @Fecha_venta = 2015;

-- Se utiliza en diferentes formas
SELECT @Fecha_venta;

SELECT SUM(v.Precio * v.cantidad), p.Tipo
FROM venta v INNER JOIN producto p 
		ON (v.IdProducto = p.IdProducto)
WHERE YEAR(v.Fecha) = @Fecha_venta
GROUP BY p.Tipo
ORDER BY 1 DESC;

SET @Cliente_nombre = 'Juan';

SELECT * FROM clientes WHERE Nombre = 'Juan';
SELECT * FROM clientes WHERE Nombre = @Cliente_nombre;
SET @Cliente_nombre = 'Augusto';

SET @Prueba = (SELECT IdProducto FROM Venta WHERE IdVenta = 1); -- NO PUEDE SER MAS DE UN ELEMENTO

SELECT @Prueba, @Cliente_nombre;

SET @Prueba = (SELECT IdProducto FROM Venta WHERE IdVenta = 1), @Cliente_nombre = 'Juan';

-- VARIABLE LOCAL

-- DECLARE variable_nombre datatype DEFAULT VALUE;
-- DECLARE totalAlumnos INT DEFAULT 0;

-- VARIABLE DE SISTEMA

SHOW VARIABLES;

SHOW VARIABLES LIKE 'datadir';
SHOW VARIABLES LIKE '%MYSQL%';

-- FUNCIONES
-- GRANT INSERT, DELETE ON tabla TO 'user'@'host';
GRANT INSERT, DELETE ON VENTA TO 'root'@'localhost';

USE henry;

/*
CREATE FUNCTION nombre_funcion(parametros) RETURN tipo_dato
BEGIN
	-- CUERPO DE LA FUNCION
END;
*/

DELIMITER $$ 

CREATE FUNCTION Edad_alumnos (Fecha_nacimiento DATE) RETURNS INT
BEGIN
	DECLARE años INT DEFAULT 0;   -- DECLARAMOS UNA VARIABLE LOCAL

	SET años = TIMESTAMPDIFF(YEAR,Fecha_nacimiento, CURDATE());		-- CUERPO DE LA FUNCION
    
    RETURN años;		-- ESTO DEVUELVE MI FUNCION
		
END$$

DELIMITER ;

-- Error Code: 1418. This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)

SHOW VARIABLES LIKE 'log_bin_trust_function_creators';
SET GLOBAL log_bin_trust_function_creators = 1;

-- Error Code: 1229. Variable 'log_bin_trust_function_creators' is a GLOBAL variable and should be set with SET GLOBAL


SELECT *, Edad_alumnos(FechaNacimiento) as Edad
FROM alumno
;

-- PROCEDIMIENTOS ALMACENADOS

-- CALL procedure;

DELIMITER $$

CREATE PROCEDURE GetTotalAlumnos() 				-- (IN nombre TIPO, OUT nombre TIPO, INOUT nombre TIPO)
BEGIN
	DECLARE total INT DEFAULT 0; 		-- DECLARAMOS LA VARIABLE LOCAL

	SELECT COUNT(IdAlumno)
    INTO total
    FROM alumno;
    
   SELECT total;

END$$

DELIMITER ;

SELECT GetTotalAlumnos();

CALL GetTotalAlumnos();

DROP PROCEDURE GetTotalAlumnos;
DROP FUNCTION Edad_Alumnos;


USE adventureworks;

-- (1200 * 0.15) + 1200
-- (1200 * 1.15)

DELIMITER $$

CREATE FUNCTION valor_nominal(Precio DECIMAL(10,2), margen DECIMAL(10,2)) RETURNS DECIMAL(10,2)
BEGIN
	DECLARE Valor_final DECIMAL(10,2) DEFAULT 0;
    
    SET Valor_final = Precio * margen;
    
    RETURN Valor_final;
    
END$$

DELIMITER ;

SELECT valor_nominal(ListPrice, 1.20)
FROM product
ORDER BY 1 DESC;

SELECT * FROM product;