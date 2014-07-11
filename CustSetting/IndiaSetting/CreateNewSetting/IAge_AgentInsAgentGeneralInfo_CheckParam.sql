USE [InCustDB]
GO
/****** Object:  StoredProcedure [dbo].[IAge_AgentRootInsAgentAdvanceMode]    Script Date: 7/9/2014 11:01:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IAge_AgentInsAgentGeneralInfo_CheckParam]	
	@Username			NVARCHAR(50), 
	@Userpwd			VARCHAR(50),
	@ParentId			INT,
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
	
	DECLARE 
			@ParentHId			HIERARCHYID,
			@ParentCredit		MONEY,
			@Currency			INT,
			@CurrencyName		VARCHAR(20),
			@AgentUserName	    VARCHAR(50)
		
	-- Set default creator is parent agent
	IF @Creator IS NULL
		SET @Creator = @ParentId

		-- Check if parent ID not exist
	SELECT TOP 1 @ParentCredit=Credit,@Currency=Currency,@ParentHId=AgentHId,@AgentUserName=UserName FROM [dbo].AgentInfo WITH (NOLOCK) WHERE AgentId = @ParentId 
	IF @ParentHId IS NULL	
		BEGIN
			SELECT @MsgId=10000
				--@ErrMsg = 'Parent ID not exist 
			RETURN
		END

	--Check if username exists
	IF (@Username NOT LIKE @AgentUserName +'%')
		BEGIN			
			SELECT @MsgId=10001		
				--user 
			RETURN
		END

	SELECT TOP 1 @CurrencyName=Currency FROM bodb02.dbo.Exchange  WITH (NOLOCK) WHERE exchangeid=@Currency
	 
	--Check if username exists
	IF EXISTS (SELECT TOP 1 1 FROM	[dbo].[AgentInfo] a WITH (NOLOCK) WHERE a.UserName=@Username)
		BEGIN			
			SELECT @MsgId=10002		
				--Another user already exists in system with the same username.				
			RETURN
		END

	--Check if username exists
	IF EXISTS (SELECT TOP 1 1 FROM bodb02.dbo.Custinfo a WITH (NOLOCK) WHERE a.UserName=@Username)
		BEGIN			
			SELECT @MsgId=10003		
				--Another user already exists in IBC system with the same username.				
			RETURN
		END

	IF(@ParentCredit !=0)
	BEGIN
		-- validate credit
		SELECT @MaxCreditOutput=
		ISNULL(@ParentCredit,0)-
		ISNULL((SELECT SUM(ISNULL(Credit,0))
		FROM AgentInfo c  WITH (NOLOCK)
		WHERE c.AgentHId.GetAncestor(1)=@ParentHId
		),0)		

		IF(@Credit > @MaxCreditOutput OR @Credit<0)	
		BEGIN
		SELECT @MsgId=10101 --'Given credit must be between 0 to 		
		RETURN
		END
	END	
END

GO 

GRANT EXECUTE ON [IAge_AgentInsAgentGeneralInfo_CheckParam] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentInsAgentGeneralInfo_CheckParam] TO bodbDownlineNetView 
