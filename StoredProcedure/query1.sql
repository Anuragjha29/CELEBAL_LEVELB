IF OBJECT_ID('InsertOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE InsertOrderDetails;
GO

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity SMALLINT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AvailableStock INT;
    DECLARE @ReorderLevel INT;
    DECLARE @DefaultUnitPrice MONEY;

    SELECT 
        @AvailableStock = p.SafetyStockLevel,
        @ReorderLevel = p.ReorderPoint,
        @DefaultUnitPrice = p.StandardCost
    FROM Production.Product p
    WHERE p.ProductID = @ProductID;

    IF @UnitPrice IS NULL
        SET @UnitPrice = @DefaultUnitPrice;

    IF @Discount IS NULL
        SET @Discount = 0;

    IF @AvailableStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available. Order aborted.';
        RETURN;
    END

    INSERT INTO Sales.SalesOrderDetail (
        SalesOrderID,
        ProductID,
        OrderQty,
        UnitPrice,
        UnitPriceDiscount,
        rowguid,
        ModifiedDate
    )
    VALUES (
        @OrderID,
        @ProductID,
        @Quantity,
        @UnitPrice,
        @Discount,
        NEWID(),
        GETDATE()
    );

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Production.Product
    SET SafetyStockLevel = SafetyStockLevel - @Quantity
    WHERE ProductID = @ProductID;

    IF (@AvailableStock - @Quantity) < @ReorderLevel
    BEGIN
        PRINT 'Warning: Stock for ProductID ' + CAST(@ProductID AS VARCHAR) + ' is below Reorder Level!';
    END
END
