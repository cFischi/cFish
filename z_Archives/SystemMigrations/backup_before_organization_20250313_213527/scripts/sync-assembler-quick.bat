@echo off
echo Syncing Assembler Child Theme to WordPress Studio...
echo.

set REPO_DIR=C:\Users\Chris\cFish.io
set STUDIO_DIR=C:\Users\Chris\Studio\cfishio

if not exist "%STUDIO_DIR%\wp-content\themes\assembler-child" mkdir "%STUDIO_DIR%\wp-content\themes\assembler-child"
xcopy "%REPO_DIR%\wp-content\themes\assembler-child" "%STUDIO_DIR%\wp-content\themes\assembler-child" /E /I /Y

echo.
echo Sync complete!
echo.
echo Press any key to close this window...
pause > nul 