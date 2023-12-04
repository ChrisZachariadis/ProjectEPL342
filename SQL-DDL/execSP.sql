---------------------------------------------------------------------------------------
     --                             REPORTS                                      --
---------------------------------------------------------------------------------------


EXEC RevenueReport
    @StartDate = '1/1/2023', 
    @EndDate = '12/31/2023',   
    @PropertyTypeName = 'Apartment',    
    @RoomTypeDescription = 'empty',         
    @PropertyLocation = 'empty';  

GO

EXEC AnalyzeNumberOfReservations 
@StartDate = '1/1/2023', 
@EndDate = '12/31/2023', 
@PropertyTypeName = 'empty', 
@RoomTypeDescription = 'empty', 
@PropertyLocation = 'Athens';

GO


EXEC CompareReservationTrends 
@StartDate = '1/1/2023', 
@EndDate = '12/31/2023';

GO

EXEC CalculateCancellationRate 
    @StartDate = '2023-01-01', 
    @EndDate = '2023-12-31',
    @PropertyTypeName = 'empty', 
    @RoomTypeDescription = 'empty', 
    @PropertyLocation = 'empty';

GO 


EXEC CalculateOccupancyRate 
    @StartDate = '1/1/2023', 
    @EndDate = '1/5/2023',
    @PropertyTypeName = 'empty', 
    @RoomTypeDescription = 'empty', 
    @PropertyLocation = 'empty';

GO

EXEC IdentifyHighOccupancyPeriods 
@StartDate = '1/1/2023',
@EndDate = '12/31/2023';

GO


EXEC CompareOccupancyRatesByRoomType
    @StartDate = '2023-01-01',          
    @EndDate = '2023-01-31',           
    @PropertyLocation = 'empty',   
    @PropertyTypeName = 'empty'      

GO

EXEC GetAverageRatingAndReviews;

GO

EXEC IdentifyPropertiesByRating;

GO

EXEC OverviewOfRoomTypeInventoryAndOccupancy 
    @StartDate = '1/1/2023', 
    @EndDate = '1/31/2023', 
    @PropertyTypeName = 'empty',
    @RoomTypeDescription = 'empty',
    @PropertyLocation = 'empty';
GO


--ANAFORES APODOSEIS:

EXEC GetPropertyRoomBookingStatus
    @Property_ID = 1,
    @StartDate = '1/1/2023', 
    @EndDate = '1/5/2023';

GO

EXEC GetRoomsWithMonthlyBookings 
    @Property_ID = 1, 
    @Year = 2023;
GO

EXEC GetRoomsWithMinBookings 
    @PropertyID = 1, 
    @Year = 2023,
    @MinBookings = 1;



