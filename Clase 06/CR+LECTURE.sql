-- CR 6 FT17 M3

USE henry_m3;

-- Normalizacion
-- 1)
DROP TABLE IF EXISTS aux_localidad;
CREATE TABLE IF NOT EXISTS aux_localidad (
	Localidad_Original VARCHAR(100),
    Provincia_Original VARCHAR(100),
    Localidad_Normalizada VARCHAR(100),
    Provincia_Normalizada VARCHAR(100),
    IdLocalidad INT
);

SELECT * FROM aux_localidad;

SELECT DISTINCT Localidad, Provincia, Localidad, Provincia 
FROM cliente
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia
FROM sucursal
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia
FROM proveedor
ORDER BY 2, 1;

INSERT INTO aux_localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, IdLocalidad)
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 -- avg(latitud), avg(longitud)
FROM cliente
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0
FROM sucursal
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0
FROM proveedor
ORDER BY 2, 1;

SELECT * FROM aux_localidad
ORDER BY Provincia_Original;

UPDATE aux_localidad SET Provincia_Normalizada = 'Buenos Aires'
WHERE Provincia_Original IN ('B. Aires', 
							'B.Aires',
                            'Bs As',
                            'Bs.As',
                            'Buenos Aires',
                            'C deBuenos Aires',
                            'Caba',
                            'CABA',
                            'Ciudad de Buenos Aires',
                            'Pcia Bs AS',
                            'Prov de Bs As.',
                            'Provincia de Buenos Aires',
                            'Bs.As. ');

SELECT * FROM aux_localidad
ORDER BY Localidad_Original;

UPDATE aux_localidad SET Localidad_Normalizada = 'Capital Federal'
WHERE Localidad_Original IN ('Caba',
							'Cap. Fed',
                            'Capfed',
                            'Cap.   Federal',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires',
                            'Cap. Fed.')
AND Provincia_normalizada = 'Buenos Aires';



UPDATE aux_localidad SET Localidad_Normalizada = 'Córdoba'
WHERE Localidad_Original IN ('Coroba',
							'Cordoba',
                            'Cã³rdoba')
AND Provincia_Normalizada = 'Córdoba';


SELECT * FROM sucursal;
DROP TABLE IF EXISTS Localidad;
CREATE TABLE IF NOT EXISTS Localidad (
	IdLocalidad INT NOT NULL AUTO_INCREMENT,
    Localidad VARCHAR(100),
    Provincia VARCHAR(100),
    IdProvincia INT,
	PRIMARY KEY(IdLocalidad)
);

SELECT * FROM localidad;

INSERT INTO localidad (localidad, provincia, IdProvincia)
SELECT DISTINCT Localidad_Normalizada, Provincia_Normalizada, 0
FROM aux_localidad
ORDER BY 1;

DROP TABLE IF EXISTS Provincia;
CREATE TABLE IF NOT EXISTS Provincia (
	IdProvincia INT NOT NULL AUTO_INCREMENT,
    Provincia VARCHAR(100),
    PRIMARY KEY(IdProvincia)
);

INSERT INTO Provincia (Provincia)
SELECT DISTINCT Provincia_normalizada
FROM aux_localidad
ORDER BY 1;

SELECT * FROM provincia;

UPDATE localidad l JOIN provincia p
						ON (p.Provincia = l.Provincia)
SET l.IdProvincia = p.IdProvincia;

SELECT * FROM localidad;
SELECT * FROM aux_localidad;

UPDATE aux_localidad a JOIN localidad l
						ON (l.Localidad = a.Localidad_Normalizada AND
							l.Provincia = a.Provincia_Normalizada)
SET a.IdLocalidad = l.IdLocalidad;

ALTER TABLE localidad DROP provincia;

ALTER TABLE cliente ADD IdLocalidad INT NOT NULL DEFAULT 0 AFTER Localidad;
ALTER TABLE sucursal ADD IdLocalidad INT NOT NULL DEFAULT 0 AFTER Localidad;

ALTER TABLE proveedor ADD IdLocalidad INT NOT NULL DEFAULT 0 AFTER Ciudad;
-- MODIFICA LA TABLA PROVEEDOR AÑADI UNA COLUMNA LLAMADA IdLocalidad VA A SER DE TIPO ENTERO NO NULO POR DEFECTO UN 0 Y VA A IR DESPUES DE LA COLUMNA Ciudad

SELECT * FROM proveedor;

UPDATE proveedor p JOIN aux_localidad a
						ON (p.Ciudad = a.Localidad_Original AND
							p.Provincia = a.Provincia_Original)
SET p.IdLocalidad = a.IdLocalidad;

UPDATE sucursal s JOIN aux_localidad a
					ON (s.Localidad = a.Localidad_Original AND
						s.Provincia = a.Provincia_Original)
SET s.IdLocalidad = a.IdLocalidad;

UPDATE cliente c JOIN aux_localidad a
					ON (a.Localidad_Original = c.Localidad AND
						a.Provincia_Original = c.Provincia)
SET c.IdLocalidad = a.IdLocalidad;

SELECT * FROM cliente;
SELECT * FROM sucursal;

ALTER TABLE cliente DROP Localidad, DROP Provincia;
ALTER TABLE sucursal DROP Localidad, DROP Provincia;
ALTER TABLE Proveedor DROP Ciudad, DROP Provincia, DROP Departamento, DROP Pais;


-- 2) 

ALTER TABLE cliente ADD Rango_Etario VARCHAR(20) NOT NULL DEFAULT '-' AFTER Edad;

SELECT * FROM cliente;

UPDATE cliente SET Rango_Etario = '1_Hasta 30 años' WHERE Edad <= 30;
UPDATE cliente SET Rango_Etario = '2_De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '3_De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '4_De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '5_Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

SELECT Rango_Etario, COUNT(*)
FROM cliente
GROUP BY 1
ORDER BY 2 DESC;

-- Deteccion de outliers para ventas

SELECT IdProducto, ROUND(AVG(Precio),2) as Promedio, ROUND(AVG(Precio) + (3 * stddev(Precio)),2) as Maximo
FROM venta
group by IdProducto;
SELECT COUNT(*), IdVenta FROM venta GROUP BY 2;
SELECT IdProducto, ROUND(AVG(Precio),2) as Promedio, ROUND(AVG(Precio) - (3 * stddev(Precio)),2) as Minimo
FROM venta
group by IdProducto;

-- OUTLIERS EN PRECIO
SELECT v.*, o.Promedio, o.Maximo, o.Minimo
FROM venta v
JOIN (SELECT IdProducto, ROUND(AVG(Precio),2) as Promedio,  ROUND(AVG(Precio) - (3 * stddev(Precio)),2) as Minimo,
													 ROUND(AVG(Precio) + (3 * stddev(Precio)),2) as Maximo
											FROM venta
											GROUP BY IdProducto) o
 ON (v.IdProducto = o.IdProducto)
 WHERE v.Precio > o.Maximo OR v.Precio < o.Minimo; -- 16466
 
 SELECT * FROM venta
 WHERE IdVenta = 16466;
 SELECT * FROM producto
 WHERE IdProducto = 42915;
 
 
 -- OUTLIERS EN CANTIDAD
 
 SELECT v.*, o.Promedio, o.Maximo, o.Minimo
FROM venta v
JOIN (SELECT IdProducto, ROUND(AVG(Cantidad),2) as Promedio,  ROUND(AVG(Cantidad) - (3 * stddev(Cantidad)),2) as Minimo,
													 ROUND(AVG(cANTIDAD) + (3 * stddev(Cantidad)),2) as Maximo
											FROM venta
											GROUP BY IdProducto) o
 ON (v.IdProducto = o.IdProducto)
 WHERE v.Cantidad > o.Maximo OR v.Cantidad < o.Minimo; 
 
 SELECT * FROM cliente
 WHERE IdCliente = 1849;
 /*
 CABE ACLARAR QUE EXISTEN OUTLIERS QUE SON VALORES LEGITIMOS, OSEA QUE SON VERDADEROS
 */
 
 SELECT * FROM aux_venta;
 /*
 AUX_VENTA GUARDA LOS "ERRORES" EN LA TABLA VENTA
 MOTIVO = 1 ERROR EN CANTIDAD = 0
 MOTIVO = 2 OUTLIER DE Cantidad
 MOTIVO = 3 OUTLIER DE Precio
 */
 
 INSERT INTO aux_venta 
 SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 2
 FROM venta v 
	JOIN (SELECT IdProducto, ROUND(AVG(Cantidad),2) as Promedio,  ROUND(AVG(Cantidad) - (3 * stddev(Cantidad)),2) as Minimo,
													 ROUND(AVG(Cantidad) + (3 * stddev(Cantidad)),2) as Maximo
											FROM venta
											GROUP BY IdProducto) o
												ON (o.IdProducto = v.IdProducto)
WHERE v.Cantidad > o.Maximo OR v.Cantidad < o.Minimo;

INSERT INTO aux_venta 
SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 3
FROM venta v 
	 JOIN (SELECT IdProducto, ROUND(AVG(Precio),2) as Promedio,  ROUND(AVG(Precio) - (3 * stddev(Precio)),2) as Minimo,
													 ROUND(AVG(Precio) + (3 * stddev(Precio)),2) as Maximo
											FROM venta
											GROUP BY IdProducto) o 
																		ON (v.IdProducto = o.IdProducto)
WHERE v.Precio > o.Maximo OR v.Precio < o.Minimo;                                                                        

SELECT * FROM aux_venta;

SELECT * FROM venta;
-- ALTER TABLE venta ADD Outlier TINYINT DEFAULT 0 AFTER Cantidad;
UPDATE venta v JOIN aux_venta a
					ON (v.IdVenta = a.IdVenta )
SET v.Outlier = 1 
where a.Motivo IN (2,3);  -- ACA IDENTIFICAMOS CUALES SON LOS OUTLIERS TANTO DE PRECIO COMO DE CANTIDAD


SELECT SUM(v.Precio * v.Cantidad) as Venta, s.Sucursal, v.Fecha
FROM venta v JOIN sucursal s 
					ON (s.IdSucursal = v.IdSucursal)
WHERE Outlier = 0 AND v.Fecha BETWEEN '2015-01-01' AND '2016-01-01'
GROUP BY 2, 3
ORDER BY 1 DESC
; -- VENTAS TOTALES POR SUCURSAL Y FECHA EN 2015 SIN TENER EN CUENTA LOS OUTLIERS

-- 542703.040	Cabildo	2015-07-20

SELECT SUM(v.Precio * v.Cantidad) as Venta, s.Sucursal, v.Fecha
FROM venta v JOIN sucursal s 
					ON (s.IdSucursal = v.IdSucursal)
WHERE v.Fecha BETWEEN '2015-01-01' AND '2016-01-01' 
GROUP BY 2, 3
ORDER BY 1 DESC
; -- VENTAS TOTALES POR SUCURSAL Y FECHA EN 2015 SIN QUE NOS IMPORTE LA EXISTENCIA DE LOS OUTLIERS

-- 51221439.280	Velez	2015-07-15

/*
ETL

Podriamos armar un proceso en el cual apenas se ingesta un registro para las tablas de HECHO que detecte por ejemplo en la tabla venta automaticamente los outliers
y los clasifique como tal, este proceso se puede hacer con triggers

*/

-- KPI´s


select year(fecha) año ,month(fecha) mes,round(avg(precio*cantidad),2) ticket_promedio from venta
where fecha between'2015-01-01' and '2018-10-31'
group by 1,2
order by 1 asc,3 desc;

SELECT 	venta.Nombre, 
		venta.SumaVentas, 
        venta.CantidadVentas, 
        venta.SumaVentasOutliers,
        compra.SumaCompras, 
        compra.CantidadCompras,
        ((venta.SumaVentas / compra.SumaCompras - 1) * 100) as margen
FROM
	(SELECT 	p.Nombre,
			SUM(v.Precio * v.Cantidad * v.Outlier) 	as 	SumaVentas,
			SUM(v.Outlier) 							as	CantidadVentas,
			SUM(v.Precio * v.Cantidad) 				as 	SumaVentasOutliers,
			COUNT(*) 								as	CantidadVentasOutliers
	FROM venta v JOIN producto p
		ON (v.IdProducto = p.IdProducto
			AND YEAR(v.Fecha) = 2019)
	GROUP BY p.Nombre) AS venta
JOIN
	(SELECT 	p.Nombre,
			SUM(c.Precio * c.Cantidad) 				as SumaCompras,
			COUNT(*)								as CantidadCompras
	FROM compra c JOIN producto p
		ON (c.IdProducto = p.IdProducto
			AND YEAR(c.Fecha) = 2019)
	GROUP BY p.Nombre) as compra
ON (venta.Nombre = compra.Nombre);

SELECT * FROM producto;

SELECT Nombre_y_apellido, IdCliente, Domicilio FROM cliente ;
select * from venta;

SELECT v.*, c.*
FROM venta v JOIN cliente c ON (v.IdCliente = c.IdCliente);
-- SI YO TUVISESE PLANTEADO LOS INDICES, ESTA QUERY SERIA MAS OPTIMA, OSEA, CONSUMIRIA MENOS RECURSO EN TIEMPO Y MEMORIA DE PROCESAMIENTO.

-- 12 45 78 94 62 
SELECT * FROM cliente
WHERE IdLocalidad = 12 OR IdLocalidad = 45 OR IdLocalidad = 78 OR IdLocalidad = 94 OR IdLocalidad = 62;
-- Esta query no es muy optima


SELECT * FROM cliente
WHERE IdLocalidad IN (12,45,78,94,62);
-- Esto es mas optimo



-- INDICES

-- CREATE INDEX idx_nombre_indice ON nombre_tabla (nombre_columna);
/*
idx_nombre_indice ES EL NOMBRE QUE LE VAMOS A ASIGNAR AL INDICE
nombre_tabla NOMBRE DE LA TABLA A LA CUAL LE CREAREMOS UN INDICE
nombre_columna NOMBRE DE LA COLUMNA EN LA TABLA QUE LE VAMOS A ASIGNAR ESTE INDICE
*/

CREATE UNIQUE INDEX IdVenta ON venta (IdVenta);
DROP INDEX IdVenta ON venta;

SELECT * FROM venta
;

CREATE UNIQUE INDEX IdCliente ON venta (IdCliente);    
-- NO PUEDO CREAR UN INDICE UNICO EN IdCliente de la tabla venta PORQUE LOS CLIENTES COMPRAN MAS DE UNA VEZ
-- ESTO QUIERE DECIR QUE TENGO CLIENTES REPETIDOS

CREATE INDEX IdCliente ON venta (IdCliente); -- ESTABLECEMOS UN Indice

SELECT * FROM venta
WHERE IdCliente = 1032; -- ESTO ES MAS OPTIMO AHORA

select * from cliente;

-- PLANTEAR PRIMARY KEYS
ALTER TABLE cliente ADD PRIMARY KEY(IdCliente);

SELECT * FROM cliente
WHERE IdCliente IN (SELECT DISTINCT IdCliente FROM venta); -- evitar el uso de subqueries en el where

SELECT * FROM cliente c LEFT JOIN venta v ON (v.IdCliente = c.IdCliente) WHERE v.IdVenta IS NULL;
-- utilizar joins en vez de subqueries

DELETE FROM cliente WHERE IdCliente = 22; -- CLIENTES QUE NO HACEN COMPRA ME DEJA ELIMINARLOS PORQUE NO ESTAN PRESENTES EN LA FK
DELETE FROM cliente WHERE IdCliente = 1; -- CLIENTES QUE SI HICIERON COMPRAS NO ME DEJA ELIMINARLOS PORQUE SON FK EN VENTA
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`henry_m3`.`venta`, CONSTRAINT `cliente_fk_venta` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`) ON DELETE RESTRICT ON UPDATE RESTRICT)
UPDATE cliente 
SET Nombre_y_apellido = 'PEPE ARGENTO'
WHERE IdCliente = 1;

-- AÑADIR FOREIGN KEYS
ALTER TABLE venta ADD CONSTRAINT cliente_fk_venta FOREIGN KEY(IdCliente) REFERENCES cliente (IdCliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
-- Error Code: 1822. Failed to add the foreign key constraint. Missing index for constraint 'cliente_fk_venta' in the referenced table 'cliente'


-- ALTER TABLE venta ADD CONSTRAINT sucursal_fk_venta FOREIGN KEY(IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;