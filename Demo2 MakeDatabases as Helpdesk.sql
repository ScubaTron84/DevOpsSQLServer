--#Demo4 Work with full escalation

CREATE DATABASE PurpleElephant
--1. Login as the HelpDesk USer, or whatever new user you create, and put in the HelpDeskUser Role, in the SQLSelfService Database
USE SQLSelfService
--1.) Create a new SQL Login, a new database in Simple REcovery mode, and Make the new login a DB_Owner in the new database
EXEC HelpDesk.CreateDatabase 'FooBar','SIMPLE','NewSQLLogin2',1,'TheAnswerIs42'
--2.) Create a new database in full recovery, and a new windows login/user, and put the user in DB_Owner Role
EXEC HelpDesk.CreateDatabase 'FooWindows','FULL','ScubaSurface\MiDaniels'

--3.) login as new User (NewSQLLogin) and create some tables
Use [FooBar]
CREATE TABLE dbo.FOO (id int)
	CREATE TABLE BAR (BestBars Sysname, Town Varchar(100), SpecialityDrinkName SysName)
	CREATE TABLE Movie (title sysname, rating Char(1))

	INSERT INTO dbo.FOO 
	SELECT 1 UNION SELECT 2 UNION SELECT 4 UNION SELECT 999

	INSERT INTO dbo.BAR
	SELECT 'Black Duck', 'Westport CT', 'The Quacker'
	UNION SELECT '235 RoofTop', 'New York NY', 'Sky line'
	UNION SELECT '21st Amendment', 'Boston MA', 'Irish Car Bomb'
	
	INSERT INTO dbo.Movie 
	SELECT 'Twins', 'G'
	UNION SELECT 'LEGO BATMAN','?'
	UNION SELECT 'DeadPool 2', 'R'
	UNION SELECT 'Gravity', 'G'
	UNION SELECT 'Cars 3', 'G'
	UNION SELECT 'Infinity Wars', 'PG'
	UNION SELECT 'The Conjuring'
	 
SELECT * FROM dbo.Movie
SELECT * FROM dbo.BAR
SELECT * FROM dbo.FOO

--4.)Login as HelpDesk USer and backup this database, MAKE SURE SQL HAS ACCESS TO THE FILE PATH!!!

EXEC HelpDesk.BackupDatabase 'FooBar', 'C:\Temp','FooBar.bak'


--5.) Log back in as NEwSQLLogin and Accidently TRUNCATE THE TABLES!!! OHHH NOOOO!!!!
USE FooBar
TRUNCATE TABLE dbo.Foo
TRUNCATE TABLE dbo.Bar
TRUNCATE Table dbo.Movie

SELECT * FROM dbo.Movie
SELECT * FROM dbo.BAR
SELECT * FROM dbo.FOO

--6.) Run as helpdesk userHELP DESK HELP!!!! RESTORE FROM LAST BACKUP
---**** NOTE **** there is an @BackupLocation parameter for the REstore Sproc,
----IF the parameter is NULL, SQL will look for the last known backup in MSDB.
----- ASSUMES SINGLE FILE BACKUP (working on this! Version 1.1)
--- You cannot supply a path (working on it) it is broken i have not finished out the logic to check validate the path,
----- find the backup file
----- validate its a backup file
----- run a restore filelist only on it to get the mdf and ldf file locations
----- move the mdf and ldf files as needed
Exec HelpDesk.RestoreDatabase @DatabaseName = 'FooBar'