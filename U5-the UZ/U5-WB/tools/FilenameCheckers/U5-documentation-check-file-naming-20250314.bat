@echo off
setlocal

echo =======================================================
echo cFish.io File Naming Convention Checker
echo =======================================================
echo.
echo This script will check all organized files against the
echo UcF file naming convention and generate a report.
echo.
echo NOTE: WordPress files, critical tools, legal documents and 
echo other essential software files are EXEMPTED from renaming
echo requirements. These files will be placed in appropriate
echo directories but will maintain their original filenames.
echo.
echo Press any key to continue...
pause > nul

echo.
echo Running file naming convention checker...
powershell -ExecutionPolicy Bypass -File check-file-naming.ps1 %*

echo.
echo Checker complete!
echo.
echo A report has been generated in file-naming-compliance-report.md
echo Please review this report to identify files that need renaming.
echo.
echo =======================================================

pause 