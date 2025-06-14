
IF OBJECT_ID('GetOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE GetOrderDetails;
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exits';
        RETURN 1;
    END

    SELECT *
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END
GO

EXEC GetOrderDetails @OrderID = 12345;
