--TODO Add a constraint to make sure each of the replicas is different.  
CREATE TABLE [CMDB].[AlwaysOnGroups]
(
	[AlwaysOnGroupId] BIGINT IDENTITY(1,1)
	CONSTRAINT [PK_AlwaysOnGroups_AlwaysOnGroupId] PRIMARY KEY CLUSTERED,
	AlwaysOnGroupName SYSNAME NOT NULL,
	AlwaysOnReplicaHostId1 BIGINT NOT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica1] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica1SyncSetting BIT NOT NULL,
	AlwaysOnReplicaHostId2 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica2] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica2SyncSetting BIT NULL,
	AlwaysOnReplicaHostId3 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica3] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica3SyncSetting BIT NULL,
	AlwaysOnReplicaHostId4 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica4] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica4SyncSetting BIT NULL,
	AlwaysOnReplicaHostId5 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica5] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica5SyncSetting BIT NULL,
	AlwaysOnReplicaHostId6 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica6] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica6SyncSetting BIT NULL,
	AlwaysOnReplicaHostId7 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica7] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica7SyncSetting BIT NULL,
	AlwaysOnReplicaHostId8 BIGINT NULL
	CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica8] FOREIGN KEY REFERENCES CMDB.Hosts(HostId),
	Replica8SyncSetting BIT NULL,
)
