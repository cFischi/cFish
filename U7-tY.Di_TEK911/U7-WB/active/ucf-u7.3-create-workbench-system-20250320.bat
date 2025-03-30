@echo off
echo ============================================================
echo              cFish.io Workbench System Creator
echo ============================================================
echo This script will create standardized workbench folders across
echo all main directories in the cFish.io workspace according to
echo the Universal cFish standards.
echo.
echo Each workbench (-WB) folder will contain:
echo  - active: For current work items
echo  - WB-readme: For README files of active items
echo  - next-WB: For upcoming work items
echo  - next-readme: For README files of upcoming items
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul

powershell.exe -ExecutionPolicy Bypass -File "create-workbench-system.ps1"

echo.
echo ============================================================
echo               Workbench Creation Completed
echo ============================================================
echo.
echo A new entry has been added to memory.md documenting this change.
echo.
echo Remember to:
echo  1. Update your SOP documentation to reflect the workbench system
echo  2. Move active working files to appropriate workbench folders
echo  3. Add README files for all workbench items
echo.
pause 