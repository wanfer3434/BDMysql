USE adventureworks;
USE checkpoint_m2;
SELECT * FROM product;
SELECT * FROM salesorderheader;
SELECT * FROM salesorderdetail;
DROP DATABASE adventureworks;
-- inner join
-- por cada venta queremos obtener la cantidad , nombre del producto y el precio el que tengo en mi stock
SELECT s.SalesOrderID, s.OrderQty, p.Name, p.ListPrice 
FROM salesorderdetail s INNER JOIN product p
						ON(p.ProductID = s.ProductID)
;

-- Total que gastarón en transporte , Nombre, Telefono
SELECT s.ContactId, SUM(s.Freight) AS TotalTransporte, CONCAT(c.Title,c.FirstName,' ',c.LastName) as Nombre, c.Phone
FROM salesorderheader s INNER JOIN contact c
				ON (c.ContactId = s.ContactID)
WHERE s.OrderDate BETWEEN '2002-01-01' AND '2003-01-01'
GROUP BY s.ContactId, Nombre
ORDER BY TotalTransporte DESC
LIMIT 10;

-- calcular cuanto en total se gastaron en la venta total venta = cantidad * precio esto es igual a TotalDue
SELECT s.ContactID, c.FirstName, SUM(s.TotalDue) as 'Total Venta'
FROM salesorderheader s JOIN contact c 
			ON (s.ContactId = c.ContactID)
GROUP BY 1 
ORDER BY 3 DESC;

-- Si queremos que los productos que sean produtos incluso que no aparezcan en ninguna venta
-- productos que se hayan vendido + productos que no se hayan vendido
-- LEFT JOIN
SELECT LineTotal FROM salesorderdetail;
SELECT DISTINCT p.ProductID, p.Name, s.LineTotal
FROM product p LEFT JOIN salesorderdetail s 
			ON (s.ProductID = p.ProductID)
-- WHERE s.SalesOrderId IS NULL;
;

-- Right join
SELECT DISTINCT p.ProductID, p.Name, s.LineTotal
FROM salesorderdetail s RIGHT JOIN product p
			ON (s.ProductID = p.ProductID)
-- WHERE s.SalesOrderId IS NULL;
;

INSERT INTO producto (IDProducto,concepto, tipo, precio)
VALUES (1,'nokia','INFORMATICA','');

-- Righ
SELECT * FROM producto;
SELECT * FROM venta;
select p.IdProducto, p.Concepto, v.IdVenta, v.Precio * v.Cantidad as Venta
FROM producto p  JOIN venta v
		ON (p.IdProducto = v.IdProducto);
        
 
-- FULL OUTER JOIN

-- FULL OUTER JOIN = RIGHT JOIN + LEFT JOIN -> RIGHT JOIN UNION LEFT JOIN

SELECT p.IdProducto, p.Concepto, v.IdVenta, v.Precio * v.Cantidad as Venta
FROM producto p RIGHT JOIN venta v
			ON(v.IdProducto = p.IdProducto)
union 
SELECT p.IdProducto, p.Concepto, v.IdVenta, v.Precio * v.Cantidad
FROM producto p LEFT JOIN venta v
			ON (v.IdProducto = p.IdProducto)

;       
        
-- ////////////////--------------------HOMWORK JOINS-------------------/////////////////
-- 1) Obtener un listado contactos que hayan ordenado productos 
-- de la subcategoría "Mountain Bikes", entre los años 2000 y 2003, cuyo método de envío sea "CARGO TRANSPORT 5".
SELECT * FROM salesorderdetail; -- ProductID Foreign Key
SELECT * FROM salesorderheader; -- ContactId Foreign Key ShipMethodId Foreign Key
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

--  2) Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", entre los años 2000 y 2003
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
SELECT CONCAT(c.Title, c.FirstName, ' ', c.LastName) as Nombre, SUM(d.OrderQty) as Cantidad, SUM(h.TotalDue) as Ventas
FROM contact c JOIN salesorderheader h
					ON (c.ContactID = h.ContactId)
				JOIN salesorderdetail d
					ON (h.SalesOrderId = d.SalesOrderId)
				JOIN product p
					ON (p.ProductID = d.ProductID)
				JOIN productsubcategory ps
    ON (p.ProductSubcategoryID = ps.ProductSubcategoryID)
WHERE YEAR(h.OrderDate) BETWEEN 2000 AND 2003
AND ps.Name = 'Mountain Bikes'
GROUP BY 1
ORDER BY 2 DESC;
-- 3) Obtener un listado de cual fue el volumen de compra (cantidad) por año y método de envío.
-- VENTA = PRECIO * CANTIDAD
-- CANTIDADES, VOLUMEN DE COMPRA = SUM(CANTIDAD)

SELECT * FROM salesorderdetail; -- OrderQty"cantidad"  - SalesOrderID
SELECT * FROM salesorderheader; -- SalesOrderId OrderDate ShipMethodId
SELECT * FROM shipmethod;     -- ShipMethodId Name

SELECT YEAR(OrderDate) año, s.name Metoddo_de_Envío, SUM(d.OrderQty) volumen_de_compra
FROM salesorderheader h JOIN salesorderdetail d
							ON (h.SalesOrderID = d.SalesOrderID)
						RIGHT JOIN shipmethod s
							ON(h.ShipMethodID = s.ShipMethodID )
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 4) Obtener un listado por categoría de productos, con el valor total de ventas y cantidad de productos vendidos.
-- lineTotal = UnitPrice * OrderQty = "TOTAL DE VENTAS"
SELECT * FROM salesorderdetail; -- SalesOrderID OrderQty LineTotal o UnitPrice
SELECT * FROM product;           -- ProductID ProductSubcategoryID
SELECT * FROM productsubcategory; -- ProductSubcategoryID ProductCategoryID
SELECT * FROM productcategory;   -- ProductCategoryID Name

SELECT pc.Name Nombre, SUM(OrderQty) Cantidad, SUM(LineTotal) Ventas 
FROM salesorderdetail d JOIN product p
							ON(d.ProductID = p.ProductID)
						JOIN productsubcategory ps
							ON(p.ProductSubcategoryID = ps.ProductSubcategoryID)
						JOIN productcategory pc
							ON(ps.ProductCategoryID = pc.ProductCategoryID)
GROUP BY 1
ORDER BY 3 DESC ;


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