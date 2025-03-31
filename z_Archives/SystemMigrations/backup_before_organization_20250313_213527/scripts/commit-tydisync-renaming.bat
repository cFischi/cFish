@echo off
echo ===== tYDiSync~ Git Commit Script =====
echo This script will commit all changes related to the tYDiSync~ file renaming project
echo.

setlocal enabledelayedexpansion

set COMMIT_MSG_FILE=..\tydisync-commit-message.txt
set VERSION=1.2.1
set TAG_NAME=v%VERSION%
set DATE=%date%

echo Creating detailed commit message...
(
echo feat(tydisync): Complete tYDiSync~ file renaming project
echo.
echo This commit completes the comprehensive renaming of all files from the old 'md-json-sync' naming convention 
echo to the new 'tydisync' branding. The renaming project included:
echo.
echo - Renamed 30+ files across the codebase
echo - Updated all references throughout the codebase
echo - Created comprehensive documentation
echo - Verified all changes with automated scripts
echo.
echo Reference: tydisync-renaming-completion.md, tydisync-completion-next-steps.md
echo.
echo Version: %VERSION%
echo Date: %DATE%
) > %COMMIT_MSG_FILE%

echo Commit message created at %COMMIT_MSG_FILE%
echo.

echo Checking git status...
git status | findstr /C:"working tree clean" > nul
if !ERRORLEVEL! EQU 0 (
    echo No changes to commit. The working tree is clean.
    echo.
    goto :tag
)

echo Staging all changes...
git add .

echo Showing summary of changes to be committed...
git status --short

echo.
echo About to commit all changes with the message from %COMMIT_MSG_FILE%
echo Press Ctrl+C to cancel or any key to continue...
pause > nul

echo Committing changes...
git commit -F %COMMIT_MSG_FILE%
if !ERRORLEVEL! NEQ 0 (
    echo Error committing changes.
    goto :eof
)

:tag
echo.
echo Would you like to tag this commit as '%TAG_NAME%'? (Y/N)
set /p TAG_CONFIRM=
if /i "%TAG_CONFIRM%" NEQ "Y" goto :push

echo Creating tag '%TAG_NAME%'...
git tag -a %TAG_NAME% -m "Version %VERSION% - tYDiSync~ File Renaming Project Completion"

:push
echo.
echo Would you like to push changes to the remote repository? (Y/N)
set /p PUSH_CONFIRM=
if /i "%PUSH_CONFIRM%" NEQ "Y" goto :cleanup

echo Pushing changes to remote repository...
git push
if !ERRORLEVEL! NEQ 0 (
    echo Error pushing changes.
    goto :cleanup
)

echo Pushing tags to remote repository...
git push --tags
if !ERRORLEVEL! NEQ 0 (
    echo Error pushing tags.
    goto :cleanup
)

:cleanup
echo.
echo Would you like to delete the temporary commit message file? (Y/N)
set /p DELETE_CONFIRM=
if /i "%DELETE_CONFIRM%" NEQ "Y" goto :eof

del %COMMIT_MSG_FILE%
echo Temporary commit message file deleted.

:eof
echo.
echo Done!
endlocal 