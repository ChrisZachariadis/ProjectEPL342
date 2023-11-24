CREATE PROCEDURE getProperties
@Property_Location varchar(20),
AS
BEGIN
IF NOT EXISTS (SELECT * FROM [dbo].PROPERTY WHERE [dbo].Property_Location = @Property_Location) BEGIN PRINT 'Unavailable location' RETURN END

SELECT * 
FROM [dbo].PROPERTY 
WHERE [dbo].Property_Location = @Property_Location
END