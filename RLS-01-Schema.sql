CREATE TABLE [dbo].[User]
(
	[UserId] [int] NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserId] ASC)
)

CREATE TABLE [dbo].[Tenant]
(
	[TenantId] [int] NOT NULL,
	CONSTRAINT [PK_Tenant] PRIMARY KEY CLUSTERED ([TenantId] ASC)
)

CREATE TABLE [dbo].[User_Tenant]
(
	[UserId] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	CONSTRAINT [PK_User_Tenant] PRIMARY KEY CLUSTERED ([UserId] ASC, [TenantId] ASC)
)

ALTER TABLE [dbo].[User_Tenant]  WITH CHECK ADD CONSTRAINT [FK_User_Tenant_Tenant] FOREIGN KEY([TenantId]) REFERENCES [dbo].[Tenant] ([TenantId])
ALTER TABLE [dbo].[User_Tenant] CHECK CONSTRAINT [FK_User_Tenant_Tenant]
ALTER TABLE [dbo].[User_Tenant]  WITH CHECK ADD CONSTRAINT [FK_User_Tenant_User] FOREIGN KEY([UserId]) REFERENCES [dbo].[User] ([UserId])
ALTER TABLE [dbo].[User_Tenant] CHECK CONSTRAINT [FK_User_Tenant_User]

CREATE TABLE [dbo].[Project]
(
	[ProjectId] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectId] ASC)
)
ALTER TABLE [dbo].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Tenant] FOREIGN KEY([TenantId]) REFERENCES [dbo].[Tenant] ([TenantId])
ALTER TABLE [dbo].[Project] CHECK CONSTRAINT [FK_Project_Tenant]

