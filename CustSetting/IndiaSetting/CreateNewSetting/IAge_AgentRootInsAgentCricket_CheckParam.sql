USE [InCustDB]
GO

ALTER PROCEDURE [dbo].[IAge_AgentRootInsAgentCricket_CheckParam](
     @AgentL0Id INT
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
	INSERT INTO @BetLimitParentTable(
			SportType,
			BetType,
			MinBet,
			MaxBet)
		SELECT 
			SportType,
			BetType,
			MAX(MinBet),
			MIN(MaxBet)
		FROM bodb02.dbo.Custsetting WITH (NOLOCK)
		WHERE custid=@AgentL0Id	AND (sporttype=203)
		GROUP BY	SportType,
					BetType
				
	UPDATE @BetLimitParentTable
	SET MaxPerMatch =  (SELECT TOP 1 maxpermatch203 FROM DBTXN.CustDB.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 203

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
	
	IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting
	SELECT * INTO #CustSetting FROM DBTXN.CustDB.dbo.CustSetting cs WITH(NOLOCK) WHERE CUSTID = @AgentL0Id AND (sporttype=203)

	---- Insert default agent discount (from its parent)
	DECLARE @TableDiscount dbo.Discount
	DECLARE @TableParentDiscount dbo.Discount

	INSERT INTO @TableDiscount (SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD)
	EXEC [dbo].[IAge_ConvertXMLDataToTable] @XMLData = @Discount, @Mode = 'D-A'

	INSERT INTO  @TableParentDiscount(SportType,BetType,DiscountA,DiscountB,DiscountC,DiscountD)
	SELECT cs.SportType,cs.BetType,CASE WHEN cs.groupa <=0 THEN cs.adiscount ELSE cs.groupa END [DiscountA],
		cs.groupb,cs.groupc,cs.groupd
	FROM #CustSetting cs
	
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
	INSERT INTO  @TableParentPositionTaking(SportType,BetType,IsLive,MaxUpper,MinGiven,MaxGiven)
	SELECT cs.SportType,
		cs.BetType,
		0 [IsLive],
		0 MaxUpperPositionTaking,
		apositiontaking MaxGivenPositionTaking,
		0 MinGivenPositionTaking
	FROM #CustSetting cs
	UNION ALL 
	SELECT cs.SportType,
		cs.BetType,
		1 [IsLive],
		0 MaxUpperPositionTaking,
		alivepositiontaking MaxGivenPositionTaking,
		0 MinGivenPositionTaking
	FROM #CustSetting cs
	WHERE alivepositiontaking	<> 0 
		OR mlivepositiontaking	<> 0
		OR slivepositiontaking  <> 0

	IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting

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

GRANT EXECUTE ON [IAge_AgentRootInsAgentCricket_CheckParam] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentRootInsAgentCricket_CheckParam] TO bodbDownlineNetView 
