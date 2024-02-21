--DEMO #1 START
--1.) Create a table to play with.
USE ExecASDemo
GO
CREATE TABLE dbo.Beer
(
	BeerID INT IDENTITY(1,1) CONSTRAINT [PK_Beer_BeerID] PRIMARY KEY CLUSTERED,
	BeerName Varchar(20) NULL,
	Brewer Varchar(20) NULL,
	City Varchar(20) NULL,
	StateCode Char(2) NULL
)
GO
INSERT INTO dbo.Beer
SELECT 'Number9','MagicHat','Burlington','VT'
UNION SELECT 'StealThisCan','LordHobo','Cambridge','MA'
UNION SELECT 'Local 1','Brooklyn Brewery','Brooklyn','NY' 
UNION SELECT 'Local 2','Brooklyn Brewery','Brooklyn','NY'
UNION SELECT 'Ruination','Stone Brewing','Escondido','CA'
UNION SELECT 'Coastway IPA','Kona Brewing Co.','Kona','HI'

--2.) ORIGINAL LOGIN VS SUser: Select from the table, 
----Suser_Name() will show us the user running the the command
----OriginalLogin() will show us who pressed EXECUTE (F5), Regardless of who is running the command  
USE ExecASDemo
GO
SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* FROM ExecAsDemo.dbo.Beer

--3.) we should see two user names,  the person running the command (CurrentLogin), 
-----and the person who actually called the command (OriginalLogin)
Use ExecASDemo
GO
EXECUTE AS Login = 'sqlDBO'
	SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* 
	FROM ExecAsDemo.dbo.Beer
REVERT  --- Switch back to the original login
----Results should be the same again.  We are no longer impersonating another login.
SELECT SUSER_NAME()AS CurrentLogin,ORIGINAL_LOGIN() AS OriginalLogin,* FROM ExecAsDemo.dbo.Beer

--DEMO #2
--7.) Executing As Stored Proc!
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
GO

--8.) Executing with Sysadmin role membership BUT NO TRUSTWORTHY on the DB
Use [master]
GO
ALTER SERVER ROLE sysadmin ADD MEMBER [sqlDBO]
GO

USE ExecASDemo
GO
EXEC ExecAsDemo.dbo.ExecAsCreateLogin @SQLLoginName = 'SQLTest'

--9.) Executing with Sysadmin role membership AND TRUSTWORTHY on the DB
USE [master]
GO
ALTER DATABASE ExecAsDemo SET TRUSTWORTHY ON;
GO

USE ExecASDemo
GO
EXEC ExecAsDemo.dbo.ExecAsCreateLogin @SQLLoginName = 'SQLTest'
GO

--DEMO #3 INJECTION!!! OH NO
--10.) Uh oh inJection
---- Tell us who is sysadmin now:
USE [master]
GO

SELECT 
   role.name AS RoleName,   
   member.name AS MemberName  
FROM sys.server_role_members  
JOIN sys.server_principals AS role  
    ON sys.server_role_members.role_principal_id = role.principal_id  
JOIN sys.server_principals AS member  
    ON sys.server_role_members.member_principal_id = member.principal_id;  

---- Lets run something EVIL!!! HEHE HEHE HEHE!
USE ExecASDemo
EXEC ExecASDemo.dbo.ExecAsCreateLogin @SQLLoginName ='SQLTest2 WITH PASSWORD = ''IStoleIt'';
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLTest2]; CREATE LOGIN SQLTest3'

---- uh oh Who is sysadmin now........?:
SELECT 
   role.name AS RoleName,   
   member.name AS MemberName  
FROM sys.server_role_members  
JOIN sys.server_principals AS role  
    ON sys.server_role_members.role_principal_id = role.principal_id  
JOIN sys.server_principals AS member  
    ON sys.server_role_members.member_principal_id = member.principal_id;  

--11.) Lets fix it:
---- Add some simple protections with QUOTENAMES
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

----Lets try the EVIL things again.  
EXEC ExecASDemo.dbo.ExecAsCreateLogin @SQLLoginName ='SQLTest2 WITH PASSWORD = ''IStoleIt'';
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLTest2]; CREATE LOGIN SQLTest3'
