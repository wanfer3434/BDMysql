USE henry;
USE adventureworks;
--  SET @nombre_variable = valor  CREACION DE UNA VARIABLE DE USUARIO
SELECT * FROM alumno;

SET @nombre = 'Carlos';

SELECT *
FROM alumno
WHERE nombre = @nombre;

-- DECLARACIÓN DE VARIABLES LOCALES OSLO EN FUNCIONES Y STORED PRODEDURES
-- DEVCLARE VARIABLE_NAME DATATYPE [DEFAULT VALUE];
-- SET VARIABLE_NAME =

SHOW VARIABLES;
SHOW VARIABLES LIKE '%secure_files%'; -- nos muestra la ruta donde vamos almacenar archivos de la base de datos
SHOW VARIABLES LIKE '%global%';  
SHOW SESSION VARIABLES LIKE 'version';

GRANT INSERT, DELETE ON alumno TO 'root'@'localhost';

DELIMITER $$

-- CREAR FUNCIONES -- NOS SIRVE PARA CREAR CALCULOS, PROCESOS REPETITIVOS
CREATE FUNCTION nombre_funciones(parametros) RETURNS tipo_retorno
BEGIN
		-- CUERPO DE LA FUNCION
        DECLARE variable INT DEFAULT 0;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION Antiguedad(fechaNacimiento DATE)  RETURNS INT 
BEGIN
	DECLARE anios INT DEFAULT 1;
    SET anios = TIMESTAMPDIFF(YEAR, fechaNacimiento, CURDATE());
    RETURN anios;
END$$

DELIMITER ;

SHOW VARIABLES LIKE  'log_bin_trust_function_creators';
SET GLOBAL log_bin_trust_function_creators = ON;

SELECT * FROM alumno;

SELECT CONCAT(nombre,' ',apellido) 'Nombre y Apellido',Antiguedad(FechaNacimiento)
FROM alumno

-- CREACION DE UN PROCEDURE IN OUT INOUT -- NOS SIRVE PARA MANIPULAR GRAN CANTIDAD DE DATOS
DELIMITER $$
CREATE PROCEDURE nombre (IN anios DATE, OUT anios DATE, INOUT nombre TIPO)
BEGIN
	SELECT, INSERT, UPDATE, DELETE
END $$

DELIMITER ;

DELIMITER $$

-- EJEMPLO DE PROCEDURE -- MOSTRAR LOS ALUMNOS POR CARRERA

CREATE PROCEDURE listaCarrera(IN NombreCarrera VARCHAR(25))
BEGIN
	SELECT CONCAT(a.nombre, ' ', a.apellido) 'Alumno', a.IdCohorte, Antiguedad(a.FechaNacimiento)
    FROM alumno a JOIN Cohorte co
		ON(a.IdCohorte = co.IdCohorte)
	JOIN carrera ca
		ON(co.IdCarrera = ca.IdCarrera)
	WHERE ca.nombre = NombreCarrera;
END $$

DELIMITER ;

CALL listaCarrera('Full Stack Developer');

DROP PROCEDURE listaCarrera;
SELECT * FROM salesorderheader;

-- 1. Crear un procedimiento que recibe como parámetro una fecha y muestre la cantidad de órdenes ingresadas en esa fecha.<br>
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS obtCantOrdenFecha(IN fechaParam DATE)
BEGIN
	SELECT COUNT(*)
    FROM salesorderheader
    WHERE DATE(OrderDate) = fechaParam;
    
END $$
DELIMITER ;

CALL obtCantOrdenFecha('2003-09-20');	

-- 2. Crear una función que calcule el valor nominal de un margen bruto determinado por el usuario a partir del precio de lista de los productos.<br>
DELIMITER $$

CREATE FUNCTION IF NOT EXISTS margenBruto (
precio DECIMAL(10,2), 
margen DECIMAL(10,2)) 
RETURNS DECIMAL(15,3)
BEGIN
	DECLARE margenBruto DECIMAL(15,3);
    
    SET margenBruto = precio * margen;
    
    RETURN margenBruto;
END $$

DELIMITER ; 
SELECT margenBruto(100,1.2);

/* Obtner un listado de productos en orden alfabético que muestre cuál debería ser el valor de precio de lista, 
si se quiere aplicar un margen bruto del 20%, utilizando la función creada en el punto 2, sobre el campo StandardCost. Mostrando tambien el campo ListPrice y la diferencia con el nuevo campo creado.<br>*/
SELECT * FROM product;

SELECT 
ProductID, 
Name, 
margenBruto(StandardCost,1.2) as 'Precio con Margen del 20%', 
StandardCost, ListPrice,
ROUND((ListPrice - margenBruto(StandardCost,1.2)),2) as 'Diferencia'
FROM product
WHERE ListPrice > 0 AND StandardCost > 0
ORDER BY Name ASC;

/*Crear un procedimiento que reciba como parámetro una fecha desde y una hasta, 
y muestre un listado con los Id de los diez Clientes que más costo de transporte tienen entre esas fechas (campo Freight).<br>*/
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS gastoTransporte (IN FechaDesde DATE,IN FechaHasta DATE )
BEGIN
	SELECT CustomerId, SUM(Freight) AS TotalTransporte
    FROM salesorderheader 
    WHERE OrderDate BETWEEN FechaDesde AND FechaHasta
    GROUP BY CustomerId
    ORDER BY TotalTransporte DESC
    LIMIT 10;
END $$

DELIMITER ; 

CALL gastoTransporte('2002-01-01','2003-01-01');

-- 5. Crear un procedimiento que permita realizar la insercción de datos en la tabla shipmethod.<br>
SELECT * FROM shipmethod;
SELECT NOW();
-- INSERT INTO shipmethod (Name, ShipBase, ShipRate, ModifiedDate)

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS cargaShipMethod(IN Nombre VARCHAR(50), IN ShipBase DOUBLE, IN ShipRate DOUBLE)
BEGIN
	INSERT INTO shipmethod (Name, ShipBase, ShipRate, ModifiedDate)
    VALUES (Nombre, ShipBase, ShipRate, NOW());
END $$

DELIMITER ;

SELECT * FROM shipmethod;

CALL cargaShipMethod('Prueba',8.75,1.25);