---------------------------------------------------------------------------------------
     --                             REPORTS                                      --
---------------------------------------------------------------------------------------


-------------------------------------
     --       REVENUE REPORT       --
-------------------------------------

-- Checked and working
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


-----------------------------------------
     --  BOOKING STATISTICS REPORTS    --
-----------------------------------------
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
        (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation)
    GROUP BY 
        PT.Property_Type_Name, 
        RT.Room_Type_Description, 
        P.Property_Location
END
GO

-----------------------------------------
     --  BOOKING STATISTICS REPORTS    --
-----------------------------------------
-- Stored procedure that for the specified property,room and location returns the total number of reservations

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

--ELEGXEI TO POSOSTO TON RESERVATIONS TOY KATHE PROPERTY TYPE SE SXESI ME TA TOTAL RESERVATION. 
--Diladi to pososto ton reservations gia kathe property type.

-- STORED PROCEDURE FOR THE COMPARISON OF RESERVATION TRENDS-----

-- For each property, count the number of reservations and the percentage of total reservations for each property type.
-- reservation count by the total reservation count and then * 100.
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

-- CREATE PROCEDURE CompareReservationTrends
--     @StartDate DATE,
--     @EndDate DATE
-- AS
-- BEGIN
--     CREATE TABLE #ReservationCounts (
--         Property_Type_ID INT,
--         ReservationCount INT
--     );

--     DECLARE #ReservationCounts ReservationCountType;

--     INSERT INTO #ReservationCounts (Property_Type_ID, ReservationCount)
--     SELECT 
--         PT.Property_Type_ID, 
--         COUNT(R.Reservation_ID) 
--     FROM 
--         PROPERTY_TYPE PT
--     JOIN 
--         PROPERTY P ON PT.Property_Type_ID = P.Property_Type_ID
--     JOIN 
--         PRODUCT PR ON P.Property_ID = PR.Property_ID
--     JOIN 
--         RESERVATIONS R ON PR.Product_ID = R.Product_ID
--     WHERE 
--         (@StartDate IS NULL OR R.Reservation_Date >= @StartDate) AND
--         (@EndDate IS NULL OR R.Reservation_Date <= @EndDate)
--     GROUP BY 
--         PT.Property_Type_ID;

--     DECLARE @TotalReservations INT;
--     SELECT @TotalReservations = SUM(ReservationCount) FROM #ReservationCounts;

--     SELECT 
--         PT.Property_Type_Name,
--         RC.ReservationCount,
--         CAST((RC.ReservationCount * 100.0) / @TotalReservations AS DECIMAL(5, 2)) AS Percentage
--     FROM 
--         #ReservationCounts RC
--     JOIN 
--         PROPERTY_TYPE PT ON RC.Property_Type_ID = PT.Property_Type_ID
--     WHERE 
--         @TotalReservations > 0;

--     DROP TABLE #ReservationCounts;
-- END
-- GO


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

-- based on the filters, we count the total available rooms and the total booked rooms, then we calculate the occupancy rate

-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.
GO
-- DEN FENONTAI TA PROPERTIES KLP,, TIPONEI MONO MIA STILI ME TO OCCUPANCY RATE!!!!

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
        (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

    -- Calculate and return the occupancy rate
    SELECT 
        CASE 
            WHEN @TotalAvailableRoomDays > 0 THEN 
                CAST((@TotalBookedRoomDays * 100.0) / @TotalAvailableRoomDays AS DECIMAL(5, 2))
            ELSE 0
        END AS OccupancyRateForAppliedFilters;
END
GO


--CHECKED AND WORKING
-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.


-- sort the date start by the date with the highest number of reservation following by the occupation rate.
-- fthinousa seira

CREATE PROCEDURE IdentifyHighOccupancyPeriods
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        S.Stock_Date AS OccupancyDate,
        SUM(S.Stock_Amount) + (SELECT COUNT(*) FROM RESERVATIONS R WHERE R.Reservation_Date = S.Stock_Date) AS Total_Occupancy,
        (SELECT COUNT(*) FROM RESERVATIONS R WHERE R.Reservation_Date = S.Stock_Date) AS BookedRooms,
        CAST(CASE 
            WHEN SUM(S.Stock_Amount) + (SELECT COUNT(*) FROM RESERVATIONS R WHERE R.Reservation_Date = S.Stock_Date) > 0 THEN 
                ((SELECT COUNT(*) FROM RESERVATIONS R WHERE R.Reservation_Date = S.Stock_Date) * 100.0) / 
                (SUM(S.Stock_Amount) + (SELECT COUNT(*) FROM RESERVATIONS R WHERE R.Reservation_Date = S.Stock_Date))
            ELSE 0 
        END AS DECIMAL(5, 2)) AS OccupancyRate
    FROM 
        STOCK S
    WHERE 
        S.Stock_Date BETWEEN @StartDate AND @EndDate
    GROUP BY 
        S.Stock_Date
    ORDER BY 
        OccupancyRate DESC, OccupancyDate;
END
GO

-- CHECKED AND WORKING

-- This stored procedure compares how full are each room type in a specific time period.
-- For every room_type, Show their occupancy rate for the given period. (also total stock and booked rooms are showed).

CREATE PROCEDURE CompareOccupancyRatesByRoomType
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        RT.Room_Type_Description,
        SUM(ISNULL(S.Stock_Amount, 0)) AS TotalStock,
        COUNT(R.Reservation_ID) AS BookedRooms,
        CAST(CASE 
            WHEN SUM(ISNULL(S.Stock_Amount, 0)) > 0 THEN 
                (COUNT(R.Reservation_ID) * 100.0) / SUM(ISNULL(S.Stock_Amount, 0))
            ELSE 0 
        END AS DECIMAL(5, 2)) AS OccupancyRate
    FROM 
        ROOM_TYPE RT
    LEFT JOIN PRODUCT PR ON RT.Room_Type_ID = PR.Room_Type_ID
    LEFT JOIN STOCK S ON PR.Product_ID = S.Product_ID AND S.Stock_Date BETWEEN @StartDate AND @EndDate
    LEFT JOIN RESERVATIONS R ON PR.Product_ID = R.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
    GROUP BY 
        RT.Room_Type_Description
    ORDER BY 
        OccupancyRate DESC;
END


GO


-----------------------------------------------
 --     RATING AND EVALUATION REPORTS        --
-----------------------------------------------

-- CHECKED AND WORKING.

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
        R.Review_ID IS NOT NULL 
    GROUP BY 
        P.Property_ID, 
        P.Property_Name
END
GO

-- MAYBE WORKING ?? NEED TO CHECK LOGIC AGAIN 

-- Stored procedure that returns the highest and lowest rated properties

CREATE PROCEDURE IdentifyPropertiesByRating
AS
BEGIN
    SELECT 
        P.Property_ID, 
        P.Property_Name, 
        AVG(CAST(R.Review_Rating AS DECIMAL(5, 2))) AS AverageRating
    FROM 
        PROPERTY P
    LEFT JOIN PRODUCT PR ON P.Property_ID = PR.Property_ID
    LEFT JOIN RESERVATIONS RV ON PR.Product_ID = RV.Product_ID
    LEFT JOIN REVIEWS R ON RV.Review_ID = R.Review_ID
    WHERE 
        R.Review_ID IS NOT NULL
    GROUP BY 
        P.Property_ID, 
        P.Property_Name
    ORDER BY 
        AverageRating DESC;
END



GO

-----------------------------------------------
 --     ROOM AVAILABILITY REPORT             --
-----------------------------------------------

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
        (@PropertyTypeName IS NULL OR P.Property_Type_Name = @PropertyTypeName) AND
        (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
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


-----------------------------------------------
 --     PERFORMANCE REPORTS                  --
-----------------------------------------------

-- THE FIRLTERS HERE DONT APPLY AS THE PREVIOUS ONES. PROPERTY TYPE NAME IS MANDATORY.

-- this store procedure returns rooms that where BOOKED EVERY DAY IN THE SPECIFIC PERIOD AS "FULLY BOOKED"
-- it also returns rooms that where NEVER BOOKED IN THE SPECIFIC PERIOD AS "NEVER BOOKED"

CREATE PROCEDURE GetPropertyRoomBookingStatus
    @PropertyTypeName NVARCHAR(255),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Check for 'empty' input and set to NULL
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;

    -- Select rooms that were booked every day within the specified period
    SELECT 
        PR.Product_ID, 
        PR.Product_Description, 
        'Fully Booked' AS BookingStatus
    FROM 
        PRODUCT PR
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        PT.Property_Type_Name = @PropertyTypeName AND
        NOT EXISTS (
            SELECT DISTINCT S.Stock_Date
            FROM STOCK S
            WHERE S.Product_ID = PR.Product_ID AND S.Stock_Date BETWEEN @StartDate AND @EndDate
            EXCEPT
            SELECT R.Reservation_Date
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
    INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        PT.Property_Type_Name = @PropertyTypeName AND
        NOT EXISTS (
            SELECT 1
            FROM RESERVATIONS R
            WHERE R.Product_ID = PR.Product_ID AND R.Reservation_Date BETWEEN @StartDate AND @EndDate
        )
END



GO

-- Stored procedure for generating a report of all rooms in a specific property that had at least ONE BOOKING EACH MONTH of a given calendar year
-- cannot have null property id (diladi na tiponei gia ola ta ids)

CREATE PROCEDURE GetRoomsWithMonthlyBookings
    @PropertyTypeName NVARCHAR(255),
    @Year INT
AS
BEGIN
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;

    -- Select rooms that were booked at least once every month
    SELECT 
        PR.Product_ID, 
        PR.Product_Description
    FROM 
        PRODUCT PR
    INNER JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    INNER JOIN 
        PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
    WHERE 
        PT.Property_Type_Name = @PropertyTypeName AND
        12 = ( -- Check if the room was booked in all 12 months of the year
            SELECT COUNT(DISTINCT MONTH(RV.Reservation_Date))
            FROM RESERVATIONS RV
            WHERE 
                RV.Product_ID = PR.Product_ID AND 
                YEAR(RV.Reservation_Date) = @Year
        )
END


-- Alternative to the previous one but now we have minimum number of booking per month
GO

CREATE PROCEDURE GetRoomsWithMinBookings
    @PropertyName NVARCHAR(255),
    @Year INT,
    @MinBookings INT
AS
BEGIN
    SELECT 
        PR.Product_ID, 
        PR.Product_Description, 
        COUNT(DISTINCT RV.Reservation_ID) AS NumberOfBookings
    FROM 
        PRODUCT PR
    INNER JOIN 
        PROPERTY P ON PR.Property_ID = P.Property_ID
    LEFT JOIN 
        RESERVATIONS RV ON PR.Product_ID = RV.Product_ID AND YEAR(RV.Reservation_Date) = @Year
    WHERE 
        P.Property_Name = @PropertyName
    GROUP BY 
        PR.Product_ID, 
        PR.Product_Description
    HAVING 
        COUNT(DISTINCT RV.Reservation_ID) >= @MinBookings;
END
