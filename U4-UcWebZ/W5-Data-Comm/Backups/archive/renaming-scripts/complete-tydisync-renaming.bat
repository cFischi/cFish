@echo off
echo tYDiSync~ Complete Renaming Process
echo ==================================
echo This script will:
echo 1. Rename all files from md-json-sync to tydisync format using git
echo 2. Update all references to these files throughout the codebase
echo 3. Update memory.md with an entry about the renaming process
echo 4. Update changelog.md with a new version entry for the renaming
echo 5. Verify the renaming process and check for any issues
echo.
echo NOTE: This process may take a few minutes to complete.
echo.

REM Confirm that the user wants to proceed
set /p confirm=Are you sure you want to proceed with the renaming? (y/n): 
if /i not "%confirm%"=="y" goto :end

echo.
echo Step 1: Renaming files with git...
echo.
call rename-files-tydisync.bat

echo.
echo Step 2: Updating file references throughout the codebase...
echo.
node update-file-references.js

echo.
echo Step 3: Updating memory.md with renaming documentation...
echo.
node update-memory-for-renaming.js

echo.
echo Step 4: Updating changelog.md with version entry...
echo.
node update-changelog-for-renaming.js

echo.
echo Step 5: Verifying the renaming process...
echo.
node verify-tydisync-renaming.js
if %ERRORLEVEL% NEQ 0 (
  echo.
  echo WARNING: Verification found issues that need to be addressed!
  echo Please review the output above and fix any problems before committing.
  echo.
  pause
)

echo.
echo ===================================
echo Complete renaming process finished!
echo.
echo Next steps:
echo 1. Review the changes using 'git diff'
echo 2. Check for any remaining references that might have been missed
echo 3. Test the system functionality to ensure everything works correctly
echo 4. Commit the changes with a descriptive message
echo.
echo It's recommended to perform a full system test before committing!
echo.

:end
pause 