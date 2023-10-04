-- CR 5 FT17 M3

USE henry_m3;

SELECT * FROM calendario;

SELECT * FROM venta;
-- No tenemos datos para actualizar esta tabla, pero tenemos el campo Fecha que nos indica cuando se ingreso un registro

SELECT * FROM cliente;
-- Estos datos no estan actualizados, pero tenemos datos de cuando se añadieron, quien los agrego y cuando, y quien, los actualizo

SELECT * FROM compra;
-- No esta actualizado y es incoherente con las fechas de ventas

SELECT * FROM gasto;


-- 2) Datos vacios

SELECT * FROM venta
WHERE (Cantidad = '' OR Cantidad IS NULL) OR 
		(Precio = '' OR Precio IS NULL);
-- df.info()

SELECT * 
FROM cliente
WHERE Telefono IS NULL OR Telefono = '';


SELECT * FROM producto
WHERE Tipo IS NULL;   

-- 3) Si, los datos son provenientes de una empresa que nos contrato y las diferentes tablas fueron sostenidas en el tiempo por distintas areas

-- 4) 

SELECT * FROM producto
WHERE ID_PRODUCTO IS NULL or id_producto= '';  --  ID_PRODUCTO
SELECT * FROM venta;	-- IdProducto
SELECT * FROM compra;	-- IdProducto

ALTER TABLE producto CHANGE ID_PRODUCTO IdProducto INT NOT NULL;
SELECT * FROM producto;
ALTER TABLE producto CHANGE Concepto Nombre VARCHAR(100) ; 

SELECT * FROM cliente;

ALTER TABLE cliente CHANGE ID IdCliente INT NOT NULL;

SELECT * FROM sucursal;

ALTER TABLE sucursal CHANGE ID IdSucursal INT NOT NULL;

SELECT * FROM empleado;

ALTER TABLE empleado CHANGE ID_empleado IdEmpleado INT NOT NULL;

SELECT * FROM proveedor;

SELECT * FROM tipo_gasto;

-- 5) Tablas de Hechos: Compra, gasto y venta
-- Tablas de dimension: Todas las demas tablas, menos compra gasto y venta, son tablas de dimensiones, contienen datos descriptivos

SELECT COUNT(IdEmpleado), IdEmpleado
FROM empleado
GROUP BY IdEmpleado
ORDER BY 1 DESC; -- La unica tabla con valores duplicados en su Id

SELECT COUNT(IdVenta), IdVenta
FROM venta
GROUP BY 2
ORDER BY 1 DESC;

SELECT COUNT(IdSucursal), IdSucursal
FROM sucursal
GROUP BY 2
ORDER BY 1 DESC;

SELECT COUNT(IdCliente), IdCliente
FROM cliente
GROUP BY 2
ORDER BY 1 DESC;


-- 8)
SELECT * FROM calendario;

CALL Llenar_dimension_calendario('2015-01-01',CURDATE());

-- 6)

SELECT * FROM cliente;
-- col10 DROP; X e Y cambiar por Longitud y Latitud
SELECT * FROM cliente
WHERE x = '' OR y = '';

ALTER TABLE cliente ADD Longitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Y,
					ADD Latitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Longitud;

SELECT * FROM cliente;

UPDATE cliente SET Y = 0 WHERE Y = ''; -- 60 Registros vacios
UPDATE cliente SET X = 0 WHERE X = '';-- 62 Registros vacios

UPDATE cliente SET Longitud = REPLACE(X,',','.');
UPDATE cliente SET Latitud = REPLACE(Y,',','.');

ALTER TABLE cliente DROP X, DROP Y, DROP COL10;

SELECT * FROM sucursal;

ALTER TABLE sucursal ADD Latitud2 DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Longitud,
					ADD Longitud2 DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Latitud2;

UPDATE sucursal SET Longitud2 = REPLACE(Longitud,',','.');
UPDATE sucursal SET Latitud2 = REPLACE(Latitud,',','.');

SELECT * FROM sucursal;

ALTER TABLE sucursal DROP Longitud, DROP latitud; -- Eliminamos las columnas viejas que ya no nos sirven
ALTER TABLE sucursal CHANGE Longitud2 Longitud DECIMAL(13,10); -- Actualizamos el nombre de las columnas nuevas normalizadas
ALTER TABLE sucursal CHANGE Latitud2 Latitud DECIMAL(13,10);

SELECT * FROM sucursal;

SELECT * FROM empleado;
SELECT * FROM producto;

SELECT * FROM venta;

SELECT * FROM venta
WHERE Precio = '';

UPDATE venta SET Precio = 0 WHERE Precio = '';   -- Ponemos los precios vacios en 0 para poder cambiar el tipo de dato de string a float

ALTER TABLE venta CHANGE Precio Precio DECIMAL(15,3) NOT NULL DEFAULT 0 ; -- Cambiamos el tipo de dato de Precio en venta



-- 7)

SELECT * FROM cliente
WHERE Domicilio = '' OR Domicilio IS NULL OR Localidad = '' OR Localidad IS NULL;

UPDATE cliente SET Domicilio = 'N/D' WHERE Domicilio = '' OR ISNULL(Domicilio);
UPDATE cliente SET Provincia = 'N/D' WHERE Provincia = '' OR ISNULL(Provincia);
UPDATE cliente SET Localidad = 'N/D' WHERE Localidad = '' OR ISNULL(Localidad);
UPDATE cliente SET Nombre_y_apellido = 'N/D' WHERE Nombre_y_apellido = '' OR ISNULL(Nombre_y_apellido);
UPDATE cliente SET Telefono = 'N/D' WHERE Telefono = '' OR ISNULL(Telefono);

SELECT * FROM cliente;

SELECT * FROM empleado;   -- Apellido Nombre Sucursal Sector

UPDATE empleado SET Apellido = 'N/D' WHERE Apellido = '' OR ISNULL(Apellido);
UPDATE empleado SET Nombre = 'N/D' WHERE Nombre = '' OR ISNULL(Nombre);
UPDATE empleado SET Sucursal = 'N/D' WHERE Sucursal = '' OR ISNULL(Sucursal);
UPDATE empleado SET Sector = 'N/D' WHERE Sector = '' OR ISNULL(Sector);

SELECT * FROM proveedor; -- Nombre Domicilio Ciudad Provincia Pais Departamente

UPDATE proveedor SET Nombre = 'N/D' WHERE Nombre = '' OR ISNULL(Nombre);
UPDATE proveedor SET Domicilio = 'N/D' WHERE Domicilio = '' OR ISNULL(Domicilio);
UPDATE proveedor SET Ciudad = 'N/D' WHERE Ciudad = '' OR ISNULL(Ciudad);
UPDATE proveedor SET Provincia = 'N/D' WHERE Provincia = '' OR ISNULL(Provincia);
UPDATE proveedor SET Pais = 'N/D' WHERE Pais = '' OR ISNULL(Pais);
UPDATE proveedor SET Departamento = 'N/D' WHERE Departamento = '' OR ISNULL(Departamento);

SELECT * FROM sucursal; -- Sucursa Direccion Localidad Provincia

UPDATE Sucursal SET Sucursal = 'N/D' WHERE Sucursal = '' OR ISNULL(Sucursal);
UPDATE Sucursal SET Direccion = 'N/D' WHERE Direccion = '' OR ISNULL(Direccion);
UPDATE Sucursal SET Localidad = 'N/D' WHERE Localidad = '' OR ISNULL(Localidad);
UPDATE Sucursal SET Provincia= 'N/D' WHERE Provincia = '' OR ISNULL(Provincia);

-- 8)

UPDATE Sucursal SET Direccion = UC_WORDS(TRIM(Direccion)),
					Localidad = UC_WORDS(TRIM(Localidad));

SELECT * FROM sucursal;

SELECT * FROM cliente;

UPDATE cliente SET Nombre_y_apellido = UC_WORDS(Nombre_y_apellido),
					Domicilio = UC_WORDS(Domicilio),
                    Localidad = UC_WORDS(Localidad);
                    
SELECT * FROM proveedor;

UPDATE proveedor SET Domicilio = UC_WORDS(Domicilio),
						Ciudad = UC_WORDS(Ciudad),
                        Provincia = UC_WORDS(Provincia),
                        Pais = UC_WORDS(Pais),
                        Departamento = UC_WORDS(Departamento);
                        
SELECT * FROM empleado;
SELECT * FROM producto;

UPDATE producto SET Nombre = UC_WORDS(Nombre),
					Tipo = UC_WORDS(Tipo);
                    
SELECT * FROM canal_venta;
SELECT * FROM tipo_gasto;

-- 9)

CREATE TABLE IF NOT EXISTS `aux_venta` (
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCliente`			INTEGER, 
  `IdSucursal`			INTEGER,
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				FLOAT,
  `Cantidad`			INTEGER,
  `Motivo`				INTEGER  		-- El campo motivo nos va a servir para identificar las ventas que tengas problemas
);

SELECT * FROM venta;

UPDATE venta v JOIN producto p 
		ON (v.IdProducto = p.IdProducto)
SET v.Precio = p.Precio
WHERE v.Precio = 0;

SELECT * FROM venta
WHERE precio = 0;

SELECT * FROM venta
WHERE Cantidad = '';


INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1
FROM venta WHERE Cantidad = '' OR Cantidad IS NULL;

SELECT * FROM aux_venta;

UPDATE venta SET Cantidad = 1 WHERE Cantidad = '' OR ISNULL(Cantidad); -- Aca modificamos los datos vacios en cantidad

ALTER TABLE venta CHANGE Cantidad Cantidad INT NOT NULL DEFAULT 1;

select * from venta
where cantidad = 1;

-- 10)
SELECT COUNT(IdEmpleado), IdEmpleado
FROM empleado
GROUP BY IdEmpleado
ORDER BY 1 DESC;

SELECT * FROM venta;

SELECT * FROM empleado;

SELECT DISTINCT sucursal FROM empleado
WHERE sucursal NOT IN (SELECT sucursal FROM sucursal); -- Mendoza 1 Mendoza 2

SELECT * FROM sucursal;

UPDATE empleado SET Sucursal = 'Mendoza1' WHERE Sucursal = 'Mendoza 1';
UPDATE empleado SET Sucursal = 'Mendoza2' WHERE Sucursal = 'Mendoza 2';

ALTER TABLE empleado ADD IdSucursal INT NOT NULL DEFAULT 0 AFTER Sucursal;

UPDATE empleado e JOIN sucursal s
				ON (s.Sucursal = e.Sucursal)
SET e.IdSucursal = s.IdSucursal;

SELECT * FROM empleado;

ALTER TABLE empleado DROP sucursal;

ALTER TABLE empleado ADD IdEmpleado2 INT NOT NULL DEFAULT 0 AFTER IdEmpleado;

UPDATE empleado SET IdEmpleado2 = IdEmpleado;

SELECT * FROM empleado;

UPDATE empleado SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado2;

SELECT COUNT(IdEmpleado), IdEmpleado
FROM empleado
GROUP BY IdEmpleado
ORDER BY 1 DESC;

SELECT * FROM venta
WHERE IdEmpleado = '' OR IdEmpleado IS NULL;

SELECT * FROM venta
WHERE IdSucursal = '' OR IdSucursal IS NULL;

UPDATE venta SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado;

SELECT * FROM venta;


-- 10) Normalizacion

SELECT * FROM empleado;

CREATE TABLE IF NOT EXISTS Sector (
	IdSector INT NOT NULL AUTO_INCREMENT,
    Sector VARCHAR(30),
    PRIMARY KEY(IdSector)

);

SELECT * FROM sector;

INSERT INTO sector (Sector) 
SELECT DISTINCT Sector FROM empleado ORDER BY 1;

ALTER TABLE empleado ADD IdSector INT NOT NULL DEFAULT 0 AFTER Sector;

SELECT * FROM empleado;

UPDATE empleado e JOIN sector s 
					ON (e.Sector = s.Sector)
SET e.IdSector = s.IdSector
WHERE e.IdSector = 0;

ALTER TABLE empleado DROP Sector;

-- 11) Producto

SELECT * FROM producto;

CREATE TABLE IF NOT EXISTS tipo_producto (
	IdTipoProducto INT NOT NULL AUTO_INCREMENT,
    Tipo_Producto VARCHAR(30),
    PRIMARY KEY(IdTipoProducto)
    
);

SELECT * FROM tipo_producto;

SELECT * FROM producto
WHERE Tipo = '' OR Tipo IS NULL;

UPDATE Producto SET Tipo = 'N/D' WHERE Tipo ='' OR ISNULL(Tipo);

INSERT INTO tipo_producto (Tipo_Producto)
SELECT DISTINCT Tipo FROM producto ORDER BY 1;

ALTER TABLE producto ADD IdTipoProducto INT NOT NULL DEFAULT 0 AFTER Tipo;

SELECT * FROM producto;

UPDATE producto p JOIN tipo_producto tp
				ON (tp.Tipo_Producto = p.Tipo)
SET p.IdTipoProducto = tp.IdTipoProducto;

ALTER TABLE producto DROP Tipo;


SELECT * FROM calendario;
-- Fechas en venta, en compra, en gastos, en cliente

SELECT * FROM sucursal; -- Localidad Provincia Latitud Longitud
SELECT * FROM cliente; -- Provincia Domicilio Localidad Latitud Longitud
SELECT * FROM proveedor; -- Domicilio Ciudad Provincia Pais Deparatamento

SELECT * FROM venta; -- Combinar la tabla producto con los precios
SELECT * FROM producto
WHERE IdProducto = 42937;   -- $4560000.000

SELECT * FROM producto
WHERE IdProducto = 42988; -- 30 * 598 = 17mil aprox

SELECT AVG(Precio*Cantidad), IdProducto
FROM venta    -- NO ESTAMOS TENIENDO EN CUENTA LOS OUTLIERS
GROUP BY 2
ORDER BY 1; -- 477035.2049689	42937

SELECT * FROM venta WHERE IdProducto = 42937; -- EN ESTE PRODUCTO TENEMOS OUTLIERS REPETIDOS

SELECT DISTINCT Localidad, Provincia
FROM cliente
ORDER BY 1;

-- Buenos Aires -> bs. as; Provincia de Buenos Aires; Buenos As

SELECT * FROM cliente;
-- Rango Etario 18 a 34      35 a 44      45 a 54       55 a 64     65 o mas


SELECT * FROM venta;

ALTER TABLE venta ADD Outlier TINYINT NOT NULL DEFAULT 0;

SELECT AVG(Precio*Cantidad)
FROM venta
WHERE Outlier = 0 ;
