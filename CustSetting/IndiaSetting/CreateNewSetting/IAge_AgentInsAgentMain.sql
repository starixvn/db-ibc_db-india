USE InCustDB
GO

/****** Object:  StoredProcedure [dbo].[Las_LicenseeInsAgentMain_xtest]    Script Date: 7/8/2014 5:39:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].IAge_AgentInsAgentMain( @Username NVARCHAR(50)
	, @Userpwd VARCHAR(50)
	, @ParentID INT
	, @FirstName NVARCHAR(50) = NULL
	, @LastName NVARCHAR(50) = NULL
	, @Phone VARCHAR(50) = NULL
	, @Mobile VARCHAR(50) = NULL
	, @Fax VARCHAR(50) = NULL
	, @Credit MONEY
	, @Status TINYINT
	, @Creator INT = NULL
	, @Ip VARCHAR(15) = NULL
	
	, @Discount VARCHAR(MAX) = ''
	, @PositionTaking VARCHAR(MAX) = ''
	, @BetLimit VARCHAR(MAX) = ''

	, @DiscountCricket VARCHAR(MAX) = ''
	, @PositionTakingCricket VARCHAR(MAX) = ''
	, @BetLimitCricket VARCHAR(MAX) = ''

	, @AgentId INT = 0 OUTPUT
	, @MsgId INT = 0 OUTPUT
	, @MaxCreditOutput MONEY = 0 OUTPUT
	, @BetLimitSportType INT = 0 OUTPUT
	, @BetLimitBetType INT = 0 OUTPUT
	, @PTSportType INT = 0 OUTPUT
	, @PTBetType INT = 0 OUTPUT
	, @BetLimitOutput MONEY = 0 OUTPUT
	, @IsLiveOutput BIT = 0 OUTPUT
)
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
	
	EXEC [dbo].IAge_AgentInsAgentGeneralInfo_CheckParam @Username = @Username
		, @Userpwd = @Userpwd
		, @ParentID  = @ParentID
		, @FirstName = @FirstName
		, @LastName = @LastName
		, @Phone = @Phone
		, @Mobile = @Mobile
		, @Fax = @Fax
		, @Credit = @Credit
		, @Status = @Status
		, @Creator = @Creator
		, @Ip = @Ip

		, @MsgId = @MsgId OUTPUT

	IF @MsgId>0
		BEGIN	
			RETURN
		END

	  EXEC [dbo].IAge_AgentInsAgentCricket_CheckParam 
			 @ParentID  = @ParentID
	
			, @Discount = @DiscountCricket
			, @PositionTaking = @PositionTakingCricket
			, @BetLimit = @BetLimitCricket
			
			, @MsgId = @MsgId OUTPUT
			, @BetLimitSportType = @BetLimitSportType OUTPUT
			, @BetLimitBetType = @BetLimitBetType OUTPUT
			, @PTSportType = @PTSportType OUTPUT
			, @PTBetType = @PTBetType OUTPUT
			, @BetLimitOutput = @BetLimitOutput OUTPUT
			, @IsLiveOutput = @IsLiveOutput OUTPUT

	IF @MsgId>0
		BEGIN	
			RETURN
		END

	IF @Discount='' AND @PositionTaking='' AND @BetLimit=''
		BEGIN
			EXEC [dbo].IAge_AgentInsAgentSB_CheckParam 
					  @ParentID  = @ParentID
	
					, @Discount = @Discount
					, @PositionTaking = @PositionTaking
					, @BetLimit = @BetLimit		
					, @MsgId = @MsgId OUTPUT
					, @BetLimitSportType = @BetLimitSportType OUTPUT
					, @BetLimitBetType = @BetLimitBetType OUTPUT
					, @PTSportType = @PTSportType OUTPUT
					, @PTBetType = @PTBetType OUTPUT
					, @BetLimitOutput = @BetLimitOutput OUTPUT
					, @IsLiveOutput = @IsLiveOutput OUTPUT
		END

	EXEC [dbo].[IAge_AgentInsAgentAdvanceMode] 
	    @Username = @Username
		, @Userpwd = @Userpwd
		, @ParentID  = @ParentID
		, @FirstName = @FirstName
		, @LastName = @LastName
		, @Phone = @Phone
		, @Mobile = @Mobile
		, @Fax = @Fax
		, @Credit = @Credit
		, @Status = @Status
		, @Creator = @Creator
		, @Ip = @Ip

		, @AgentId = @AgentId OUTPUT
		, @MsgId = @MsgId OUTPUT
		, @MaxCreditOutput = @MaxCreditOutput OUTPUT
		
	IF (ISNULL(@AgentId,0) <> 0 AND @MsgId = 0)
	BEGIN
		EXEC [dbo].[IAge_AgentInsAgentCricket] 
			 @AgentId = @AgentId
	
			, @Discount = @DiscountCricket
			, @PositionTaking = @PositionTakingCricket
			, @BetLimit = @BetLimitCricket
			
			, @MsgId = @MsgId OUTPUT
			, @BetLimitSportType = @BetLimitSportType OUTPUT
			, @BetLimitBetType = @BetLimitBetType OUTPUT
			, @PTSportType = @PTSportType OUTPUT
			, @PTBetType = @PTBetType OUTPUT
			, @BetLimitOutput = @BetLimitOutput OUTPUT
			, @IsLiveOutput = @IsLiveOutput OUTPUT
	END
	
	IF (ISNULL(@AgentId,0) <> 0 AND @MsgId = 0)
	BEGIN
		IF @Discount='' AND @PositionTaking='' AND @BetLimit=''
			EXEC [dbo].IAge_AgentInsAgentSB_DefaultSetting
				@ParentID = @ParentID
				,@AgentId = @AgentId	
				,@MsgId = @MsgId OUTPUT
		ELSE
			EXEC [dbo].[IAge_AgentInsAgentSB] 
				  @AgentId = @AgentId
	
				, @Discount = @Discount
				, @PositionTaking = @PositionTaking
				, @BetLimit = @BetLimit		
				, @MsgId = @MsgId OUTPUT
				, @BetLimitSportType = @BetLimitSportType OUTPUT
				, @BetLimitBetType = @BetLimitBetType OUTPUT
				, @PTSportType = @PTSportType OUTPUT
				, @PTBetType = @PTBetType OUTPUT
				, @BetLimitOutput = @BetLimitOutput OUTPUT
				, @IsLiveOutput = @IsLiveOutput OUTPUT
	END
END

GO 

GRANT EXECUTE ON IAge_AgentInsAgentMain TO bodbDownlineNet 
GRANT EXECUTE ON IAge_AgentInsAgentMain TO bodbDownlineNetView 
