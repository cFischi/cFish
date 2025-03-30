@echo off
echo Adding Low-CPU Mode Support
echo ==========================
echo.

:: Check if tydisync.js exists
if not exist "tydisync.js" (
  echo Error: tydisync.js not found. Please make sure it exists.
  pause
  exit /b 1
)

:: Create a backup of the original file
echo Creating backup of tydisync.js...
copy tydisync.js tydisync.js.backup
if %ERRORLEVEL% NEQ 0 (
  echo Failed to create backup.
  pause
  exit /b 1
)

:: Create a patch script
echo Creating patch script...
echo // Add low-CPU mode support to tydisync.js > patch-low-cpu.js
echo.>> patch-low-cpu.js
echo const fs = require('fs');>> patch-low-cpu.js
echo const path = require('path');>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Read the original file>> patch-low-cpu.js
echo let content = fs.readFileSync('tydisync.js', 'utf8');>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Check if low-CPU mode is already supported>> patch-low-cpu.js
echo if (content.includes('lowCpuMode')) {>> patch-low-cpu.js
echo   console.log('Low-CPU mode already supported.');>> patch-low-cpu.js
echo   process.exit(0);>> patch-low-cpu.js
echo }>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Add low-CPU mode support>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Look for argument parsing code>> patch-low-cpu.js
echo const argParseRegex = /const\s+args\s+=\s+processArgs\(\);/;>> patch-low-cpu.js
echo if (argParseRegex.test(content)) {>> patch-low-cpu.js
echo   // Add lowCpuMode to the args parsing>> patch-low-cpu.js
echo   const argsParseReplacement = 'const args = processArgs();\n// Set low CPU mode based on args\nconst lowCpuMode = args.lowCpu || false;\nconsole.log(`MD-JSON Sync System starting in ${lowCpuMode ? "LOW CPU" : "NORMAL"} mode...`);';>> patch-low-cpu.js
echo   content = content.replace(argParseRegex, argsParseReplacement);>> patch-low-cpu.js
echo }>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Look for AlphaAgent initialization>> patch-low-cpu.js
echo const agentRegex = /const\s+alphaAgent\s+=\s+new\s+AlphaAgent\(config\)/;>> patch-low-cpu.js
echo if (agentRegex.test(content)) {>> patch-low-cpu.js
echo   // Update the config with lowCpuMode>> patch-low-cpu.js
echo   const configUpdate = 'config.lowCpuMode = lowCpuMode;\n// Update other config settings based on CPU mode\nif (lowCpuMode) {\n  config.debounceTime = config.debounceTime || 2000;\n  if (!config.throttling) config.throttling = {};\n  config.throttling.maxConcurrent = 1;\n  config.throttling.delayBetweenFiles = config.throttling.delayBetweenFiles || 5000;\n  config.throttling.batchSize = config.throttling.batchSize || 5;\n  config.throttling.batchDelay = config.throttling.batchDelay || 10000;\n}\nconst alphaAgent = new AlphaAgent(config)';>> patch-low-cpu.js
echo   content = content.replace(agentRegex, configUpdate);>> patch-low-cpu.js
echo }>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Look for processArgs function>> patch-low-cpu.js
echo const processArgsRegex = /function\s+processArgs\(\)\s*\{[^}]*return\s+args;\s*\}/s;>> patch-low-cpu.js
echo if (processArgsRegex.test(content)) {>> patch-low-cpu.js
echo   // Get the current processArgs function>> patch-low-cpu.js
echo   const processArgsMatch = content.match(processArgsRegex);>> patch-low-cpu.js
echo   if (processArgsMatch) {>> patch-low-cpu.js
echo     // Update to include the --low-cpu flag>> patch-low-cpu.js
echo     const currentFunc = processArgsMatch[0];>> patch-low-cpu.js
echo     const returnArgsRegex = /return\s+args;/;>> patch-low-cpu.js
echo     const updatedFunc = currentFunc.replace(returnArgsRegex, 'args.lowCpu = process.argv.includes("--low-cpu");\nreturn args;');>> patch-low-cpu.js
echo     content = content.replace(processArgsRegex, updatedFunc);>> patch-low-cpu.js
echo   }>> patch-low-cpu.js
echo }>> patch-low-cpu.js
echo.>> patch-low-cpu.js
echo // Write the updated file>> patch-low-cpu.js
echo fs.writeFileSync('tydisync.js', content, 'utf8');>> patch-low-cpu.js
echo console.log('Low-CPU mode support added to tydisync.js');>> patch-low-cpu.js

:: Execute the patch script
echo Applying low-CPU mode patch...
node patch-low-cpu.js
if %ERRORLEVEL% NEQ 0 (
  echo Failed to apply patch.
  echo Restoring backup...
  copy tydisync.js.backup tydisync.js
  pause
  exit /b 1
)

echo.
echo Successfully added low-CPU mode support to tydisync.js.
echo You can now run the system with: run-low-cpu.bat
echo.

pause 