call DateTime.bat
call Parameters.bat
SET HolidayFile=%HolidayOutputPath%\%HolidayOutputFile%
SET CheckCntFile=%Min15RecCntOutputPath%\%Min15RecCntOutputFile%

@ECHO OFF
sqlcmd -h-1 -S %ServerName% -Q "%HolidaySQL:"=%" -o "%HolidayFile%"
REM for /f "tokens=1*delims= " %%a in ('findstr /n "^" %HolidayOutputPath%\%HolidayOutputFile%') do SET /A HolidayCnt=%%a
SET /p HolidayCnt=<%HolidayFile%
SET /A HolidayCnt=%HolidayCnt%
echo Holiday -- %HolidayCnt%
IF "%HolidayCnt%"=="1" goto EndProgram
sqlcmd -S %ServerName% -Q "SET NOCOUNT ON;%Min15SQL:"=%" -o "%CheckCntFile%"

for /f "tokens=1-2*delims= " %%a in ('findstr /n "^" %CheckCntFile%') do SET "SysDate=%%a" & set "SysTime=%%b"
for /f "tokens=3-4*delims= " %%a in ('findstr /n "^" %CheckCntFile%') do SET "SysDate15Min=%%a" & set "SysTime15Min=%%b"
for /f "tokens=5*delims= " %%a in ('findstr /n "^" %CheckCntFile%') do SET /A RecCnt=%%a
echo Number -- %RecCnt%
echo DATETIME -- %SysDate:~2% 
echo time ------ %SysTime%

echo DATETIME15 -- %SysDate15Min:~2% 
echo time15 ------ %SysTime15Min%

REM pause >nul
rem cd "C:\TEMP\EMAIL\"
REM exit

REM IF "%RecCnt%"=="0" (
call EmailLog.bat "Activity Count at %SysDate:~2% %SysTime15Min% - %SysTime% : %RecCnt%" %CheckCntFile%
REM )

goto EndProgram
:EndProgram


@ECHO On
pause