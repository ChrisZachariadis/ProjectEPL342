

EXEC getProductsBasedOnFilters @Property_LocationA='Athens' ,@Room_TypeA='',@Property_Type_NameA='' ,@StartDateA='', @EndDateA=''
GO

SELECT *
FROM [dbo].[TempResultsFinal]


GO


-----Check for adding user properly------

SELECT *
FROM [dbo].[USER]

GO

EXEC spRegister_User
    @User_ID = 6,                
    @Date_of_Birth = '08/09/2003', 
    @First_Name = 'Chris',          
    @Last_Name = 'TheGreat',          
    @Email = 'mynameisChris@email.com', 
    @Passwd = 'password1245',       
    @Gender = 'M',               
    @Approved = '1';               

---Check for user login-----

EXEC spLOGIN 
    @Email = 'gfeatenby4@army.mil', -- Replace with the actual user email
    @Passwd = '15830422865982700720'; -- Replace with the actual user password

GO

-- Return user_type for the given user_id

EXEC spGetUserType @User_ID = 2;

GO


------Insert product with new Product_ID-----

EXEC spInsert_Product
    @Product_ID = 41, -- Replace with the actual Product ID
    @Product_Price = 500.00, -- Replace with the actual Product Price
    @Max_Guests = 4, -- Replace with the actual Maximum Number of Guests
    @Product_Description = N'mountain view', -- Replace with the actual Product Description
    @Room_Type_ID = 16, -- Replace with the actual Room Type ID
    @Property_ID = 2; -- Replace with the actual Property ID

GO

SELECT *
FROM [dbo].[PRODUCT]

GO
----Edit product with given Product ID ------

EXEC spEdit_Product
    @Product_ID = 41, -- Replace with the Product ID of the product you want to edit
    @Product_Price = 180.00, -- Replace with the new Product Price
    @Max_Guests = 5, -- Replace with the new Maximum Number of Guests
    @Product_Description = N'traxanas view', -- Replace with the new Product Description
    @Room_Type_ID = 3, -- Replace with the new Room Type ID
    @Property_ID = 9; -- Replace with the new Property ID
	GO

---Insert Property with new Property_ID------??????????????????? CHECK NOTES
EXEC spInsert_Property
    @Property_ID = 11, -- Replace with the actual Property ID
    @Property_Name = 'Ocean View Villa', -- Replace with the actual Property Name
    @Property_Address = '123 Beachside Blvd', -- Replace with the actual Property Address
    @Property_Description = 'Seaside', -- Replace with the actual Property Description
    @Property_Coordinates = '37.7749,-122.4194', -- Replace with the actual Property Coordinates
    @Property_Location = 'San Francisco', -- Replace with the actual Property Location
    @Owner_ID = 7, -- Replace with the actual Owner ID
    @Owner_First_Name = 'Jane', -- Replace with the actual Owner's First Name
    @Owner_Last_Name = 'Doe', -- Replace with the actual Owner's Last Name
    @Property_Type_ID = 301, -- Replace with the actual Property Type ID
    @User_ID = 401; -- Replace with the actual User ID

GO
SELECT *
FROM [dbo].[PROPERTY]
GO

---Edit property with giben Property ID--------

EXEC spUpdate_Property
    @Property_ID = 1, -- Replace with the Property ID of the property you want to edit
    @Property_Name = 'Updated Ocean View Villa', -- Replace with the new Property Name
    @Property_Address = '123 Updated Beachside Blvd', -- Replace with the new Property Address
    @Property_Description = 'Updated Seaside', -- Replace with the new Property Description
    @Property_Coordinates = '37.7749,-122.4194', -- Replace with the updated Property Coordinates
    @Property_Location = 'Rhodes', -- Replace with the updated Property Location
    @Owner_ID = 202, -- Replace with the updated Owner ID
    @Owner_First_Name = 'John', -- Replace with the updated Owner's First Name
    @Owner_Last_Name = 'Smith', -- Replace with the updated Owner's Last Name
    @Property_Type_ID = 3, -- Replace with the updated Property Type ID
    @User_ID = 1; -- Replace with the updated User ID



--- View the property owners that are not approved yet. ----

EXEC spViewUnapprovedPropertyOwners;



-- Edit unapproved property owner with the given user_id. (admin)

EXEC spApproveUnapprovedOwnersByID @User_ID = 1;

GO

-- view reservations for a given product_id and user_id

EXEC spViewReservations @Product_ID = 1, @User_ID = 1;





------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR FORMS ----------------------------------------------------------------
------------ STORE PROCEDURES FOR REVENUE ----------------------------------------------------------------



GO
EXEC RevenueReport
    @StartDate = '1/1/2023', 
    @EndDate = '12/30/2023',   
    -- anti id tha prepei na dinoume property_type_description kai roomtypeDescription
    @PropertyTypeID = NULL,    
    @RoomTypeID = NULL,         
    @PropertyLocation = NULL;  

GO

-- mou dinei ta total revenue gia to property 1,gia to 2023, gia ola ta diaforetika room_types kai gia ola ta diaforetika locations!!!!!!!!!!!!

EXEC RevenueReport
    @StartDate = '1/1/2023',  
    @EndDate = '12/30/2023',    
    @PropertyTypeID = 1,    
    @RoomTypeID = NULL,       
    @PropertyLocation = NULL;  

GO



-- EPAULI TOU CHRIS --- EXO RESERVATION GIA 2 MERES SE AUTO (IDIO REVIEW,PRODUCT ID) 
-- KAI TIPONEI SOSTA TO TOTAL REVENUE TOU


GO
INSERT INTO RESERVATIONS (Reservation_ID, Reservation_Date, Review_ID, User_ID, Product_ID) VALUES
(1, '1/5/2023', 1, 1, 1),
(2, '1/6/2023', 1, 1, 1),

(3, '1/15/2023', 1, 1, 6),

(4, '1/20/2023', 1, 4, 6),
(5, '1/25/2023', 1, 5, 5);

GO
INSERT INTO PRODUCT (Product_ID, Product_Price, Max_Guests, Product_Description, Room_Type_ID, Property_ID) VALUES
(1, 100.00, 2, 'Description1', 1, 1),
(2, 150.00, 4, 'Description2', 2, 2),
(3, 200.00, 3, 'Description3', 3, 3),
(4, 250.00, 2, 'Description4', 4, 4),
(5, 300.00, 4, 'Description5', 5, 5),

(6, 1000.00, 4, 'Description6', 2, 6);


GO

INSERT INTO PROPERTY (Property_ID, Property_Name, Property_Address, Property_Description, Property_Coordinates, Property_Location, Owner_ID, Owner_First_Name, Owner_Last_Name, Property_Type_ID, User_ID) VALUES
(1, 'Property1', 'Address1', 'OXTAPLO KREVATI', 'Coordinates1', 'AMERIKI', 1, 'Owner1', 'LastName1', 1, 3),

(2, 'Property2', 'Address2', 'Description2', 'Coordinates2', 'Location2', 2, 'Owner2', 'LastName2', 2, 2),
(3, 'Property3', 'Address3', 'Description3', 'Coordinates3', 'Location3', 3, 'Owner3', 'LastName3', 3, 3),
(4, 'Property4', 'Address4', 'Description4', 'Coordinates4', 'Location4', 4, 'Owner4', 'LastName4', 4, 4),
(5, 'Property5', 'Address5', 'Description5', 'Coordinates5', 'Location5', 5, 'Owner5', 'LastName5', 5, 5),

(6, 'Property6', 'Address6', 'Description6', 'Coordinates6', 'LONDINO', 1, 'Owner1', 'LastName1', 1, 1),

(7, 'Property7', 'Address7', 'Description7', 'Coordinates7', 'Location7', 5, 'Owner1', 'LastName1', 4, 2);


GO
INSERT INTO PROPERTY_TYPE (Property_Type_ID, Property_Type_Name) VALUES
(1, 'EPAULI TOU CHRIS'),
(2, 'Type2'),
(3, 'Type3'),
(4, 'TESTARO TOUTO TWra!!!'),
(5, 'Type5'),
(6, 'KOLOSPITO TOU PETTER');

GO
INSERT INTO ROOM_TYPE (Room_Type_ID, Room_Type_Description, Bed_Type) VALUES
(1, 'domatio polla striniariko', 'BedType1'),
(2, 'Description2', 'BedType2'),
(3, 'Description3', 'BedType3'),
(4, 'Description4', 'BedType4'),
(5, 'Description5', 'BedType5');

GO

INSERT INTO STOCK (Stock_Date, Product_ID, Stock_Amount) VALUES
('1/1/2023', 1, 10),
('1/1/2023', 2, 8),
('1/1/2023', 3, 6),
('1/1/2023', 4, 7),
('1/1/2023', 5, 5),
('1/1/2023', 6, 9),
('1/2/2023', 1, 11),
('1/2/2023', 2, 7),
('1/2/2023', 3, 8),
('1/2/2023', 4, 6);



--EXEC for reservations report---

EXEC AnalyzeNumberOfReservations @StartDate = '1/1/2023', @EndDate = '12/31/2023', @PropertyTypeID = NULL, @RoomTypeID = NULL, @PropertyLocation = 'Athens';


GO

EXEC CompareOccupancyRatesByRoomType 
    @StartDate = '2023-01-01', 
    @EndDate = '2023-01-31';



GO


EXEC CalculateOccupancyRate 
    @StartDate = '2023-01-01', 
    @EndDate = '2023-12-31',
    @PropertyTypeName = 'Hotel',  -- Replace with the desired property type name
    @RoomTypeDescription = 'Suite',  -- Replace with the desired room type description
    @PropertyLocation = 'Downtown';  -- Replace with the desired location
GO


EXEC CalculateCancellationRate 
    @StartDate = '2023-01-01', 
    @EndDate = '2023-12-31',
    @PropertyTypeName = 'Hotel', 
    @RoomTypeDescription = 'Suite', 
    @PropertyLocation = 'Downtown';

GO


--EXEC for reservation trends report---
EXEC CompareReservationTrends @StartDate = '1/1/2023', @EndDate = '12/31/2023';

GO

-- EXEC for cancellation rate report---

EXEC CalculateCancellationRate 
    @StartDate = '1/1/2023', 
    @EndDate = '12/31/2023', 
    @PropertyTypeID = NULL, 
    @RoomTypeID = NULL, 
    -- @PropertyLocation = 'Athens';
    @PropertyLocation = NULL;

    GO

    -- EXEC for occupancy rate report---

    EXEC CalculateOccupancyRate 
    @StartDate = '1/1/2023', 
    @EndDate = '12/31/2023', 
    @PropertyTypeID = NULL, 
    @RoomTypeID = NULL, 
    @PropertyLocation = NULL;

GO

EXEC IdentifyHighOccupancyPeriods @StartDate = '1/1/2023', @EndDate = '12/31/2023';

GO


EXEC GetRoomsWithMinBookings 
    @PropertyID = 6,  -- Replace with the actual property ID
    @Year = 2023,
    @MinBookings = 1;  -- Replace with the desired minimum number of bookings




