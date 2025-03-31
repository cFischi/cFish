@echo off
echo MD-JSON Sync System - Optimized Launcher
echo =======================================
echo.

:: Set Node.js memory limits
set NODE_OPTIONS=--max-old-space-size=2048

:: Create backups directory if it doesn't exist
if not exist "backups" mkdir backups

:: Check if chokidar is installed
node -e "try { require('chokidar'); console.log('Chokidar is installed.'); } catch (e) { console.log('ERROR: Chokidar is not installed. Installing...'); process.exit(1); }"

:: Install chokidar if not present
if %ERRORLEVEL% NEQ 0 (
    echo Installing required dependencies...
    npm install chokidar fs-extra moment
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install dependencies. Please run 'npm install chokidar fs-extra moment' manually.
        pause
        exit /b 1
    )
)

:: Define configuration
set CONFIG_FILE=config.json

:: Check if config exists
if not exist "%CONFIG_FILE%" (
    echo Creating default configuration file...
    echo {^
    "watchDirs": [^
        { "md": "./docs", "json": "./docs/json" },^
        { "md": "./shortlinks", "json": "./shortlinks/json" },^
        { "md": "./", "json": "./json" }^
    ],^
    "backupDir": "./backups",^
    "maxBackups": 5,^
    "enableBackups": true,^
    "debounceTime": 800,^
    "exclusions": [^
        "node_modules", ".git", ".cursor",^
        "wp-content", "wp-admin", "wp-includes", "plugins", "themes",^
        "wordpress", "vendor", "backup", "temp", "tmp", "cache"^
    ],^
    "conflictResolutionMethod": "timestamp",^
    "criticalFiles": ["memory.md"],^
    "recursiveWatching": true,^
    "validationThreshold": 0.95,^
    "throttling": {^
        "maxConcurrent": 1,^
        "delayBetweenFiles": 2000,^
        "batchSize": 10,^
        "batchDelay": 5000^
    }^
} > %CONFIG_FILE%
)

echo Starting MD-JSON Sync with optimized settings...
echo Press Ctrl+C to stop
echo.

:: Run with optimized settings
node tydisync.js --watch --verbose --config=%CONFIG_FILE%

pause 