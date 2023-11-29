
------------EXEC OF MAIN STORED PROCEDURE-------------
--EXEC getProductsBasedOnFilters @Property_LocationA='Athens' ,@Room_TypeA='Triple',@Property_Type_NameA='' ,@StartDateA='', @EndDateA=''

-------------------------------------
-- ALL THE SP ARE USED FOR FILTERS / GET PROPERTIES / GET PRODUCTS -- 
----------------------------------------------------------------------------------------------------
--(1) Get products based on location and stores them on a table named TempResultsLocation
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
END
GO
----------------------------------------------------------------------------------------------------
--(2) Get products based on room type and insert to temporary table named TempResultsRoomType
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
----------------------------------------------------------------------------------------------------
--(3) Get products based on property type and insert to temporary table name TempResultsPropertyType
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
----------------------------------------------------------------------------------------------------
--(4) Gets products based on a range of dates and the stock. It saves the results in TempResultsByDate
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
END
GO
------------------------------------------------------------------------------------------------------------
--(5) Gets all data based on filters and stores them in the table (TempResultFinal)
CREATE PROCEDURE getProductsBasedOnFilters
    @Property_LocationA VARCHAR(20),
    @Room_TypeA VARCHAR(50),
    @Property_Type_NameA VARCHAR(50),
    @StartDateA DATE,
    @EndDateA DATE
    AS
    BEGIN
        --call only the procedures that their arguments are not null
         IF NOT(@Property_LocationA='empty')
            EXEC getProductByLocation @Property_Location=@Property_LocationA
        IF NOT(@Room_TypeA='empty')
            EXEC getProductByRoomType @Room_Type=@Room_TypeA
        IF NOT(@Property_Type_NameA='empty')
            EXEC getProductByPropertyType @Property_Type_Name=@Property_Type_NameA
        IF (@StartDateA IS NOT NULL AND @EndDateA IS NOT NULL)
            EXEC getProductDate @StartDate=@StartDateA, @EndDate=@EndDateA
        
        --return the intersection of all the temp resutls.

        DECLARE @Query NVARCHAR(MAX);

-- Initialize the query with a SELECT that always returns no results
-- Dynamically add tables to the query if they have rows
SET @Query = N'SELECT * WHERE 1 = 0';

IF OBJECT_ID('[dbo].[TempResultsRoomType]') IS NOT NULL 
    SET @Query = N'SELECT * FROM [dbo].[TempResultsRoomType]';

IF OBJECT_ID('[dbo].[TempResultsPropertyType]') IS NOT NULL 
    IF @Query = N'SELECT * WHERE 1 = 0'
        SET @Query = N'SELECT * FROM [dbo].[TempResultsPropertyType]'
    ELSE
        SET @Query = @Query + N' INTERSECT SELECT * FROM [dbo].[TempResultsPropertyType]';

IF OBJECT_ID('[dbo].[TempResultsDate]') IS NOT NULL 
    IF @Query = N'SELECT * WHERE 1 = 0'
        SET @Query = N'SELECT * FROM [dbo].[TempResultsDate]'
    ELSE
        SET @Query = @Query + N' INTERSECT SELECT * FROM [dbo].[TempResultsDate]';

IF OBJECT_ID('[dbo].[TempResultsLocation]') IS NOT NULL 
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

IF OBJECT_ID('[dbo].[TempResultsLocation]') IS NOT NULL  
DROP TABLE [dbo].[TempResultsLocation];
IF OBJECT_ID('[dbo].[TempResultsRoomType]') IS NOT NULL 
DROP TABLE [dbo].[TempResultsRoomType];
IF OBJECT_ID('[dbo].[TempResultsPropertyType]') IS NOT NULL 
DROP TABLE [dbo].[TempResultsPropertyType];
IF OBJECT_ID('[dbo].[TempResultsDate]') IS NOT NULL 
DROP TABLE [dbo].[TempResultsDate];

    END
GO
------------------------------------------------------------------------------------------------------------
--(6) Gets all property data that match the filters.
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
------------------------------------------------------------------------------------------------------------
--(7) Get all products based on property ID
CREATE PROCEDURE getAllProductsData
    @Property_ID INT
AS
BEGIN
    SELECT O.Product_ID, O.Product_Price, O.Max_Guests, O.Product_Description, (SELECT RT.Room_Type_Description                         
                                                                                FROM [dbo].[ROOM_TYPE] RT 
                                                                                WHERE Room_Type_ID = O.Room_Type_ID) AS Room_Type ,
(SELECT STRING_AGG (M.Meal_Plan_Description,', ') 
FROM [dbo].[MEAL_PLAN] M
WHERE M.[Meal_Plan_ID] IN ( SELECT MP.Meal_Plan_ID FROM [dbo].[MEAL_PLAN_FOR_PRODUCT] MP WHERE MP.[Product_ID] = O.Product_ID)) AS Meal_Plan, 

(SELECT  STRING_AGG (AM.Amenity_Type,', ')
FROM [dbo].[AMENITIES] AM
WHERE AM.[Amenity_ID] IN ( 
SELECT ART.[MAmenity_ID] 
FROM [dbo].[AMENITIES_ROOM_TYPE] ART 
WHERE ART.[MRoom_Type_ID] IN (SELECT P.[Room_Type_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =O.Product_ID))) AS Amenities , 
							
(SELECT  STRING_AGG (P.Policy_Description,', ')
FROM [dbo].[POLICY] P
WHERE P.[Policy_ID] IN ( SELECT PP.[MPolicy_ID] FROM [dbo].[PRODUCT_POLICIES] PP WHERE PP.[MProduct_ID]=O.Product_ID)) AS Policies


FROM [dbo].[TempResultsFinal] T, [dbo].[PRODUCT] O
WHERE T.Property_ID = @Property_ID  AND T.Product_ID = O.Product_ID
END
GO

------------------------------------------------------------------------------
     --   USED TO GET FACILITIES / MAKE RESERVATION / MAKE REVIEW    --
------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- Get Facilities of a product based on Product_ID
CREATE PROCEDURE getFacilities
@Property_ID INT
AS
BEGIN
SELECT F.[Facility_Type]
FROM [dbo].[FACILITIES] F
WHERE F.[Facility_ID] IN ( 
SELECT PF.[MFacility_ID] 
FROM [dbo].[PROPERTY_FACILITIES] PF
WHERE PF.[MProperty_ID] IN (SELECT P.[Property_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =@Property_ID) )
END
GO
------------------------------------------------------------------------------------------------------------
-- Makes a new Reservation for every date and returns all the reservation ID's
CREATE PROCEDURE makeReservation
    @Product_ID INT,
    @User_ID INT,
    @Start_Date DATE,
    @End_Date DATE
AS
BEGIN
    DECLARE @Current_Date DATE = @Start_Date

    WHILE @Current_Date <= @End_Date
    BEGIN
        -- Insert a reservation and capture the Reservation_ID
        INSERT INTO [dbo].RESERVATIONS (Reservation_Date, User_ID, Product_ID)
        VALUES (@Current_Date, @User_ID, @Product_ID)

        -- Update stock amount
        UPDATE [dbo].STOCK
        SET Stock_Amount = Stock_Amount - 1
        WHERE Product_ID = @Product_ID AND Stock_Date = @Current_Date

        -- Move to the next day
        SET @Current_Date = DATEADD(DAY, 1, @Current_Date)
    END

    

    -- Return the inserted reservation IDs
END
GO

CREATE PROCEDURE getID
AS
BEGIN
SELECT TOP 1 R.Reservation_ID
    FROM [dbo].[RESERVATIONS] R
    ORDER BY R.Reservation_ID DESC;

END
GO
------------------------------------------------------------------------------------------------------------
-- Create a new Review and also alter the table RESERVATIONS to include the Review ID.
CREATE PROCEDURE makeReview
    @Reservation_ID INT,
    @Review_Description VARCHAR(170),
    @Review_Rating INT
AS
BEGIN
    -- Table variable to store the generated Review_ID
    DECLARE @Generated_Review_IDs TABLE (Review_ID INT);

    -- Insert the review and capture the Review_ID
    INSERT INTO [dbo].[REVIEWS] (Review_Description, Review_Rating)
    OUTPUT INSERTED.Review_ID INTO @Generated_Review_IDs
    VALUES (@Review_Description, @Review_Rating);

    -- Extract the generated Review_ID
    DECLARE @Generated_Review_ID INT;
    SELECT @Generated_Review_ID = Review_ID FROM @Generated_Review_IDs;

    -- Update the reservation with the new Review_ID
    UPDATE [dbo].[RESERVATIONS]
    SET Review_ID = @Generated_Review_ID
    WHERE Reservation_ID = @Reservation_ID;
END
GO
------------------------------------------------------------------------------------------------------------
-- Get Reviews for a specific Property
CREATE PROCEDURE getReviews
    @Property_ID INT
AS
BEGIN
    SELECT R.Review_Description
    FROM REVIEWS R
    INNER JOIN [dbo].[RESERVATIONS] RES ON R.Review_ID = RES.Review_ID
    INNER JOIN [dbo].[PRODUCT] P ON RES.Product_ID = P.Product_ID
    WHERE P.Property_ID = @Property_ID;
END
GO
------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------
-- EXTRA ---------------------------------------------------------------------------------------------------
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
GO
------------------------------------------------------------------------------------------------------------
-- Get Meal Plan
CREATE PROCEDURE getMealPlan
@Product_ID INT
AS
BEGIN
SELECT M.Meal_Plan_Description
FROM [dbo].[MEAL_PLAN] M
WHERE M.[Meal_Plan_ID] IN ( SELECT MP.Meal_Plan_ID FROM [dbo].[MEAL_PLAN_FOR_PRODUCT] MP WHERE MP.[Product_ID] = @Product_ID)  
END
GO
------------------------------------------------------------------------------------------------------------
-- Get Policies
CREATE PROCEDURE getPolices
@Product_ID INT
AS
BEGIN
SELECT P.[Policy_Description]  
FROM [dbo].[POLICY] P
WHERE P.[Policy_ID] IN ( SELECT PP.[MPolicy_ID] FROM [dbo].[PRODUCT_POLICIES] PP WHERE PP.[MProduct_ID]=@Product_ID)
END
GO
------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE spInsert_Product
    @User_ID INT,
    @Product_Price DECIMAL(10, 2),
    @Max_Guests INT,
    @Product_Description NVARCHAR(MAX),
    @Room_Type_ID INT,
    @Property_ID INT
AS
BEGIN
    -- Check if the @User_ID matches the User_ID for the specified Property_ID
    IF EXISTS (
        SELECT 1
        FROM [dbo].[PROPERTY]
        WHERE Property_ID = @Property_ID
        AND User_ID = @User_ID
    )
    BEGIN
        -- Insert the product 
        INSERT INTO [dbo].[PRODUCT] (Product_ID, Product_Price, Max_Guests, Product_Description, Room_Type_ID, Property_ID)
        VALUES (,@Product_Price, @Max_Guests, @Product_Description, @Room_Type_ID, @Property_ID);        
        PRINT 'SUCCESS.';
    END
    ELSE
    BEGIN
        PRINT 'FAILURE.';
    END
END
