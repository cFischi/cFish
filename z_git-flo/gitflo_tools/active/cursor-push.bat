@echo off
echo ===== Git Push Operation =====

rem Change to repository directory
cd /d "C:\Users\Chris\cFish.io"

rem Get current branch
for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%a
echo Current branch: %BRANCH%

rem Check for changes
git status -s > git-status.tmp
set /p HAS_CHANGES=<git-status.tmp
del git-status.tmp

if "%HAS_CHANGES%"=="" (
    echo No changes to commit.
    goto :end
)

echo Changes to be committed:
git status -s

rem Check if in test mode
if "%1"=="--test" (
    echo Test mode: Would commit and push the changes above.
    goto :end
)

rem Get commit message
set /p COMMIT_MESSAGE=Enter commit message (or press Enter for default): 

if "%COMMIT_MESSAGE%"=="" (
    set COMMIT_MESSAGE=Update from %COMPUTERNAME% - %DATE% %TIME%
    echo Using default message: %COMMIT_MESSAGE%
)

rem Add changes
echo Adding changes...
git add .

rem Commit with -n flag to bypass hooks
echo Committing changes...
git commit -n -m "%COMMIT_MESSAGE%"

rem Push with --no-verify flag
echo Pushing to remote repository...
git push origin %BRANCH% --no-verify

:end
echo ===== Push operation completed ===== 