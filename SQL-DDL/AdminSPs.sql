
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
-- filter the properties based on the id and return them 

-- get the total revenue for a given property id and date

-- CREATE PROCEDURE spGetTotalRevenue


CREATE PROCEDURE GenerateReport
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