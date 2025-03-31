@echo off
echo Installing required dependencies if needed...
npm install archiver --save-dev

echo.
echo Exporting Assembler child theme for WordPress.com...
node export-theme.js

echo.
echo Done! Theme package is ready for upload.
echo Check the 'exports' folder for the generated zip file.
pause 