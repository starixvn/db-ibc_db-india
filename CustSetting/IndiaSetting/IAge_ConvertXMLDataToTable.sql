USE [InCustDB]
GO
 

ALTER PROCEDURE [dbo].[IAge_ConvertXMLDataToTable]
(
	@XMLData VARCHAR(MAX) = ''
	, @Mode VARCHAR(20) = ''
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	IF @XMLData = ''
		RETURN

	DECLARE @DocHandler INT
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @XMLData

	IF @Mode = 'BL' --BetLimit for normal
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.Min, Data.Max, Data.MaxPerMatch
		FROM OPENXML(@DocHandler, '/ROOT/BetLimit', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, Min MONEY, Max MONEY, MaxPerMatch MONEY) AS Data
	END
	ELSE IF @Mode = 'BL-3rd'--BetLimit for 3rd( have more field MaxPerBall)
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.Min, Data.Max, Data.MaxPerMatch, ISNULL(Data.MaxPerBall,0)
		FROM OPENXML(@DocHandler, '/ROOT/BetLimit', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, Min MONEY, Max MONEY, MaxPerMatch MONEY, MaxPerBall MONEY) AS Data
	END
	ELSE IF @Mode = 'D-A'--discount on agent
	BEGIN
		SELECT Data.BetType, Data.SportType, Data.DiscountA, Data.DiscountB, Data.DiscountC, Data.DiscountD
		FROM OPENXML(@DocHandler, '/ROOT/Discount', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, DiscountA DECIMAL(9, 8), DiscountB DECIMAL(9, 8), DiscountC DECIMAL(9, 8), DiscountD DECIMAL(9, 8)) AS Data
	END
	ELSE IF @Mode = 'D-M' -- discount on member
	BEGIN
		SELECT Data.BetType, Data.SportType, Data.Discount
		FROM OPENXML(@DocHandler, '/ROOT/Discount', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, Discount DECIMAL(9, 8)) AS Data
	END
	ELSE IF @Mode = 'PT-All' -- PT has ApplyAll column
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.IsLive, Data.MaxUpper, Data.MaxGiven, Data.MinGiven, Data.ApplyAll
		FROM OPENXML(@DocHandler, '/ROOT/PositionTaking', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ApplyAll BIT, MaxUpper SMALLINT, MaxGiven SMALLINT, MinGiven SMALLINT) AS Data
	END
	ELSE IF @Mode = 'PT-A' --PT
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.IsLive, Data.MaxUpper, Data.MaxGiven, Data.MinGiven
		FROM OPENXML(@DocHandler, '/ROOT/PositionTaking', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, IsLive BIT, MaxUpper SMALLINT, MaxGiven SMALLINT, MinGiven SMALLINT) AS Data
		
	END
	ELSE IF @Mode = 'PT-L' --PT
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.IsLive, 10000-Data.MaxGiven, Data.MaxGiven, Data.MinGiven
		FROM OPENXML(@DocHandler, '/ROOT/PositionTaking', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, IsLive BIT, MaxUpper SMALLINT, MaxGiven SMALLINT, MinGiven SMALLINT) AS Data
		
	END
	ELSE IF @Mode = 'PT-M' --PT
	BEGIN
		SELECT Data.SportType, Data.BetType, Data.IsLive, Data.PT
		FROM OPENXML(@DocHandler, '/ROOT/PositionTaking', 1) 
		WITH (SportType SMALLINT, BetType SMALLINT, IsLive BIT, PT SMALLINT) AS Data
	END

	EXEC sp_xml_removedocument @DocHandler
END
GO

GO 

GRANT EXECUTE ON [IAge_ConvertXMLDataToTable] TO bodbDownlineNet 
GRANT EXECUTE ON [IAge_ConvertXMLDataToTable] TO bodbDownlineNetView 
