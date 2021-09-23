/* Zalo��me testovac� u�ivatele */

CREATE USER SuperUser WITHOUT LOGIN;  
CREATE USER User1 WITHOUT LOGIN;  
CREATE USER User2 WITHOUT LOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO SuperUser;  
GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO User1;  
GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO User2; 

/* Zat�m vid� v�e */
EXECUTE AS USER = 'User1';  
SELECT * FROM Project;
REVERT
GO

/* "Zapneme RLS" */
CREATE SCHEMA Security
GO

CREATE FUNCTION Security.TenantSecurityPredicate(@TenantId AS int)
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS [Result]
	FROM [dbo].[User]
	INNER JOIN [dbo].[User_Tenant] ON [User].UserId = User_Tenant.UserId  ANd User_Tenant.TenantId = @TenantId
	WHERE [dbo].[User].Username = USER_NAME()
GO

CREATE SECURITY POLICY TenantFilter  
ADD FILTER PREDICATE Security.TenantSecurityPredicate(TenantId)
ON [dbo].Project
WITH (STATE = ON);  
GO

/* Ka�d� vid� svoje  */

EXECUTE AS USER = 'User1';  
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'User2';  
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'SuperUser';  
SELECT * FROM Project;
REVERT

/* Ale vlo�it m��eme ... (p�i�em� vlo�en� sami nevid�me) */
EXECUTE AS USER = 'User2';  
INSERT INTO Project (ProjectId, TenantId, Name) VALUES (500, 1, 'Projekt E')
SELECT * FROM Project;
REVERT

DROP SECURITY POLICY TenantFilter

CREATE SECURITY POLICY TenantFilter
ADD FILTER PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project AFTER INSERT
WITH (STATE = ON);  

GO

/* Vlo�it n�komu jin�mu u� nem��eme */
EXECUTE AS USER = 'User2';  
INSERT INTO Project (ProjectId, TenantId, Name) VALUES (600, 1, 'Project F')
REVERT

/* Scroll down */
























/* Ale p�i�adit aktualizac� ano */
EXECUTE AS USER = 'User2';  
UPDATE Project SET TenantId = 1
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'SuperUser';  
SELECT * FROM Project;
REVERT

/* D�ky filtru nem��eme smazat ciz� */
EXECUTE AS USER = 'User2';  
DELETE Project 
REVERT

DROP SECURITY POLICY TenantFilter

CREATE SECURITY POLICY TenantFilter
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project AFTER INSERT,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project BEFORE UPDATE,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project AFTER UPDATE,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project BEFORE DELETE
WITH (STATE = ON);  

/* U� vlo�it ciz�mu nem��eme ... */
EXECUTE AS USER = 'User2';  
INSERT INTO Project (ProjectId, TenantId, Name) VALUES (600, 1, 'Projekt E')
REVERT

CREATE SECURITY POLICY TenantFilter
ADD FILTER PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project
WITH (STATE = ON);  


/* Odstran�n� RLS */

DROP SECURITY POLICY TenantFilter
DROP FUNCTION Security.TenantSecurityPredicate
DROP SCHEMA Security
