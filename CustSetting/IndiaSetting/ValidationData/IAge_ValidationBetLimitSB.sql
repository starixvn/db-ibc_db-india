 USE [InCustDB]
GO
 

ALTER PROCEDURE [dbo].[IAge_ValidationBetLimitSB]
(	@BetLimitTable dbo.BetLimit READONLY
	, @BetLimitParentTable dbo.BetLimit READONLY
	
	, @MsgId INT = 0 OUTPUT
	, @SportTypeOutput INT = 0 OUTPUT
	, @BetTypeOutput INT = 0 OUTPUT
	, @BetLimitOutput MONEY = 0 OUTPUT
)	
AS
/**
 * Created by	: 20140708@Tom.Vo
 * Task : Validation betlimit 3rd
 * DB : DBIN/InCustDB
 * Revisions :   

 * Parameters:
 *	•
 *	•
 *  
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @NoneZeroBetLimitTable TABLE (
				SportType SMALLINT,
				BetType SMALLINT,
				MinBet MONEY,
				MaxBet MONEY,
				MaxPerMatch MONEY)
	INSERT INTO @NoneZeroBetLimitTable (
		SportType,
		BetType,
		MinBet,
		MaxBet,
		MaxPerMatch)
	SELECT
		SportType,
		BetType,
		MinBet,
		MaxBet,
		MaxPerMatch
	FROM @BetLimitTable
	EXCEPT
		SELECT
		SportType,
		BetType,
		MinBet,
		MaxBet,
		MaxPerMatch
	FROM @BetLimitTable
	WHERE MinBet=0 AND MaxBet=0 AND MaxPerMatch=0

-- Min Bet > Max Bet
	IF EXISTS(SELECT TOP(1) 1					
		FROM @BetLimitTable 
		WHERE MinBet > MaxBet)
		BEGIN
		SELECT TOP 1 @SportTypeOutput = SportType, @BetTypeOutput=BetType, @MsgId=10201 --'Min Single Bet must be less than or equal to Single Bet' 
		FROM @BetLimitTable 
		WHERE MinBet > MaxBet
		RETURN
		END

	-- Max Bet > Max Per Match
	IF EXISTS (SELECT TOP(1) 1				
		FROM @BetLimitTable 
		WHERE MaxBet > MaxPerMatch)
		BEGIN
		SELECT TOP 1 @SportTypeOutput = SportType,@BetTypeOutput=BetType, @MsgId=10202	--	'Single Bet must be less than or equal to Single Game' 
		FROM @BetLimitTable 
		WHERE MaxBet > MaxPerMatch
		RETURN
		END

	-- Check validate min bet must be equal to or greater than parent
	IF EXISTS ( SELECT TOP(1) 1					
	FROM 
		@BetLimitParentTable AS pa
		INNER JOIN @NoneZeroBetLimitTable AS b
		ON	pa.SportType	= b.SportType 
		AND pa.BetType		= b.BetType	
		AND b.MinBet		< pa.MinBet)
	BEGIN
	SELECT TOP 1 @SportTypeOutput = b.SportType,@BetLimitOutput=pa.MinBet,@BetTypeOutput=pa.BetType,@MsgId=10203	--	Min Single Bet must be equal to or greater than Parent Agent Min Single Bet
	FROM 
		@BetLimitParentTable AS pa
		INNER JOIN @NoneZeroBetLimitTable AS b
		ON	pa.SportType	= b.SportType 
		AND pa.BetType		= b.BetType	
		AND b.MinBet		< pa.MinBet
	RETURN
	END

	---- Check validate max bet must be equal to or less than parent	
		IF EXISTS ( SELECT TOP(1) 1
		FROM 
			@BetLimitParentTable AS pa
			INNER JOIN @NoneZeroBetLimitTable AS b 
			ON 	pa.SportType	 = b.SportType 
			AND pa.BetType		 = b.BetType
			AND b.MaxBet		 > pa.MaxBet)
		BEGIN
		SELECT  TOP 1 @SportTypeOutput = b.SportType,@BetLimitOutput=pa.MaxBet,@BetTypeOutput=pa.BetType, @MsgId=10204 --'Single Bet must be equal to or less than Parent Agent Single Bet' 
		FROM 
			@BetLimitParentTable AS pa
			INNER JOIN @NoneZeroBetLimitTable AS b 
			ON 	pa.SportType	 = b.SportType 
			AND pa.BetType		 = b.BetType
			AND b.MaxBet		 > pa.MaxBet
		RETURN
		END

	---- Check validate max per match must be equal to or less than parent
		IF EXISTS (SELECT TOP(1) 1
		FROM 
			@BetLimitParentTable AS pa
			INNER JOIN @NoneZeroBetLimitTable AS b 
			ON 
				pa.SportType = b.SportType 
				AND pa.BetType = b.BetType	
				AND b.MaxPerMatch > pa.MaxPerMatch)
		BEGIN
		SELECT  TOP 1 @SportTypeOutput = b.SportType,@BetLimitOutput=pa.MaxPerMatch,@BetTypeOutput=pa.BetType, @MsgId=10205	--'Single Game must be equal to or less than Parent Agent Single Game' 
		FROM 
			@BetLimitParentTable AS pa
			INNER JOIN @NoneZeroBetLimitTable AS b 
			ON 
				pa.SportType = b.SportType 
				AND pa.BetType = b.BetType	
				AND b.MaxPerMatch > pa.MaxPerMatch
		RETURN
		END	

END
GO



GO 

GRANT EXECUTE ON [IAge_ValidationBetLimitSB] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_ValidationBetLimitSB] TO bodbDownlineNetView 
