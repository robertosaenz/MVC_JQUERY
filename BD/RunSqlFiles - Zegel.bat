@ECHO ON
SET root=%cd%
SET PSScript=%root%\RunSQLFiles.ps1
SET PowerShellDir=C:\Windows\System32\WindowsPowerShell\v1.0
CD /D "%PowerShellDir%"
 
SET path=%root%
SET "machine=10.1.3.21"
SET "db=Academico"
SET "user=smart_prueba"
SET "pwd=qwerty123456"
SET "Includesubfolders=1"
 
Powershell -ExecutionPolicy Bypass -Command "& '%PSScript%' '%path%' '%machine%' '%db%' '%user%' '%pwd%' '%Includesubfolders%'"
 
Pause
EXIT /B