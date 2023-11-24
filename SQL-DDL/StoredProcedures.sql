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
--returns Amenity_Type's
CREATE PROCEDURE getAmenities
@Product_ID INT
AS
BEGIN
SELECT AM.[Amenity_Type]
FROM [dbo].[AMENITIES] AM
WHERE AM.[Amenity_ID] IN ( 
SELECT ART.[MAmenity_ID] 
FROM [dbo].[AMENITIES_ROOM_TYPE] ART 
WHERE ART.[MRoom_Type_ID] IN (SELECT A.[Room_Type_ID]
                            FROM [dbo].[PRODUCT] A
                            WHERE P.[Product_ID] =@Product_ID) )
END

--get Facilities of a product based on Product_ID
--returns facility_type's
CREATE PROCEDURE getFacilities
@Product_ID INT
AS
BEGIN
SELECT F.[Facility_Type]
FROM [dbo].[FACILITIES] F
WHERE F.[Facility_ID] IN ( 
SELECT PF.[MFacility_ID] 
FROM [dbo].[PROPERTY_FACILITIES] PF
WHERE PF.[MProperty_ID] IN (SELECT P.[Property_ID]
                            FROM [dbo].[PRODUCT] P
                            WHERE P.[Product_ID] =@Product_ID) )
END










--getAvailableProducts based on date and property id

--getProperties based on Property_type