CREATE PROCEDURE [dbo].[In_AgentLoginDownline]    
	 @UserName		VARCHAR(50)		= '',    
	 @UserPwd		VARCHAR(50),    
	 @LoginIP		VARCHAR(15)		='',
	 @LoginDomain	NVARCHAR(253)	= NULL,
	 @BrowserName	NVARCHAR(255)	= NULL,  
	 @Platform		NVARCHAR(255)	= NULL,        
	 @CountryCode	VARCHAR(64)  = NULL, 
	 @AgentID		INT						OUTPUT,   
	 @AgentLevel	SMALLINT		= 0		OUTPUT,    
	 @Currency		VARCHAR(10)		= ''	OUTPUT,    
	 @CurrencyId	INT				= 0		OUTPUT,
	 @ErrCode		INT				= 0		OUTPUT 
AS  
/*  
	Created: 20140710@Dominic  
	Task : Sport Agency Login for Viren Agent ,Agent_1 to Agent_N
	DB: DBIN/INCUSTDB
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @Begin  DATETIME  
	  ,@End  DATETIME  
	  ,@Duration INT  
	  ,@Status  TINYINT
	  ,@xml   XML  
	  ,@LogData  NVARCHAR(500)  
	  ,@Remark  NVARCHAR(500)  
	SET @Begin = GETDATE() 
	
	--SET @xml = (  
	--   SELECT   
	--	@AgentID  AS '@ag', 
	--	@AgentLevel  AS '@agl', 
	--	@LoginDomain AS '@ldo',
	--	@LoginIP AS '@i',
	--	@BrowserName AS '@br',
	--	@Platform AS '@pl',
	--	@CountryCode AS '@co',
	--	@UserName AS '@usr'
	--	FOR XML PATH('z'), ROOT('r')  
	--  )  
	--SET @LogData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')  
  
	SELECT   
	 @AgentID	= ai.AgentId,  
	 @Status	= ai.Status,  
	 @AgentLevel = ai.AgentLevel,
	 @CurrencyId = ai.Currency,
	 @Currency = e.currency
	FROM	dbo.AgentInfo ai WITH (NOLOCK)  
	JOIN	bodb02.dbo.Exchange e ON ai.Currency = e.exchangeid
	WHERE   
		ai.Username = @UserName   
		AND ai.UserPwd  = @UserPwd   

	IF (@AgentID IS NULL OR @AgentID = 0)  
	BEGIN  
	  --'Wrong username or password.'   		    
	  SELECT @ErrCode= 17001   
	 -- SET @Remark = 'User: ' + @UserName +  ' - ' + 'Failed(Password)'     
	    
	 -- SET @End  = GETDATE()  
	 -- SET @Duration = DATEDIFF(MILLISECOND,@Begin,@End)  
	  
	 -- EXEC InLogDB.dbo.WriteLog_LoginAgent  
		--@AdminId  = @AgentID,  
		--@SpName  ='In_AgentLoginDownline',  
		--@LogDate  =@End,  
		--@Duration  =@Duration,  
		--@Data   =@LogData,  
		--@OldData  =@Remark  
	  RETURN  	    
	END  
	ELSE IF (@Status <> 1)  
	BEGIN  
	  --print @Status  
	  --'This user is not active.'    
	  SELECT @ErrCode= 17002     
	 -- SET @Remark = 'User: ' + @UserName + ' - ' + 'Failed(User_Not_Active)'    
	    
	 -- SET @End  = GETDATE()  
	 -- SET @Duration = DATEDIFF(MILLISECOND,@Begin,@End)  
	  
	 -- EXEC InLogDB.dbo.WriteLog_LoginAgent 
		--@AdminId  = @UserId,  
		--@SpName  ='In_AgentLoginDownline',  
		--@LogDate  =@End,  
		--@Duration  =@Duration,  
		--@Data   =@LogData,  
		--@OldData  =@Remark  
	  RETURN  	    
	END 
	
	--SET @AgentID		= ISNULL(@AgentID,0)
	--SET @Remark = 'Agent: ' + @AgentID + ' - ' + 'Success'   

	--SET @End		= GETDATE()
	--SET @Duration	= DATEDIFF(MILLISECOND,@Begin,@End)

	--EXEC InLogDB.dbo.WriteLog_LoginAgent
	--			 @AdminId		= @UserId,
	--			 @SpName		='In_AgentLoginDownline',
	--			 @LogDate		=@End,
	--			 @Duration		=@Duration,
	--			 @Data			=@LogData,
	--			 @OldData		=@Remark
END
GO

GRANT EXECUTE ON [dbo].[In_CheckIn] TO bodbDownlineNet   
GO
GRANT EXECUTE ON [dbo].[In_CheckIn] TO bodbDownlineNetView
GO
GRANT VIEW definition ON [dbo].[In_CheckIn] TO vnteam