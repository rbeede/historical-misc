@REM	================================================================================================================


@REM	Make sure the log file is created on the user's desktop
%HOMEDRIVE%
CD "%USERPROFILE%"
CD DESKTOP


for /F %%i in ('dir /b /on "R:\Rodneys_Backup\Backup_Tools\sanity-backup-*-jar-with-dependencies.jar"') do SET LATEST_SANITY_BACKUP=%%i


java -Xms2g -Xmx2g -jar "R:\Rodneys_Backup\Backup_Tools\%LATEST_SANITY_BACKUP%" "R:\Rodneys_Backup" "\\192.168.0.20\Rodneys_Backup"

@REM	Any return code of X or greater gets caught
@IF ERRORLEVEL 1 ECHO FAILED R TO NAS



@REM	================================================================================================================
java -Xms2g -Xmx2g -jar "R:\Rodneys_Backup\Backup_Tools\%LATEST_SANITY_BACKUP%"  "\\192.168.0.20\Shaunas_Laptop_Backup" "R:\Shaunas_Laptop_Backup"

@REM	Any return code of X or greater gets caught
@IF ERRORLEVEL 2 ECHO FAILED NAS Shauna's to R

@REM Now we need to fix local ownership and permissions since source network share
@REM might cause an unknown owner setting we don't want.

TAKEOWN /F "R:\Shaunas_Laptop_Backup" /R /D Y

ICACLS "R:\Shaunas_Laptop_Backup" /q /inheritance:r /grant:r rbeede:F
ICACLS "R:\Shaunas_Laptop_Backup\*" /reset /t /q

@IF ERRORLEVEL 1 ECHO FAILED FIX PERMS NAS-SHAUNA TO R DRIVE

@REM	================================================================================================================

@REM	Need to make B: drive writeable
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_writeable.diskpart"


java -Xms2g -Xmx2g -jar "R:\Rodneys_Backup\Backup_Tools\%LATEST_SANITY_BACKUP%"  "R:\Shaunas_Laptop_Backup" "B:\Shaunas_Laptop_Backup"
@REM	Any return code of X or greater gets caught
@IF ERRORLEVEL 2 ECHO FAILED Shauna's R -- B


@REM	Need to make B: drive readonly
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_readonly.diskpart"



shutdown /s /t 900

@REM Allow user to shutdown /a in another console window, using cmd.exe holds the window open and allows user to type command
@REM versus using a regular PAUSE which closes window afterwards
cmd.exe