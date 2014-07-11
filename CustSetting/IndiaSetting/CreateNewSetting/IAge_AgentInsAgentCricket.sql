USE [InCustDB]
GO

ALTER PROCEDURE [dbo].[IAge_AgentInsAgentCricket](
    @AgentId INT
	
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
	
	---- Insert default agent discount (from its parent)
	DECLARE @TableDiscount dbo.Discount
	DECLARE @TableParentDiscount dbo.Discount

	INSERT INTO @TableDiscount (SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @Discount, @Mode = 'D-A'
	
	---- Insert Agent0 PT
	DECLARE  @TablePositionTaking [dbo].[PositionTaking]
	
	INSERT INTO @TablePositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @PositionTaking, @Mode = 'PT-A'
			
	-- Insert into AgentBetLimit
	INSERT INTO  [AgentBetLimit](
	AgentId,
	SportType,
	BetType,
	MinBet,
	MaxBet,
	MaxPerMatch
	)
	SELECT	@AgentId,
			SportType,
			BetType,
			MinBet,
			MaxBet,
			MaxPerMatch
	FROM @BetLimitTable	
	IF @@ERROR > 0
	BEGIN
		SELECT @MsgId=10501
			-- 'Failed to insert agent - Cricket<BetLimit>
		DELETE FROM AgentBetLimit WITH(ROWLOCK) WHERE AgentId = @AgentID -- ROLL BACK manual
		RETURN
	END	

	-- Insert into Agent discount
	INSERT INTO  [AgentDiscount](
		AgentId,
		SportType,
		BetType,
		DiscountA,
		DiscountB,
		DiscountC,
		DiscountD
		)
	SELECT	@AgentId,		
			SportType,
			BetType,
			DiscountA,
			DiscountB,
			DiscountC,
			DiscountD
	FROM @TableDiscount
	IF @@ERROR > 0
	BEGIN
		SELECT @MsgId=10502
		-- 'Failed to insert agent - Cricket<Discount>
		DELETE FROM AgentBetLimit WITH(ROWLOCK) WHERE AgentId = @AgentID AND (sporttype=203)-- ROLL BACK manual
		DELETE FROM AgentDiscount WITH(ROWLOCK) WHERE AgentId = @AgentID AND (sporttype=203)-- ROLL BACK manual
		RETURN
	END	

	-- Insert into Agent PT
	INSERT INTO  AgentPositionTaking(
		AgentId,
		SportType,
		BetType,
		IsLive,
		MaxUpperPositionTaking,
		MinGivenPositionTaking,
		MaxGivenPositionTaking	
	)
	SELECT	@AgentId,		
			SportType,
			BetType,
			IsLive,
			MaxUpper,
			MinGiven,
			MaxGiven
	FROM @TablePositionTaking
	
	IF @@ERROR > 0
	BEGIN
		SELECT @MsgId=10503
			-- 'Failed to insert agent - Cricket<PositionTaking>
		DELETE FROM AgentBetLimit		WITH(ROWLOCK) WHERE AgentId = @AgentID AND (sporttype=203)-- ROLL BACK manual
		DELETE FROM AgentDiscount		WITH(ROWLOCK) WHERE AgentId = @AgentID AND (sporttype=203)-- ROLL BACK manual
		DELETE FROM AgentPositionTaking WITH(ROWLOCK) WHERE AgentId = @AgentID AND (sporttype=203)-- ROLL BACK manual
		RETURN
	END	
	
END


GO 

GRANT EXECUTE ON [IAge_AgentInsAgentCricket] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentInsAgentCricket] TO bodbDownlineNetView 
