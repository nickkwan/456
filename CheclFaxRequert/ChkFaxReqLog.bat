REM @echo off

REM SET DBName=[CIXDB_UAT].[dbo].[FAX_STMT_LOG]
REM Migrate to production require to update below CurPath parametner 
REM and the ChkFaxReq.sql file's DB instant name to CIXDB

SET CurPath=D:\VRUBatch\UAT\JOB\CheckFaxRequest
SET LastMinutes=60

SET SQLFile=%CurPath%\ChkFaxReq.sql
SET LogFile=%CurPath%\ChkFaxReq_Log.txt
SET ErrLog=%CurPath%\ChkFaxReq_Err.txt
REM SET SQLLastNErr=%CurPath%\LastNErr.sql
REM SET LogLastNErr=%CurPath%\LastNErr_Log.txt

REM set for send email
if "%computername%" == "PRDVVRUDB" goto Is_PROD_DR
if "%computername%" == "DRVVRUDB" goto Is_PROD_DR
if "%computername%" == "DSBVRUDB" goto Is_PROD_DR

set EmailList="kennychu@dahsing.com, samau@dahsing.com, shaneho@dahsing.com"
REM set EmailList="kennychu@dahsing.com"
set EMAILSERVER=172.27.2.91
goto HereToContinue

:Is_PROD_DR
set EmailList="ITD_SYS_CC@dahsing.com"
set EMAILSERVER=172.27.2.142
goto HereToContinue

:HereToContinue
D:
cd %CurPath%

echo *** Checking Fax Request - Start 
REM list recent errors
sqlcmd -i %SQLFILE%  1> %LogFile% 2>&1
find /i "Error" %LogFile% > %ErrLog% 2>&1
REM 0 == found
REM 1 == not found

IF %ERRORLEVEL% == 1 goto No_Problem
goto FaxReq_Error

:FaxReq_Error
echo.
echo *** Checking Fax Request *** ERROR FOUND

Powershell.exe -ExecutionPolicy Bypass -File sendemail.ps1 %EmailList% "%computername%@dahsing.com" "[ERROR] Fax Request Error Found"  %LogFile%  %EMAILSERVER%  %LogFile%
if exist blat.exe blat.exe %LogFile% -f "%computername%@dahsing.com" -s "[ERROR] Fax Request Error Found" -attach %LogFile% -server %EMAILSERVER%  -t %EmailList%

REM remove last normal check ok files
del CheckIn??.ok

goto The_End

:No_Problem
echo.
echo *** Checking Fax Request - NORMAL

IF EXIST Checked01.ok goto SkipSend
IF Not EXIST Checked01.ok Powershell.exe -ExecutionPolicy Bypass -File sendemail.ps1 %EmailList% "%computername%@dahsing.com" "[NORMAL] Fax Request Normal"  %LogFile%  %EMAILSERVER%  %LogFile%
IF Not EXIST Checked01.ok if exist blat.exe blat.exe %LogFile% -f "%computername%@dahsing.com" -s "[NORMAL] Fax Request Normal"  -attach %LogFile% -server %EMAILSERVER%  -t %EmailList%
time /t > Checked01.ok

goto The_End

:SkipSend
REM remove last normal check ok files if skipped check for four times.
REM IF EXIST Checked04.ok del Checked??.ok
REM IF EXIST Checked03.ok time /t > Checked04.ok
IF EXIST Checked03.ok del Checked??.ok
IF EXIST Checked02.ok time /t > Checked03.ok
IF EXIST Checked01.ok time /t > Checked02.ok

Goto The_End

Goto The_End

:The_End
echo.
echo *** Checking Fax Request - End


