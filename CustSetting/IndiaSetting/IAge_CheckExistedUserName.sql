USE [InCustDB]
GO

ALTER PROCEDURE [dbo].[IAge_CheckExistedUserName]
	@username nvarchar(100)=null
AS
/**
 * Created by	: 20140708@Tom.Vo
 * Task			: Check a member username is existed or not
 * DB			: DBIN.InCustDB
 * Revisions	:
 * Parameters:
 *	•
 *	•
 */  
 
SET NOCOUNT ON

if exists (SELECT TOP 1 1 FROM dbo.AgentInfo with(nolock) WHERE username=@username)
BEGIN
	SELECT 1 isExisted
END
ELSE IF exists (SELECT TOP 1 1 FROM bodb02.dbo.CustInfo with(nolock) WHERE username=@username)
	SELECT 1 isExisted
ELSE
	SELECT 0 isExisted


GO

GO 

GRANT EXECUTE ON [IAge_CheckExistedUserName] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_CheckExistedUserName] TO bodbDownlineNetView 
