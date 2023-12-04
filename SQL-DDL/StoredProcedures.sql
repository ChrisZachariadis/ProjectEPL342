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



