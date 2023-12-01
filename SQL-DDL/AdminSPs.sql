
-- -- USER REGISTRATION. ONLY CUSTOMERS CAN REGISTER (PROPERTY OWNER IS ADDED BY THE ADMIN)
-- CREATE PROCEDURE spRegister_User
--     @User_ID INT,
--     @Date_of_Birth DATE,
--     @First_Name VARCHAR(15),
--     @Last_Name VARCHAR(15),
--     @Email VARCHAR(50),
--     @Passwd VARCHAR(20),
--     @Gender CHAR(1),
--     @Approved CHAR(1)
-- AS
-- BEGIN
--     SET @First_Name = RTRIM(@First_Name);
--     SET @Last_Name = RTRIM(@Last_Name);
--     SET @Email = RTRIM(@Email);
--     SET @Passwd = RTRIM(@Passwd);

--     -- Check if the Email format is valid
--     IF @Email NOT LIKE '%@%.%'
--     BEGIN
--         RAISERROR ('Invalid Email format', 16, 1);
--         RETURN;
--     END
-- ELSE IF EXISTS (
--   SELECT *
--   FROM [dbo].[USER]
--   WHERE [Email] = @Email
-- ) BEGIN PRINT 'Error: Email already exists'
-- END
-- ELSE BEGIN
--     -- Insert customer data into the table with User_Type set to 'Customer'
--     INSERT INTO [dbo].[USER] 
--         (User_ID, Date_of_Birth, User_Type, First_Name, Last_Name, Email, Passwd, Gender, Approved)
--     VALUES 
--         (@User_ID, @Date_of_Birth, 'Customer', @First_Name, @Last_Name, @Email, @Passwd, @Gender, @Approved);
-- END
-- END


GO

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
    ELSE IF @User_Type = 'Property_Owner'
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
        -- Insert user data into the table with dynamic User_Type
        INSERT INTO [dbo].[USER] 
            (Date_of_Birth, User_Type, First_Name, Last_Name, Email, Passwd, Gender, Approved)
        VALUES 
            (@Date_of_Birth, @User_Type, @First_Name, @Last_Name, @Email, @Passwd, @Gender, @Approved);
    END
END;




GO

------------------USER LOGIN--------------------------------

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
          AND [Passwd] = @Passwd
    )
    BEGIN 
        PRINT 'Error: Invalid Email or password';
        -- It's generally not a good practice to print the hash of the password.
        -- The below line can be commented out or removed if not required.
        -- PRINT HASHBYTES('SHA2_256', @Passwd);
    END
    ELSE
    BEGIN
        -- Also return the user_id of the user who logged in
        SELECT [user_id],[User_Type],[Approved]
        FROM [dbo].[USER]
        WHERE [Email] = @Email
        AND [Passwd] = @Passwd;
    END
END;

GO

CREATE PROCEDURE spGetUserType
    @User_ID INT
AS
BEGIN
    -- Select User_Type for the given user_id
    SELECT User_Type
    FROM [dbo].[USER]
    WHERE user_id = @User_ID;
END;



-- GO
-- ---ADMIN LOGIN--------

-- CREATE PROCEDURE spADMINLOGIN @UserName VARCHAR(30),
--   @Passwd VARCHAR(20),
--   @Email VARCHAR(50) 
--   AS 
--   BEGIN
--   IF NOT EXISTS (
--     SELECT *
--     FROM [dbo].[USER]
--     WHERE [Email] = @Email AND @Email = 'administrator@gmail.com'
--       AND [Passwd] = @Passwd
--   )  BEGIN 
--     PRINT 'Error: Invalid email or password' 
--     PRINT HASHBYTES('SHA2_256', @Passwd)
--     END
--     ELSE
--     BEGIN
--         PRINT 'Admin Login successful';
--     END
-- END;



GO

-------ADMIN DASHBOARD // CAN ADD AND EDIT PRODUCTS USING PRODUCT_ID.--------

--Add a product with a new product_ID.
CREATE PROCEDURE spInsert_Product
    @Product_ID INT,
    @Product_Price DECIMAL(10, 2),
    @Max_Guests INT,
    @Product_Description NVARCHAR(MAX),
    @Room_Type_ID INT,
    @Property_ID INT
AS
BEGIN

    INSERT INTO [dbo].[PRODUCT] (Product_ID,Product_Price, Max_Guests, Product_Description, Room_Type_ID, Property_ID)
    VALUES (@Product_ID, @Product_Price, @Max_Guests, @Product_Description, @Room_Type_ID, @Property_ID);
END



GO
--Edit the product based on product_ID
CREATE PROCEDURE spEdit_Product
    @Product_ID INT,
    @Product_Price DECIMAL(10, 2),
    @Max_Guests INT,
    @Product_Description NVARCHAR(MAX),
    @Room_Type_ID INT,
    @Property_ID INT
AS
BEGIN
    UPDATE [dbo].[PRODUCT]
    SET Product_Price = @Product_Price,
        Max_Guests = @Max_Guests,
        Product_Description = @Product_Description,
        Room_Type_ID = @Room_Type_ID,
        Property_ID = @Property_ID
    WHERE Product_ID = @Product_ID;
END

GO


-- PROPERTY MANAGER // CAN ADD PROPERTY AND EDIT THE AVAILABILITY / PRICE  -- AN ADMIN NEEDS TO APPROVE HIS CHANGES 


-- GET properties that belong to the property owner with the given user_id. (property owner) 

CREATE PROCEDURE spGetPropertyOwnerProperties
    @User_ID INT
AS
BEGIN
    -- Select properties that belong to the user
    SELECT Property_ID, Property_Name, Property_Address, Property_Description, 
           Property_Coordinates, Property_Location, Owner_ID, Owner_First_Name, 
           Owner_Last_Name, Property_Type_ID
    FROM [dbo].[PROPERTY]
    WHERE User_ID = @User_ID;
END;

GO


CREATE PROCEDURE spInsert_Property
    @Property_ID INT,  
    @Property_Name VARCHAR(50),
    @Property_Address VARCHAR(50),
    @Property_Description VARCHAR(15),
    @Property_Coordinates VARCHAR(20),
    @Property_Location VARCHAR(20),
    @Owner_ID INT,
    @Owner_First_Name VARCHAR(15),
    @Owner_Last_Name VARCHAR(15),
    @Property_Type_ID INT,
    @User_ID INT
AS
BEGIN
    INSERT INTO [dbo].[PROPERTY] (
        Property_ID, Property_Name, Property_Address, Property_Description, Property_Coordinates, Property_Location,
        Owner_ID, Owner_First_Name, Owner_Last_Name, Property_Type_ID, User_ID
    )
    VALUES (
        @Property_ID, @Property_Name, @Property_Address, @Property_Description, @Property_Coordinates,
        @Property_Location, @Owner_ID, @Owner_First_Name, @Owner_Last_Name, @Property_Type_ID, @User_ID
    );
END;


GO
-- EDIT PROPERTY BASED ON THE PROPERTY_ID 

CREATE PROCEDURE spUpdate_Property
    @Property_ID INT,
    @Property_Name VARCHAR(50),
    @Property_Address VARCHAR(50),
    @Property_Description VARCHAR(15),
    @Property_Coordinates VARCHAR(20),
    @Property_Location VARCHAR(20),
    @Owner_ID INT,
    @Owner_First_Name VARCHAR(15),
    @Owner_Last_Name VARCHAR(15),
    @Property_Type_ID INT,
    @User_ID INT
AS
BEGIN
    UPDATE [dbo].[PROPERTY]
    SET 
        Property_Name = @Property_Name,
        Property_Address = @Property_Address,
        Property_Description = @Property_Description,
        Property_Coordinates = @Property_Coordinates,
        Property_Location = @Property_Location,
        Owner_ID = @Owner_ID,
        Owner_First_Name = @Owner_First_Name,
        Owner_Last_Name = @Owner_Last_Name,
        Property_Type_ID = @Property_Type_ID,
        User_ID = @User_ID
    WHERE Property_ID = @Property_ID;
END;



--- FOR OWNER --- VIEW THE REGISTERED PROPERTY OWNERS AND IF HE WANT HE CAN APPROVE THEM.
GO

CREATE PROCEDURE spViewUnapprovedPropertyOwners
AS
BEGIN
    SELECT User_ID, Date_of_Birth, First_Name, Last_Name, Email, Approved
    FROM [dbo].[USER]
    WHERE User_Type = 'Property Owner' AND Approved = 'N'
END;


GO

-- FOR OWNER --- APPROVE THE PROPERTY OWNER BASED ON THE USER_ID

CREATE PROCEDURE spApproveUnapprovedOwnersByID
    @User_ID INT
AS
BEGIN
    UPDATE [dbo].[USER]
    SET Approved = 'Y'
    WHERE User_ID = @User_ID
END;

GO

-- View reservations --- FOR OWNER --- Edit reservations.


CREATE PROCEDURE spViewReservations
    @Product_ID INT,
    @User_ID INT
AS
BEGIN
    SELECT Reservation_ID, Reservation_Date, Review_ID, User_ID, Product_ID
    FROM [dbo].[Reservations]
    WHERE Product_ID = @Product_ID AND User_ID = @User_ID
END;

GO


-----------------------------------FORMS------------------------
-----------------------------------FORMS------------------------
-----------------------------------FORMS------------------------
-----------------------------------FORMS------------------------


-- get the total revenue for given filters
CREATE PROCEDURE RevenueReport
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PropertyTypeID INT = NULL,
    @RoomTypeID INT = NULL,
    @PropertyLocation NVARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location, 
        SUM(PR.Product_Price) AS TotalRevenue
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
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
END

GO

CREATE PROCEDURE AnalyzeNumberOfReservations
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PropertyTypeID INT = NULL,
    @RoomTypeID INT = NULL,
    @PropertyLocation NVARCHAR(50) = NULL 
AS
BEGIN
    SELECT 
        COUNT(R.Reservation_ID) AS NumberOfReservations,
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
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
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
END


GO



-- STORED PROCEDURE FOR THE COMPARISON OF RESERVATION TRENDS-----

CREATE PROCEDURE CompareReservationTrends
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    -- Temporary table to store the count of reservations for each property type
    CREATE TABLE #ReservationCounts (
        Property_Type_ID INT,
        ReservationCount INT
    );

    -- Insert the reservation count for each property type
    INSERT INTO #ReservationCounts (Property_Type_ID, ReservationCount)
    SELECT 
        PT.Property_Type_ID, 
        COUNT(R.Reservation_ID) 
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
        PT.Property_Type_ID;

    -- Total reservations for the calculation of percentages
    DECLARE @TotalReservations INT;
    SELECT @TotalReservations = SUM(ReservationCount) FROM #ReservationCounts;

    -- Select percentages for each property type
    SELECT 
        PT.Property_Type_Name,
        RC.ReservationCount,
        CAST((RC.ReservationCount * 100.0) / @TotalReservations AS DECIMAL(5, 2)) AS Percentage
    FROM 
        #ReservationCounts RC
    JOIN 
        PROPERTY_TYPE PT ON RC.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        @TotalReservations > 0;

    -- Cleanup
    DROP TABLE #ReservationCounts;
END


GO

-- STORED PROCEDURE FOR THE CALCULATION OF CANCELLATION RATE-----

CREATE PROCEDURE CalculateCancellationRate
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PropertyTypeID INT = NULL,
    @RoomTypeID INT = NULL,
    @PropertyLocation NVARCHAR(50) = NULL
AS
BEGIN
    -- Assuming 'Status' column in RESERVATIONS indicates cancellation status

    DECLARE @TotalReservations INT;
    DECLARE @CancelledReservations INT;

    -- FIND THE TOTAL NUMBER OF RESERVATIONS FOR THE GIVEN FILTERS
    SELECT @TotalReservations = COUNT(*)
    FROM RESERVATIONS R
    INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- FIND THE TOTAL NUMBER OF CANCELLED RESERVATIONS FOR THE GIVEN FILTERS.
    SELECT @CancelledReservations = COUNT(*)
    FROM RESERVATIONS R
    INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        R.Status = 'Cancelled' AND
        (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
        (@EndDate IS NULL OR R.Reservation_Date <= @EndDate) AND
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
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

-- STORED PROCEDURE FOR THE CALCULATION OF OCCUPANCY RATE-----
-- based on the filters, we count the total available rooms and the total booked rooms, then we calculate the occupancy rate
CREATE PROCEDURE CalculateOccupancyRate
    @StartDate DATE,
    @EndDate DATE,
    @PropertyTypeID INT = NULL,
    @RoomTypeID INT = NULL,
    @PropertyLocation NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @TotalAvailableRoomDays INT;
    DECLARE @TotalBookedRoomDays INT;

    -- Calculate the total number of available room-days from the STOCK table
    SELECT @TotalAvailableRoomDays = SUM(S.Stock_Amount)
    FROM STOCK S
    INNER JOIN PRODUCT PR ON S.Product_ID = PR.Product_ID
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
    WHERE 
        S.Stock_Date BETWEEN @StartDate AND @EndDate AND
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
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
        (@PropertyTypeID IS NULL OR PT.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- total stock is the total available stock + total reserved stock.
    SET @TotalPotentialOccupancy = @TotalPotentialOccupancy + @TotalBookedRoomDays; 



    -- Calculate and return the occupancy rate
    SELECT 
        CASE 
            WHEN @TotalAvailableRoomDays > 0 THEN 
                CAST((@TotalBookedRoomDays * 100.0) / @TotalAvailableRoomDays AS DECIMAL(5, 2))
            ELSE 0
        END AS OccupancyRate;
END

GO

-----NOT CHECKED!!!!!!!!!!!!!------------

CREATE PROCEDURE IdentifyHighOccupancyPeriods
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Temporary table to store daily occupancy rates
    CREATE TABLE #DailyOccupancyRates (
        OccupancyDate DATE,
        OccupancyRate DECIMAL(5, 2)
    );

    -- Iterate through each day in the date range to calculate occupancy rate
    DECLARE @CurrentDate DATE = @StartDate;
    WHILE @CurrentDate <= @EndDate
    BEGIN
        DECLARE @TotalPotentialOccupancy INT;
        DECLARE @TotalBookedRoomDays INT;

        -- Calculate total potential occupancy for the current day
        SELECT @TotalPotentialOccupancy = ISNULL(SUM(Stock_Amount), 0)
        FROM STOCK
        WHERE Stock_Date = @CurrentDate;

        -- Calculate total booked room-days for the current day
        SELECT @TotalBookedRoomDays = COUNT(*)
        FROM RESERVATIONS
        WHERE Reservation_Date = @CurrentDate;

        -- Add the total booked room-days to the total potential occupancy
        SET @TotalPotentialOccupancy = @TotalPotentialOccupancy + @TotalBookedRoomDays;

        -- Calculate and store the occupancy rate for the current day
        INSERT INTO #DailyOccupancyRates (OccupancyDate, OccupancyRate)
        SELECT 
            @CurrentDate, 
            CASE 
                WHEN @TotalPotentialOccupancy > 0 THEN 
                    CAST((@TotalBookedRoomDays * 100.0) / @TotalPotentialOccupancy AS DECIMAL(5, 2))
                ELSE 0
            END;

        -- Move to the next day
        SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
    END

    -- Return the occupancy rates in descending order
    SELECT * FROM #DailyOccupancyRates
    ORDER BY OccupancyRate DESC, OccupancyDate;

    -- Cleanup
    DROP TABLE #DailyOccupancyRates;
END


GO


-- create PROCEDURE nicebro 

GO


-- Average rating and reviews for each property

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
        R.Review_ID IS NOT NULL  -- To consider only reservations with reviews
    GROUP BY 
        P.Property_ID, 
        P.Property_Name
END

GO


CREATE PROCEDURE IdentifyPropertiesByRating
AS
BEGIN
    -- Temporary table to store average ratings for each property
    CREATE TABLE #PropertyRatings (
        Property_ID INT,
        Property_Name NVARCHAR(255),
        AverageRating DECIMAL(5, 2)
    );

    -- Calculate average ratings for each property
    INSERT INTO #PropertyRatings (Property_ID, Property_Name, AverageRating)
    SELECT 
        P.Property_ID, 
        P.Property_Name, 
        AVG(R.Review_Rating) AS AverageRating
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
        P.Property_Name;

    -- Select properties with the highest ratings
    SELECT TOP 1 WITH TIES 
        Property_ID, 
        Property_Name, 
        AverageRating
    FROM 
        #PropertyRatings
    ORDER BY 
        AverageRating DESC;

    -- Select properties with the lowest ratings
    SELECT TOP 1 WITH TIES 
        Property_ID, 
        Property_Name, 
        AverageRating
    FROM 
        #PropertyRatings
    ORDER BY 
        AverageRating;

    -- Cleanup
    DROP TABLE #PropertyRatings;
END

GO


CREATE PROCEDURE OverviewOfRoomTypeInventoryAndOccupancy
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PropertyTypeID INT = NULL,
    @RoomTypeID INT = NULL,
    @PropertyLocation NVARCHAR(50) = NULL
AS
BEGIN
    -- Temporary table to store inventory and occupancy data
    CREATE TABLE #InventoryAndOccupancyData (
        Room_Type_ID INT,
        Room_Type_Description NVARCHAR(255),
        TotalStock INT,
        OccupiedStock INT,
        OccupancyRate DECIMAL(5, 2)
    );

    -- Calculate total stock, occupied stock, and occupancy rate for each room type within the date range
    INSERT INTO #InventoryAndOccupancyData (Room_Type_ID, Room_Type_Description, TotalStock, OccupiedStock, OccupancyRate)
    SELECT 
        RT.Room_Type_ID, 
        RT.Room_Type_Description, 
        SUM(S.Stock_Amount) AS TotalStock,
        COUNT(RV.Reservation_ID) AS OccupiedStock,
        CASE WHEN SUM(S.Stock_Amount) > 0 THEN 
             CAST((COUNT(RV.Reservation_ID) * 100.0) / SUM(S.Stock_Amount) AS DECIMAL(5, 2))
             ELSE 0 END AS OccupancyRate
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
        (@PropertyTypeID IS NULL OR P.Property_Type_ID = @PropertyTypeID) AND
        (@RoomTypeID IS NULL OR RT.Room_Type_ID = @RoomTypeID) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        RT.Room_Type_ID, 
        RT.Room_Type_Description;

    -- Select the inventory and occupancy data
    SELECT * FROM #InventoryAndOccupancyData;

    -- Cleanup
    DROP TABLE #InventoryAndOccupancyData;
END

GO


-------------ANAFORES APODOSIS------------------------------



-- this store procedure returns rooms that where BOOKED EVERY DAY IN THE SPECIFIC PERIOD AS "FULLY BOOKED"
-- it also returns rooms that where NEVER BOOKED IN THE SPECIFIC PERIOD AS "NEVER BOOKED"

CREATE PROCEDURE GetPropertyRoomBookingStatus
    @PropertyID INT,
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
    WHERE 
        PR.Property_ID = @PropertyID AND
        NOT EXISTS (
            SELECT 1
            FROM STOCK S
            WHERE S.Product_ID = PR.Product_ID AND S.Stock_Date BETWEEN @StartDate AND @EndDate
            EXCEPT
            SELECT 1
            FROM RESERVATIONS R
            WHERE R.Product_ID = PR.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
        )

    UNION ALL

    -- Select rooms that had no bookings within the same period
    SELECT 
        PR.Product_ID, 
        PR.Product_Description, 
        'Never Booked' AS BookingStatus
    FROM 
        PRODUCT PR
    WHERE 
        PR.Property_ID = @PropertyID AND
        NOT EXISTS (
            SELECT 1
            FROM RESERVATIONS R
            WHERE R.Product_ID = PR.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
        )
END

GO

-- stored procedure for generating a report of all rooms in a specific property that had at least ONE BOOKING EACH MONTH of a given calendar year
--cannot have null property id (diladi na tiponei gia ola ta ids)

CREATE PROCEDURE GetRoomsWithMonthlyBookings
    @PropertyID INT,
    @Year INT
AS
BEGIN
    -- Table to store rooms with at least one booking each month
    CREATE TABLE #RoomsMonthlyBooked (
        Product_ID INT,
        RoomBookedEveryMonth BIT
    );

    -- Initialize the table with all rooms set to 'booked every month' (1)
    INSERT INTO #RoomsMonthlyBooked (Product_ID, RoomBookedEveryMonth)
    SELECT Product_ID, 1
    FROM PRODUCT
    WHERE Property_ID = @PropertyID;

    -- Check each month for bookings
    DECLARE @Month INT = 1;
    WHILE @Month <= 12
    BEGIN
        -- Update status for rooms that were not booked in a given month
        UPDATE #RoomsMonthlyBooked
        SET RoomBookedEveryMonth = 0
        FROM #RoomsMonthlyBooked RMB
        WHERE RMB.Product_ID NOT IN (
            SELECT RV.Product_ID
            FROM RESERVATIONS RV
            WHERE RV.Product_ID = RMB.Product_ID 
            AND YEAR(RV.Reservation_Date) = @Year 
            AND MONTH(RV.Reservation_Date) = @Month
        )

        SET @Month = @Month + 1;
    END

    -- Select rooms that were booked every month
    SELECT PR.Product_ID, PR.Product_Description
    FROM #RoomsMonthlyBooked RMB
    JOIN PRODUCT PR ON RMB.Product_ID = PR.Product_ID
    WHERE RMB.RoomBookedEveryMonth = 1;

    -- Cleanup
    DROP TABLE #RoomsMonthlyBooked;
END




--alternative to the previous one but now we have minimum number of booking per month

GO

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





