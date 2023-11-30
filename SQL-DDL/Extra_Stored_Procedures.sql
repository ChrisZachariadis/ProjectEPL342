
------------EXEC OF MAIN STORED PROCEDURE-------------
--EXEC getProductsBasedOnFilters @Property_LocationA='Athens' ,@Room_TypeA='Triple',@Property_Type_NameA='' ,@StartDateA='', @EndDateA=''
------------------------------------------------------------------------------------------------------------

-- EXTRA ---------------------------------------------------------------------------------------------------
-- Get Amenities of a product based on Product_ID 
CREATE PROCEDURE getAmenities
@Product_ID INT
AS
BEGIN
SELECT AM.[Amenity_Type]
FROM [dbo].[AMENITIES] AM
WHERE AM.[Amenity_ID] IN ( 
SELECT ART.[MAmenity_ID] 
FROM [dbo].[AMENITIES_ROOM_TYPE] ART 
WHERE ART.[MRoom_Type_ID] IN (SELECT P.[Room_Type_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =@Product_ID) )
END
GO
------------------------------------------------------------------------------------------------------------
-- Get Meal Plan
CREATE PROCEDURE getMealPlan
@Product_ID INT
AS
BEGIN
SELECT M.Meal_Plan_Description
FROM [dbo].[MEAL_PLAN] M
WHERE M.[Meal_Plan_ID] IN ( SELECT MP.Meal_Plan_ID FROM [dbo].[MEAL_PLAN_FOR_PRODUCT] MP WHERE MP.[Product_ID] = @Product_ID)  
END
GO
------------------------------------------------------------------------------------------------------------
-- Get Policies
CREATE PROCEDURE getPolices
@Product_ID INT
AS
BEGIN
SELECT P.[Policy_Description]  
FROM [dbo].[POLICY] P
WHERE P.[Policy_ID] IN ( SELECT PP.[MPolicy_ID] FROM [dbo].[PRODUCT_POLICIES] PP WHERE PP.[MProduct_ID]=@Product_ID)
END
GO
------------------------------------------------------------------------------------------------------------
--Delete Product based on product ID 
CREATE PROCEDURE spDelete_Product
    @Product_ID INT
AS
BEGIN
	DELETE FROM [dbo].[MEAL_PLAN_FOR_PRODUCT]
	WHERE Product_ID=@Product_ID

	DELETE FROM [dbo].[PRODUCT_POLICIES]
	WHERE MProduct_ID= @Product_ID

	DELETE FROM [dbo].[STOCK]
	WHERE Product_ID=@Product_ID

    DELETE FROM [dbo].[RESERVATIONS]
    WHERE Product_ID=@Product_ID

    DELETE FROM [dbo].[PRODUCT] 
    WHERE Product_ID = @Product_ID
END
GO
------------------------------------------------------------------------------------------------------------
-- Delete property based on product ID and all its products
CREATE PROCEDURE spDelete_Property
    @Property_ID INT
AS
BEGIN
    DELETE FROM [dbo].[MEAL_PLAN_FOR_PRODUCT]
    WHERE Product_ID IN (SELECT Product_ID FROM [dbo].[PRODUCT] WHERE Property_ID = @Property_ID);

    DELETE FROM [dbo].[RESERVATIONS]
    WHERE Product_ID IN (SELECT Product_ID FROM [dbo].[PRODUCT] WHERE Property_ID = @Property_ID);

    DELETE FROM [dbo].[PRODUCT_POLICIES]
    WHERE MProduct_ID IN (SELECT Product_ID FROM [dbo].[PRODUCT] WHERE Property_ID = @Property_ID);

    DELETE FROM [dbo].[STOCK]
    WHERE Product_ID IN (SELECT Product_ID FROM [dbo].[PRODUCT] WHERE Property_ID = @Property_ID);

    DELETE FROM [dbo].[PRODUCT]
    WHERE Property_ID = @Property_ID;

    DELETE FROM [dbo].[PROPERTY_FACILITIES] 
    WHERE MProperty_ID = @Property_ID;

    DELETE FROM [dbo].[PROPERTY]
    WHERE Property_ID = @Property_ID;
END
GO