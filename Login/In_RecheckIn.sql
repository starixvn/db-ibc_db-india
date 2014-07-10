CREATE PROCEDURE [dbo].[In_RecheckIn]   
 @On_UserID int,  
 @IsKickedOut bit = 0 OUTPUT  
AS  
SET NOCOUNT ON  
/*  
	Created: 20140710@Dominic  
	Task : Sport Agency ReCheckIn
	DB: DBIN/ON_USER	  
	Revisions:  
*/  
BEGIN   
	DECLARE @OUTPUT TABLE (IsKickedOut bit)  
  
	UPDATE dbo.on_user_agent with (ROWLOCK)  
	SET reload_time = getdate()   
	OUTPUT DELETED.IsKickedOut INTO @OUTPUT  
	where on_userid = @On_UserID  
  
	IF @@ROWCOUNT = 0  
	 SELECT @IsKickedOut = 1  
	ELSE IF EXISTS (SELECT 1 FROM @OUTPUT WHERE IsKickedOut = 1)  
	 SELECT @IsKickedOut = 1  
	ELSE  
	 SET @IsKickedOut = 0  
END
GO

GRANT EXECUTE ON [dbo].[In_RecheckIn] TO bodbDownlineNet   
GO
GRANT EXECUTE ON [dbo].[In_RecheckIn] TO bodbDownlineNetView
GO
GRANT VIEW definition ON [dbo].[In_RecheckIn] TO vnteam