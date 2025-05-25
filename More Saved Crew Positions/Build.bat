@echo off
setlocal

REM Define the list of files and folders to add to the zip (use full paths or relative paths)
set FILES="data" "mod-appendix" "img" "audio"
REM Define the relative path of the file to copy
set "RELATIVE_FILE=More Saved Crew Positions.zip"
set "ABSOLUTE_PATH=C:\Users\GunBuild-1\Documents\Workspace\ftlman-x86_64-pc-windows-gnu\ftlman\mods\%RELATIVE_FILE%"

REM Create a temporary folder for zipping if necessary
set TEMP_ZIP_DIR=%TEMP%\zip_temp
if not exist "%TEMP_ZIP_DIR%" mkdir "%TEMP_ZIP_DIR%"

REM Compile fennel code into lua (Fennel doesn't work for this use case as it requires statements.)
REM powershell -command ".\fixed_fennel_compile.bat example.fnl"

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
powershell -command "Compress-Archive -Force -Path '%TEMP_ZIP_DIR%\*' -DestinationPath '%CD%\%RELATIVE_FILE%'"

REM Clean up temporary folder
rd /s /q "%TEMP_ZIP_DIR%"
echo Zip file created: %RELATIVE_FILE%

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

powershell -NoProfile -Command "Set-Location C:\Users\GunBuild-1\Documents\Workspace\ftlman-x86_64-pc-windows-gnu\ftlman; .\ftlman.exe patch 'Multiverse 5.5 - Assets (Patch above Data).zip' 'Multiverse 5.5 - Data.zip' Vertex-Util.ftl 'Lightweight Lua.zip' %RELATIVE_FILE%"
powershell -command "& 'C:\Program Files (x86)\Steam\steamapps\common\FTL Faster Than Light\FTLGame.exe'"
