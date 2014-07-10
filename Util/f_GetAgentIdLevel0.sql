CREATE FUNCTION [dbo].[f_GetAgentIdLevel0]  
(  
	@AgentId INT  
)   
RETURNS INT  
AS  
/*  
	Created: 20140710@Dominic  
	Task : get Agent Root
	DB: DBIN/INCUSTDB
	Revisions:  
*/  
  
BEGIN  
 DECLARE @AgentIdLevel0 INT  
 ;WITH Upline(AgentId, AgentHId, AgentLevel) AS  
 (  
  SELECT AgentId, AgentHId, AgentLevel  
  FROM dbo.AgentInfo WITH(NOLOCK)  
  WHERE AgentId = @AgentId  
  
  UNION ALL  
  
  SELECT ai.AgentId, ai.AgentHId, ai.AgentLevel  
  FROM dbo.AgentInfo ai WITH(NOLOCK)  
   INNER JOIN Upline ul ON ul.AgentHId.GetAncestor(1) = ai.AgentHId   
 )     
 SELECT @AgentIdLevel0 = AgentId FROM Upline WHERE AgentLevel = 1  
 RETURN @AgentIdLevel0  
END  