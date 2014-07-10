USE [InCustDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

ALTER PROCEDURE [dbo].[IAge_ValidationDiscountCricket]
(	@TableDiscount dbo.Discount READONLY
	, @TableParentDiscount dbo.Discount READONLY
	
	, @MsgId INT = 0 OUTPUT
	, @SportTypeOutput INT = 0 OUTPUT
	, @BetTypeOutput INT = 0 OUTPUT
)	
AS
/**
 * Created by	: 20140708@Tom.Vo
 * Task : Validation Discount SB
 * DB : DBIN/InCustDB
 * Revisions :   

 * Parameters:
 *	•
 *	•
 *  
 */
BEGIN
	SET NOCOUNT ON
	
	-- Check validate range
	IF EXISTS (SELECT TOP(1) 1					
	FROM @TableDiscount
	WHERE 
		(DiscountA NOT BETWEEN 0 AND 0.0025		AND SportType = 1 AND BetType = 1)		-- Group A
	OR	(DiscountB NOT BETWEEN 0 AND 0.005		AND SportType = 1 AND BetType = 1)		-- Group B
	OR	(DiscountC NOT BETWEEN 0 AND 0.0075		AND SportType = 1 AND BetType = 1)		-- Group C				
	OR	(DiscountD NOT BETWEEN 0 AND 0.01		AND SportType = 1 AND BetType = 1)		-- Group D
	OR	(DiscountA NOT BETWEEN 0 AND 0.0025		AND SportType = 1 AND BetType = 5)		-- 1x2
	OR	(DiscountA NOT BETWEEN 0 AND 0.01		AND SportType = 1 AND BetType = 4)		-- Others 
	OR	(DiscountA NOT BETWEEN 0 AND 0.0001		AND SportType = 154 AND BetType = 20)		-- HRFO
	)
	BEGIN
	SELECT @MsgId=10301	--'Invalid commission rate'
	RETURN
	END
END


GO 

GRANT EXECUTE ON [IAge_ValidationDiscountCricket] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_ValidationDiscountCricket] TO bodbDownlineNetView 
