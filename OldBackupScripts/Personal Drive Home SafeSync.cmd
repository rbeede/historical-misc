@REM	Get current year month day
@REM	Valid only for U.S. (English) locale
FOR /F "tokens=2-4 delims=/ " %%i IN ('date /t') DO SET MONTH=%%i& SET DAY=%%j& SET YEAR=%%k

@echo.
@echo.
echo Year is "%YEAR%"
echo Month is "%MONTH%"
echo Day is "%DAY%"


@REM	================================================================================================================
@REM	Make a secure backup of all my Google documents
"C:\Program Files\VeraCrypt\VeraCrypt.exe" /v "C:\Users\rbeede\Documents\Rodney_truecrypt.tc" /letter S /history y /mountoption timestamp /quit

S:
CD "S:\GoogleAppsBackup"


@REM	Backup the online Google Apps docs.rodneybeede.com
SET GoogleDocsDirectory=S:\GoogleAppsBackup\%YEAR%\%MONTH%\%DAY%
mkdir "%GoogleDocsDirectory%"

cd "%GoogleDocsDirectory%"

@REM	0B--NpiOkf69oZjEwRkFDbThOUlk	is NO_BACKUP inside my Google Drive
@REM	0B--NpiOkf69oWGc2dDJ0LWR3aUU	is My Computer from Google Backup & Sync (annoying)
for /F %%i in ('dir /b /on "S:\GoogleAppsBackup\BackupProgram\backup-my-google-drive-*-jar-with-dependencies.jar"') do SET LATEST_BACKUP_MY_GOOGLE_DRIVE=%%i
java -jar "S:\GoogleAppsBackup\BackupProgram\%LATEST_BACKUP_MY_GOOGLE_DRIVE%" email "S:\GoogleAppsBackup\BackupProgram\.backupmygoogledrive.oauth" "%GoogleDocsDirectory%" "--google-api-filter=not '0B--NpiOkf69oZjEwRkFDbThOUlk' in parents and 'me' in owners" "--post-parentid-tree-exclude=0B--NpiOkf69oWGc2dDJ0LWR3aUU"

@IF ERRORLEVEL 1 ECHO FAILED Google Backup
@IF ERRORLEVEL 1 PAUSE

@REM	Compress it
"c:\Program Files\7-Zip\7z.exe" a "%GoogleDocsDirectory%\..\..\..\GoogleDocs_%YEAR%-%MONTH%-%DAY%.7z" "%GoogleDocsDirectory%\*" -mx=9 -ms=on -mmt=on -mtc=on -t7z -m0=LZMA2

cd \

@REM	Remove it (removing the %YEAR% folder)
rmdir /s /q "%GoogleDocsDirectory%\..\..\"

C:

"C:\Program Files\VeraCrypt\VeraCrypt.exe" /dismount S /quit /force


@REM	================================================================================================================
@REM	Archive truecrypt volume to dated entry
copy C:\Users\rbeede\Documents\Rodney_truecrypt.tc "R:\Rodneys_Backup\Personal\Rodney_truecrypt\Rodney_truecrypt.tc__%YEAR%-%MONTH%-%DAY%"

@REM	Need to back B: drive writeable
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_writeable.diskpart"

copy C:\Users\rbeede\Documents\Rodney_truecrypt.tc "B:\Rodneys_Backup\Personal\Rodney_truecrypt\Rodney_truecrypt.tc__%YEAR%-%MONTH%-%DAY%"



@REM	================================================================================================================
@REM	Make sure the log file is created on the user's desktop
%HOMEDRIVE%
CD "%USERPROFILE%"
CD DESKTOP


@REM	Sync entire disk to other backup disks
for /F %%i in ('dir /b /on "R:\Rodneys_Backup\Backup_Tools\sanity-backup-*-jar-with-dependencies.jar"') do SET LATEST_SANITY_BACKUP=%%i
java -Xms4g -Xmx4g -jar "R:\Rodneys_Backup\Backup_Tools\%LATEST_SANITY_BACKUP%" "R:\Rodneys_Backup" "B:\Rodneys_Backup"


@REM	Need to back B: drive readonly
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_readonly.diskpart"


PAUSE