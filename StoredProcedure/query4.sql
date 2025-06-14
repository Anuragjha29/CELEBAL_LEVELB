IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE DeleteOrderDetails;
GO

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Invalid parameters: OrderID or ProductID not found in SalesOrderDetail.';
        RETURN -1;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;
END
GO


EXEC DeleteOrderDetails @OrderID = 43665, @ProductID = 870;
