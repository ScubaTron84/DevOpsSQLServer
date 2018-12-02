--TODO add a constraint to verify IPS in same subnet as 
CREATE TABLE [CMDB].[AlwaysOnListeners]
(
	[AlwaysOnListenerId] BIGINT IDENTITY (1,1)
	CONSTRAINT [PK_AlwaysOnListeners_AlwaysOnListenerId] PRIMARY KEY CLUSTERED,
	ListenerName SYSNAME NOT NULL,
	ListenerIP1 VARCHAR(16) NOT NULL,
	ListenerIP2 VARCHAR(16) NULL,
	ListenerIP3 VARCHAR(16) NULL,
	ListenerIP4 VARCHAR(16) NULL,
	ListenerIP5 VARCHAR(16) NULL,
	ListenerIP6 VARCHAR(16) NULL,
	ListenerIP7 VARCHAR(16) NULL,
	ListenerIP8 VARCHAR(16) NULL
)