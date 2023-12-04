----------------------------------------------------------------------------------------------------
-- USED FOR FILTERS / GET PROPERTIES / GET PRODUCTS FOR CUSTOMERS ONLY -- 
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
        (SELECT Property_Type_Name FROM [dbo].[Property_Type] WHERE Property_Type_ID = Prop.Property_Type_ID) AS Property_Type,
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
------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
     --   USED TO GET FACILITIES / GET REVIEWS / MAKE RESERVATION / MAKE REVIEW    --
---------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
--(8)Get Facilities of a product based on Product_ID
CREATE PROCEDURE getFacilities
@Property_ID INT
AS
BEGIN
SELECT F.[Facility_Type]
FROM [dbo].[FACILITIES] F
WHERE F.[Facility_ID] IN ( 
SELECT PF.[MFacility_ID] 
FROM [dbo].[PROPERTY_FACILITIES] PF
WHERE PF.[MProperty_ID] = @Property_ID )
END
GO
------------------------------------------------------------------------------------------------------------
--(9)Makes a new Reservation for every date and returns all the reservation ID's
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
END
GO
------------------------------------------------------------------------------------------------------------
--(10)Used with makeReservation to get the Reservation ID.
CREATE PROCEDURE getID
AS
BEGIN
    WITH CTE AS (
        SELECT 
            R.Reservation_ID,
            R.User_ID,
            R.Product_ID,
            ROW_NUMBER() OVER (ORDER BY R.Reservation_ID DESC) AS RowNum
        FROM [dbo].[RESERVATIONS] R
    )
    SELECT STRING_AGG(Reservation_ID, ', ') AS Reservation_ID
    FROM CTE
    WHERE User_ID = (SELECT TOP 1 User_ID FROM CTE ORDER BY RowNum)
    AND Product_ID = (SELECT TOP 1 Product_ID FROM CTE ORDER BY RowNum);
END
GO
------------------------------------------------------------------------------------------------------------
--(11)Create a new Review and also alter the table RESERVATIONS to include the Review ID. (Review Status must be finished).
CREATE PROCEDURE makeReview
    @Reservation_ID INT,
    @Review_Description VARCHAR(170),
    @Review_Rating INT
AS
BEGIN
    -- Check if the Reservation Status is 'Finished'
    IF EXISTS (
        SELECT 1 
        FROM [dbo].[RESERVATIONS]
        WHERE Reservation_ID = @Reservation_ID AND Reservation_Status = 'Finished'
    )
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
    ELSE
    BEGIN
        RAISERROR('Cannot leave a review for a reservation that is not finished.', 16, 1);
    END
END
GO
------------------------------------------------------------------------------------------------------------
--(12)Get Reviews for a specific Property.
CREATE PROCEDURE getReviews
    @Property_ID INT
AS
BEGIN
    SELECT R.Review_Description, R.Review_Rating
    FROM REVIEWS R
    INNER JOIN [dbo].[RESERVATIONS] RES ON R.Review_ID = RES.Review_ID
    INNER JOIN [dbo].[PRODUCT] P ON RES.Product_ID = P.Product_ID
    WHERE P.Property_ID = @Property_ID;
END
GO
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- USED FOR ADMIN AND MANAGER TO GET PROPERTIES / PRODUCTS / EDIT
------------------------------------------------------------------------------------------------------------
--(13)Insert a new product on a specific property.
CREATE PROCEDURE spInsert_Product
    @User_ID INT,
    @Product_Price DECIMAL(10, 2),
    @Max_Guests INT,
    @Product_Description NVARCHAR(MAX),
    @Room_Type_Description VARCHAR(50),
    @Property_ID INT
AS
BEGIN
    DECLARE @Room_Type_ID INT
	DECLARE @Date DATE = '2023-01-01' -- Initialize the start date
    DECLARE @EndDate DATE = '2023-12-31' -- Initialize the end date

    -- Check if the @User_ID matches the User_ID for the specified Property_ID
    IF EXISTS (
        SELECT 1
        FROM [dbo].[PROPERTY]
        WHERE Property_ID = @Property_ID
        AND User_ID = @User_ID
    )
    BEGIN
        -- Check if the Room_Type_Description exists in the ROOM_TYPE table
        SELECT @Room_Type_ID = Room_Type_ID
        FROM [dbo].[ROOM_TYPE]
        WHERE Room_Type_Description = @Room_Type_Description

        -- Insert the product 
        INSERT INTO [dbo].[PRODUCT] ( Product_Price, Max_Guests, Product_Description, Room_Type_ID, Property_ID)
        VALUES (@Product_Price, @Max_Guests, @Product_Description, @Room_Type_ID, @Property_ID);       
		
		WHILE @Date <= @EndDate
		BEGIN
			PRINT @Date
        -- Insert a row into STOCK table for each date
        INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount)
        VALUES ((SELECT TOP 1 Product_ID FROM [dbo].[PRODUCT] ORDER BY Product_ID DESC), @Date, 0)

        -- Increment the date by 1 day
        SET @Date = DATEADD(DAY, 1, @Date)
    END

    END
    ELSE
    BEGIN
        PRINT 'FAILURE.';
    END
END
GO
------------------------------------------------------------------------------------------------------------
--(14)Insert a new property
CREATE PROCEDURE spInsert_Property
    @Property_Name VARCHAR(50),
    @Property_Address VARCHAR(50),
    @Property_Description VARCHAR(100),
    @Property_Coordinates VARCHAR(20),
    @Property_Location VARCHAR(20),
    @Owner_ID INT,
    @Owner_First_Name VARCHAR(15),
    @Owner_Last_Name VARCHAR(15),
    @Property_Type VARCHAR(50),
    @User_ID INT
AS
BEGIN
    -- Declare a variable to store Property_Type_ID
    DECLARE @Property_Type_ID INT;

    -- Retrieve Property_Type_ID from PRODUCT_TYPE table
    SELECT @Property_Type_ID = Property_Type_ID
    FROM [dbo].[PROPERTY_TYPE]
    WHERE Property_Type_Name = @Property_Type;

    -- Proceed with the insertion
    INSERT INTO [dbo].[PROPERTY] (
        Property_Name, Property_Address, Property_Description, Property_Coordinates, Property_Location,
        Owner_ID, Owner_First_Name, Owner_Last_Name, Property_Type_ID, User_ID
    )
    VALUES (
        @Property_Name, @Property_Address, @Property_Description, @Property_Coordinates,
        @Property_Location, @Owner_ID, @Owner_First_Name, @Owner_Last_Name, @Property_Type_ID, @User_ID
    );
END;
GO
------------------------------------------------------------------------------------------------------------
--(15)Get property details based on property ID.
CREATE PROCEDURE spGet_Property
    @Property_ID INT
AS
BEGIN
    SELECT P.Property_ID, P.Property_Name, P.Property_Address, P.Property_Coordinates, P.Property_Location, P.Property_Description,P.Owner_First_Name,P.Owner_Last_Name, (SELECT Property_Type_Name FROM [dbo].[PROPERTY_TYPE] WHERE Property_Type_ID = P.Property_Type_ID) AS Property_Type
    FROM [dbo].[PROPERTY] P
	WHERE P.Property_ID=@Property_ID
END
GO
------------------------------------------------------------------------------------------------------------
--(16)Update a property based on property ID.
CREATE PROCEDURE spEdit_Property
	@Property_ID INT,
    @Property_Name VARCHAR(50),
    @Property_Address VARCHAR(50),
    @Property_Description VARCHAR(100),
    @Property_Coordinates VARCHAR(20),
    @Property_Location VARCHAR(20),
    @Owner_First_Name VARCHAR(15),
    @Owner_Last_Name VARCHAR(15),
    @Property_Type_Name VARCHAR(15)
AS
BEGIN
    DECLARE @Property_Type_ID INT

    -- Check if the Property_Type_Name exists in the PROPERTY_TYPE table and get the corresponding Property_Type_ID
    SELECT @Property_Type_ID = Property_Type_ID
    FROM PROPERTY_TYPE
    WHERE Property_Type_Name = @Property_Type_Name

    -- Update the PROPERTY table
    UPDATE [dbo].[PROPERTY]
    SET 
        Property_Name = @Property_Name,
        Property_Address = @Property_Address,
        Property_Description = @Property_Description,
        Property_Coordinates = @Property_Coordinates,
        Property_Location = @Property_Location,
        Owner_First_Name = @Owner_First_Name,
        Owner_Last_Name = @Owner_Last_Name,
        Property_Type_ID = @Property_Type_ID
    WHERE Property_ID = @Property_ID;
END
GO
------------------------------------------------------------------------------------------------------------
--(17)Get all products based on Property ID.
CREATE PROCEDURE spGet_Product
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


FROM  [dbo].[PRODUCT] O
WHERE O.Property_ID=@Property_ID 

END
GO
------------------------------------------------------------------------------------------------------------
--(18)Update product based on product ID.
CREATE PROCEDURE spEdit_Product
    @Product_ID INT,
    @Product_Price DECIMAL(10, 2),
    @Max_Guests INT,
    @Product_Description NVARCHAR(MAX),
    @Room_Type_Description VARCHAR(15)
AS
BEGIN
    DECLARE @Room_Type_ID INT

    -- Check if the Room_Type_Description exists in the ROOM_TYPE table and get the corresponding Room_Type_ID
    SELECT @Room_Type_ID = Room_Type_ID
    FROM ROOM_TYPE
    WHERE Room_Type_Description = @Room_Type_Description

    -- Update the PRODUCT table
    UPDATE [dbo].[PRODUCT]
    SET 
        Product_Price = @Product_Price,
        Max_Guests = @Max_Guests,
        Product_Description = @Product_Description,
        Room_Type_ID = @Room_Type_ID
    WHERE Product_ID = @Product_ID;
END
GO
------------------------------------------------------------------------------------------------------------
--(19)Get prodcut details based on product ID
CREATE PROCEDURE spGet_Product_Details
    @Product_ID INT
AS
BEGIN
    SELECT P.Product_Description, P.Product_Price, P.Product_Description, P.Max_Guests, (SELECT Room_Type_Description FROM [dbo].[ROOM_TYPE] WHERE Room_Type_ID = P.Room_Type_ID) AS Room_Type
    FROM [dbo].[PRODUCT] P
    WHERE Product_ID = @Product_ID
END
GO
------------------------------------------------------------------------------------------------------------
--(20)Get properties based on manager ID
CREATE PROCEDURE spGetManagerProperties
    @User_ID INT
AS
BEGIN
    SELECT P.Property_ID, P.Property_Name, P.Property_Description, P.Property_Location, (SELECT Property_Type_Name FROM [dbo].[PROPERTY_TYPE] WHERE P.Property_Type_ID = Property_Type_ID) AS Property_Type
    FROM [dbo].[PROPERTY] P
    WHERE P.User_ID = @User_ID
END
GO
------------------------------------------------------------------------------------------------------------
--(21)Get properties for admin
CREATE PROCEDURE spGetAdminProperties
AS
BEGIN
    SELECT  P.Property_ID, P.Property_Name, P.Property_Description, P.Property_Location, (SELECT Property_Type_Name FROM [dbo].[PROPERTY_TYPE] WHERE P.Property_Type_ID = Property_Type_ID) AS Property_Type
    FROM [dbo].[PROPERTY] p
END
GO
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
-- USED TO VIEW NOT APPROVE MANAGERS AND APPROVE THEM
------------------------------------------------------------------------------------------------------------
--(22)Get not approved property owners.
CREATE PROCEDURE spView_Unapproved
AS
BEGIN
    SELECT User_ID, Date_of_Birth, First_Name, Last_Name, Email
    FROM [dbo].[USER]
    WHERE User_Type = 'Property Owner' AND Approved = 'N'
END
GO
------------------------------------------------------------------------------------------------------------
--(23)Approve user based on ID.
CREATE PROCEDURE spApproveUser
    @User_ID INT
AS
BEGIN
    UPDATE [dbo].[USER]
    SET Approved = 'Y'
    WHERE User_ID = @User_ID
END
GO
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- USED TO VIEW RESERVATIONS AND CANCEL THEM
------------------------------------------------------------------------------------------------------------
--(24)View Reservations based on User ID. (Grouped by Product_ID and Reservation_Dates)
CREATE PROCEDURE spViewReservations
    @User_ID INT
AS
BEGIN
    ;WITH RankedReservations AS (
        SELECT 
            R.Reservation_ID,
            R.Product_ID,
            R.Reservation_Date,
            R.Review_ID,
            R.Reservation_Status,
            R.Reservation_Fine,
            ROW_NUMBER() OVER (PARTITION BY R.Product_ID ORDER BY R.Reservation_Date) AS rn,
            DATEDIFF(DAY, '2000-01-01', R.Reservation_Date) - ROW_NUMBER() OVER (PARTITION BY R.Product_ID ORDER BY R.Reservation_Date) AS grp
        FROM [dbo].[Reservations] R
        WHERE R.User_ID = @User_ID
    ),
    GroupedReservations AS (
        SELECT 
            Product_ID,
            STRING_AGG(CAST(Reservation_ID AS VARCHAR), ', ') AS Reservation_IDs,
            MIN(Reservation_Date) AS Start_Date,
            MAX(Reservation_Date) AS End_Date,
            STRING_AGG(ISNULL(CAST(Review_ID AS VARCHAR), 'NULL'), ', ') AS Review_IDs,
            STRING_AGG(Reservation_Status, ', ') AS Reservation_Statuses,
            STRING_AGG(ISNULL(CAST(Reservation_Fine AS VARCHAR), 'NULL'), ', ') AS Reservation_Fines,
            grp
        FROM RankedReservations
        GROUP BY Product_ID, grp
    )
    SELECT 
        (SELECT P.Property_Name FROM [dbo].[PROPERTY] P, [dbo].[PRODUCT] A WHERE A.Product_ID=G.Product_ID AND P.Property_ID=A.Property_ID) AS Property_Name,
        G.Reservation_IDs,
        CASE 
            WHEN G.Start_Date = G.End_Date THEN CAST(G.Start_Date AS VARCHAR)
            ELSE CAST(G.Start_Date AS VARCHAR) + ' to ' + CAST(G.End_Date AS VARCHAR)
        END AS Reservation_Dates,
        G.Reservation_Statuses,
        G.Reservation_Fines
    FROM GroupedReservations G
END;
GO

------------------------------------------------------------------------------------------------------------
--(25)Cancel Reservation (Alters the status and also applies 50% fine and also updates Stock).
CREATE PROCEDURE spCancelReservation
    @Reservation_IDs VARCHAR(MAX)
AS
BEGIN
    DECLARE @ReservationIDList TABLE (Reservation_ID INT)
    
    INSERT INTO @ReservationIDList (Reservation_ID)
    SELECT value
    FROM STRING_SPLIT(@Reservation_IDs, ',')

    DECLARE @Reservation_ID INT
    DECLARE @Product_ID INT
    DECLARE @Reservation_Date DATE
    
    DECLARE reservationCursor CURSOR FOR
    SELECT R.Reservation_ID, R.Product_ID, R.Reservation_Date
    FROM @ReservationIDList RL
    INNER JOIN [dbo].[RESERVATIONS] R ON RL.Reservation_ID = R.Reservation_ID
    
    OPEN reservationCursor
    
    FETCH NEXT FROM reservationCursor INTO @Reservation_ID, @Product_ID, @Reservation_Date
    
    WHILE @@FETCH_STATUS = 0                                    
    BEGIN
        -- Update the reservation status and fine
        UPDATE R
        SET R.Reservation_Status = 'Cancelled',
            R.Reservation_Fine = P.Product_Price * 0.5
        FROM [dbo].[RESERVATIONS] R
        INNER JOIN [dbo].[PRODUCT] P ON R.Product_ID = P.Product_ID
        WHERE R.Reservation_ID = @Reservation_ID

        -- Update the stock amount
        UPDATE S
        SET S.Stock_Amount = S.Stock_Amount + 1
        FROM [dbo].[STOCK] S
        WHERE S.Product_ID = @Product_ID AND S.Stock_Date = @Reservation_Date
    
        FETCH NEXT FROM reservationCursor INTO @Reservation_ID, @Product_ID, @Reservation_Date
    END
    
    CLOSE reservationCursor
    DEALLOCATE reservationCursor
END
GO
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- REGISTER / LOGIN 
------------------------------------------------------------------------------------------------------------
--Register
CREATE PROCEDURE spRegister_User
    -- @User_ID INT,
    @Date_of_Birth DATE,
    @User_Type VARCHAR(15),
    @First_Name VARCHAR(15),
    @Last_Name VARCHAR(15),
    @Email VARCHAR(50),
    @Passwd VARCHAR(20),
    @Gender CHAR(1)
AS
BEGIN
    SET @First_Name = RTRIM(@First_Name);
    SET @Last_Name = RTRIM(@Last_Name);
    SET @Email = RTRIM(@Email);
    SET @Passwd = RTRIM(@Passwd);
    SET @User_Type = RTRIM(@User_Type);

    DECLARE @Approved CHAR(1);
    IF @User_Type = 'Customer' 
    BEGIN
        SET @Approved = 'Y';
    END
    ELSE IF @User_Type = 'Property Owner'
    BEGIN
        SET @Approved = 'N';
    END
    -- Check if the Email format is valid
    IF @Email NOT LIKE '%@%.%'
    BEGIN
        RAISERROR ('Invalid Email format', 16, 1);
        RETURN;
    END
    ELSE IF EXISTS (
        SELECT *
        FROM [dbo].[USER]
        WHERE [Email] = @Email
    )
    BEGIN 
        PRINT 'Error: Email already exists';
    END
    ELSE
    BEGIN
        --Insert user data into the table with dynamic User_Type
        INSERT INTO [dbo].[USER] 
            (Date_of_Birth, User_Type, First_Name, Last_Name, Email, Passwd, Gender, Approved)
        VALUES 
            (@Date_of_Birth, @User_Type, @First_Name, @Last_Name, @Email, CONVERT(VARCHAR(256),HASHBYTES('SHA2_256',@Passwd),2), @Gender, @Approved);
    END
END
GO
------------------------------------------------------------------------------------------------------------
-- Login
CREATE PROCEDURE spLOGIN 
    @Email VARCHAR(50),
    @Passwd VARCHAR(20) 
AS 
BEGIN
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Passwd = LTRIM(RTRIM(@Passwd));

    -- Check if the credentials exist in the database
    IF NOT EXISTS (
        SELECT *
        FROM [dbo].[USER]
        WHERE [Email] = @Email
          AND [Passwd] = CONVERT(VARCHAR(256),HASHBYTES ('SHA2_256',@Passwd),2)
    )
    BEGIN 
        PRINT 'Error: Invalid Email or password';

    END
    ELSE
    BEGIN
        -- Also return the user_id of the user who logged in
        SELECT [user_id],[User_Type],[Approved]
        FROM [dbo].[USER]
        WHERE [Email] = @Email
          AND [Passwd] = CONVERT(VARCHAR(256),HASHBYTES ('SHA2_256',@Passwd),2)
    END
END
GO
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE addStock
    @Product_ID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Stock_Amount INT
AS
BEGIN
    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM STOCK
            WHERE Product_ID = @Product_ID AND Stock_Date = @CurrentDate
        )
        BEGIN
            -- Update existing stock record
            UPDATE STOCK
            SET Stock_Amount = @Stock_Amount
            WHERE Product_ID = @Product_ID AND Stock_Date = @CurrentDate;
        END
        -- Move to the next date
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END
GO
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-------------------------------------
     --       REVENUE REPORT       --
-------------------------------------

--(1)

-- Get the total revenue with the given filters applied.
CREATE PROCEDURE RevenueReport
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeName NVARCHAR(50), 
    @RoomTypeDescription NVARCHAR(50), 
    @PropertyLocation NVARCHAR(50)
AS
BEGIN
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;
        
    SELECT 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location, 
        SUM(CASE 
                WHEN R.Reservation_Status = 'Finished' THEN PR.Product_Price 
                WHEN R.Reservation_Status = 'Cancelled' THEN R.Reservation_Fine 
                ELSE 0 
            END) AS TotalRevenue
    FROM 
        RESERVATIONS R
    INNER JOIN 
        PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN 
        PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN 
        ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation) AND
        (R.Reservation_Status IN ('Finished', 'Cancelled')) AND
        (R.Product_ID = PR.Product_ID) 
    GROUP BY 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
END
GO
------------------------------------------------------------------------------------------------------------------------
-----------------------------------------
     --  BOOKING STATISTICS REPORTS    --
-----------------------------------------

----- (1) ------

-- Checked and working
-- Stored procedure that for the specified property,room and location returns the total number of reservations


CREATE PROCEDURE AnalyzeNumberOfReservations
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeName NVARCHAR(50), 
    @RoomTypeDescription NVARCHAR(50),
    @PropertyLocation NVARCHAR(50)
AS
BEGIN

    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;

    SELECT 
        P.Property_Location,
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        COUNT(R.Reservation_ID) AS NumberOfReservations
    FROM 
        RESERVATIONS R
    INNER JOIN 
        PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN 
        PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN 
        ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
    ORDER BY 
        P.Property_Location ASC;
END
GO


----- (2) ------

--ELEGXEI TO POSOSTO TON RESERVATIONS TOY KATHE PROPERTY TYPE SE SXESI ME TA TOTAL RESERVATION. 
CREATE PROCEDURE CompareReservationTrends
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Common Table Expression to calculate reservation counts
    WITH ReservationCounts AS (
        SELECT 
            PT.Property_Type_ID, 
            COUNT(R.Reservation_ID) AS ReservationCount
        FROM 
            PROPERTY_TYPE PT
        JOIN 
            PROPERTY P ON PT.Property_Type_ID = P.Property_Type_ID
        JOIN 
            PRODUCT PR ON P.Property_ID = PR.Property_ID
        JOIN 
            RESERVATIONS R ON PR.Product_ID = R.Product_ID
        WHERE 
            (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
            (@EndDate IS NULL OR R.Reservation_Date <= @EndDate)
        GROUP BY 
            PT.Property_Type_ID
    )
    -- Select final result set with percentages
    SELECT 
        PT.Property_Type_Name,
        RC.ReservationCount,
        CAST((RC.ReservationCount * 100.0) / (SELECT SUM(ReservationCount) FROM ReservationCounts) AS DECIMAL(5, 2)) AS Percentage
    FROM 
        ReservationCounts RC
    JOIN 
        PROPERTY_TYPE PT ON RC.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        (SELECT SUM(ReservationCount) FROM ReservationCounts) > 0;
END
GO


----- (3) ------

-- Based on the filters, we count the total number of reservations and the total number of cancelled reservations, 
-- then we calculate the cancellation rate.
CREATE PROCEDURE CalculateCancellationRate
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeName NVARCHAR(50),
    @RoomTypeDescription NVARCHAR(50),
    @PropertyLocation NVARCHAR(50)
AS
BEGIN
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;

    DECLARE @TotalReservations INT;
    DECLARE @CancelledReservations INT;

    -- Find the total number of reservations for the given filters
    SELECT @TotalReservations = COUNT(*)
    FROM RESERVATIONS R
    INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- Find the total number of cancelled reservations for the given filters
    SELECT @CancelledReservations = COUNT(*)
    FROM RESERVATIONS R
    INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        R.Reservation_Status = 'Cancelled' AND
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- Calculate the percentage of cancellations
    SELECT 
        CASE 
            WHEN @TotalReservations > 0 THEN 
                CAST((@CancelledReservations * 100.0) / @TotalReservations AS DECIMAL(5, 2))
            ELSE 0
        END AS CancellationRate;
END
GO

-----------------------------------------
     --    OCCUPATION REPORTS          --
-----------------------------------------


----- (1) ------

-- based on the filters, we count the total available rooms and the total booked rooms, then we calculate the occupancy rate
-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.
CREATE PROCEDURE CalculateOccupancyRate
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeName NVARCHAR(50),
    @RoomTypeDescription NVARCHAR(50),
    @PropertyLocation NVARCHAR(50)
AS
BEGIN
    -- Convert 'empty' string to NULL for filtering
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;

    DECLARE @TotalAvailableRoomDays INT = 0;
    DECLARE @TotalBookedRoomDays INT = 0;

    -- Calculate the total number of available room-days from the STOCK table
    SELECT @TotalAvailableRoomDays = SUM(S.Stock_Amount)
    FROM STOCK S
    INNER JOIN PRODUCT PR ON S.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        S.Stock_Date BETWEEN @StartDate AND @EndDate AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- Calculate the total number of booked room-days based on the filters
    SELECT @TotalBookedRoomDays = COUNT(*)
    FROM RESERVATIONS R
    INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        R.Reservation_Date BETWEEN @StartDate AND @EndDate AND
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation) AND
        R.Reservation_Status = 'Upcoming';

    -- Calculate and return the occupancy rate
    SELECT 
        CASE 
            WHEN @TotalAvailableRoomDays > 0 THEN 
                CAST((@TotalBookedRoomDays * 100.0) / (@TotalAvailableRoomDays+@TotalBookedRoomDays) AS DECIMAL(5, 2))
            ELSE 0
        END AS OccupancyRateForAppliedFilters;
END
GO

----- (2) ------

-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.
-- sort the date start by the date with the highest number of reservation following by the occupation rate.
-- fthinousa seira
CREATE PROCEDURE IdentifyHighOccupancyPeriods
    @PropertyTypeName NVARCHAR(50),
    @RoomTypeDescription NVARCHAR(50),
    @PropertyLocation NVARCHAR(50)
AS
BEGIN
    -- Set start and end dates for the year 2023
    DECLARE @StartDate DATE = '2023-01-01';
    DECLARE @EndDate DATE = '2023-12-31';

    -- Convert 'empty' string to NULL for filtering
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;

    ;WITH DateRange AS (
        SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
            DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY a.object_id) - 1, @StartDate) AS DateValue
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ),
    OccupancyData AS (
        SELECT
            dr.DateValue AS OccupancyDate,
            ISNULL((SELECT SUM(S.Stock_Amount)
                FROM STOCK S
                INNER JOIN PRODUCT PR ON S.Product_ID = PR.Product_ID
                INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
                INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
                INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
                WHERE 
                    S.Stock_Date = dr.DateValue AND
                    (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
                    (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
                    (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
            ), 0) AS TotalAvailableRoomDays,
            ISNULL((SELECT COUNT(*)
                FROM RESERVATIONS R
                INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
                INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
                INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
                INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
                WHERE 
                    R.Reservation_Date = dr.DateValue AND
                    (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
                    (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
                    (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation) AND
                    R.Reservation_Status = 'Upcoming'
            ), 0) AS TotalBookedRoomDays
        FROM DateRange dr
    )
    SELECT 
        OccupancyDate,
        CAST(FLOOR(
            CASE 
                WHEN TotalAvailableRoomDays > 0 THEN 
                   ((TotalBookedRoomDays ) * 100.0/ (TotalAvailableRoomDays+TotalBookedRoomDays))
                ELSE 0 
            END * 100) / 100.0 AS DECIMAL(10,2)) AS OccupancyRate
    FROM OccupancyData
    WHERE 
        CAST(FLOOR(
            CASE 
                WHEN TotalAvailableRoomDays > 0 THEN 
                    ((TotalBookedRoomDays ) * 100.0/ (TotalAvailableRoomDays+TotalBookedRoomDays))
                ELSE 0 
            END * 100) / 100.0 AS DECIMAL(10,2)) >= 40.0
END;
GO

----- (3) ------
--Calculates total Reservations and total Stock. TotalReservations/TotalStock*100
CREATE PROCEDURE CompareOccupancyRatesByRoomType
    @StartDate DATE,
    @EndDate DATE,
    @PropertyLocation NVARCHAR(255),  
    @PropertyTypeName NVARCHAR(255)   
AS
BEGIN
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    SELECT 
        RT.Room_Type_Description,
        (SUM(ISNULL(S.Stock_Amount, 0))+COUNT(R.Reservation_ID) )AS TotalStock,
        COUNT(R.Reservation_ID) AS BookedRooms,
        CAST(CASE 
            WHEN SUM(ISNULL(S.Stock_Amount, 0)) > 0 THEN 
                (COUNT(R.Reservation_ID) * 100.0) / (SUM(ISNULL(S.Stock_Amount, 0))+COUNT(R.Reservation_ID))
            ELSE 0 
        END AS DECIMAL(5, 2)) AS OccupancyRate
    FROM 
        ROOM_TYPE RT
    LEFT JOIN PRODUCT PR ON RT.Room_Type_ID = PR.Room_Type_ID
    LEFT JOIN STOCK S ON PR.Product_ID = S.Product_ID AND S.Stock_Date BETWEEN @StartDate AND @EndDate
    LEFT JOIN RESERVATIONS R ON PR.Product_ID = R.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
    LEFT JOIN PROPERTY P ON PR.Property_ID = P.Property_ID  -- Linking to property
    LEFT JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID -- Linking to property type
    WHERE 
        (P.Property_Location = @PropertyLocation OR @PropertyLocation IS NULL) AND 
        (PT.Property_Type_Name = @PropertyTypeName OR @PropertyTypeName IS NULL)
    GROUP BY 
        RT.Room_Type_Description
    ORDER BY 
        OccupancyRate DESC;
END

GO

-----------------------------------------------
 --     RATING AND EVALUATION REPORTS        --
-----------------------------------------------

----- (1) ------

-- Average rating and number of reviews for each property
CREATE PROCEDURE GetAverageRatingAndReviews
AS
BEGIN
    SELECT 
        P.Property_ID, 
        P.Property_Name, 
        AVG(R.Review_Rating) AS Average_Rating, 
        COUNT(R.Review_ID) AS Number_Of_Reviews
    FROM 
        PROPERTY P
    LEFT JOIN 
        PRODUCT PR ON P.Property_ID = PR.Property_ID
    LEFT JOIN 
        RESERVATIONS RV ON PR.Product_ID = RV.Product_ID
    LEFT JOIN 
        REVIEWS R ON RV.Review_ID = R.Review_ID
    WHERE 
        R.Review_ID IS NOT NULL 
    GROUP BY 
        P.Property_ID, 
        P.Property_Name
    ORDER BY Property_ID
END
GO

----- (2) ------

-- Stored procedure that returns the highest and lowest average rated properties
CREATE PROCEDURE IdentifyPropertiesByRating
AS
BEGIN
    WITH RatedProperties AS (
        SELECT 
            P.Property_ID, 
            P.Property_Name, 
            AVG(R.Review_Rating) AS AverageRating
        FROM 
            PROPERTY P
        LEFT JOIN PRODUCT PR ON P.Property_ID = PR.Property_ID
        LEFT JOIN RESERVATIONS RV ON PR.Product_ID = RV.Product_ID
        LEFT JOIN REVIEWS R ON RV.Review_ID = R.Review_ID
        WHERE 
            R.Review_ID IS NOT NULL
        GROUP BY 
            P.Property_ID, P.Property_Name
    )
    SELECT * FROM RatedProperties
    WHERE AverageRating = (SELECT MAX(AverageRating) FROM RatedProperties)
    OR AverageRating = (SELECT MIN(AverageRating) FROM RatedProperties);
END
GO


-----------------------------------------------
 --     ROOM AVAILABILITY REPORT             --
-----------------------------------------------

----- (1) ------

-- Stored procedure that returns the total stock, the occupied stock, and the occupancy rate with the applied filters.
CREATE PROCEDURE OverviewOfRoomTypeInventoryAndOccupancy
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeName NVARCHAR(50),
    @RoomTypeDescription NVARCHAR(50),
    @PropertyLocation NVARCHAR(50)
AS
BEGIN
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
    IF (@RoomTypeDescription = 'empty')
        SET @RoomTypeDescription = NULL;
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;

    -- Directly select the inventory and occupancy data
    SELECT 
        RT.Room_Type_ID, 
        RT.Room_Type_Description, 
        SUM(S.Stock_Amount) AS TotalStock,
        COUNT(RV.Reservation_ID) AS OccupiedStock,
        ( SUM(S.Stock_Amount)+COUNT(RV.Reservation_ID)) AS TotalAvailableStock
        
        -- CASE WHEN SUM(S.Stock_Amount) > 0 THEN 
        --      CAST((COUNT(RV.Reservation_ID) * 100.0) / SUM(S.Stock_Amount) AS DECIMAL(5, 2))
        --      ELSE 0 END AS OccupancyRate
    FROM 
        ROOM_TYPE RT
    LEFT JOIN 
        PRODUCT PR ON RT.Room_Type_ID = PR.Room_Type_ID
    LEFT JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    LEFT JOIN 
        STOCK S ON PR.Product_ID = S.Product_ID AND S.Stock_Date BETWEEN @StartDate AND @EndDate
    LEFT JOIN 
        RESERVATIONS RV ON PR.Product_ID = RV.Product_ID AND RV.Reservation_Date BETWEEN @StartDate AND @EndDate
    WHERE 
        (@PropertyTypeName IS NULL OR  (SELECT Property_Type_Name FROM [dbo].[PROPERTY_TYPE] WHERE Property_Type_ID=P.Property_Type_ID)= @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        RT.Room_Type_ID, 
        RT.Room_Type_Description
	ORDER BY RT.Room_Type_ID
END;
GO

-----------------------------------------------
 --          PERFORMANCE REPORTS             --
-----------------------------------------------


CREATE PROCEDURE spGetProperties
    AS
    BEGIN
    SELECT Property_ID, Property_Name
    FROM [dbo].[PROPERTY]
END
GO

----- (1) ------

-- this store procedure returns rooms that where BOOKED EVERY DAY IN THE SPECIFIC PERIOD AS "FULLY BOOKED"
-- it also returns rooms that where NEVER BOOKED IN THE SPECIFIC PERIOD AS "NEVER BOOKED"
CREATE PROCEDURE GetPropertyRoomBookingStatus
    @Property_ID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Select rooms that were booked every day within the specified period
     SELECT 
        PR.Product_ID, 
        PR.Product_Description, 
        'Fully Booked' AS BookingStatus
    FROM 
        PRODUCT PR
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    WHERE 
        P.Property_ID = @Property_ID AND
        NOT EXISTS (
            SELECT 1
            FROM STOCK S
            WHERE S.Product_ID = PR.Product_ID AND 
                  S.Stock_Date BETWEEN @StartDate AND @EndDate AND
                  S.Stock_Amount > 0
        )
    UNION ALL

    -- Select rooms that had no bookings within the same period
    SELECT 
        PR.Product_ID, 
        PR.Product_Description, 
        'Never Booked' AS BookingStatus
    FROM 
        PRODUCT PR
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        P.Property_ID = @Property_ID AND
        NOT EXISTS (
            SELECT 1
            FROM RESERVATIONS R
            WHERE R.Product_ID = PR.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
        )
END
GO

----- (2) ------

-- Stored procedure for generating a report of all rooms in a specific property that had at least ONE BOOKING EACH MONTH of a given calendar year
CREATE PROCEDURE GetRoomsWithMonthlyBookings
    @Property_ID INT,
    @Year INT
AS
BEGIN
    -- Select rooms that were booked at least once every month
    SELECT 
        PR.Product_ID, 
        PR.Product_Description
    FROM 
        PRODUCT PR
    INNER JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    WHERE 
        PR.Property_ID = @Property_ID AND
        12 = ( -- Check if the room was booked in all 12 months of the year
            SELECT COUNT(DISTINCT MONTH(RV.Reservation_Date))
            FROM RESERVATIONS RV
            WHERE 
                RV.Product_ID = PR.Product_ID AND 
                YEAR(RV.Reservation_Date) = @Year
        )
END
GO

----- (3) ------

CREATE PROCEDURE GetRoomsWithMinBookings
    @PropertyID INT,
    @Year INT,
    @MinBookings INT
AS
BEGIN
    -- Select rooms that meet or exceed the minimum booking threshold for a specific property
    SELECT 
        PR.Product_ID,
        PR.Product_Description, 
        COUNT(DISTINCT RV.Reservation_ID) AS NumberOfBookings
    FROM 
        PRODUCT PR
    LEFT JOIN 
        RESERVATIONS RV ON PR.Product_ID = RV.Product_ID AND YEAR(RV.Reservation_Date) = @Year
    WHERE 
        PR.Property_ID = @PropertyID
    GROUP BY 
        PR.Product_ID, 
        PR.Product_Description
    HAVING 
        COUNT(DISTINCT RV.Reservation_ID) >= @MinBookings;
END
GO

CREATE PROCEDURE test1
AS
 
BEGIN
DECLARE @PID INT = (SELECT TOP 1 Product_ID FROM [dbo].[PRODUCT] ORDER BY Product_ID DESC )

INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-01-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-02-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-03-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-04-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-05-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-06-30', 0);
END
GO

CREATE PROCEDURE test2
AS
BEGIN
DECLARE @PID INT = (SELECT TOP 1 Product_ID FROM [dbo].[PRODUCT] ORDER BY Product_ID DESC )

INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-07-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-08-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-09-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-10-31', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-11-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-01', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-02', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-03', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-04', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-05', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-06', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-07', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-08', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-09', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-10', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-11', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-12', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-13', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-14', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-15', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-16', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-17', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-18', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-19', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-20', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-21', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-22', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-23', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-24', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-25', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-26', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-27', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-28', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-29', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-30', 0);
INSERT INTO [dbo].[STOCK] (Product_ID, Stock_Date, Stock_Amount) VALUES (@PID, '2023-12-31', 0);
END
GO
