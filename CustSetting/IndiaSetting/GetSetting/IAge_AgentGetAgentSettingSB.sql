USE [InCustDB]
GO
/****** Object:  StoredProcedure [dbo].[Las_AgentGetAgentSBSettingForUpdate_xtest]    Script Date: 7/10/2014 2:02:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[IAge_AgentGetAgentSettingSB]
	@AgentId	INT 
AS

/**
 * Created by	: 20140708@Tom.Vo
 * Task			: IAge_AgentGetAgentSBSetting
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
		@agentHId		HIERARCHYID,
		@parentAgentId	INT,
		@AgentL0Id		INT,
		@AgentLevel		INT

	-- Get agent hierarchy ID
	SELECT 
		@agentHId		= AgentHId,
		@AgentLevel		= AgentLevel
	FROM AgentInfo a WITH (NOLOCK)
	WHERE AgentId = @AgentId

	SELECT 
		@parentAgentId		= AgentId		
	FROM AgentInfo a WITH (NOLOCK)
	WHERE @agentHId.GetAncestor(1)=AgentHId
	
	DECLARE @BetLimitParentTable dbo.BetLimit
	DECLARE @TableParentPositionTaking [dbo].[PositionTaking]

	--Viren Agent
	IF @AgentLevel=1
	BEGIN
		IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting
		SELECT * INTO #CustSetting FROM bodb02.dbo.CustSetting cs WITH(NOLOCK) WHERE CUSTID = @AgentId AND (SportType<=99 OR sporttype=154)

		--------GET DISCOUNT
		SELECT DISTINCT cs.SportType,cs.BetType,
			CASE WHEN cs.groupa <=0 THEN cs.adiscount ELSE cs.groupa END [DiscountA],
			cs.groupb DiscountB,
			cs.groupc DiscountC,
			cs.groupd DiscountD,
			CASE WHEN cs.groupa <=0 THEN cs.adiscount ELSE cs.groupa END UplineMinDiscountA,
			cs.groupb UplineMinDiscountB,
			cs.groupc UplineMinDiscountC,
			cs.groupd UplineMinDiscountD
		FROM #CustSetting cs
				
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
			WHERE custid=@AgentId	AND (SportType<=99 OR sporttype=154)
			GROUP BY	SportType,
						BetType
			ORDER BY SportType,
						BetType

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 1
				
		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch2 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 2
			
		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch3 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 3

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch5 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 5
				
		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch8 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 8

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch10 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 10

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch11 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 11

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch99 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 99 AND BetType=1

		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch99MP FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 99 AND BetType=9
				
		UPDATE @BetLimitParentTable
		SET MaxPerMatch =  (SELECT TOP 1 maxpermatch154 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentId)
		WHERE SportType = 154 AND BetType=20

		DELETE FROM @BetLimitParentTable WHERE MinBet=0 AND MaxBet=0 AND MaxPerMatch=0
		
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
		GROUP BY abl.SportType,
			abl.BetType
		ORDER BY abl.SportType,
			abl.BetType

		INSERT INTO  @TableParentPositionTaking(SportType,BetType,IsLive,MaxUpper,MaxGiven,MinGiven)
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

		SELECT  
			apt.SportType,
			apt.BetType,
			apt.IsLive,
			apt.MaxUpper MaxUpperPositionTaking,
			apt.MaxGiven 						AS MaxGivenPositionTaking,
			apt.MaxGiven MaxGivenPositionTaking,
			0	AS MaxOfMaxUpperAndGiven,
			apt.MinGiven MinGivenPositionTaking,
			apt.MinGiven				AS ParentMinGivenPositionTaking
		FROM @TableParentPositionTaking apt
		ORDER BY apt.SportType,
			apt.BetType
	
		IF OBJECT_ID('tempdb..#CustSetting') IS NOT NULL    DROP TABLE #CustSetting
		RETURN
	END


	SELECT 
	@AgentL0Id		= AgentId		
	FROM AgentInfo a WITH (NOLOCK)
	WHERE @agentHId.IsDescendantOf(AgentHId)=1 AND a.AgentLevel=1

	SELECT @AgentL0Id,@parentAgentId
	--------GET DISCOUNT
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
		AgentDiscount AS ad WITH (NOLOCK)					-- agent discount
		LEFT JOIN AgentDiscount AS adp WITH (NOLOCK)		-- parent discount
			ON ad.SportType	= adp.SportType	
			AND ad.BetType	= adp.BetType
			AND adp.AgentId = @parentAgentId
	WHERE ad.AgentId = @AgentId AND (ad.SportType <=99 OR ad.SportType=154)

	
-- Select of AgentBetLimit
	DECLARE @BetLimitTempParentTable TABLE (
		SportType SMALLINT,
		BetType SMALLINT,
		MinBet MONEY,
		MaxBet MONEY,
		MaxPerMatch MONEY)
	DECLARE @BetLimitParentTable1 TABLE (
		SportType SMALLINT,
		BetType SMALLINT,
		MinBet MONEY,
		MaxBet MONEY,
		MaxPerMatch MONEY)

	INSERT INTO @BetLimitTempParentTable(				
		SportType,
		BetType,
		MinBet,
		MaxBet)
	SELECT 				
		SportType,
		BetType,
		MAX(MinBet),
		MIN(MaxBet)
	FROM bodb02.dbo.Dep_custsetting WITH (NOLOCK)
	WHERE custid=@AgentL0Id AND (BetType=1 OR (SportType=99 AND BetType=9) OR sporttype=154)		
	GROUP BY	SportType,
				BetType

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 1
				
	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch2 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 2
			
	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch3 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 3

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch5 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 5
				
	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch8 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 8

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch10 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 10

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch11 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 11	

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch99 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 99 AND BetType=1
				
	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch99MP FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 99 AND BetType=9	

	UPDATE @BetLimitTempParentTable
	SET MaxPerMatch =  (SELECT maxpermatch154 FROM bodb02.dbo.Custinfo  WITH (NOLOCK) WHERE custid=@AgentL0Id)
	WHERE SportType = 154 AND BetType=20
			
	INSERT INTO @BetLimitTempParentTable(		
	SportType,
	BetType,
	MinBet,
	MaxBet,
	MaxPerMatch)
	SELECT	
			[SportType],
			[BetType],
			[MinBet],
			[MaxBet],
			[MaxPerMatch]
	FROM 	AgentBetLimit WITH (NOLOCK)
	INNER JOIN AgentInfo ON AgentBetLimit.AgentId=AgentInfo.AgentId
	WHERE @AgentHId.IsDescendantOf(AgentInfo.AgentHId)=1 AND AgentInfo.AgentHId!=@AgentHId

	DELETE FROM @BetLimitTempParentTable WHERE MinBet=0 AND MaxBet=0 AND MaxPerMatch=0

	INSERT INTO @BetLimitParentTable(		
	SportType,
	BetType,
	MinBet,
	MaxBet,
	MaxPerMatch)
	SELECT  [SportType],
			[BetType],
			MAX([MinBet])		AS MinBet,
			MIN([MaxBet])		AS MaxBet,
			MIN([MaxPerMatch])	AS MaxPerMatch
	FROM	@BetLimitTempParentTable
	GROUP BY	SportType,
				BetType	
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
		AgentBetLimit AS abl WITH (NOLOCK)
		LEFT JOIN @BetLimitParentTable AS ubl 	-- parent betlimmit
			ON abl.SportType	= ubl.SportType	
			AND abl.BetType		= ubl.BetType				
	WHERE abl.AgentId = @AgentId


	DECLARE  @TablePositionTaking TABLE(
			AgentId		INT,
			SportType	SMALLINT,
			BetType		SMALLINT,
			IsLive		BIT,		
			MaxUpperPositionTaking	SMALLINT,
			MaxGivenPositionTaking	SMALLINT,
			MinGivenPositionTaking	SMALLINT
			)	
	
	INSERT INTO @TablePositionTaking(
		AgentId,
		SportType,
		BetType,
		IsLive,		
		MaxUpperPositionTaking,
		MaxGivenPositionTaking,
		MinGivenPositionTaking
	)
	SELECT	AgentId,
			SportType,
			BetType,
			IsLive,
			MaxUpperPositionTaking,
			MaxGivenPositionTaking,
			MinGivenPositionTaking 
	FROM AgentPositionTaking WITH (NOLOCK)
	WHERE AgentId = @AgentId

	DECLARE  @TableDownline TABLE(			
		SportType	SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,		
		MaxOfMaxUpperAndGiven	SMALLINT			
		)

	INSERT INTO @TableDownline(	
	SportType,
	BetType,
	IsLive,		
	MaxOfMaxUpperAndGiven
	)
	SELECT	
	capt.SportType,
	capt.BetType,
	capt.IsLive,
	MAX(capt.MaxUpperPositionTaking + capt.MaxGivenPositionTaking) AS MaxOfMaxUpperAndGiven
	FROM AgentPositionTaking AS capt WITH (NOLOCK)			
	INNER JOIN AgentInfo AS a  WITH (NOLOCK) ON capt.AgentId=a.AgentId
	WHERE AgentHId.GetAncestor(1) = @AgentHId 
	GROUP BY 				
	capt.SportType,
	capt.BetType,
	capt.IsLive
	
	IF EXISTS(SELECT TOP 1 1 FROM @TableDownline)
	BEGIN
		SELECT 
		apt.SportType,
		apt.BetType,
		apt.IsLive,
		apt.MaxUpperPositionTaking,
		papt.MaxGivenPositionTaking						AS ParentMaxGivenPositionTaking,
		apt.MaxGivenPositionTaking,
		maxDownAgent.MaxOfMaxUpperAndGiven				AS MaxOfMaxUpperAndGiven,
		apt.MinGivenPositionTaking
		,papt.MinGivenPositionTaking					AS ParentMinGivenPositionTaking
	FROM 
		@TablePositionTaking AS apt 
		INNER JOIN AgentPositionTaking AS papt WITH (NOLOCK)
			ON  papt.AgentId	= @parentAgentId	
			AND apt.SportType	= papt.SportType
			AND apt.BetType		= papt.BetType
			AND apt.IsLive		= papt.IsLive
			
		INNER JOIN 		
		 @TableDownline AS maxDownAgent
			ON 			
			apt.SportType		= maxDownAgent.SportType
			AND apt.BetType		= maxDownAgent.BetType
			AND apt.IsLive		= maxDownAgent.IsLive
	END
	ELSE
	BEGIN
	SELECT  
		apt.SportType,
		apt.BetType,
		apt.IsLive,
		apt.MaxUpperPositionTaking,
		papt.MaxGivenPositionTaking						AS ParentMaxGivenPositionTaking,
		apt.MaxGivenPositionTaking,
		0	AS MaxOfMaxUpperAndGiven,
		apt.MinGivenPositionTaking
		,papt.MinGivenPositionTaking					AS ParentMinGivenPositionTaking
	FROM 
		@TablePositionTaking AS apt 
		INNER JOIN AgentPositionTaking AS papt WITH (NOLOCK)
			ON  papt.AgentId	= @parentAgentId	
			AND apt.SportType	= papt.SportType
			AND apt.BetType		= papt.BetType
			AND apt.IsLive		= papt.IsLive
	END

END


GO


GRANT EXECUTE ON [IAge_AgentGetAgentSettingSB] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_AgentGetAgentSettingSB] TO bodbDownlineNetView 

