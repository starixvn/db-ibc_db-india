CREATE PROCEDURE [dbo].[In_CheckIn]  
 @AgentID int,  
 @NetSessionID varchar(30),  
 @ServerID int,    
 @IP nvarchar(15) = '',  
 @SubAccID int = 0,
 @On_UserID int OUTPUT 
AS  
  
/*  
	Created: 20140710@Dominic  
	Task : Sport Agency CheckIn
	DB: DBIN/ON_USER
	Revisions:  
*/
BEGIN 
   
	SET NOCOUNT ON  
	
	UPDATE dbo.on_user_agent WITH (ROWLOCK)   
	SET IsKickedOut = 1, ServerID=0   
	WHERE AgentID = @AgentID   
		AND SubAccID = @SubAccID 

		   
	INSERT INTO dbo.On_User_Agent  
	 (AgentID, NetSessionID, ServerID, IsKickedout, IP, SubAccID,LoginTime)  
	values  
	 (@AgentID, @NetSessionid, @ServerID, 0, @IP, @SubAccID,GETDATE())  
	   
	SELECT @On_UserID = SCOPE_IDENTITY()  
END
GO

GRANT EXECUTE ON [dbo].[In_CheckIn] TO bodbDownlineNet   
GO
GRANT EXECUTE ON [dbo].[In_CheckIn] TO bodbDownlineNetView
GO
GRANT VIEW definition ON [dbo].[In_CheckIn] TO vnteam