-- CR 4 FT17 M3

DROP DATABASE henry_m3;

CREATE DATABASE IF NOT EXISTS henry_m3;

USE henry_m3;

SELECT @@global.secure_file_priv;


CREATE TABLE IF NOT EXISTS gasto (
	IdGasto INT NOT NULL, 
    IdSucursal INT NOT NULL,
    IdTipoGasto INT NOT NULL,
    Fecha DATE ,
    Monto DECIMAL(10,2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Gasto.csv'			-- doble barra en la ruta \\
INTO TABLE gasto
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n' IGNORE 1 LINES
(IdGasto, IdSucursal, IdTipoGasto, Fecha, Monto);
-- Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
SET GLOBAL local_infile = 1;
SELECT @@global.local_infile;

SELECT * FROM gasto;

CREATE TABLE IF NOT EXISTS compra (
	IdCompra INT NOT NULL,
    Fecha DATE,
    IdProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    Precio DECIMAL(10,2),
    IdProveedor INT NOT NULL

);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Compra.csv'
INTO TABLE compra
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n' IGNORE 1 LINES
(IdCompra, Fecha, IdProducto, Cantidad, Precio, IdProveedor);

SELECT * FROM compra;

DROP TABLE IF EXISTS venta;

CREATE TABLE IF NOT EXISTS venta (
	IdVenta INT NOT NULL,
    Fecha DATE ,
    Fecha_Entrega DATE,
    IdCanal INT NOT NULL,
    IdCliente INT NOT NULL,
    IdSucursal INT NOT NULL,
    IdEmpleado INT NOT NULL,
    IdProducto INT NOT NULL,
	Precio VARCHAR(30),
    Cantidad VARCHAR(30)
--    Precio DECIMAL(10,2),
--  Cantidad INT
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Venta.csv'
INTO TABLE venta
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente,IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad);

select * from venta
WHERE Precio = '';


CREATE TABLE IF NOT EXISTS sucursal (
	ID INT NOT NULL,
    Sucursal VARCHAR(40),
    Direccion VARCHAR(150),
    Localidad VARCHAR(80),
    Provincia VARCHAR(80),
    Latitud VARCHAR(30),
    Longitud VARCHAR(30)
);

select * from sucursal;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Sucursales.csv'
INTO TABLE sucursal
-- CHARACTER SET latin1    ESTO RECONOCE LA CODIFICACION 
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
;


CREATE TABLE IF NOT EXISTS tipo_gasto (
	IdTipoGasto INT NOT NULL,
    Descripcion VARCHAR(80),
    Monto_Aproximado DECIMAL(10,2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TiposDeGasto.csv'
INTO TABLE tipo_gasto
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n' IGNORE 1 LINES
;

SELECT * FROM tipo_gasto;

CREATE TABLE IF NOT EXISTS cliente (
	ID INT NOT NULL,
    Provincia VARCHAR(80),
    Nombre_y_apellido VARCHAR(100),		-- object, string, text
    Domicilio VARCHAR(150),
    Telefono VARCHAR(30),
    Edad INT,
    Localidad VARCHAR(80),
    X VARCHAR(30),
    Y VARCHAR(30),
    Fecha_Alta DATE,
    Usuario_Alta VARCHAR(30),
    Fecha_Ultima_Modificacion DATE,
    Usuario_Ultima_Modificacion VARCHAR(30),
    Marca_Baja TINYINT,
    col10 VARCHAR(2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Clientes.csv'
INTO TABLE cliente
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM cliente;
TRUNCATE TABLE cliente;


CREATE TABLE IF NOT EXISTS canal_venta (
	IdCanal INT,
    Canal VARCHAR(50)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CanalDeVenta.csv'
INTO TABLE canal_venta
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM canal_venta;
SELECT * FROM producto;

CREATE TABLE IF NOT EXISTS proveedor (
	IdProveedor INT,
    Nombre VARCHAR(100),
    Domicilio VARCHAR(150),
    Ciudad VARCHAR(80),
    Provincia VARCHAR(80),
    Pais VARCHAR(80),
    Departamento VARCHAR(80)

);
SELECT * FROM proveedor;

CREATE TABLE IF NOT EXISTS empleado (
	ID_empleado INT,
    Apellido VARCHAR(50),
    Nombre VARCHAR(50),
    Sucursal VARCHAR(80),
    Sector VARCHAR(50),
    Cargo VARCHAR(50),
    Salario DECIMAL(10,2)
);

SELECT * FROM empleado;

-- LECTURE

SELECT COUNT(Id_Empleado), Id_Empleado
FROM empleado
GROUP BY Id_Empleado; -- 1968 1674

SELECT *
 FROM empleado
 WHERE Id_Empleado IN (1968,1674);
 
 select * from sucursal;
 
 SELECT * FROM venta;		-- TABLA DE HECHOS
 SELECT * FROM producto;    -- TABLA DE DIMENSIONES
 
 SELECT * FROM cliente;
 USE henry_m3;
 
 -- 10 PT1 
CREATE TABLE IF NOT EXISTS cargo (
	IdCargo INT NOT NULL AUTO_INCREMENT,
    Cargo VARCHAR(50),
    PRIMARY KEY(IdCargo)
);

INSERT INTO cargo (Cargo)
SELECT DISTINCT cargo FROM empleado
ORDER BY Cargo;

SELECT * FROM cargo;

ALTER TABLE empleado ADD IdCargo INT DEFAULT 0 AFTER Cargo;

SELECT * FROM empleado;

UPDATE empleado e JOIN cargo g
						ON (g.Cargo = e.Cargo)
SET e.IdCargo = g.IdCargo;

ALTER TABLE empleado DROP Cargo;
-- 
SELECT * FROM venta;