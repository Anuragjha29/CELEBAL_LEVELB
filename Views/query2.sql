CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    ISNULL(s.Name, p.FirstName + ' ' + p.LastName) AS CompanyName,
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    od.ProductID,
    pr.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    od.OrderQty * od.UnitPrice AS TotalPrice
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product pr ON od.ProductID = pr.ProductID
JOIN Sales.Customer c ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE CAST(o.OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
