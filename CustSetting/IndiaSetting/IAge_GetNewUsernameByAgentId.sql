USE [InCustDB]
GO
/****** Object:  StoredProcedure [dbo].[IAge_AgentRootInsAgentAdvanceMode]    Script Date: 7/9/2014 11:01:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IAge_GetNewUsernameByAgentId]
	@AgentId			INT

/**
 * Created by	: 20140708@Tom.Vo
 * Task			: Get New User Name
 * DB			: DBIN.InCustDB
 * Revisions	:
 * Parameters:
 *	•
 *	•
 *  
 */
 AS
 BEGIN
 SET NOCOUNT ON
	DECLARE @UserName VARCHAR(50),@UserNameParent VARCHAR(50)
	DECLARE @AgentLevel INT,@NumberAgentLevel INT,@NumAccountDownLine INT,@RootHid HIERARCHYID,@Rootid INT

	SELECT TOP 1 @UserNameParent=UserName,@AgentLevel=AgentLevel,@RootHid=AgentHId.GetAncestor(AgentLevel-1) FROM [dbo].AgentInfo WITH (NOLOCK) WHERE AgentId = @AgentId
	SELECT TOP 1 @Rootid=AgentId FROM [dbo].AgentInfo WITH (NOLOCK) WHERE AgentHId = @RootHid
	SELECT TOP 1 @NumberAgentLevel=NumberAgentLevel FROM [dbo].AgentLevelSetting WITH (NOLOCK) WHERE CustId = @Rootid

	SELECT TOP 1 @UserName=MAX(UserName),@NumAccountDownLine=COUNT(1) FROM [dbo].AgentInfo WITH (NOLOCK) WHERE ParentId = @AgentId  AND UserName LIKE @UserNameParent + '%'

	IF @NumberAgentLevel = @AgentLevel+1
	BEGIN
		SELECT top 1 @UserName=SeqName
			FROM [dbo].AgentCustSeq WITH(NOLOCK)
			WHERE type = 1
			AND @UserNameParent + SeqName NOT IN (
				SELECT Username
				FROM [dbo].AgentInfo WITH(NOLOCK)
				WHERE ParentId = @AgentId
				)
			ORDER BY SeqName ASC

			SELECT @UserNameParent UserName, LEFT(@UserName,1)+';'+SUBSTRING(@UserName,1,1)+';'+RIGHT(@UserName,1) [CHAR]
	END
	ELSE
	BEGIN
			SELECT top 1 @UserName = SeqName
			FROM [dbo].AgentCustSeq WITH(NOLOCK)
			WHERE type = 2
			AND @UserNameParent + SeqName NOT IN (
				SELECT Username
				FROM [dbo].AgentInfo WITH(NOLOCK)
				WHERE ParentId = @AgentId
				)
			ORDER BY SeqName ASC

			SELECT @UserNameParent UserName, LEFT(@UserName,1)+';'+RIGHT(@UserName,1) [CHAR]
	END
	
 END

GO 

GRANT EXECUTE ON [IAge_GetNewUsernameByAgentId] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_GetNewUsernameByAgentId] TO bodbDownlineNetView 
