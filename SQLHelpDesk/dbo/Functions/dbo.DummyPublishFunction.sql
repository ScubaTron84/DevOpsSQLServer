CREATE FUNCTION [dbo].[DummyPublishFunction]
(
)
RETURNS TABLE AS RETURN
(
    SELECT *
    FROM sys.databases
)
