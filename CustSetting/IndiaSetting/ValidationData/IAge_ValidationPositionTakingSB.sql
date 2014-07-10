USE [InCustDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

ALTER PROCEDURE [dbo].[IAge_ValidationPositionTakingSB]
(	@TablePositionTaking dbo.PositionTaking READONLY
	,@TableParentPositionTaking dbo.PositionTaking READONLY
	
	, @MsgId INT = 0 OUTPUT
	, @PTSportType INT = 0 OUTPUT
	, @PTBetType INT = 0 OUTPUT
	, @IsLiveOutput BIT = 0 OUTPUT
)	
AS
/**
 * Created by	: 20140708@Tom.Vo
 * Task : Validation PositionTaking SB
 * DB : DBIN/InCustDB
 * Revisions :   

 * Parameters:
 *	•
 *	•
 *  
 */
BEGIN
	SET NOCOUNT ON
-- Check rule min <=PT of Licensee and max <=PT of Licensee
		IF EXISTS (SELECT TOP(1) 1
		FROM @TablePositionTaking PT_C
			INNER JOIN @TableParentPositionTaking PT_P
				ON PT_C.SportType = PT_P.SportType
				AND PT_C.BetType = PT_P.BetType
				AND PT_C.IsLive = PT_P.IsLive
		WHERE PT_C.MaxGiven	> PT_P.MaxGiven
			 )
		BEGIN
		SELECT TOP 1 @PTSportType=PT_C.SportType,@PTBetType=PT_C.BetType,@IsLiveOutput=PT_C.IsLive, @MsgId=10401		--'% must be equal or less than zero Max PT of Licensee' 
		FROM @TablePositionTaking PT_C
			INNER JOIN @TableParentPositionTaking PT_P
				ON PT_C.SportType = PT_P.SportType
				AND PT_C.BetType = PT_P.BetType
				AND PT_C.IsLive = PT_P.IsLive
		WHERE PT_C.MaxGiven	> PT_P.MaxGiven
		RETURN
		END

			-- Check rule min >= 0 and max >= 0
		IF EXISTS (SELECT TOP(1) 1
		FROM @TablePositionTaking
		WHERE MinGiven	< 0
			OR MaxGiven	< 0
			OR MaxUpper	< 0 )
		BEGIN
	
		SELECT TOP 1 @PTSportType=SportType,@PTBetType=BetType,@IsLiveOutput=IsLive,@MsgId=10402		--'% must be equal or greater than zero' 
		FROM @TablePositionTaking
		WHERE MinGiven	< 0
			OR MaxGiven	< 0
			OR MaxUpper	< 0 
		RETURN 
		END	
		

		-- Check rule max >= min
		IF EXISTS (SELECT TOP(1) 1
		FROM @TablePositionTaking
		WHERE MinGiven > MaxGiven)
		BEGIN
		SELECT TOP 1 @PTSportType=SportType,@PTBetType=BetType,@IsLiveOutput=IsLive,@MsgId=10403		--'% Min given PT must be equal to or less than % Max given PT' 
		FROM @TablePositionTaking
		WHERE MinGiven > MaxGiven
		RETURN
		END

END
		

GO 

GRANT EXECUTE ON [IAge_ValidationPositionTakingSB] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_ValidationPositionTakingSB] TO bodbDownlineNetView 
