# Rodney Beede
#
# 2018-09-28


Set-Location -Path c:\users\rbeede\Desktop


$processIds = @()

$processIds += Start-Process -PassThru -FilePath "java" -ArgumentList "-jar", "R:\Rodneys_Backup\Backup_Tools\HashAndVerifyBackups\hash-directory-tree-2017.08.14-jar-with-dependencies.jar", "R:\", "hashes_R_drive.csv"

# Need a brief pause to ensure log files are different names
sleep 1

$processIds += Start-Process -PassThru -FilePath "java" -ArgumentList "-jar", "R:\Rodneys_Backup\Backup_Tools\HashAndVerifyBackups\hash-directory-tree-2017.08.14-jar-with-dependencies.jar", "B:\", "hashes_B_drive.csv"


Write-Output "Waiting on processes to finish"

Wait-Process -InputObject $processIds

Write-Output "All done waiting, now going to create reports"


Start-Process -NoNewWindow -Wait -FilePath "java" -ArgumentList "-jar", "R:\Rodneys_Backup\Backup_Tools\HashAndVerifyBackups\hash-compare-directory-tree-report-2018.08.12-jar-with-dependencies.jar", "hashes_R_drive.csv", "hashes_B_drive.csv"


Write-Output "Report finished"


& shutdown /s /t 60 /c "Hashing complete" /d p:0:0

sleep 30