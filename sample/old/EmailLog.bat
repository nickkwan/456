

set ThisPath=D:\VRUBatch\UAT\Job\VRUInhouseMon
set ThisLog=%ThisPath%\ServerRebootEmail.Log

D:
CD %ThisPath%

if "%computername%" == "PRDVVRUDB" goto Is_PROD_DR
if "%computername%" == "DRVVRUDB" goto Is_PROD_DR

set EmailList="kennychu@dahsing.com, samau@dahsing.com"
set EMAILSERVER=172.27.2.91
goto SendEmail

:Is_PROD_DR
set EmailList="kennychu@dahsing.com, samau@dahsing.com"
set EMAILSERVER=172.27.2.142
goto SendEmail

:SendEmail

date /t > %ThisLog%
time /t >> %ThisLog%


REM blat %3 -f "%4%computername%" -s "%1" -attach %2 -server dsbxchsrv02a -t %EmailList%
REM echo blat %2 -f "%3%computername%@dahsing.com" -s "%1"  -server dsbxchsrv02a -t %EmailList%
blat %2 -f "%3%computername%@dahsing.com" -s %1  -server %EMAILSERVER% -t %EmailList%

REM blat %ThisLog% -f "%computername%@dahsing.com" -s "Rebooted [Internal Use Only]" -attach %ThisLog% -server %EMAILSERVER% -t %EmailList%
REM echo Powershell.exe -ExecutionPolicy Bypass -File sendemail.ps1 %EmailList% "%3%computername%" %1 %ThisLog%  %EMAILSERVER%  %2	>>%ThisLog%
REM Powershell.exe -ExecutionPolicy Bypass -File sendemail.ps1 %EmailList% "%3%computername%" %1 %ThisLog%  %EMAILSERVER%  %2
