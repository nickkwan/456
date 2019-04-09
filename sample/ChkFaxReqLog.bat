REM @echo off

REM SET DBName=[CIXDB_UAT].[dbo].[FAX_STMT_LOG]
REM Migrate to production require to update below CurPath parametner 
REM and the ChkFaxReq.sql file's DB instant name to CIXDB

SET CurPath=D:\VRUBatch\UAT\JOB\Stationery_Request\Sample


SET SQLFile=%CurPath%\ChkFaxReq.sql
SET LogFile=%CurPath%\EmailContent.txt
SET ErrLog="D:\VRUBatch\UAT\OUTBOX\VRU_CCD_NON_MERCHANT_INFO.TXT"
REM SET SQLLastNErr=%CurPath%\LastNErr.sql
REM SET LogLastNErr=%CurPath%\LastNErr_Log.txt

REM set for send email
if "%computername%" == "PRDVVRUDB" goto Is_PROD_DR
if "%computername%" == "DRVVRUDB" goto Is_PROD_DR
if "%computername%" == "DSBVRUDB" goto Is_PROD_DR

REM set EmailList="kennychu@dahsing.com, samau@dahsing.com, shaneho@dahsing.com"
set EmailList="nickho@dahsing.com"
REM set EmailList="kennychu@dahsing.com"
set EMAILSERVER=172.27.2.91
goto HereToContinue

:Is_PROD_DR
REM set EmailList="ITD_SYS_CC@dahsing.com"
set EmailList="nickho@dahsing.com"
set EMAILSERVER=172.27.2.142
goto HereToContinue

:HereToContinue
D:
cd %CurPath%

echo *** Checking Fax Request - Start 
REM list recent errors
REM sqlcmd -i %SQLFILE%  1> %LogFile% 2>&1
REM find /i "Error" %LogFile% > %ErrLog% 2>&1
REM 0 == found
REM 1 == not found

IF %ERRORLEVEL% == 1 goto No_Problem
goto FaxReq_Error

:FaxReq_Error
echo.
echo *** Checking Fax Request *** ERROR FOUND

Powershell.exe -ExecutionPolicy Bypass -File sendemail.ps1 %EmailList% "%computername%@dahsing.com" "Notification: VRU non-office hour call record"  %LogFile%  %EMAILSERVER%  %ErrLog%
if exist blat.exe blat.exe %LogFile% -f "%computername%@dahsing.com" -s "Notification: VRU non-office hour call record" -attach %LogFile% -server %EMAILSERVER%  -t %EmailList%

REM remove last normal check ok files


goto The_End

:No_Problem


goto The_End

:SkipSend
REM remove last normal check ok files if skipped check for four times.
REM IF EXIST Checked04.ok del Checked??.ok
REM IF EXIST Checked03.ok time /t > Checked04.ok


Goto The_End

Goto The_End

:The_End
echo.
echo *** Checking Fax Request - End


