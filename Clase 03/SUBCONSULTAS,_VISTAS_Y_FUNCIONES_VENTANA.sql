USE henry;
-- LECTURE

-- subquerie
SELECT * FROM alumno;
SELECT MIN(FechaIngreso)
FROM alumno;
-- Que alumno ingreso primero en Henry?

SELECT IdAlumno,Nombre, Apellido, FechaIngreso
FROM alumno
ORDER BY 4
LIMIT 2;
/*
UPDATE alumno
SET FechaIngreso = '2019-12-04'
WHERE IdAlumno = 181;
*/

-- te va traer todos los que ingresaron primero
SELECT Nombre, Apellido, FechaIngreso
FROM alumno
WHERE FechaIngreso = (SELECT MIN(FechaIngreso) FROM alumno);


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

-- VISTAS "Tablas virtuales" - "No se puede hacer insert ni Update" "Se pueden hacer CREATE Y DROP"
-- Los alumnos mayores al promedio de edad
-- CREATE VIEW nombre_vista AS Consulta
-- AVG "Para sacar el promedio"
SELECT AVG(FechaNacimiento)FROM alumno;
SELECT AVG(TIMESTAMPDIFF(YEAR,FechaNacimiento,CURDATE()))FROM alumno;

CREATE VIEW alumnos_mayor_promedio AS
	SELECT Nombre, Apellido, TIMESTAMPDIFF(YEAR, FechaNacimiento,CURDATE()) AS EDAD
    FROM alumno
    WHERE TIMESTAMPDIFF(YEAR,FechaNacimiento,CURDATE()) > (SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento,CURDATE()))FROM alumno)
    ORDER BY 3 DESC;
-- Seleccionamos lo que hay en la vista    
SELECT * FROM alumnos_mayor_promedio;

-- MODIFICAR UNA VISTA
ALTER VIEW alumnos_mayor_promedio AS
	SELECT Nombre, Apellido, TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE()) AS Edad
    FROM alumno
    WHERE TIMESTAMPDIFF(YEAR,FechaNacimiento, CURDATE()) < (SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE())) FROM alumno)
    ORDER BY 3 DESC;
SELECT * FROM alumnos_mayor_promedio;

-- Eliminar una vista
DROP VIEW alumnos_mayor_promedio;

-- SELECT * FROM prueba;


-- FUNCIONES VENTANA

USE checkpoint_m2;

-- Promedio de ventas por fecha " Las Funciones Ventana , Utilies para el analisis de datos, y para generar informes, ejemplo: se calcula el promedio acumulado", "Generan un margen"
SELECT * FROM venta;

SELECT Fecha, AVG(Precio*Cantidad) as Promedio_ventas
FROM venta
GROUP BY Fecha;

-- Unimos el promedio de ventas por fecha con las ventas por cada fecha

SELECT Precio * cantidad, Fecha
FROM venta;

SELECT v.Fecha, v.Precio * v.Cantidad as Venta, v2.Promedio_ventas
FROM venta v JOIN (SELECT Fecha, AVG(precio*cantidad) as Promedio_ventas 
					FROM venta
                    GROUP BY Fecha) v2
ON (v.Fecha = v2.Fecha)
ORDER BY v.Fecha;

-- Aplicamos funcion ventana

SELECT Fecha, Precio * Cantidad as Venta,
AVG(precio*cantidad)  OVER (PARTITION BY Fecha) as Promedio_ventas -- Para cada una de las fechas existentes va a haber un calculo de AVG(Precio*Cantidad)
FROM venta;

SELECT Fecha, Precio * Cantidad as Venta,IdVenta,
		(precio*cantidad) / SUM(precio*cantidad)   OVER (PARTITION BY Fecha ORDER BY Fecha) as Promedio_ventas -- Para cada una de las fechas existentes va a haber un calculo
FROM venta;
SELECT AVG(Precio * cantidad)
FROM venta;

SELECT AVG(Precio * cantidad) as Promedio, Fecha
FROM venta
GROUP BY Fecha;

-- ROW_NUMBER(), RANK(), DENSE_RANK(), FIRST_VALUE()

SELECT fecha, precio * cantidad,
		AVG(Precio * cantidad) OVER (PARTITION BY Fecha ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as Acumulado
FROM venta ;

SELECT fecha, precio * cantidad,
		SUM(Precio * cantidad) OVER (PARTITION BY Fecha ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as Acumulado
FROM venta ;

-- FUNCION VENTANA RANK()
SELECT RANK() OVER (PARTITION BY Fecha ORDER BY precio * cantidad DESC) AS Ranking_venta,
		Fecha, IdCliente, Precio, Cantidad, precio * cantidad as Venta, IdProducto
FROM venta;

-- FUNCION VENTA DENSE_RANK()
SELECT  DENSE_RANK() OVER (PARTITION BY Fecha ORDER BY precio * cantidad DESC) AS Ranking_venta,
		Fecha, IdCliente, Precio, Cantidad, precio * cantidad as Venta, IdProducto
FROM venta;

/* ///////////////////////////-----------------HOMWORK-------------------------///////////////////////////////////*/
-- CR 3 FT 17 M3

USE adventureworks;

-- 1)Obtener un listado de cuál fue el volumen de ventas (cantidad) por año y método de envío 
-- mostrando para cada registro, qué porcentaje representa del total del año.
-- SUBQUERIE

SELECT * FROM salesorderheader;  -- OrderDate SalesOrderID  ShipMethodID
SELECT * FROM salesorderdetail;  -- SalesOrderID OrderQty
SELECT * FROM shipmethod;		-- ShipMethodID Name

SELECT YEAR(h.OrderDate) AS Año, s.Name as MetodoEnvio, 
SUM(d.OrderQty) AS Volumen_Compra,
ROUND(SUM(d.OrderQty) / t.CantidadTotalAño * 100, 2) AS PorcentajeTotalAño,
t.CantidadTotalAño
                            FROM salesorderdetail d JOIN salesorderheader h
							ON (h.SalesOrderID = d.SalesOrderID)
						JOIN shipmethod s 
							ON (h.ShipMethodID = s.ShipMethodID)
						JOIN ( SELECT SUM(d.OrderQty) AS CantidadTotalAño, YEAR(h.OrderDate) as Año
							  FROM salesorderheader h JOIN salesorderdetail d
															ON (h.SalesOrderID = d.SalesOrderID)
							   GROUP BY 2 ) t
                               ON (YEAR(h.OrderDate) = t.Año)
GROUP BY 1, 2;



-- 1.56
/*
SET @@sql_mode = SYS.LIST_DROP(@@sql_mode, 'ONLY_FULL_GROUP_BY');
*/

/*
SELECT SUM(d.OrderQty) AS CantidadTotalAño, YEAR(h.OrderDate) as Año
FROM salesorderheader h JOIN salesorderdetail d
							ON (h.SalesOrderID = d.SalesOrderID)
GROUP BY 2;
*/

-- FUNCION VENTANA

SELECT YEAR(h.OrderDate) as Año, s.Name as MetodoEnvio, SUM(d.OrderQty) as VolumenCompra,
		d.OrderQty / SUM(d.OrderQty) OVER (PARTITION BY YEAR(h.OrderDate) ORDER BY YEAR(h.OrderDate)) as PorcentajeTotalAño
    
FROM salesorderheader h JOIN salesorderdetail d
							ON (d.SalesOrderID = h.SalesOrderID)
						JOIN shipmethod s
							ON (s.ShipMethodID = h.ShipMethodID)
GROUP BY 1, 2
ORDER BY 1, 2;

SELECT DISTINCT YEAR(b.OrderDate) AS Año,
		c.name Metodo_Envio,
		a.SalesOrderID,
        a.Volumen_Venta,
    PERCENT_RANK() OVER (PARTITION BY YEAR(b.OrderDate) ORDER BY a.Volumen_Venta) AS porcentaje
FROM (SELECT SalesOrderID,
		     SUM(OrderQty) AS Volumen_Venta
        FROM SalesOrderDetail 
        GROUP BY SalesOrderID
     ) AS a
INNER JOIN SalesOrderHeader b ON a.SalesOrderID = b.SalesOrderID    
INNER JOIN ShipMethod c ON c.ShipMethodID = b.ShipMethodID
ORDER BY a.SalesOrderID
;

SELECT Año, MetodoEnvio, Cantidad,
		Cantidad / SUM(Cantidad) OVER (PARTITION BY Año ) as PorcentajeTotalAño
FROM (SELECT YEAR(h.OrderDate) as Año, s.Name as MetodoEnvio, SUM(d.OrderQty) as Cantidad
		FROM salesorderheader h JOIN salesorderdetail d
							ON (d.SalesOrderID = h.SalesOrderID)
						JOIN shipmethod s
							ON (s.ShipMethodID = h.ShipMethodID)
		GROUP BY 1, 2) AS V;
-- 0.656
	
/*2. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos, mostrando para ambos, 
su porcentaje respecto del total.<br>*/
SELECT * FROM salesorderdetail;     --  ProductID - Ventas = OrderQty * UnitPrice
SELECT * FROM product; 				-- Product ID, ProductSubcategoryID
SELECT * FROM productsubcategory;   -- ProductSubcategoryID
SELECT * FROM productcategory;      -- ProductCategoryID

SELECT Categoria, 
Cantidad, 
Cantidad / SUM(Cantidad) OVER() AS Porcentaje_Cantidad,
Total_Ventas,
Total_Ventas / SUM(Total_Ventas) OVER() AS Porcentaje_Total_Ventas
FROM (SELECT sc.Name as Categoria, SUM(d.OrderQty) AS Cantidad, SUM(d.OrderQty * d.UnitPrice) as Total_Ventas
FROM salesorderdetail d JOIN product p
							ON(d.ProductID = p.ProductID)
						JOIN productsubcategory sb
							ON(sb.ProductSubcategoryID = p.ProductSubcategoryID)
						JOIN productcategory sc
							ON(sc.ProductCategoryID = sb.ProductCategoryID)
GROUP BY 1
ORDER BY 1) v
;

-- 3)Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, 
-- mostrando para ambos, su porcentaje respecto del total.

SELECT * FROM salesorderdetail; -- SalesOrderID -- VENTA = OrderQty * UnitPrice
SELECT * FROM salesorderheader; -- SalesOrderID --"ShipToAddressID"
SELECT * FROM address; -- AddressID -- StateProvinceID
SELECT * FROM stateprovince; -- StateProvinceID -- CountryRegionCode
SELECT * FROM countryregion; --  CountryRegionCode -- Name

SELECT Pais, Cantidad,
		ROUND(Cantidad / SUM(Cantidad) OVER ()*100,2) AS PorcentajeCantidad,
			Total_Ventas,
        ROUND(Total_Ventas / SUM(Total_Ventas) OVER() *100,2) AS PorcentajeTotalVentas
FROM(SELECT c.Name as Pais, SUM(d.OrderQty) AS Cantidad, SUM(d.OrderQty * d.UnitPrice) as Total_Ventas
FROM salesorderdetail d JOIN salesorderheader h
							ON(d.SalesOrderID = h.SalesOrderID)
						JOIN  address a
							ON(h.ShipToAddressID = a.AddressID)
						JOIN stateprovince s
							ON(a.StateProvinceID = s.StateProvinceID)
						JOIN countryregion c
							ON(s.CountryRegionCode = c.CountryRegionCode)
GROUP BY 1
ORDER BY 1) V
;	
-- 4) FLOOR CEILING

-- Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), sobre las ordenes realizadas

SELECT ProductID, Cant, AVG(LineTotal) AS Mediana_Producto
FROM (
SELECT ProductID, LineTotal, 
		COUNT(*) OVER (PARTITION BY ProductID) as Cant,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY LineTotal) AS RowNum
FROM salesorderdetail ) v
WHERE ( FLOOR(Cant/2) = CEILING(Cant/2) AND (RowNum = FLOOR(Cant/2) OR RowNum = FLOOR(Cant/2)+1)
	OR
    (FLOOR(Cant/2) <> CEILING(Cant/2) AND RowNum = CEILING(Cant/2))
)
GROUP BY ProductID
;


-- LECTURE

CREATE DATABASE henry_m3;

USE henry_m3;

/* INGESTAR DATOS DESDE UN .CSV A UNA TABLA EXISTENTE
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\nombre_archivo.csv'
INTO TABLE nombre_tabla
*/
SELECT @@global.secure_file_priv;


SELECT * FROM tiposdegasto;
