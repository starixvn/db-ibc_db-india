USE [InCustDB]
GO
/****** Object:  StoredProcedure [dbo].[Las_AgentGetAgentSBSettingForUpdate_xtest]    Script Date: 7/10/2014 2:02:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[IAge_AgentGetAgentSettingCricket]
	@AgentId	INT 
AS

/**
 * Created by	: 20140708@Tom.Vo
 * Task			: IAge_AgentGetAgentSettingCricket
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
		@AgentHId		HIERARCHYID,
		@parentAgentId	INT,
		@AgentLevel		INT,
		@TempID			INT

	-- Get agent hierarchy ID
	SELECT @parentAgentId= a.ParentId  ,@AgentHId		= AgentHId,	@AgentLevel	= AgentLevel	FROM AgentInfo a WITH (NOLOCK)	WHERE AgentId = @AgentId
	
	DECLARE @TableParentDiscount dbo.Discount
	DECLARE @BetLimitParentTable dbo.BetLimit
	DECLARE @TableParentPositionTaking [dbo].[PositionTaking]	
	
	--Viren Agent
	IF @AgentLevel IN (1,2)
	BEGIN
		IF @AgentLevel = 1
			SET @TempID = @AgentId
		ELSE
			SET @TempID = @parentAgentId

		IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting
		SELECT * INTO #CustSetting FROM bodb02.dbo.CustSetting cs WITH(NOLOCK) WHERE CUSTID = @TempID AND (SportType=203)

		--------GET DISCOUNT
		INSERT INTO @TableParentDiscount(SportType,BetType,[DiscountA],DiscountB,DiscountC,DiscountD)
		SELECT DISTINCT cs.SportType,cs.BetType,
			CASE WHEN cs.groupa <=0 THEN cs.adiscount ELSE cs.groupa END [DiscountA],
			cs.groupb DiscountB,
			cs.groupc DiscountC,
			cs.groupd DiscountD
		FROM #CustSetting cs
		
		-------GET BET LIMIT
		INSERT INTO @BetLimitParentTable(SportType,BetType,MinBet,MaxBet)
		SELECT 
			SportType,
			BetType,
			MAX(MinBet),
			MIN(MaxBet)
		FROM #CustSetting
		WHERE custid=@AgentId	AND (Sporttype=203)
		GROUP BY	SportType,
					BetType

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch203 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 1
		
		DELETE FROM @BetLimitParentTable WHERE MinBet=0 AND MaxBet=0 AND MaxPerMatch=0
		
		-------GET Position Taking
		INSERT INTO  @TableParentPositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
		SELECT cs.SportType,
			cs.BetType,
			0 [IsLive],
			0 MaxUpperPositionTaking,
			10000*mpositiontaking MaxGivenPositionTaking,
			0 MinGivenPositionTaking			
		FROM #CustSetting cs
		UNION ALL 
		SELECT cs.SportType,
			cs.BetType,
			1 [IsLive],
			0 MaxUpperPositionTaking,
			10000*mlivepositiontaking MaxGivenPositionTaking,
			0 MinGivenPositionTaking
		FROM #CustSetting cs
		WHERE alivepositiontaking	<> 0 
			OR mlivepositiontaking	<> 0
			OR slivepositiontaking  <> 0
			 
		IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting
	END
	ELSE
	BEGIN
			--------GET DISCOUNT
		INSERT INTO @TableParentDiscount(SportType,BetType,[DiscountA],DiscountB,DiscountC,DiscountD)
		SELECT DISTINCT cs.SportType,cs.BetType,
			cs.[DiscountA],
			cs.DiscountB,
			cs.DiscountC,
			cs.DiscountD
		FROM dbo.AgentDiscount cs  WITH(NOLOCK) 
		WHERE AgentId = @AgentId AND (SportType=203)
		
		-------GET BET LIMIT
		INSERT INTO @BetLimitParentTable(SportType,BetType,MinBet,MaxBet,MaxPerMatch)
		SELECT cs.SportType,cs.BetType,cs.MinBet,cs.MaxBet,cs.MaxPerMatch 
		FROM dbo.AgentBetLimit cs  WITH(NOLOCK) 
		WHERE AgentId = @AgentId AND (SportType=203)

		-------GET Position Taking
		INSERT INTO  @TableParentPositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
		SELECT cs.SportType,cs.BetType,cs.IsLive,cs.MaxUpperPositionTaking,cs.MaxGivenPositionTaking,cs.MinGivenPositionTaking
		FROM dbo.AgentPositionTaking cs  WITH(NOLOCK) 
		WHERE AgentId = @AgentId AND (SportType=203)
	END

	IF @AgentLevel=1
	BEGIN
		--------GET DISCOUNT
		SELECT DISTINCT cs.SportType,cs.BetType,
			cs.DiscountA,
			cs.DiscountB,
			cs.DiscountC,
			cs.DiscountD,
			cs.DiscountA UplineMinDiscountA,
			cs.DiscountB UplineMinDiscountB,
			cs.DiscountC UplineMinDiscountC,
			cs.DiscountD UplineMinDiscountD
		FROM @TableParentDiscount cs
		ORDER BY cs.SportType,cs.BetType
				
		SELECT  
			abl.SportType,
			abl.BetType,
			MAX(ISNULL([MinBet],0))		AS MinBet,
			MIN(ISNULL([MaxBet],0))		AS MaxBet,
			MIN(ISNULL([MaxPerMatch],0))	AS MaxPerMatch,
			MAX(ISNULL([MinBet],0))		AS MaxMinBet,
			MIN(ISNULL([MaxBet],0))		AS MinMaxBet,
			MIN(ISNULL([MaxPerMatch],0))	AS MinMaxPerMatch
		FROM @BetLimitParentTable abl
		GROUP BY abl.SportType,abl.BetType
		ORDER BY abl.SportType,abl.BetType

		SELECT  
			apt.SportType,
			apt.BetType,
			apt.IsLive,
			apt.MaxUpper	AS	MaxUpperPositionTaking,
			apt.MaxGiven 	AS	MaxGivenPositionTaking,
			apt.MaxGiven	AS	MaxGivenPositionTaking,
			0				AS	MaxOfMaxUpperAndGiven,
			apt.MinGiven	AS	MinGivenPositionTaking,
			apt.MinGiven	AS	ParentMinGivenPositionTaking
		FROM @TableParentPositionTaking apt
		ORDER BY apt.SportType,
			apt.BetType
	
		RETURN
	END	
	ELSE
	BEGIN
		SELECT 
			ad.SportType,
			ad.BetType,
			ad.DiscountA,
			ad.DiscountB,
			ad.DiscountC,
			ad.DiscountD,
			adp.DiscountA	AS UplineMinDiscountA,
			adp.DiscountB	AS UplineMinDiscountB,
			adp.DiscountC	AS UplineMinDiscountC,
			adp.DiscountD	AS UplineMinDiscountD
		FROM 
			dbo.AgentDiscount AS ad WITH (NOLOCK)		-- agent discount
			LEFT JOIN @TableParentDiscount AS adp  -- parent discount
				ON ad.SportType	= adp.SportType	
				AND ad.BetType	= adp.BetType
		WHERE ad.AgentId = @AgentId AND (ad.SportType=203)

		SELECT  
			abl.SportType,
			abl.BetType,
			abl.MinBet,
			abl.MaxBet,
			abl.MaxPerMatch,
			ISNULL(ubl.MinBet,0)		AS MaxMinBet,
			ISNULL(ubl.MaxBet,0)		AS MinMaxBet,
			ISNULL(ubl.MaxPerMatch,0)	AS MinMaxPerMatch
		FROM 
			dbo.AgentBetLimit AS abl WITH (NOLOCK)
			LEFT JOIN @BetLimitParentTable AS ubl 	-- parent betlimmit
				ON abl.SportType	= ubl.SportType	
				AND abl.BetType		= ubl.BetType				
		WHERE abl.AgentId = @AgentId  AND (abl.SportType=203)

		SELECT apt.SportType, apt.BetType, apt.IsLive
			, apt.MaxUpperPositionTaking
			, apt.MaxGivenPositionTaking
			, apt.MinGivenPositionTaking
			, ISNULL(directDownline.MaxOfMaxUpperAndGiven, 0) AS MaxOfMaxUpperAndGiven
			, papt.MaxGiven AS ParentMaxGivenPositionTaking
			, papt.MinGiven AS ParentMinGivenPositionTaking
		FROM dbo.AgentPositionTaking  AS apt WITH (NOLOCK)
			INNER JOIN @TableParentPositionTaking AS papt 
			ON  apt.SportType = papt.SportType 
				AND apt.BetType = papt.BetType AND apt.IsLive = papt.IsLive
			LEFT JOIN (
					SELECT capt.SportType, capt.BetType, capt.IsLive
						, MAX(capt.MaxUpperPositionTaking + capt.MaxGivenPositionTaking) AS MaxOfMaxUpperAndGiven
					FROM dbo.AgentPositionTaking AS capt WITH (NOLOCK)
					WHERE capt.AgentId IN (SELECT ai.AgentId FROM dbo.AgentInfo AS ai WITH (NOLOCK) WHERE ai.AgentHId.GetAncestor(1) = @AgentHId)
						AND capt.SportType = 203
					GROUP BY capt.SportType, capt.BetType, capt.IsLive
				) AS directDownline 
			ON apt.SportType = directDownline.SportType
				AND apt.BetType = directDownline.BetType 
				AND apt.IsLive = directDownline.IsLive
		WHERE apt.AgentId = @AgentId AND apt.SportType =203
	END
	

 
END

GO 

GRANT EXECUTE ON [IAge_AgentGetAgentSettingCricket] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentGetAgentSettingCricket] TO bodbDownlineNetView 
