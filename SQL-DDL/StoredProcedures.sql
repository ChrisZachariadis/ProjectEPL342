
------------EXEC OF MAIN STORED PROCEDURE-------------
--Just add whatever filters you want and see which products match
--EXEC getProductsBasedOnFilters @Property_LocationA='Athens' ,@Room_TypeA='Triple',@Property_Type_NameA='' ,@StartDateA='', @EndDateA=''




-- ALL THE SP ARE USED FOR FILTERS 
---------------------------------------

--(1)Get products based on location and stores them on a table named TempResultsLocation
CREATE PROCEDURE getProductByLocation
    @Property_Location VARCHAR(20)
AS
BEGIN
    -- Check if the location exists
    IF NOT EXISTS (
        SELECT * 
        FROM [dbo].[PROPERTY]
        WHERE [Property_Location] = @Property_Location
    )
    BEGIN 
        PRINT 'Unavailable location'
        RETURN 
    END

    -- Create a temporary table to store the results
    IF OBJECT_ID('[dbo].[TempResultsLocation]') IS NOT NULL DROP TABLE [dbo].[TempResultsLocation];
    CREATE TABLE [dbo].[TempResultsLocation] (
        Product_ID INT,
        Property_ID INT

    );

    -- Insert the query results into the temporary table
    INSERT INTO [dbo].[TempResultsLocation] (Product_ID,Property_ID)
    SELECT 
        B.[Product_ID],B.[Property_ID]
    FROM 
        [dbo].[PROPERTY] A, 
        [dbo].[PRODUCT] B, 
        [dbo].[ROOM_TYPE] C
    WHERE 
        A.[Property_Location] = @Property_Location AND 
        A.[Property_ID] = B.[Property_ID] AND  
        B.[Room_Type_ID] = C.[Room_Type_ID];

    -- Select from the temporary table (optional)
    --SELECT * FROM [dbo].[TempResultsLocation];

    -- The temporary table #TempResults will be automatically dropped when the session ends
END
GO


--(2)Get products based on room type and insert to temporary table named TempResultsRoomType
CREATE PROCEDURE getProductByRoomType
@Room_Type VARCHAR(50)
AS
BEGIN
IF OBJECT_ID('[dbo].[TempResultsRoomType]') IS NOT NULL DROP TABLE [dbo].[TempResultsRoomType];
CREATE TABLE [dbo].[TempResultsRoomType] (
Product_ID INT,
Property_ID INT

);
INSERT INTO [dbo].[TempResultsRoomType] (Product_ID,Property_ID)
SELECT  P.[Product_ID],P.[Property_ID]
FROM [dbo].[PRODUCT] P
WHERE P.[Room_Type_ID] IN (
    SELECT A.[Room_Type_ID]
    FROM [dbo].[ROOM_TYPE] A
    WHERE [Room_Type_Description] = @Room_Type)
END
GO


--(3)Get products based on property type and insert to temporary table name TempResultsPropertyType
CREATE PROCEDURE getProductByPropertyType
@Property_Type_Name VARCHAR(50)
AS
BEGIN
IF OBJECT_ID('[dbo].[TempResultsPropertyType]') IS NOT NULL DROP TABLE [dbo].[TempResultsPropertyType];
CREATE TABLE [dbo].[TempResultsPropertyType] (
Product_ID INT,
Property_ID INT

);
INSERT INTO [dbo].[TempResultsPropertyType] (Product_ID,Property_ID)

SELECT A.[Product_ID], A.[Property_ID]
FROM [dbo].[PRODUCT] A
WHERE A.[Property_ID] IN 
((SELECT P.[Property_ID]
FROM [dbo].[PROPERTY] P
WHERE P.[Property_Type_ID] IN (SELECT PT.[Property_Type_ID]
                                FROM [dbo].[PROPERTY_TYPE] PT
                                WHERE PT.[Property_Type_Name] = @Property_Type_Name)))

END
GO

--(4)Gets products based on a range of dates and the stock. It saves the results in TempResultsByDate
CREATE PROCEDURE getProductDate
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Check if the start date is less than or equal to the end date
    IF @StartDate > @EndDate
    BEGIN
        PRINT 'Start date must be less than or equal to end date.'
        RETURN
    END

    -- Create the temporary table
    IF OBJECT_ID('[dbo].[TempResultsDate]') IS NOT NULL DROP TABLE [dbo].[TempResultsDate];
    CREATE TABLE [dbo].[TempResultsDate] (
        Product_ID INT,
        Property_ID INT
    );

    -- Calculate the total number of days in the range
    DECLARE @TotalDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1
    DECLARE @CurrentDate DATE = @StartDate

    WHILE @CurrentDate <= @EndDate
    BEGIN
    -- Insert into the temporary table the product IDs that have stock_amount > 0 for all days in the range
    INSERT INTO [dbo].[TempResultsDate] (Product_ID,Property_ID)
    SELECT S.Product_ID, P.Property_ID
    FROM [dbo].[STOCK] S,[dbo].[Product] P
    WHERE S.Stock_Amount > 0 AND  S.Stock_Date BETWEEN @StartDate
    AND  @EndDate AND S.Product_ID = P.Product_ID
    GROUP BY S.Product_ID, P.Property_ID
    HAVING COUNT(DISTINCT S.Stock_Date) = @TotalDays


  SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
    END
    -- Select the results from the temporary table
   -- SELECT * FROM [dbo].[TempResultsByDate]

    -- Optionally, drop the temporary table if you don't need it after this procedure
    -- DROP TABLE #TempResultByDate
END
GO

--procedure that gets all data based on filters and stores them in the temporary table (TempResultFinal)
CREATE PROCEDURE getProductsBasedOnFilters
    @Property_LocationA VARCHAR(20),
    @Room_TypeA VARCHAR(50),
    @Property_Type_NameA VARCHAR(50),
    @StartDateA DATE,
    @EndDateA DATE
    AS
    BEGIN
        --call only the procedures that their arguments are not null
        IF(@Property_LocationA IS NOT NULL )
            EXEC getProductByLocation @Property_Location=@Property_LocationA
        IF(@Room_TypeA IS NOT NULL)
            EXEC getProductByRoomType @Room_Type=@Room_TypeA
        IF(@Property_Type_NameA IS NOT NULL)
            EXEC getProductByPropertyType @Property_Type_Name=@Property_Type_NameA
        IF(@StartDateA IS NOT NULL AND @EndDateA IS NOT NULL)
            EXEC getProductDate @StartDate=@StartDateA, @EndDate=@EndDateA
        
        --return the intersection of all the temp resutls.

        DECLARE @Query NVARCHAR(MAX);

-- Initialize the query with a SELECT that always returns no results
SET @Query = N'SELECT * WHERE 1 = 0';

-- Dynamically add tables to the query if they have rows
IF EXISTS (SELECT TOP 1 1 FROM [dbo].[TempResultsRoomType])
    SET @Query = N'SELECT * FROM [dbo].[TempResultsRoomType]';

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[TempResultsPropertyType])
    IF @Query = N'SELECT * WHERE 1 = 0'
        SET @Query = N'SELECT * FROM [dbo].[TempResultsPropertyType]'
    ELSE
        SET @Query = @Query + N' INTERSECT SELECT * FROM [dbo].[TempResultsPropertyType]';

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[TempResultsDate])
    IF @Query = N'SELECT * WHERE 1 = 0'
        SET @Query = N'SELECT * FROM [dbo].[TempResultsDate]'
    ELSE
        SET @Query = @Query + N' INTERSECT SELECT * FROM [dbo].[TempResultsDate]';

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[TempResultsLocation])
    IF @Query = N'SELECT * WHERE 1 = 0'
        SET @Query = N'SELECT * FROM [dbo].[TempResultsLocation]'
    ELSE
        SET @Query = @Query + N' INTERSECT SELECT * FROM [dbo].[TempResultsLocation]';




-- Execute the dynamically constructed query
IF OBJECT_ID('[dbo].[TempResultsFinal]') IS NOT NULL DROP TABLE [dbo].[TempResultsFinal];
CREATE TABLE [dbo].[TempResultsFinal] (
Product_ID INT,
Property_ID INT

);
INSERT INTO [dbo].[TempResultsFinal] (Product_ID,Property_ID)
EXEC sp_executesql @Query;

    END
GO

--(5)returns all property data that match the filters.
CREATE PROCEDURE getAllPropertyData
AS
BEGIN
    SELECT DISTINCT 
        Prop.[Property_ID], 
        Prop.[Property_Name], 
        Prop.[Property_Location], 
        Prop.[Property_Description], 
        (SELECT MIN(Prod.[Product_Price])
         FROM [dbo].[TempResultsFinal] Temp
         JOIN [dbo].[PRODUCT] Prod ON Temp.[Product_ID] = Prod.[Product_ID]
         WHERE Temp.[Property_ID] = Prop.[Property_ID]) AS MinPrice
    FROM [dbo].[PROPERTY] Prop
    JOIN [dbo].[TempResultsFinal] Temp ON Prop.[Property_ID] = Temp.[Property_ID];
END
GO





-- CREATE PROCEDURE getAllProperties
-- AS
-- BEGIN

-- DECLARE @CurrentPropertyID INT;

-- -- Declare the cursor
-- DECLARE property_cursor CURSOR FOR
-- SELECT Property_ID FROM [dbo].[TempResultsFinal];

-- -- Open the cursor
-- OPEN property_cursor;

-- -- Fetch the first row from the cursor
-- FETCH NEXT FROM property_cursor INTO @CurrentPropertyID;

-- -- Loop through the cursor
-- WHILE @@FETCH_STATUS = 0
-- BEGIN
--     -- Call your stored procedure for each Property_ID
--     EXEC getPropertyData @Property_ID = @CurrentPropertyID;

--     -- Fetch the next row from the cursor
--     FETCH NEXT FROM property_cursor INTO @CurrentPropertyID;
-- END

-- -- Close and deallocate the cursor
-- CLOSE property_cursor;
-- DEALLOCATE property_cursor;


-- END

-- --(5)Returns Property data based on property_id.
-- CREATE PROCEDURE getPropertyData
--     @Property_ID INT
-- AS
-- BEGIN
--     SELECT DISTINCT P.[Property_ID] , P.[Property_Name] , P.[Property_Location] , P.[Property_Description] , (SELECT MIN(P.[Product_Price]) 
--                                                                                                                 FROM [dbo].[TempResultsFinal] T, [dbo].[PRODUCT] P
--                                                                                                                 WHERE T.[Property_ID]=@Property_ID AND T.[Product_ID]=P.[Product_ID] ) AS MinPrice
--     FROM [dbo].[PROPERTY] P, [dbo].[TempResultsFinal] T 
--     WHERE P.[Property_ID] = @Property_ID;
-- END
-- GO






-- THIS PART IS FOR WHEN WE ARE DIPLAYING THE PRODUCTS IN THE PRODUCT LIST. 
----------------------------------------------------------------------------

-- Get Amenities of a product based on Product_ID 

CREATE PROCEDURE getAmenities
@Product_ID INT
AS
BEGIN
SELECT AM.[Amenity_Type]
FROM [dbo].[AMENITIES] AM
WHERE AM.[Amenity_ID] IN ( 
SELECT ART.[MAmenity_ID] 
FROM [dbo].[AMENITIES_ROOM_TYPE] ART 
WHERE ART.[MRoom_Type_ID] IN (SELECT P.[Room_Type_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =@Product_ID) )
END

-- Get Facilities of a product based on Product_ID

CREATE PROCEDURE getFacilities
@Product_ID INT
AS
BEGIN
SELECT F.[Facility_Type]
FROM [dbo].[FACILITIES] F
WHERE F.[Facility_ID] IN ( 
SELECT PF.[MFacility_ID] 
FROM [dbo].[PROPERTY_FACILITIES] PF
WHERE PF.[MProperty_ID] IN (SELECT P.[Property_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =@Product_ID) )
END


-- Get Prices of a product based on Product_ID

CREATE PROCEDURE getPrices
@Product_ID INT
AS 
BEGIN
SELECT P.[Product_Price]
FROM [dbo].[PRODUCT] P
WHERE P.[Product_ID] = @Product_ID
END