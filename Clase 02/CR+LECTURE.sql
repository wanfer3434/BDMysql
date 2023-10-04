-- CR 2 FT 17 M3 

 USE adventureworks;
 
 -- 1) Obtener un listado contactos que hayan ordenado productos 
 -- de la subcategoría "Mountain Bikes", entre los años 2000 y 2003, cuyo método de envío sea "CARGO TRANSPORT 5".
 
 SELECT * FROM salesorderdetail; -- ProductID Foreign Key
 SELECT * FROM s.alesorderheader; -- ContactId Foreign Key ShipMethodId Foreign Key
 SELECT * FROM product; -- ProductSubcategoryId Foreign Key
 SELECT * FROM productsubcategory; -- Aca tenemos la subcategoria Mountain Bikes
 SELECT * FROM shipmethod; -- Aca tenemos el metodo de envio CARGO TRANSPORT 5 
 SELECT * FROM contact;
 
 SELECT DISTINCT CONCAT(c.Title,c.FirstName,' ',c.LastName) as Nombre, c.EmailAddress, c.Phone
 FROM salesorderheader h INNER JOIN salesorderdetail d
					ON (h.SalesOrderID = d.SalesOrderID)
						  JOIN product p
					ON (p.ProductId = d.ProductId)
						  JOIN productsubcategory ps
					ON (p.ProductSubcategoryID = ps.ProductSubcategoryID)
						  JOIN shipmethod s
					ON (s.ShipMethodID = h.ShipMethodID)
						JOIN contact c
					ON (h.ContactID = c.ContactID)
WHERE YEAR(h.OrderDate) BETWEEN 2000 AND 2003
AND ps.Name = 'Mountain Bikes'
AND s.Name = 'CARGO TRANSPORT 5'
;

-- 2) Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", entre los años 2000 y 2003
--  con la cantidad de productos adquiridos y ordenado por este valor, de forma descendente.

SELECT * FROM salesorderheader; -- ContactID  SalesOrderID OrderDate
SELECT * FROM salesorderdetail; -- SalesOrderID ProductID OrderQty
SELECT * FROM product; -- ProductID ProductSubcategoryID
SELECT * FROM productsubcategory; -- ProductSubcategoryID Name = 'Mountain Bikes'
SELECT * FROM contact;  -- Nombre Apellido Email Phone

SELECT CONCAT(c.Title,c.FirstName,' ',c.LastName) as Nombre, SUM(d.OrderQty) as Cantidad, SUM(h.TotalDue) as Ventas
FROM salesorderheader h JOIN salesorderdetail d
							ON (h.SalesOrderId = d.SalesOrderId)
						JOIN product p
							ON (p.ProductID = d.ProductID)
						JOIN productsubcategory ps
							ON (p.ProductSubcategoryID = ps.ProductSubcategoryID)
						JOIN contact c
							ON (c.ContactID = h.ContactId)
WHERE YEAR(h.OrderDate) BETWEEN 2000 AND 2003
AND ps.Name = 'Mountain Bikes'
GROUP BY 1
ORDER BY 2 DESC
;

-- 3) Obtener un listado de cual fue el volumen de compra (cantidad) por año y método de envío.

-- VENTA = PRECIO * CANTIDAD
-- CANTIDADES, VOLUMEN DE COMPRA = SUM(CANTIDAD)

SELECT * FROM salesorderdetail; -- OrderQty SalesOrderID
SELECT * FROM salesorderheader; -- SalesOrderId OrderDate ShipMethodId
SELECT * FROM shipmethod;     -- ShipMethodId Name

SELECT YEAR(h.OrderDate) Año, s.Name Metodo_Envio, SUM(d.OrderQty) Volumen_Compra
FROM salesorderheader h JOIN salesorderdetail d
							ON (h.SalesOrderID = d.SalesOrderID)
						RIGHT JOIN shipmethod s 
							ON (s.ShipMethodID = h.ShipMethodID)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 4) Obtener un listado por categoría de productos, con el valor total de ventas y cantidad de productos vendidos.

SELECT * FROM salesorderdetail; -- SalesOrderID OrderQty LineTotal o UnitPrice
SELECT * FROM product; -- ProductID ProductSubcategoryID
SELECT * FROM productcategory; -- ProductCategoryID
SELECT * FROM productsubcategory; -- ProductSubcategoryID ProductCategoryID

SELECT pc.Name Nombre, SUM(d.OrderQty) Cantidad, SUM(d.LineTotal) Total_Ventas, (SUM(d.LineTotal)  / (SELECT SUM(LineTotal) FROM salesorderdetail) * 100) Porcentaje -- SUM(d.OrderQty * d.UnitPrice)
FROM salesorderdetail d JOIN product p
							ON (d.ProductID = p.ProductID)
						JOIN productsubcategory ps
							ON (p.ProductSubcategoryID = ps.ProductSubcategoryID) 
						JOIN productcategory pc
							ON (ps.ProductCategoryID = pc.ProductCategoryID)
						
GROUP BY 1
ORDER BY 3 desc;

-- 5) Obtener un listado por país (según la dirección de envío), 
-- con el valor total de ventas y productos vendidos, sólo para aquellos países donde se enviaron más de 15 mil productos.

SELECT * FROM salesorderdetail; -- SalesOrderId OrderQty LineTotal
SELECT * FROM salesorderheader; -- SalesOrderId ShipToAddressID
SELECT * FROM address; -- AdressID StateProvinceID
SELECT * FROM stateprovince; -- StateProvinceID CountryRegionCode
SELECT * FROM countryregion; -- CountryRegionCode Name

SELECT cr.Name as Nombre, SUM(d.LineTotal) AS Total_Ventas, SUM(d.OrderQty) AS Cantidad
FROM salesorderdetail d JOIN salesorderheader h
							ON (h.SalesOrderID = d.SalesOrderID)
						JOIN address a
							ON (a.AddressID = h.ShipToAddressId)
						JOIN stateprovince sp
							ON (a.StateProvinceID = sp.StateProvinceID)
						JOIN countryregion cr
							ON (cr.CountryRegionCode = sp.CountryRegionCode)
GROUP BY 1
HAVING SUM(d.OrderQty) > 15000
ORDER BY 1;

select c.Name as Pais, sum(sd.OrderQty) as Cantidad, sum(sd.LineTotal) as Total
from salesorderheader sh
	join salesorderdetail sd on sh.SalesOrderID = sd.SalesOrderID
	join currencyrate cr on sh.CurrencyRateID = cr.CurrencyRateID
    join countryregioncurrency crc on cr.ToCurrencyCode = crc.CurrencyCode
    join countryregion c on crc.CountryRegionCode = c.CountryRegionCode
group by  Pais
having Cantidad>15000
ORDER BY c.Name;


-- 6) Obtener un listado de las cohortes que no tienen alumnos asignados, 
-- utilizando la base de datos henry, desarrollada en el módulo anterior

USE henry;

SELECT * FROM alumno
WHERE IdCohorte = null;

SELECT * 
FROM cohorte c LEFT JOIN alumno a 
					ON (a.IdCohorte = c.IdCohorte)
WHERE a.IdCohorte is null;



-- LECTURE

-- subquerie

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
WHERE IdAlumno = 8;
*/

SELECT Nombre, Apellido, FechaIngreso
FROM alumno
WHERE FechaIngreso = (SELECT MIN(FechaIngreso) FROM alumno);
SELECT Nombre, Apellido, FechaIngreso
FROM alumno
WHERE FechaIngreso = '2019-12-04';

-- COHORTES SIN ALUMNOS

SELECT DISTINCT IdCohorte
FROM alumno;

SELECT * FROM cohorte
WHERE IdCohorte NOT IN (SELECT DISTINCT IdCohorte FROM alumno)
;

-- VISTAS
-- CREATE VIEW nombre_vista AS Consulta
SELECT * FROM alumno;
SELECT AVG(FechaNacimiento) FROM alumno;

SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE())) FROM alumno;
CREATE VIEW alumnos_mayor_promedio AS
	SELECT Nombre, Apellido, TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE()) AS Edad
    FROM alumno
    WHERE TIMESTAMPDIFF(YEAR,FechaNacimiento, CURDATE()) > (SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE())) FROM alumno)
    ORDER BY 3 DESC;

-- Seleccionamos lo que hay en la vista
SELECT * FROM alumnos_mayor_promedio;

-- MODIFICAR UNA VISTA
ALTER VIEW alumnos_mayor_promedio AS
	SELECT Nombre, Apellido, TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE()) AS Edad
    FROM alumno
    WHERE TIMESTAMPDIFF(YEAR,FechaNacimiento, CURDATE()) >= (SELECT AVG(TIMESTAMPDIFF(YEAR, FechaNacimiento, CURDATE())) FROM alumno)
    ORDER BY 3 DESC;

SELECT * FROM alumnos_mayor_promedio;

-- Eliminar una vista
DROP VIEW alumnos_mayor_promedio;

-- SELECT * FROM pruebas1;

-- FUNCIONES VENTANA

USE checkpoint_m2;

-- Promedio de ventas por fecha
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

SELECT Fecha, Precio * Cantidad as Venta,IdVenta,
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