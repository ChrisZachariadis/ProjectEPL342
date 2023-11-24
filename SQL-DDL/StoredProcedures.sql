--get products based on location
--returns product ID, property name, product price and room type.
CREATE PROCEDURE getProduct
@Property_Location VARCHAR(20)
AS
BEGIN
IF NOT EXISTS (
SELECT * 
FROM [dbo].[PROPERTY]
WHERE [Property_Location] = @Property_Location
) BEGIN PRINT 'Unavailable location' RETURN 
END
SELECT B.[Product_ID], A.[Property_Name],B.[Product_Price], C.[Bed_Type]
FROM [dbo].[PROPERTY] A , [dbo].[PRODUCT] B , [dbo].[ROOM_TYPE] C
WHERE A.[Property_Location] = @Property_Location AND A.[Property_ID] = B.[Property_ID] AND  B.[Room_Type_ID]=C.[Room_Type_ID]
END

--get Amenities of a product based on Product_ID 

CREATE PROCEDURE getAmenities
@Product_ID INT
AS
BEGIN
SELECT A.*
FROM [dbo].[AMENITIES] A, [dbo].[PRODUCT] P, [dbo].[ROOM_TYPE] RT, [dbo].[ROOM_TYPE_AMENITIES] RTA

WHERE P.[Product_ID] = @Product_ID AND P.[Room_Type_ID] = RT.[Room_Type_ID] AND RT[Room_Type_ID] = RTA.[Room_Type_ID] AND RTA.[Amenities_ID] = A.[Amenities_ID] 
END
 






--getProducts based on property id
--getAvailableProducts based on date and property id
--getProducts based on property id and facilities
--getProducts based on property id and facilities and amenities
--getProperties based on Property_type