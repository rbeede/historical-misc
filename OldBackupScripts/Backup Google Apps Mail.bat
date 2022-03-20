@ECHO OFF
@REM	Valid only for U.S. (English) locale
FOR /F "tokens=2-4 delims=/ " %%i IN ('date /t') DO SET MONTH=%%i& SET DAY=%%j& SET YEAR=%%k

@echo.
@echo.
echo Year is "%YEAR%"
echo Month is "%MONTH%"
echo Day is "%DAY%"


@REM	Must "/quit" in order for script to continue
"C:\Program Files\VeraCrypt\VeraCrypt.exe" /v "R:\Rodneys_Backup\Personal\E-mail Archive.hc" /letter U /history y /mountoption timestamp /quit


U:
cd "U:\EmailArchive"

java -jar U:\java_imap_to_mbox--SNAPSHOT-jar-with-dependencies.jar U:\java_imap_to_mbox_config.xml "U:\EmailArchive"

C:

"C:\Program Files\VeraCrypt\VeraCrypt.exe" /dismount U /quit

start robocopy "R:\Rodneys_Backup\Personal" "\\192.168.0.20\Rodneys_Backup\Personal" "E-mail Archive.hc" /MT:2


@REM	Need to back B: drive writeable
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_writeable.diskpart"


robocopy "R:\Rodneys_Backup\Personal" "B:\Rodneys_Backup\Personal" "E-mail Archive.hc" /MT:2

@REM	Need to back B: drive readonly
diskpart /s "R:\Rodneys_Backup\Backup_Tools\make_drive_readonly.diskpart"



@PAUSE