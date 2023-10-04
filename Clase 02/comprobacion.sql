SELECT LineTotal FROM salesorderdetail;
SELECT DISTINCT p.ProductID, p.Name, s.LineTotal
FROM product p LEFT JOIN salesorderdetail s 
			ON (s.ProductID = p.ProductID)
-- WHERE s.SalesOrderId IS NULL