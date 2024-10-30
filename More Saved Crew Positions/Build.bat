@echo off
setlocal

REM Define the name of the zip file
set "ZIP_NAME=More Saved Crew Positions.zip"

REM Define the list of files and folders to add to the zip (use full paths or relative paths)
set FILES="data" "mod-appendix"
REM Define the relative path of the file to copy
set "RELATIVE_FILE=More Saved Crew Positions.zip"
set "ABSOLUTE_PATH=C:\Program Files (x86)\Steam\steamapps\common\FTL Faster Than Light\mods\More Saved Crew Positions.zip"

REM Define the path to the shortcut file
set "SHORTCUT_PATH=C:\Users\GunBuild-1\Documents\Workspace\Letterbox Small Mods\More Saved Crew Positions\modman_orig.exe - Shortcut.lnk"

REM Create a temporary folder for zipping if necessary
set TEMP_ZIP_DIR=%TEMP%\zip_temp
if not exist "%TEMP_ZIP_DIR%" mkdir "%TEMP_ZIP_DIR%"

REM Copy files and folders to the temporary folder
for %%F in (%FILES%) do (
    if exist "%%~F" (
        if exist "%%~F\" (
            REM If it's a directory, copy it recursively
            xcopy /e /i /y "%%~F" "%TEMP_ZIP_DIR%\%%~nF"
        ) else (
            REM If it's a file, copy it
            copy "%%~F" "%TEMP_ZIP_DIR%\"
        )
    ) else (
        echo File or folder not found: %%~F
    )
)

REM Use PowerShell to create a zip file from the temporary folder
powershell -command "Compress-Archive -Force -Path '%TEMP_ZIP_DIR%\*' -DestinationPath '%CD%\%ZIP_NAME%'"

REM Clean up temporary folder
rd /s /q "%TEMP_ZIP_DIR%"

echo Zip file created: %ZIP_NAME%






REM Check if the source file exists
if exist "%RELATIVE_FILE%" (
    REM Copy the file to the absolute path
    copy /Y "%RELATIVE_FILE%" "%ABSOLUTE_PATH%"

    REM Check if the copy was successful
    if errorlevel 1 (
        echo Failed to copy the file.
    ) else (
        echo File copied successfully.
    )
) else (
    echo Source file not found: %RELATIVE_FILE%
    goto :EOF
)

if exist "%SHORTCUT_PATH%" (
    echo Executing the shortcut target...
    powershell -command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); Start-Process $Shortcut.TargetPath"
) else (
    echo Shortcut not found: %SHORTCUT_PATH%
)