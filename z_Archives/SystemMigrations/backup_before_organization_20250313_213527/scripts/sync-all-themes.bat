@echo off
echo Syncing all WordPress themes to Local by Flywheel...

echo.
echo Step 1: Copying Assembler parent theme...
xcopy "wp-content\themes\assembler" "C:\Users\Chris\Local Sites\cFish.io\app\public\wp-content\themes\assembler" /E /I /Y

echo.
echo Step 2: Copying Assembler child theme...
xcopy "wp-content\themes\assembler-child" "C:\Users\Chris\Local Sites\cFish.io\app\public\wp-content\themes\assembler-child" /E /I /Y

echo.
echo Sync complete! Please check for any errors above.
echo Remember to activate the child theme in WordPress admin if not already active.
pause 