DELETE FROM Project
DELETE FROM User_Tenant
DELETE FROM Tenant
DELETE FROM [User]

INSERT INTO Tenant (TenantID)
VALUES 
	(1),
	(2)

INSERT INTO [User] (UserId, Username)
VALUES 
	(0, 'SuperUser'),
	(1, 'User1'),
	(2, 'User2')

INSERT INTO User_Tenant (UserId, TenantId)
VALUES
    (0, 1),
	(0, 2),
	(1, 1),
	(2, 2)

INSERT INTO Project (ProjectId, TenantId, Name)
VALUES
	(100, 1, 'Projekt A'),
	(200, 1, 'Projekt B'),
	(300, 2, 'Projekt C'),
	(400, 2, 'Projekt D')
