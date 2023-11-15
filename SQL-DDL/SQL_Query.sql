CREATE TABLE [dbo].[USER]
(
    User_ID INT NOT NULL,
    Date_of_Birth DATE NOT NULL,
    User_Type VARCHAR(15) NOT NULL,
    CHECK (
        User_Type IN ('Customer', 'Admin', 'Property Owner')
    ),
    First_Name VARCHAR(15) NOT NULL,
    Last_Name VARCHAR(15) NOT NULL,
    Gender CHAR(1) NOT NULL,
    Approved CHAR(1) NOT NULL,

    CONSTRAINT PK_USER PRIMARY KEY (User_ID)
)
;

CREATE TABLE [dbo].[PRODUCT]
(
    Product_ID INT NOT NULL,
    Price FLOAT NOT NULL,
    Max_Guests INT NOT NULL,
    CHECK (Max_Guests > 0),
    Product_Description VARCHAR(15) NOT NULL,
    Product_Price FLOAT NOT NULL,

    --FKeys
    Room_Type_ID INT NOT NULL,
    Property_ID INT NOT NULL,
    Stock_ID INT NOT NULL,
    Reservation_ID INT NOT NULL,

    CONSTRAINT Product_ID PRIMARY KEY (Product_ID)
)
;

CREATE TABLE [dbo].[MEAL_PLAN]
(
    Meal_Plan_ID INT NOT NULL,
    Meal_Plan_Description VARCHAR(15) NOT NULL,

    CONSTRAINT Meal_Plan_ID PRIMARY KEY (Meal_Plan_ID)
);



CREATE TABLE [dbo].[PROPERTY]
(
    Property_ID INT NOT NULL,
    Property_Name VARCHAR(15) NOT NULL,
    Property_Address VARCHAR(15) NOT NULL,
    Property_Description VARCHAR(15) NOT NULL,
    Property_Coordinates VARCHAR(20) NOT NULL,
    Owner_ID INT NOT NULL,
    Owner_First_Name VARCHAR(15) NOT NULL,
    Owner_Last_Name VARCHAR(15) NOT NULL,

    --FKeys
    Property_Type_ID INT NOT NULL,
    User_ID INT NOT NULL,

    CONSTRAINT Property_ID PRIMARY KEY (Property_ID)
)
;

CREATE TABLE [dbo].[PROPERTY_TYPE]
(
    Property_Type_ID INT NOT NULL,
    Property_Type_Name VARCHAR(15) NOT NULL,

    CONSTRAINT Property_Type_ID PRIMARY KEY (Property_Type_ID)
);

CREATE TABLE [dbo].[AMENITIES]
(
    Amenity_ID INT NOT NULL,
    Amenity_Type VARCHAR(15) NOT NULL,

    CONSTRAINT Amenity_ID PRIMARY KEY (Amenity_ID)

);

CREATE TABLE [dbo].[ROOM_TYPE]
(
    Room_Type_ID INT NOT NULL,
    Room_Type_Description VARCHAR(15) NOT NULL,
    Bed_Type VARCHAR(15) NOT NULL,

    CONSTRAINT Room_Type_ID PRIMARY KEY (Room_Type_ID)
);

CREATE TABLE [dbo].[FACILITIES]
(
    Facility_ID INT NOT NULL,
    Facility_Type VARCHAR(15) NOT NULL,

    CONSTRAINT Facility_ID PRIMARY KEY (Facility_ID)
);

CREATE TABLE [dbo].[STOCK]
(
    Stock_ID INT NOT NULL,
    Stock_Date DATE NOT NULL,
    Stock_Amount INT NOT NULL,
    CHECK (Stock_Amount > 0),

    CONSTRAINT Stock_ID PRIMARY KEY (Stock_ID)
);

CREATE TABLE [dbo].[RESERVATIONS]
(
    Reservation_ID INT NOT NULL,
    Reservation_Date DATE NOT NULL,

    --FKeys
    Review_ID INT NOT NULL,
    User_ID INT NOT NULL,

    CONSTRAINT Reservation_ID PRIMARY KEY (Reservation_ID)
);

CREATE TABLE [dbo].[REVIEWS]
(
    Review_ID INT NOT NULL,
    Review_Description VARCHAR(15) NOT NULL,
    Review_Rating INT NOT NULL,
    CHECK (Review_Rating BETWEEN 0 AND 5),

    CONSTRAINT Review_ID PRIMARY KEY (Review_ID)
);

CREATE TABLE [dbo].[POLICY]
(
    Policy_ID INT NOT NULL,
    Policy_Description VARCHAR(15) NOT NULL,

    CONSTRAINT Policy_ID PRIMARY KEY (Policy_ID)
);




-- MANY TO MANY RELATIONSHIPS

GO

-- Product - Meal Plan relationship
CREATE TABLE [dbo].[MEAL_PLAN_FOR_PRODUCT]
(
    Product_ID INT NOT NULL,
    Meal_Plan_ID INT NOT NULL,

    CONSTRAINT PK_PRODUCT_MEAL_PLANS PRIMARY KEY (Product_ID, Meal_Plan_ID),
    CONSTRAINT FK_PMP_PRODUCT_ID FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID),
    CONSTRAINT FK__PMP_MEAL_ID FOREIGN KEY (Meal_Plan_ID) REFERENCES MEAL_PLAN(Meal_Plan_ID)

);

-- Policy - Product relationship
CREATE TABLE [dbo].[PRODUCT_POLICIES]
(
    MPolicy_ID INT NOT NULL,
    MProduct_ID INT NOT NULL,

    CONSTRAINT PK_PRODUCT_POLICIES PRIMARY KEY (MPolicy_ID, MProduct_ID),
    CONSTRAINT FK_PP_POLICY_ID FOREIGN KEY (MPolicy_ID) REFERENCES POLICY(Policy_ID),
    CONSTRAINT FK_PP_PRODUCT_ID FOREIGN KEY (MProduct_ID) REFERENCES PRODUCT(Product_ID)

);

-- Room Type - Amenity relationship
CREATE TABLE [dbo].[AMENITIES_ROOM_TYPE]
(
    MAmenity_ID INT NOT NULL,
    MRoom_Type_ID INT NOT NULL,

    CONSTRAINT PK_AMENITIES_ROOM_TYPE PRIMARY KEY (MAmenity_ID, MRoom_Type_ID),
    CONSTRAINT FK_AR_MENITY_ID FOREIGN KEY (MAmenity_ID) REFERENCES AMENITIES(Amenity_ID),
    CONSTRAINT FK_AR_ROOM_TYPE_ID FOREIGN KEY (MRoom_Type_ID) REFERENCES ROOM_TYPE(Room_Type_ID)
);

-- PROPERTY - FACILITIES relationship
CREATE TABLE [dbo].[PROPERTY_FACILITIES]
(
    MFacility_ID INT NOT NULL,
    MProperty_ID INT NOT NULL,

    CONSTRAINT PK_FACILITIES_PROPERTY PRIMARY KEY (MFacility_ID, MProperty_ID),
    CONSTRAINT FK_PF_FACILITY_ID FOREIGN KEY (MFacility_ID) REFERENCES FACILITIES(Facility_ID),
    CONSTRAINT FK_PF_PROPERTY_ID FOREIGN KEY (MProperty_ID) REFERENCES PROPERTY(Property_ID)
);



-- FOREIGN KEYS

GO

-- PRODUCT Foreign keys:
ALTER TABLE 
    [dbo].[PRODUCT] WITH CHECK 
    ADD 
        CONSTRAINT [FK_Room_Type_ID] FOREIGN KEY([Room_Type_ID]) REFERENCES [dbo].[ROOM_TYPE] ([Room_Type_ID])
        ;
GO
ALTER TABLE 
    [dbo].[PRODUCT] WITH CHECK 
    ADD 
        CONSTRAINT [FK_Property_ID] FOREIGN KEY([Property_ID]) REFERENCES [dbo].[PROPERTY] ([Property_ID])
        ;
GO
ALTER TABLE 
    [dbo].[PRODUCT] WITH CHECK 
    ADD 
        CONSTRAINT [FK_Stock_ID] FOREIGN KEY([Stock_ID]) REFERENCES [dbo].[STOCK] ([Stock_ID])
        ;
GO
ALTER TABLE 
    [dbo].[PRODUCT] WITH CHECK 
    ADD 
        CONSTRAINT [FK_Reservation_ID] FOREIGN KEY([Reservation_ID]) REFERENCES [dbo].[RESERVATIONS] ([Reservation_ID])
        ;
GO

-- RESERVATION Foreign keys:

ALTER TABLE 
    [dbo].[RESERVATIONS] WITH CHECK
    ADD 
        CONSTRAINT [FK_Review_ID] FOREIGN KEY([Review_ID]) REFERENCES [dbo].[REVIEWS] ([Review_ID])
        ;
GO
ALTER TABLE
    [dbo].[RESERVATIONS] WITH CHECK
    ADD
        CONSTRAINT [FK_RESERVATIONS_USER_ID] FOREIGN KEY([User_ID]) REFERENCES [dbo].[USER] ([User_ID])
        ;
GO

-- PROPERTY Foreign keys:

ALTER TABLE
    [dbo].[PROPERTY] WITH CHECK
    ADD 
        CONSTRAINT [FK_Property_Type_ID] FOREIGN KEY([Property_Type_ID]) REFERENCES [dbo].[PROPERTY_TYPE] ([Property_Type_ID])
        ;
GO
ALTER TABLE
    [dbo].[PROPERTY] WITH CHECK
    ADD
     CONSTRAINT [FK_PROPERTY_USER_ID] FOREIGN KEY([User_ID]) REFERENCES [dbo].[USER] ([User_ID])
     ;


