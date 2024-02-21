--CLEAN UP
USE [master]
GO
/****** Object:  Login [ScubaSurface\MiDaniels]    Script Date: 2017-05-20 1:25:05 AM ******/
/*
IF EXISTS (SELECT 1 from master.sys.server_principals where name = 'ScubaSurface\MiDaniels')
	DROP LOGIN [ScubaSurface\MiDaniels]
GO
DROP DATABASE IF EXISTS TEST4
DROP DATABASE IF EXISTS TESTSimple2
DROP DATABASE IF EXISTS TESTSimple3
DROP DATABASE IF EXISTS FOO
DROP DATABASE IF EXISTS FooBar

USE SQLSelfService
TRUNCATE TABLE SQLSelfService.audit.helpdesklog
SELECT * FROM SQLSelfService.Audit.HelpDeskLog order by id desc
*/
--Demo 1 Execute As, using OriginalLogin() to audit who fired the command
--1.)Clean up the ExecAs demo DB
USE MASTER
IF EXISTS (SELECT 1 FROM sys.databases where name = 'ExecAsDemo')
	DROP DATABASE ExecASDemo
GO
--2.)Create ExecAs demo database
USE MASTER
IF NOT EXISTS(SELECT NULL FROM sys.databases WHERE name = 'ExecAsDemo')
	CREATE Database ExecASDemo 
GO
--3.)Create our new ExecAs demo dbo owner and Make it DBO of our database
--****NOTE CHANGE THE PASSWORD BELOW!!!!*******
USE master
IF NOT EXISTS (SELECT NULL FROM sys.server_principals WHERE name = 'sqlDBO')
	CREATE LOGIN [sqlDBO] WITH PASSWORD = 'test123'
GO
IF ((SELECT IS_SRVROLEMEMBER('sysadmin','sqlDBO')) = 1)
	ALTER SERVER ROLE sysadmin DROP MEMBER [sqlDBO]
GO
--alter the database owner with ALTER AUTHORIZATION ON DATABASE (replaces sp_changeDBowner)
ALTER AUTHORIZATION ON DATABASE::ExecAsDemo TO [sqlDBO]

--DEMO START
--4.) Create a table to play with.
USE ExecASDemo
CREATE TABLE dbo.Beer
(
	BeerID INT IDENTITY(1,1) CONSTRAINT [PK_Beer_BeerID] PRIMARY KEY CLUSTERED,
	BeerName Varchar(20) NULL,
	Brewer Varchar(20) NULL,
	City Varchar(20) NULL,
	StateCode Char(2) NULL
)
INSERT INTO dbo.Beer
SELECT 'Number9','MagicHat','Burlington','VT'
UNION SELECT 'StealThisCan','LordHobo','Cambridge','MA'
UNION SELECT 'Local 1','Brooklyn Brewery','Brooklyn','NY' 
UNION SELECT 'Local 2','Brooklyn Brewery','Brooklyn','NY'
UNION SELECT 'Ruination','Stone Brewing','Escondido','CA'
UNION SELECT 'Coastway IPA','Kona Brewing Co.','Kona','HI'

--5.) ORIGINAL LOGIN VS SUser: Select from the table, 
----Suser_Name() will show us the user running the the command
----OriginalLogin() will show us who pressed EXECUTE (F5), Regardless of who is running the command  
USE ExecASDemo
SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* FROM ExecAsDemo.dbo.Beer

--6.) we should see two user names,  the person running the command (CurrentLogin), 
-----and the person who actually called the command (OriginalLogin)

EXECUTE AS Login = 'sqlDBO'
	SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* FROM ExecAsDemo.dbo.Beer
REVERT  --- Switch back to the original login
----Results should be the same again.  We are no longer impersonating another login.
SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* FROM ExecAsDemo.dbo.Beer

--7.) DEMO 2 Executing As Stored Proc!
--We get to see what our sprocs can do.  Lets 
USE ExecASDemo
GO
CREATE OR ALTER PROCEDURE dbo.ExecAsCreateLogin
	@SQLLoginName VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	--DECLARE @SafeLogin sysname = QUOTENAME(@SQLLoginName)
	--PRINT @SafeLogin
	SELECT SUSER_NAME() AS ExecutingAs,ORIGINAL_LOGIN() AS OriginalLogin
	EXEC ('CREATE LOGIN '+ @SQLLoginName+' WITH PASSWORD = ''Test123''');
END
GRANT EXECUTE ON dbo.ExecAsCreateLogin to [HelpDesk_JohnDoe]
GO
--ALTER SERVER ROLE sysadmin ADD MEMBER [sqlDBO]
ALTER SERVER ROLE sysadmin ADD MEMBER [sqlDBO]
EXEC ExecAsDemo.dbo.ExecAsCreateLogin @SQLLoginName = 'SQLTest'
ALTER DATABASE ExecAsDemo SET TRUSTWORTHY ON;
EXEC ExecAsDemo.dbo.ExecAsCreateLogin @SQLLoginName = 'SQLTest'
GO

--8.) Uh oh inJection
EXEC ExecASDemo.dbo.ExecAsCreateLogin @SQLLoginName ='SQLTest2 WITH PASSWORD = ''IStoleIt'';
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLTest2]; CREATE LOGIN SQLTest42'
---- Who is sysadmin now:

SELECT 
   role.name AS RoleName,   
   member.name AS MemberName  
FROM sys.server_role_members  
JOIN sys.server_principals AS role  
    ON sys.server_role_members.role_principal_id = role.principal_id  
JOIN sys.server_principals AS member  
    ON sys.server_role_members.member_principal_id = member.principal_id;  

--9.) Lets fix it:
USE ExecASDemo
GO
CREATE OR ALTER PROCEDURE dbo.ExecAsCreateLogin
	@SQLLoginName VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	DECLARE @SafeLogin sysname = QUOTENAME(@SQLLoginName)
	PRINT @SafeLogin
	SELECT SUSER_NAME() AS ExecutingAs,ORIGINAL_LOGIN() AS OriginalLogin
	EXEC ('CREATE LOGIN '+ @SafeLogin+' WITH PASSWORD = ''Test123''');
END
GO
EXEC ExecASDemo.dbo.ExecAsCreateLogin @SQLLoginName ='SQLTest52 WITH PASSWORD = ''IStoleIt'';
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLTest52]; CREATE LOGIN SQLTest32'

--ALTER SERVER ROLE sysadmin ADD MEMBER [sqlDBO]
-----Reference Links: https://technet.microsoft.com/en-us/library/ms188268(v=sql.105).aspx 
---Alter Database SQLSELFSERVICE
USE MASTER
ALTER DATABASE SQLSelfService SET Trustworthy OFF
EXEC SQLSelfService.HelpDesk.CreateLogin @LoginName = 'ScubaSurface\MiDaniels'

USE MASTER
ALTER DATABASE SQLSelfService SET Trustworthy ON
EXEC SQLSelfService.HelpDesk.CreateLogin @LoginName = 'ScubaSurface\MiDaniels'
--Create the Login
--RESTORE DEMO
	--After Create DB
	USE TEST4
	CREATE TABLE FOO (id int)
	CREATE TABLE BAR (BestBars Sysname, Town Varchar(100), SpecialityDrinkName SysName)
	CREATE TABLE Movie (title sysname, rating Char(1))

	INSERT INTO FOO 
	SELECT 1 UNION SELECT 2 UNION SELECT 4 UNION SELECT 999

	INSERT INTO BAR
	SELECT 'Black Duck', 'Westport CT', 'The Quacker'
	UNION SELECT '235 RoofTop', 'New York NY', 'Sky line'
	UNION SELECT '21st Amendment', 'Boston MA', 'Irish Car Bomb'
	
	INSERT INTO Movie 
	SELECT 'Twins', 'G'
	UNION SELECT 'LEGO BATMAN','?'
	UNION SELECT 'DeadPool', 'R'
	UNION SELECT 'Gravity', 'G'
	UNION SELECT 'Cars 3', 'G'
	 
SELECT * FROM Movie
SELECT * FROM BAR
SELECT * FROM FOO

--Take a backup

--Little Bobby Tables
TRUNCATE TABLE Movie
TRUNCATE TABLE BAR

SELECT * FROM Movie
SELECT * FROM BAR
SELECT * FROM FOO
