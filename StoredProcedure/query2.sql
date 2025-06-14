IF OBJECT_ID('UpdateOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE UpdateOrderDetails;
GO

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity SMALLINT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity SMALLINT;
    DECLARE @OldUnitPrice MONEY;
    DECLARE @OldDiscount FLOAT;
    DECLARE @NewQuantity SMALLINT;
    DECLARE @NewUnitPrice MONEY;
    DECLARE @NewDiscount FLOAT;

    SELECT 
        @OldQuantity = OrderQty,
        @OldUnitPrice = UnitPrice,
        @OldDiscount = UnitPriceDiscount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    SET @NewQuantity = ISNULL(@Quantity, @OldQuantity);
    SET @NewUnitPrice = ISNULL(@UnitPrice, @OldUnitPrice);
    SET @NewDiscount = ISNULL(@Discount, @OldDiscount);

    UPDATE Sales.SalesOrderDetail
    SET 
        OrderQty = @NewQuantity,
        UnitPrice = @NewUnitPrice,
        UnitPriceDiscount = @NewDiscount,
        ModifiedDate = GETDATE()
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    UPDATE Production.Product
    SET SafetyStockLevel = ISNULL(SafetyStockLevel, 0) - (@NewQuantity - @OldQuantity)
    WHERE ProductID = @ProductID;
END
GO
EXEC UpdateOrderDetails 
    @OrderID = 43665,
    @ProductID = 870,
    @Quantity = 15;
