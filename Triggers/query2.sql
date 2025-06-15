CREATE TRIGGER trg_StockValidation
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

  
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN Production.ProductInventory pi
            ON i.ProductID = pi.ProductID AND pi.LocationID = 1
        WHERE i.OrderQty > pi.Quantity
    )
    BEGIN
        RAISERROR('Order could not be placed due to insufficient stock.', 16, 1);
        RETURN;
    END

   
    UPDATE pi
    SET pi.Quantity = pi.Quantity - i.OrderQty
    FROM Production.ProductInventory pi
    JOIN INSERTED i
        ON pi.ProductID = i.ProductID AND pi.LocationID = 1;


    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice)
    SELECT SalesOrderID, ProductID, OrderQty, UnitPrice
    FROM INSERTED;
END;
