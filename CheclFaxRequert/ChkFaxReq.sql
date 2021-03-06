SET NOCOUNT ON
USE [CIXDB_UAT]
PRINT ' '

PRINT '/*** Status on Stmt Fax request check for last hour ***/'
select IIF(T.Cnt <12, 'ERROR : Check Fax Request count less than expected 12 trials per hour! '  + char(10) + 
 + char(10) + 'Please check the following on ' + (select top 1 MachineCode From [dbo].[FAX_STMT_LOG] order by [ActionDate] desc)+ '!' 
 + char(10) + '(1) Edify AO Job Start_Fax failed or '
 + char(10) + '(2) Windows scheduled task "Start Fax" is not running?', 'NORMAL') "Status"
From 
(SELECT ISNULL((select count(MachineCode) 
From [dbo].[FAX_STMT_LOG] 
where  datediff(MINUTE, ActionDate , getdate()) <= 60 
GROUP by MachineCode),0) Cnt) as T


-- Check retrieved host msg content if is null
select IIF((isnull((select top 1 [HostMsg] From [dbo].[FAX_STMT_LOG] order by [ActionDate] desc),'NULL')='NULL'), 'ERROR : Fax Request job failed to retrieve info from Host session (NULL HostMsg)! '  + char(10) + 
 + char(10) + 'Please check the following on ' + (select top 1 MachineCode From [dbo].[FAX_STMT_LOG] order by [ActionDate] desc)+ '!' 
 + char(10) + '(1) Any pending FAX jobs and'
 + char(10) + '(2) Whether Terminal session#25 is stalled?', 'NORMAL') "Status"
From 
(SELECT ISNULL((select count(MachineCode) 
From [dbo].[FAX_STMT_LOG] 
where  datediff(MINUTE, ActionDate , getdate()) <= 60 
GROUP by MachineCode),0) Cnt) as T

PRINT char(10) + '/*** Recent Stmt Fax request check Last Hr ***/'
select T.MachineCode, Count(1) "Trials/Hr" , sum(T.StmtReqCnt) "Stmt request check with content"
From 
	(SELECT MachineCode , IIF((HostMsg like '00%' or HostMsg is null), 0 ,1 ) StmtReqCnt 
	FROM [dbo].[FAX_STMT_LOG] 
	where  datediff(MINUTE, ActionDate , getdate()) <= 60 ) 	T
GROUP by MachineCode;

PRINT char(10) + '/*** Last 5 Stmt Fax request check ***/'
SELECT TOP (5) [ActionDate]
      ,[MachineCode]
      ,[Fax_Count]
      ,left([HostMsg], 25) HostMsg_25Char
  FROM [dbo].[FAX_STMT_LOG]
  --where  datediff(MINUTE, ActionDate , getdate()) <= 60
  order by [ActionDate] desc ;

PRINT char(10) + '/*** Last 5 Stmt Fax request check with content ***/'
SELECT TOP (5) [ActionDate]
      ,[MachineCode]
      ,[Fax_Count]
      ,left([HostMsg], 25) HostMsg_25Char
  FROM [dbo].[FAX_STMT_LOG]
  where HostMsg not like '00%'
  order by [ActionDate] desc ;

