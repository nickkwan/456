@ECHO OFF
:: Query the registry for the date format and delimiter
CALL :DateFormat

:: Parse today's date depending on registry's local date format settings
IF %iDate%==0 FOR /F "TOKENS=1-4* DELIMS=%sDate%" %%A IN ('DATE/T') DO (
	SET LocalFormat=MM%sDate%DD%sDate%YYYY
	
	SET Year=%%C
	SET Month=%%A
	SET Day=%%B
)
IF %iDate%==1 FOR /F "TOKENS=1-4* DELIMS=%sDate%" %%A IN ('DATE/T') DO (
	SET LocalFormat=DD%sDate%MM%sDate%YYYY
	
	SET Year=%%C
	SET Month=%%B
	SET Day=%%A
)
IF %iDate%==2 FOR /F "TOKENS=1-4* DELIMS=%sDate%" %%A IN ('DATE/T') DO (
	SET LocalFormat=YYYY%sDate%MM%sDate%DD
	
	SET Year=%%A
	SET Month=%%B
	SET Day=%%C
)

:: Remove the day of week if applicable
FOR %%A IN (%Year%)  DO SET Year=%%A
FOR %%A IN (%Month%) DO SET Month=%%A
FOR %%A IN (%Day%)   DO SET Day=%%A

:: Today's date in YYYYMMDD format
SET SortDate=%Year%%Month%%Day%

:: Today's date in local format
FOR %%A IN (%Date%) DO SET Today=%%A

:: Remove leading zeroes
IF   "%Day:~0,1%"=="0" SET   Day=%Day:~1%
IF "%Month:~0,1%"=="0" SET Month=%Month:~1%

:: Display the results
ECHO Format:     YYYYMMDD  (%LocalFormat%)
ECHO.==================================
CALL ECHO Today:      %SortDate%  (%Today%)

SET Hour=%TIME:~0,2%
SET Minute=%TIME:~3,2%
IF "%Hour:~0,1%" == " " set Hour=0%Hour:~1,1%
IF "%Minute:~0,1%" == " " set Minute=0%Minute:~1,1%
GOTO:EOF

:DateFormat
REG.EXE /? 2>&1 | FIND "REG QUERY" >NUL
IF ERRORLEVEL 1 (
	CALL :DateFormatRegEdit
) ELSE (
	CALL :DateFormatReg
)
GOTO:EOF

:DateFormatReg
FOR /F "tokens=1-3" %%A IN ('REG Query "HKCU\Control Panel\International" ^| FINDSTR /R /C:"[is]Date"') DO (
	IF "%%~A"=="REG_SZ" (
		SET %%~B=%%~C
	) ELSE (
		SET %%~A=%%~C
	)
)
GOTO:EOF

@ECHO ON