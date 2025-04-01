@echo off
echo tYDiSync~ File Renaming Script
echo ===============================
echo This script will rename all files from md-json-sync to tydisync naming convention.
echo.

REM Create a directory for the renamed documentation files if it doesn't exist
if not exist "docs\tydisync" mkdir "docs\tydisync"

echo Renaming documentation files...
if exist tydisync-status-report.md (
    rename tydisync-status-report.md tydisync-status-report.md
    echo Renamed: tydisync-status-report.md to tydisync-status-report.md
)

if exist tydisync-low-cpu-reference.md (
    rename tydisync-low-cpu-reference.md tydisync-low-cpu-reference.md
    echo Renamed: tydisync-low-cpu-reference.md to tydisync-low-cpu-reference.md
)

if exist tydisync-implementation-verification.md (
    rename tydisync-implementation-verification.md tydisync-implementation-verification.md
    echo Renamed: tydisync-implementation-verification.md to tydisync-implementation-verification.md
)

if exist tydisync-system-summary.md (
    rename tydisync-system-summary.md tydisync-system-summary.md
    echo Renamed: tydisync-system-summary.md to tydisync-system-summary.md
)

if exist tydisync-testing-findings.md (
    rename tydisync-testing-findings.md tydisync-testing-findings.md
    echo Renamed: tydisync-testing-findings.md to tydisync-testing-findings.md
)

if exist tydisync-quick-reference.md (
    rename tydisync-quick-reference.md tydisync-quick-reference.md
    echo Renamed: tydisync-quick-reference.md to tydisync-quick-reference.md
)

echo Renaming script files...
if exist start-tydisync-silent.vbs (
    rename start-tydisync-silent.vbs start-tydisync-silent.vbs
    echo Renamed: start-tydisync-silent.vbs to start-tydisync-silent.vbs
)

echo Renaming debug log files...
if exist tydisync-debug.log (
    rename tydisync-debug.log tydisync-debug.log
    echo Renamed: tydisync-debug.log to tydisync-debug.log
)

if exist "sync-system\tydisync-debug.log" (
    cd sync-system
    rename tydisync-debug.log tydisync-debug.log
    echo Renamed: sync-system\tydisync-debug.log to sync-system\tydisync-debug.log
    cd ..
)

echo Renaming next steps (check if needed)...
if exist tydisync-next-steps.md (
    if exist tydisync-next-steps.md (
        echo tydisync-next-steps.md already exists alongside tydisync-next-steps.md
        echo Removing the old file since contents have been transferred...
        del tydisync-next-steps.md
    ) else (
        rename tydisync-next-steps.md tydisync-next-steps.md
        echo Renamed: tydisync-next-steps.md to tydisync-next-steps.md
    )
)

echo.
echo File renaming complete. Now updating references in files...
echo.

echo.
echo All done! Please review the changes to make sure all references have been updated correctly.
echo After verification, commit these changes with a message like "Rename files to tYDiSync~ branding"
echo. 