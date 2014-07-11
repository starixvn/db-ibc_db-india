USE [InCustDB]
GO

ALTER PROCEDURE [dbo].[IAge_AgentInsAgentCricket_CheckParam](
     @ParentId INT
	, @Discount VARCHAR(MAX) = ''
	, @PositionTaking VARCHAR(MAX) = ''
	, @BetLimit VARCHAR(MAX) = ''
	
	, @MsgId INT = 0 OUTPUT
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
 * Task			: Add new agent setting for Cricket
 * DB			: DBIN.InCustDB
 * Revisions	:
 * Parameters:
 *	•
 *	•
 *  
 */


BEGIN
	
	SET NOCOUNT ON
	-- Insert  agent bet limit from UI
	DECLARE @BetLimitTable dbo.BetLimit

	INSERT INTO @BetLimitTable (SportType,BetType,MinBet,MaxBet,MaxPerMatch)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @BetLimit, @Mode = 'BL'
	
	DECLARE @BetLimitParentTable dbo.BetLimit
	INSERT INTO @BetLimitParentTable(SportType,BetType,MinBet,MaxBet,MaxPerMatch)
	SELECT 
		SportType,
		BetType,
		MAX(MinBet),
		MIN(MaxBet),
		MIN(MaxPerMatch)
	FROM dbo.AgentBetLimit WITH (NOLOCK)
	WHERE AgentId=@ParentId	AND (sporttype=203)
	GROUP BY	SportType,
				BetType

	DELETE FROM @BetLimitParentTable WHERE MinBet=0 AND MaxBet=0 AND MaxPerMatch=0
	
	EXEC [dbo].IAge_ValidationBetLimitCricket
		 	@BetLimitTable =@BetLimitTable
			, @BetLimitParentTable =@BetLimitParentTable
	
			, @MsgId = @MsgId OUTPUT
			, @SportTypeOutput = @BetLimitSportType OUTPUT
			, @BetTypeOutput = @BetLimitBetType OUTPUT
			, @BetLimitOutput = @BetLimitOutput OUTPUT		 	

	IF @MsgId <> 0
		BEGIN
			SELECT @MsgId=@MsgId	--'Invalid commission rate'
			RETURN
		END	

	---- Insert default agent discount (from its parent)
	DECLARE @TableDiscount dbo.Discount
	DECLARE @TableParentDiscount dbo.Discount

	INSERT INTO @TableDiscount (SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @Discount, @Mode = 'D-A'

	INSERT INTO  @TableParentDiscount(SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD)
	SELECT SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD
	FROM dbo.AgentDiscount WITH(NOLOCK) WHERE AgentId=@ParentId	AND (sporttype=203)
	
	EXEC [dbo].[IAge_ValidationDiscountCricket]
		 	@TableDiscount =@TableDiscount
			, @TableParentDiscount =@TableParentDiscount	
			, @MsgId = @MsgId OUTPUT		 	
					
	IF @MsgId <> 0
		BEGIN
			SELECT @MsgId=@MsgId	--'Invalid discount'
			RETURN
		END	

	---- Insert Agent0 PT
	DECLARE  @TablePositionTaking [dbo].[PositionTaking]
	DECLARE  @TableParentPositionTaking [dbo].[PositionTaking]

	INSERT INTO @TablePositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @PositionTaking, @Mode = 'PT-A'

	-- Insert into Agent PT
	INSERT INTO  @TableParentPositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
	SELECT SportType,BetType,IsLive,MaxUpperPositionTaking,MaxGivenPositionTaking,MinGivenPositionTaking
	FROM dbo.AgentPositionTaking WITH(NOLOCK) WHERE AgentId=@ParentId	AND (sporttype=203)
		
	EXEC [dbo].[IAge_ValidationPositionTakingCricket]
		@TablePositionTaking =@TablePositionTaking
		, @TableParentPositionTaking =@TableParentPositionTaking
	
		, @MsgId = @MsgId OUTPUT		 	
		, @PTSportType = @PTSportType OUTPUT
		, @PTBetType  = @PTBetType OUTPUT
		, @IsLiveOutput  = @IsLiveOutput  OUTPUT

	IF @MsgId <> 0
		BEGIN
			SELECT @MsgId=@MsgId	--'Invalid PositionTaking'
			RETURN
		END	
END


GO 

GRANT EXECUTE ON [IAge_AgentInsAgentCricket_CheckParam] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentInsAgentCricket_CheckParam] TO bodbDownlineNetView 


