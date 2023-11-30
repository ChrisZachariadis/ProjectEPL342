

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