
-- USER REGISTRATION. ONLY CUSTOMERS CAN REGISTER (PROPERTY OWNER IS ADDED BY THE ADMIN)
CREATE PROCEDURE spRegister_User
    @User_ID INT,
    @Date_of_Birth DATE,
    @First_Name VARCHAR(15),
    @Last_Name VARCHAR(15),
    @Email VARCHAR(50),
    @Passwd VARCHAR(20),
    @Gender CHAR(1),
    @Approved CHAR(1)
AS
BEGIN
    SET @First_Name = RTRIM(@First_Name);
    SET @Last_Name = RTRIM(@Last_Name);
    SET @Email = RTRIM(@Email);
    SET @Passwd = RTRIM(@Passwd);

    -- Check if the Email format is valid
    IF @Email NOT LIKE '%@%.%'
    BEGIN
        RAISERROR ('Invalid Email format', 16, 1);
        RETURN;
    END
ELSE IF EXISTS (
  SELECT *
  FROM [dbo].USER
  WHERE [Email] = @Email
) BEGIN PRINT 'Error: Email already exists'
END
ELSE BEGIN
    -- Insert customer data into the table with User_Type set to 'Customer'
    INSERT INTO [dbo].[USER] 
        (User_ID, Date_of_Birth, User_Type, First_Name, Last_Name, Email, Passwd, Gender, Approved)
    VALUES 
        (@User_ID, @Date_of_Birth, 'Customer', @First_Name, @Last_Name, @Email, @Passwd, @Gender, @Approved);
END


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
        PRINT 'Login successful';
    END
END;



---ADMIN LOGIN--------

CREATE PROCEDURE spADMINLOGIN @UserName VARCHAR(30),
  @Passwd VARCHAR(20) 
  AS 
  BEGIN
  IF NOT EXISTS (
    SELECT *
    FROM [dbo].USER
    WHERE [Email] = @Email AND @Email = 'administrator@gmail.com'
      AND [Passwd] = @Passwd
  )  BEGIN PRINT 'Error: Invalid email or password' PRINT HASHBYTES('SHA2_256', @Passwd)
    END
    ELSE
    BEGIN
        PRINT 'Login successful';
    END
END;




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


    
    