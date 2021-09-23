/* Založíme testovací uživatele */

CREATE USER SuperUser WITHOUT LOGIN;  
CREATE USER User1 WITHOUT LOGIN;  
CREATE USER User2 WITHOUT LOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO SuperUser;  
GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO User1;  
GRANT SELECT, INSERT, UPDATE, DELETE ON Project TO User2; 

/* Zatím vidí vše */
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

/* Každý vidí svoje  */

EXECUTE AS USER = 'User1';  
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'User2';  
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'SuperUser';  
SELECT * FROM Project;
REVERT

/* Ale vložit mùžeme ... (pøièemž vložený sami nevidíme) */
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

/* Vložit nìkomu jinému už nemùžeme */
EXECUTE AS USER = 'User2';  
INSERT INTO Project (ProjectId, TenantId, Name) VALUES (600, 1, 'Project F')
REVERT

/* Scroll down */
























/* Ale pøiøadit aktualizací ano */
EXECUTE AS USER = 'User2';  
UPDATE Project SET TenantId = 1
SELECT * FROM Project;
REVERT

EXECUTE AS USER = 'SuperUser';  
SELECT * FROM Project;
REVERT

/* Díky filtru nemùžeme smazat cizí */
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

/* Už vložit cizímu nemùžeme ... */
EXECUTE AS USER = 'User2';  
INSERT INTO Project (ProjectId, TenantId, Name) VALUES (600, 1, 'Projekt E')
REVERT

CREATE SECURITY POLICY TenantFilter
ADD FILTER PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project,
ADD BLOCK PREDICATE Security.TenantSecurityPredicate(TenantId) ON [dbo].Project
WITH (STATE = ON);  


/* Odstranìní RLS */

DROP SECURITY POLICY TenantFilter
DROP FUNCTION Security.TenantSecurityPredicate
DROP SCHEMA Security
