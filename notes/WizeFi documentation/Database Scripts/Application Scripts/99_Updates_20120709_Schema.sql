
--Widen field since one option is 11 chars exceeding the 10
PRINT 'alter Gender on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN Gender VARCHAR(15) NOT NULL
GO

PRINT 'alter Gender on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN Gender VARCHAR(15) NOT NULL
GO


--Enable encryption

--PrimaryConsumer
PRINT 'alter HomePhone on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN HomePhone VARCHAR(30) NOT NULL
GO

PRINT 'alter WorkPhone on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN WorkPhone VARCHAR(30) NOT NULL
GO

PRINT 'alter MobilePhone on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN MobilePhone VARCHAR(30) NOT NULL
GO

PRINT 'alter PhysicalZip on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN PhysicalZip VARCHAR(30) NOT NULL
GO

PRINT 'alter DriverLicense on PrimaryConsumer'
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN DriverLicense VARCHAR(30) NOT NULL
GO

--SecondaryConsumer
PRINT 'alter HomePhone on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN HomePhone VARCHAR(30) NOT NULL
GO

PRINT 'alter WorkPhone on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN WorkPhone VARCHAR(30) NOT NULL
GO

PRINT 'alter MobilePhone on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN MobilePhone VARCHAR(30) NOT NULL
GO

PRINT 'alter PhysicalZip on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN PhysicalZip VARCHAR(30) NOT NULL
GO

PRINT 'alter DriverLicense on SecondaryConsumer'
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN DriverLicense VARCHAR(30) NOT NULL
GO

--FamilyMember
PRINT 'alter Phone on FamilyMember'
ALTER TABLE [Consumer].FamilyMember 
ALTER COLUMN Phone VARCHAR(30) NOT NULL
GO

PRINT 'alter PhysicalZip on FamilyMember'
ALTER TABLE [Consumer].FamilyMember 
ALTER COLUMN PhysicalZip VARCHAR(30) NOT NULL
GO



