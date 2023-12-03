-------------------------------------
     --       REVENUE REPORT       --
-------------------------------------
<<<<<<< Updated upstream

--(1)

=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

----- (1) ------

-- Checked and working
-- Stored procedure that for the specified property,room and location returns the total number of reservations


=======
-- Get total number of reservations based on filters.
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream

----- (2) ------

=======
--COMPARE  RESERVATION TRENDS AMONG PROPERTY TYPES-----------------------------------------
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream

----- (3) ------

=======
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream

----- (1) ------

-- based on the filters, we count the total available rooms and the total booked rooms, then we calculate the occupancy rate
-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.


=======
-- based on the filters, we count the total available rooms and the total booked rooms, then we calculate the occupancy rate
-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.
-- DEN FENONTAI TA PROPERTIES KLP,, TIPONEI MONO MIA STILI ME TO OCCUPANCY RATE!!!!
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
----- (2) ------

-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.

=======
-- Stored procedure that returns the highest and lowest occupancy rates for each property type in a specific time.
>>>>>>> Stashed changes
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

    DECLARE @DateCursor DATE = @StartDate;
    DECLARE @TotalAvailableRoomDays INT;
    DECLARE @TotalBookedRoomDays INT;
    DECLARE @OccupancyRate DECIMAL(5, 2);

    -- Define a table variable to store high occupancy dates
    DECLARE @HighOccupancyDates TABLE (OccupancyDate DATE, OccupancyRate DECIMAL(5, 2));

    WHILE @DateCursor <= @EndDate
    BEGIN
        -- Reset counts for each date
        SET @TotalAvailableRoomDays = 0;
        SET @TotalBookedRoomDays = 0;

        -- Calculate total available room-days
        SELECT @TotalAvailableRoomDays = SUM(S.Stock_Amount)
        FROM STOCK S
        INNER JOIN PRODUCT PR ON S.Product_ID = PR.Product_ID
        INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
        INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
        INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
        WHERE 
            S.Stock_Date = @DateCursor AND
            (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
            (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
            (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

        -- Calculate total booked room-days
        SELECT @TotalBookedRoomDays = COUNT(*)
        FROM RESERVATIONS R
        INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
        INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
        INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
        INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
        WHERE 
            R.Reservation_Date = @DateCursor AND
            (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
            (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
            (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation) AND
            R.Reservation_Status = 'Upcoming';

        -- Calculate occupancy rate
        SET @OccupancyRate = CASE 
                                WHEN @TotalAvailableRoomDays > 0 THEN 
                                    (@TotalBookedRoomDays * 100.0) / @TotalAvailableRoomDays
                                ELSE 0
                             END;

        -- Insert into table variable if occupancy rate exceeds threshold
        IF @OccupancyRate >= 0.40
            INSERT INTO @HighOccupancyDates (OccupancyDate, OccupancyRate)
            VALUES (@DateCursor, @OccupancyRate);

        -- Move to next date
        SET @DateCursor = DATEADD(DAY, 1, @DateCursor);
    END;

    -- Output the accumulated results as a single result set
    SELECT * FROM @HighOccupancyDates;
END;
GO

<<<<<<< Updated upstream
----- (3) ------
=======
>>>>>>> Stashed changes


-- CREATE PROCEDURE IdentifyHighOccupancyPeriods
--     @PropertyTypeName NVARCHAR(50),
--     @RoomTypeDescription NVARCHAR(50),
--     @PropertyLocation NVARCHAR(50)
-- AS
-- BEGIN
--     -- Set start and end dates for the year 2023
--     DECLARE @StartDate DATE = '2023-01-01';
--     DECLARE @EndDate DATE = '2023-12-31';

--     -- Convert 'empty' string to NULL for filtering
--     IF (@PropertyTypeName = 'empty')
--         SET @PropertyTypeName = NULL;
--     IF (@RoomTypeDescription = 'empty')
--         SET @RoomTypeDescription = NULL;
--     IF (@PropertyLocation = 'empty')
--         SET @PropertyLocation = NULL;

--     DECLARE @DateCursor DATE = @StartDate;
--     DECLARE @TotalAvailableRoomDays INT;
--     DECLARE @TotalBookedRoomDays INT;
--     DECLARE @OccupancyRate DECIMAL(5, 2);

--     CREATE TABLE #HighOccupancyDates (OccupancyDate DATE, OccupancyRate DECIMAL(5, 2));

--     WHILE @DateCursor <= @EndDate
--     BEGIN
--         -- Reset counts for each date
--         SET @TotalAvailableRoomDays = 0;
--         SET @TotalBookedRoomDays = 0;

--         -- Calculate total available room-days
--         SELECT @TotalAvailableRoomDays = SUM(S.Stock_Amount)
--         FROM STOCK S
--         INNER JOIN PRODUCT PR ON S.Product_ID = PR.Product_ID
--         INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
--         INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
--         INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
--         WHERE 
--             S.Stock_Date = @DateCursor AND
--             (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
--             (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
--             (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation);

--         -- Calculate total booked room-days
--         SELECT @TotalBookedRoomDays = COUNT(*)
--         FROM RESERVATIONS R
--         INNER JOIN PRODUCT PR ON R.Product_ID = PR.Product_ID
--         INNER JOIN PROPERTY P ON PR.Property_ID = P.Property_ID
--         INNER JOIN PROPERTY_TYPE PT ON P.Property_Type_ID = PT.Property_Type_ID
--         INNER JOIN ROOM_TYPE RT ON PR.Room_Type_ID = RT.Room_Type_ID
--         WHERE 
--             R.Reservation_Date = @DateCursor AND
--             (@PropertyTypeName IS NULL OR PT.Property_Type_Name = @PropertyTypeName) AND
--             (@RoomTypeDescription IS NULL OR RT.Room_Type_Description = @RoomTypeDescription) AND
--             (@PropertyLocation IS NULL OR P.Property_Location = @PropertyLocation) AND
--             R.Reservation_Status = 'Upcoming';

--         -- Calculate occupancy rate
--         SET @OccupancyRate = CASE 
--                                 WHEN @TotalAvailableRoomDays > 0 THEN 
--                                     (@TotalBookedRoomDays * 100.0) / @TotalAvailableRoomDays
--                                 ELSE 0
--                              END;

--         -- Add to results if occupancy rate exceeds threshold
--         IF @OccupancyRate >= 0.40
--             INSERT INTO #HighOccupancyDates (OccupancyDate, OccupancyRate)
--             VALUES (@DateCursor, @OccupancyRate);

--         -- Move to next date
--         SET @DateCursor = DATEADD(DAY, 1, @DateCursor);
--     END;

--     -- Return the high occupancy dates
--     SELECT * FROM #HighOccupancyDates;
--     DROP TABLE #HighOccupancyDates;
-- END;
-- GO


CREATE PROCEDURE CompareOccupancyRatesByRoomType
    @StartDate DATE,
    @EndDate DATE,
<<<<<<< Updated upstream
    @PropertyLocation NVARCHAR(255),  
    @PropertyTypeName NVARCHAR(255)   
AS
BEGIN
=======
    @PropertyLocation NVARCHAR(255),   -- New parameter for Property Location
    @PropertyTypeName NVARCHAR(255)    -- Parameter for Property Type Name
AS
BEGIN

>>>>>>> Stashed changes
    IF (@PropertyLocation = 'empty')
        SET @PropertyLocation = NULL;
    IF (@PropertyTypeName = 'empty')
        SET @PropertyTypeName = NULL;
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
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

GO

-----------------------------------------------
 --     RATING AND EVALUATION REPORTS        --
-----------------------------------------------

<<<<<<< Updated upstream
----- (1) ------

-- Average rating and number of reviews for each property

=======
-- Average rating and reviews for each property
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
----- (2) ------

-- Stored procedure that returns the highest and lowest average rated properties

=======
-- Stored procedure that returns the highest and lowest rated properties
>>>>>>> Stashed changes
CREATE PROCEDURE IdentifyPropertiesByRating
AS
BEGIN
    WITH RatedProperties AS (
        SELECT 
            P.Property_ID, 
            P.Property_Name, 
<<<<<<< Updated upstream
            AVG(CAST(R.Review_Rating AS DECIMAL(5, 2))) AS AverageRating
=======
            AVG(R.Review_Rating) AS AverageRating
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream


-----------------------------------------------
 --     ROOM AVAILABILITY REPORT             --
-----------------------------------------------

----- (1) ------


=======
-----------------------------------------------
 --     ROOM AVAILABILITY REPORT             --
-----------------------------------------------
>>>>>>> Stashed changes
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
        ( SUM(S.Stock_Amount)-COUNT(RV.Reservation_ID)) AS TotalAvailableStock
        
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
<<<<<<< Updated upstream


=======
>>>>>>> Stashed changes
CREATE PROCEDURE spGetProperties
    AS
    BEGIN
    SELECT Property_ID, Property_Name
    FROM [dbo].[PROPERTY]
END
GO

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