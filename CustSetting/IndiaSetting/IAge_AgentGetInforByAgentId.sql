USE [InCustDB]
GO

ALTER PROCEDURE [dbo].[IAge_AgentGetInforByAgentId]
	@AgentId	INT 
AS

/**
 * Created by	: 20140708@Tom.Vo
 * Task			: Get information By AgentId
 * DB			: DBIN.InCustDB
 * Revisions	:
 * Parameters:
 *	•
 *	•
 *  
 */
  
BEGIN
	
	SET NOCOUNT ON 

	DECLARE @GivenCredit Money
	
	SELECT @GivenCredit=SUM(ISNULL(Credit,0))	FROM dbo.AgentInfo c  WITH (NOLOCK)WHERE ParentId=@AgentId

	SELECT TOP 1 AgentId
			,AgentHId
			,UserName
			,AgentLevel	
			,ParentId	
			,Currency	
			,LoginCount	
			,Status	
			,Nickname	
			,Userpwd	
			,PwdExpiry
			,LastName
			,FirstName
			,Phone
			,Mobile
			,Fax
			,Credit
			,ISNULL(@GivenCredit,0) GivenCredit
	FROM dbo.AgentInfo WITH(NOLOCK) WHERE AgentId=@AgentId
	
END


GO 

GRANT EXECUTE ON [IAge_AgentGetInforByAgentId] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentGetInforByAgentId] TO bodbDownlineNetView 
