USE DB
CREATE TABLE [dbo].[USER] (
    User_ID INT IDENTITY (1,1),
    Date_of_Birth DATE NOT NULL,
    User_Type VARCHAR(15) NOT NULL,
    CHECK (
        User_Type IN ('Customer', 'Admin', 'Property Owner')
    ),
    First_Name VARCHAR(15) NOT NULL,
    Last_Name VARCHAR(15) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    CHECK (Email LIKE '%@%.%'),
    Passwd VARCHAR(20) NOT NULL,
    Gender CHAR(1) NOT NULL,
    Approved CHAR(1) NOT NULL,
    CONSTRAINT PK_USER PRIMARY KEY (User_ID)
);

CREATE TABLE [dbo].[PRODUCT] (
    Product_ID INT IDENTITY (1,1),
    Product_Price FLOAT NOT NULL,
    Max_Guests INT NOT NULL,
    CHECK (Max_Guests > 0),
    Product_Description VARCHAR(100) NOT NULL,
    --FKeys
    Room_Type_ID INT NOT NULL,
    Property_ID INT NOT NULL,
    CONSTRAINT Product_ID PRIMARY KEY (Product_ID)
);

CREATE TABLE [dbo].[MEAL_PLAN] (
    Meal_Plan_ID INT NOT NULL,
    Meal_Plan_Description VARCHAR(50) NOT NULL,
    CONSTRAINT Meal_Plan_ID PRIMARY KEY (Meal_Plan_ID)
);

CREATE TABLE [dbo].[PROPERTY] (
    Property_ID INT IDENTITY (1,1),
    Property_Name VARCHAR(50) NOT NULL,
    Property_Address VARCHAR(50) NOT NULL,
    Property_Description VARCHAR(100) NOT NULL,
    Property_Coordinates VARCHAR(20) NOT NULL,
    Property_Location VARCHAR(20) NOT NULL,
    Owner_ID INT NOT NULL,
    Owner_First_Name VARCHAR(15) NOT NULL,
    Owner_Last_Name VARCHAR(15) NOT NULL,
    --FKeys
    Property_Type_ID INT NOT NULL,
    User_ID INT NOT NULL,
    CONSTRAINT Property_ID PRIMARY KEY (Property_ID)
);

CREATE TABLE [dbo].[PROPERTY_TYPE] (
    Property_Type_ID INT NOT NULL,
    Property_Type_Name VARCHAR(50) NOT NULL,
    CONSTRAINT Property_Type_ID PRIMARY KEY (Property_Type_ID)
);

CREATE TABLE [dbo].[AMENITIES] (
    Amenity_ID INT NOT NULL,
    Amenity_Type VARCHAR(200) NOT NULL,
    CONSTRAINT Amenity_ID PRIMARY KEY (Amenity_ID)
);

CREATE TABLE [dbo].[ROOM_TYPE] (
    Room_Type_ID INT NOT NULL,
    Room_Type_Description VARCHAR(50) NOT NULL,
    Bed_Type VARCHAR(50) NOT NULL,
    CONSTRAINT Room_Type_ID PRIMARY KEY (Room_Type_ID)
);

CREATE TABLE [dbo].[FACILITIES] (
    Facility_ID INT NOT NULL,
    Facility_Type VARCHAR(200) NOT NULL,
    CONSTRAINT Facility_ID PRIMARY KEY (Facility_ID)
);

CREATE TABLE [dbo].[STOCK] (
    Stock_ID INT NOT NULL,
	--FK
	  Product_ID INT NOT NULL,
    Stock_Date DATE NOT NULL,
    Stock_Amount INT NOT NULL,
    CHECK (Stock_Amount >= 0),
    CONSTRAINT Stock_ID PRIMARY KEY (Stock_ID)
);

CREATE TABLE [dbo].[RESERVATIONS] (
    Reservation_ID INT IDENTITY (1,1),
    Reservation_Date DATE NOT NULL,
    
    --FKeys
    Review_ID INT,
    User_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    --
    Reservation_Status VARCHAR(15) DEFAULT 'Upcoming' ,
     CHECK (
        Reservation_Status IN ('Finished', 'Cancelled', 'Upcoming')
    ),
    Reservation_Fine FLOAT DEFAULT(0.0) ,
    CONSTRAINT Reservation_ID PRIMARY KEY (Reservation_ID)
);

CREATE TABLE [dbo].[REVIEWS] (
    Review_ID INT IDENTITY (1,1),
    Review_Description VARCHAR(170) NOT NULL,
    Review_Rating INT NOT NULL,
    CHECK (
        Review_Rating BETWEEN 0
        AND 5
    ),
    CONSTRAINT Review_ID PRIMARY KEY (Review_ID)
);

CREATE TABLE [dbo].[POLICY] (
    Policy_ID INT NOT NULL,
    Policy_Description VARCHAR(50) NOT NULL,
    CONSTRAINT Policy_ID PRIMARY KEY (Policy_ID)
);


USE DB
BULK 
	INSERT [dbo].[USER]
FROM 'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\USER.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

USE DB
BULK 
	INSERT [dbo].[PRODUCT] 
	FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\PRODUCT.csv' WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2

  );
GO

BULK
INSERT
    [dbo].MEAL_PLAN
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\MEAL_PLAN.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].PROPERTY
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\PROPERTY.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].PROPERTY_TYPE
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\PROPERTY_TYPE.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].AMENITIES
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\AMENITIES.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].ROOM_TYPE
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\ROOM_TYPE.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].FACILITIES
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\FACILITIES.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].STOCK
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\STOCK.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].RESERVATIONS
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\RESERVATIONS.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].REVIEWS
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\REVIEWS.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].[POLICY]
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\POLICY.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

-- MANY TO MANY RELATIONSHIPS
GO
    -- Product - Meal Plan relationship
    CREATE TABLE [dbo].[MEAL_PLAN_FOR_PRODUCT] (
        Product_ID INT NOT NULL,
        Meal_Plan_ID INT NOT NULL,
        CONSTRAINT PK_PRODUCT_MEAL_PLANS PRIMARY KEY (Product_ID, Meal_Plan_ID),
        CONSTRAINT FK_PMP_PRODUCT_ID FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID),
        CONSTRAINT FK__PMP_MEAL_ID FOREIGN KEY (Meal_Plan_ID) REFERENCES MEAL_PLAN(Meal_Plan_ID)
    );

-- Policy - Product relationship
CREATE TABLE [dbo].[PRODUCT_POLICIES] (
    MPolicy_ID INT NOT NULL,
    MProduct_ID INT NOT NULL,
    CONSTRAINT PK_PRODUCT_POLICIES PRIMARY KEY (MPolicy_ID, MProduct_ID),
    CONSTRAINT FK_PP_POLICY_ID FOREIGN KEY (MPolicy_ID) REFERENCES POLICY(Policy_ID),
    CONSTRAINT FK_PP_PRODUCT_ID FOREIGN KEY (MProduct_ID) REFERENCES PRODUCT(Product_ID)
);

-- Room Type - Amenity relationship
CREATE TABLE [dbo].[AMENITIES_ROOM_TYPE] (
    MAmenity_ID INT NOT NULL,
    MRoom_Type_ID INT NOT NULL,
    CONSTRAINT PK_AMENITIES_ROOM_TYPE PRIMARY KEY (MAmenity_ID, MRoom_Type_ID),
    CONSTRAINT FK_AR_MENITY_ID FOREIGN KEY (MAmenity_ID) REFERENCES AMENITIES(Amenity_ID),
    CONSTRAINT FK_AR_ROOM_TYPE_ID FOREIGN KEY (MRoom_Type_ID) REFERENCES ROOM_TYPE(Room_Type_ID)
);

-- PROPERTY - FACILITIES relationship
CREATE TABLE [dbo].[PROPERTY_FACILITIES] (
    MFacility_ID INT NOT NULL,
    MProperty_ID INT NOT NULL,
    CONSTRAINT PK_FACILITIES_PROPERTY PRIMARY KEY (MFacility_ID, MProperty_ID),
    CONSTRAINT FK_PF_FACILITY_ID FOREIGN KEY (MFacility_ID) REFERENCES FACILITIES(Facility_ID),
    CONSTRAINT FK_PF_PROPERTY_ID FOREIGN KEY (MProperty_ID) REFERENCES PROPERTY(Property_ID)
);

BULK
INSERT
    [dbo].[MEAL_PLAN_FOR_PRODUCT]
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\MEAL_PLAN_FOR_PRODUCT.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].[PRODUCT_POLICIES]
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\PRODUCT_POLICIES.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].[AMENITIES_ROOM_TYPE]
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\AMENITIES_ROOM_TYPE.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO

BULK
INSERT
    [dbo].[PROPERTY_FACILITIES]
FROM
  'C:\Users\asus\Documents\GitHub\ProjectEPL342\Supplemenraty\PROPERTY_FACILITIES.csv' WITH (
    FIELDTERMINATOR = ',',
    -- Change to '\t' if your fields are tab-separated
    ROWTERMINATOR = '\n',
    -- Windows-style newline '\r\n' might be needed
    FIRSTROW = 2,
    TABLOCK

  );
GO


-- FOREIGN KEYS
GO
    -- PRODUCT Foreign keys:
ALTER TABLE
    [dbo].[PRODUCT] WITH CHECK
ADD
    CONSTRAINT [FK_Room_Type_ID] FOREIGN KEY([Room_Type_ID]) REFERENCES [dbo].[ROOM_TYPE] ([Room_Type_ID]);

GO
ALTER TABLE
    [dbo].[PRODUCT] WITH CHECK
ADD
    CONSTRAINT [FK_Property_ID] FOREIGN KEY([Property_ID]) REFERENCES [dbo].[PROPERTY] ([Property_ID]);

GO
ALTER TABLE
    [dbo].[STOCK] WITH CHECK
ADD
    CONSTRAINT [FK_Product_Stock_ID] FOREIGN KEY([Product_ID]) REFERENCES [dbo].[PRODUCT] ([Product_ID]);

GO
    -- RESERVATION Foreign keys:
ALTER TABLE
    [dbo].[RESERVATIONS] WITH CHECK
ADD
    CONSTRAINT [FK_Product_Res_ID] FOREIGN KEY([Product_ID]) REFERENCES [dbo].[PRODUCT] ([Product_ID]);

GO
ALTER TABLE
    [dbo].[RESERVATIONS] WITH CHECK
ADD
    CONSTRAINT [FK_Review_ID] FOREIGN KEY([Review_ID]) REFERENCES [dbo].[REVIEWS] ([Review_ID]);

GO
ALTER TABLE
    [dbo].[RESERVATIONS] WITH CHECK
ADD
    CONSTRAINT [FK_RESERVATIONS_USER_ID] FOREIGN KEY([User_ID]) REFERENCES [dbo].[USER] ([User_ID]);

GO
    -- PROPERTY Foreign keys:
ALTER TABLE
    [dbo].[PROPERTY] WITH CHECK
ADD
    CONSTRAINT [FK_Property_Type_ID] FOREIGN KEY([Property_Type_ID]) REFERENCES [dbo].[PROPERTY_TYPE] ([Property_Type_ID]);

GO
ALTER TABLE
    [dbo].[PROPERTY] WITH CHECK
ADD
    CONSTRAINT [FK_PROPERTY_USER_ID] FOREIGN KEY([User_ID]) REFERENCES [dbo].[USER] ([User_ID]);