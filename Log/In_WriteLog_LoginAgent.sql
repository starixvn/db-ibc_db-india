CREATE PROCEDURE [dbo].[In_WriteLog_LoginAgent]  
 @AgentId  INT    = NULL,  
 @SPName   NVARCHAR(50) = NULL,  
 @LogDate  DATETIME,  
 @Duration  INT    = NULL,  
 @Data   NVARCHAR(MAX) = NULL,  
 @OldData  NVARCHAR(MAX) = NULL  
AS  
  
/*  
	Created: 20140710@Dominic  
	Task : Write log login for Viren Agent to Agent_N
	DB: DBIN/INLOGDB
	Revisions:  
*/  
  
BEGIN  
  
 SET NOCOUNT ON  
   
 INSERT INTO LoginAgent (   
  AgentId,  
  SPName,  
  LogDate,    
  ActionId,  
  Duration,  
  Data,  
  OldData  
  )  
 SELECT   
  @AgentId,  
  @SPName,  
  @LogDate,    
  ActionId,  
  @Duration,  
  @Data,  
  @OldData  
 FROM LogAction WITH (NOLOCK)  
 WHERE SPName = @SPName  
  
END  

GO
GRANT EXECUTE ON [dbo].[In_WriteLog_LoginAgent] TO bodbDownlineNet   
GO
GRANT EXECUTE ON [dbo].[In_WriteLog_LoginAgent] TO bodbDownlineNetView