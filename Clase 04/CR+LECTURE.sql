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



SELECT Año, MetodoEnvio, Cantidad,
		Cantidad / SUM(Cantidad) OVER (PARTITION BY Año ) as PorcentajeTotalAño
FROM (SELECT YEAR(h.OrderDate) as Año, s.Name as MetodoEnvio, SUM(d.OrderQty) as Cantidad
		FROM salesorderheader h JOIN salesorderdetail d
							ON (d.SalesOrderID = h.SalesOrderID)
						JOIN shipmethod s
							ON (s.ShipMethodID = h.ShipMethodID)
		GROUP BY 1, 2) AS V;
-- 0.656
        

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


-- 2) Obtener un listado por categoría de productos, 
-- con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total

SELECT * FROM product; -- ProductID ProductSubcategoryID
SELECT * FROM productsubcategory; -- ProductSubcategoryID ProductCategoryID
SELECT * FROM productcategory;  -- ProductCategoryID
SELECT * FROM salesorderdetail;   -- ProductID OrderQty Venta = OrderQty * UnitPrice


SELECT v.Categoria, v.Cantidad,
		ROUND(v.Cantidad / SUM(v.Cantidad) OVER ()*100,2) AS PorcentajeCantidad,
        v.TotalVentas,
        ROUND(v.TotalVentas / SUM(v.TotalVentas) OVER() *100,2) AS PorcentajeTotalVentas

FROM (SELECT c.Name as Categoria, SUM(d.OrderQty) AS Cantidad, 
		SUM(d.OrderQty * d.UnitPrice) AS TotalVentas
FROM salesorderdetail d JOIN product p
							ON (p.ProductID = d.ProductID)
						JOIN productsubcategory ps
							ON (p.ProductSubcategoryID =ps.ProductSubcategoryID) 
						JOIN productcategory c
							ON (c.ProductCategoryID = ps.ProductCategoryID)
GROUP BY 1
ORDER BY 1) AS v
; -- Error Code: 1248. Every derived table must have its own alias



-- 3)Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, 
-- mostrando para ambos, su porcentaje respecto del total.

SELECT * FROM salesorderheader; -- SalesOrderID ShipToAddressID
SELECT * FROM salesorderdetail; -- SalesOrderID OrderQty  Venta = OrderQty * UnitPrice
SELECT * FROM address;          -- AddressID StateProvinceID
SELECT * FROM stateprovince;	-- StateProvinceID CountryRegionCode
SELECT * FROM countryregion;	-- CountryRegionCode Name

SELECT Pais, Cantidad, 
			ROUND(Cantidad / SUM(Cantidad) OVER ()*100,2) AS PorcentajeCantidad,
			TotalVentas,
            ROUND(TotalVentas / SUM(TotalVentas) OVER()*100,2) AS PorcentajeTotalVentas
FROM (
SELECT cr.Name as Pais, SUM(d.OrderQty) as Cantidad, SUM(d.OrderQty * d.UnitPrice) as TotalVentas
FROM salesorderdetail d JOIN salesorderheader h
							ON (d.SalesOrderID = h.SalesOrderID) 
						JOIN address a 
							ON (a.AddressID = h.ShipToAddressID) 
						JOIN stateprovince sp
							ON (a.StateProvinceID = sp.StateProvinceID) 
						 JOIN countryregion cr
							ON (cr.CountryRegionCode = sp.CountryRegionCode)
GROUP BY 1
ORDER BY 1) v
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
