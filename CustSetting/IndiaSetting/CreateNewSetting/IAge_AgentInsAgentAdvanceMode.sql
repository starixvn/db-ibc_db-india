USE [InCustDB]
GO
/****** Object:  StoredProcedure [dbo].[IAge_AgentRootInsAgentAdvanceMode]    Script Date: 7/10/2014 1:57:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IAge_AgentInsAgentAdvanceMode]	
	@AgentId			INT				= 0			OUTPUT,
	@Username			NVARCHAR(50), 
	@Userpwd			VARCHAR(50),
	@ParentID			INT,
	@FirstName			NVARCHAR(50)	=NULL,
	@LastName			NVARCHAR(50)	=NULL,
	@Phone				VARCHAR(50)		=NULL,
	@Mobile				VARCHAR(50)		=NULL,
	@Fax				VARCHAR(50)		=NULL,
	@Credit				MONEY,
	@Status				TINYINT			,
	@Creator			INT				= NULL,
	@MsgId			    INT				= 0			OUTPUT,	
	
	@MaxCreditOutput    MONEY			= 0			OUTPUT,
	@Ip					VARCHAR(15)		= NULL
AS

/**
 * Created by	: 20140708@Tom.Vo
 * Task			: Add new agent information and default setting
 * DB			: DBIN.InCustDB
 * Revisions	:
 * Parameters:
 *	•
 *	•
 *  
 */

BEGIN
	
	SET NOCOUNT ON

	-- Set default creator is parent agent
	IF @Creator IS NULL
		SET @Creator = @ParentID

	-- Begin INSERT Agent1
	DECLARE @UplineNode				HIERARCHYID,
			@LastChild				HIERARCHYID,
			@Currency				INT

	-- Get parent information
	SELECT	
		@UplineNode = AgentHId,
		@Currency =Currency
	FROM AgentInfo WITH (NOLOCK)
	WHERE AgentId = @ParentID

	-- Get last child hierarchyid 
	SELECT @LastChild = MAX(AgentHId) 
	FROM AgentInfo WITH (NOLOCK)
	WHERE AgentHId.GetAncestor(1) = @UplineNode
	 

	-- Insert into AgentInfo
	INSERT INTO AgentInfo (		
		AgentHId,
		ParentId,
		Username,
		Currency,
		Status,
		Userpwd,
		PwdExpiry,
		LastName,
		FirstName,
		Phone,
		Mobile,
		Fax,
		Credit,
		LoginCount,
		CreatedDate
	)
	VALUES (		
		@UplineNode.GetDescendant(@LastChild, NULL),
		@ParentID,
		@Username,
		@Currency,		
		@Status,		
		@Userpwd,
		DATEADD(DD, 180, GETDATE()),
		@LastName,
		@FirstName,
		@Phone,
		@Mobile,
		@Fax,
		@Credit,
		0,
		GETDATE()
	)	

	SELECT @AgentId = SCOPE_IDENTITY()
													
	IF @@ERROR > 0 OR @AgentId IS NULL
		BEGIN	
			SELECT @MsgId=10500			
				-- 'Failed to insert agent
			RETURN
		END		
END


GO


GRANT EXECUTE ON [IAge_AgentInsAgentAdvanceMode] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentInsAgentAdvanceMode] TO bodbDownlineNetView 
