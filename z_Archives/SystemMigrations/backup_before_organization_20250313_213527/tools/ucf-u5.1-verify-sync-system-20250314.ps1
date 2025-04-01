# ucf-u5.1-verify-sync-system-20250314.ps1
# This script verifies the sync system is working properly after path fixes
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 1 - Documentation

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    SyncSystem = @{
        Path = "sync-system"
        LogFile = "sync-system\tydisync-debug.log"
        ConfigFile = "sync-system\config\sync-config.json"
        StartScript = "sync-system\start-optimized-sync.bat"
        StateDirectory = "sync-system\state"
    }
    TestFiles = @(
        @{
            SourcePath = "memory.md"
            TestString = "###### Sync System Verification Test"
        },
        @{
            SourcePath = "changelog.md"
            TestString = "###### Sync System Verification"
        }
    )
    LogFile = "logs\sync-verification-$(Get-Date -Format 'yyyyMMdd').log"
    MemoryMdPath = "memory.md"
    TimeoutSeconds = 30
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ErrorActionPreference = "Stop"
$successCount = 0
$errorCount = 0

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Functions
#-----------------------------------------------
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
    Write-Host $logMessage
}

function Test-SyncSystemRunning {
    $syncProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
                   Where-Object { $_.CommandLine -like "*start-optimized-sync.js*" }
    
    return $null -ne $syncProcess
}

function Start-SyncSystem {
    try {
        Write-Log "Starting sync system..." -Level "INFO"
        
        $startScriptPath = Join-Path -Path (Get-Location) -ChildPath $CONFIG.SyncSystem.StartScript
        if (-not (Test-Path $startScriptPath)) {
            Write-Log "Sync system start script not found at: $startScriptPath" -Level "ERROR"
            return $false
        }
        
        Start-Process -FilePath $startScriptPath -NoNewWindow
        
        ##### Wait for process to start
        $timeout = (Get-Date).AddSeconds($CONFIG.TimeoutSeconds)
        while ((Get-Date) -lt $timeout) {
            if (Test-SyncSystemRunning) {
                Write-Log "Sync system started successfully" -Level "INFO"
                return $true
            }
            Start-Sleep -Seconds 1
        }
        
        Write-Log "Timeout waiting for sync system to start" -Level "ERROR"
        return $false
    }
    catch {
        Write-Log "Failed to start sync system: $_" -Level "ERROR"
        return $false
    }
}

function Test-SyncFunctionality {
    try {
        $allTestsPassed = $true
        
        foreach ($testFile in $CONFIG.TestFiles) {
            $sourcePath = $testFile.SourcePath
            if (-not (Test-Path $sourcePath)) {
                Write-Log "Test file not found: $sourcePath" -Level "ERROR"
                $errorCount++
                $allTestsPassed = $false
                continue
            }
            
            ##### Backup original content
            $originalContent = Get-Content -Path $sourcePath -Raw
            
            ##### Add test string
            $testString = $testFile.TestString
            $testContent = "$testString ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))`n$originalContent"
            Set-Content -Path $sourcePath -Value $testContent
            
            Write-Log "Added test string to $sourcePath" -Level "INFO"
            
            ##### Wait for sync to process
            Start-Sleep -Seconds 5
            
            ##### Verify sync directory exists
            $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
            $expectedJsonFile = "sync-system\json\$fileNameWithoutExt.json"
            
            if (Test-Path $expectedJsonFile) {
                $jsonContent = Get-Content -Path $expectedJsonFile -Raw | ConvertFrom-Json
                
                ##### Check if our test string exists in the JSON
                if ($jsonContent -match $testString) {
                    Write-Log "Sync test passed for $sourcePath -> $expectedJsonFile" -Level "INFO"
                    $successCount++
                }
                else {
                    Write-Log "Sync test failed for $sourcePath -> $($expectedJsonFile): Test string not found in JSON" -Level "ERROR"
                    $errorCount++
                    $allTestsPassed = $false
                }
            }
            else {
                Write-Log "Sync test failed for $sourcePath -> $($expectedJsonFile): JSON file not found" -Level "ERROR"
                $errorCount++
                $allTestsPassed = $false
            }
            
            ##### Restore original content
            Set-Content -Path $sourcePath -Value $originalContent
            Write-Log "Restored original content to $sourcePath" -Level "INFO"
        }
        
        return $allTestsPassed
    }
    catch {
        Write-Log "Error testing sync functionality: $_" -Level "ERROR"
        $errorCount++
        return $false
    }
}

function Test-StateDirectoryFiles {
    try {
        $stateDir = $CONFIG.SyncSystem.StateDirectory
        if (-not (Test-Path $stateDir)) {
            Write-Log "State directory not found: $stateDir" -Level "ERROR"
            return $false
        }
        
        $expectedFiles = @(
            "sync-status.json",
            "last-sync.timestamp",
            "active-files.json"
        )
        
        $allFilesExist = $true
        
        foreach ($file in $expectedFiles) {
            $filePath = Join-Path -Path $stateDir -ChildPath $file
            if (Test-Path $filePath) {
                Write-Log "State file exists: $file" -Level "INFO"
                $successCount++
            }
            else {
                Write-Log "State file missing: $file" -Level "ERROR"
                $errorCount++
                $allFilesExist = $false
            }
        }
        
        return $allFilesExist
    }
    catch {
        Write-Log "Error checking state directory files: $_" -Level "ERROR"
        $errorCount++
        return $false
    }
}

function Update-MemoryMd {
    param (
        [string]$Content
    )
    
    try {
        $memoryContent = Get-Content -Path $CONFIG.MemoryMdPath -Raw
        $todayDate = Get-Date -Format "MM-dd-2025"
        $sectionTitle = "###### Sync System Verification ($todayDate)"
        
        # Check if we already have a section for today
        if ($memoryContent -match [regex]::Escape($sectionTitle)) {
            # Update existing section
            $memoryContent = $memoryContent -replace 
                "(?ms)$([regex]::Escape($sectionTitle)).*?(?=^###### |\Z)", 
                "$sectionTitle`n$Content`n`n_Updated $todayDate | AI: Cursor (Claude 3.7 Sonnet)_`n`n"
        }
        else {
            ##### Add new section at the top
            $memoryContent = "$sectionTitle`n$Content`n`n_Updated $todayDate | AI: Cursor (Claude 3.7 Sonnet)_`n`n$memoryContent"
        }
        
        Set-Content -Path $CONFIG.MemoryMdPath -Value $memoryContent
        Write-Log "Successfully updated memory.md with verification results" -Level "INFO"
    }
    catch {
        Write-Log "Failed to update memory.md: $_" -Level "ERROR"
        $errorCount++
    }
}

function Get-TaskLastRunTime {
    param (
        [string]$TaskName
    )
    
    try {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction Stop
        
        $status = "Unhealthy"
        if ($task.State -eq "Ready" -and $taskInfo.LastTaskResult -eq 0) {
            $status = "Healthy"
        }
        
        return @{
            LastRunTime = $taskInfo.LastRunTime
            LastTaskResult = $taskInfo.LastTaskResult
            State = $task.State
            Status = $status
        }
    }
    catch {
        Write-Log "Failed to get information for task '$TaskName': $_" -Level "ERROR"
        $errorCount++
        
        return @{
            LastRunTime = $null
            LastTaskResult = -1
            State = "Unknown"
            Status = "Unhealthy"
        }
    }
}

#-----------------------------------------------
##### Main process
#-----------------------------------------------
Write-Log "Starting sync system verification" -Level "INFO"

try {
    $memoryContent = ""
    $allTestsPassed = $true
    
    ##### Check if sync system is running
    $isRunning = Test-SyncSystemRunning
    if ($isRunning) {
        Write-Log "Sync system is already running" -Level "INFO"
        $memoryContent += "- ✅ Sync system is running\n"
        $successCount++
    }
    else {
        Write-Log "Sync system is not running, attempting to start it" -Level "WARNING"
        $memoryContent += "- ⚠️ Sync system was not running\n"
        
        ##### Try to start the sync system
        $startResult = Start-SyncSystem
        if ($startResult) {
            Write-Log "Successfully started sync system" -Level "INFO"
            $memoryContent += "- ✅ Successfully started sync system\n"
            $successCount++
        }
        else {
            Write-Log "Failed to start sync system" -Level "ERROR"
            $memoryContent += "- ❌ Failed to start sync system\n"
            $errorCount++
            $allTestsPassed = $false
        }
    }
    
    ##### Check state directory files
    $stateResult = Test-StateDirectoryFiles
    if ($stateResult) {
        Write-Log "All required state files exist" -Level "INFO"
        $memoryContent += "- ✅ All required state files exist\n"
        $successCount++
    }
    else {
        Write-Log "Some state files are missing" -Level "ERROR"
        $memoryContent += "- ❌ Some state files are missing\n"
        $errorCount++
        $allTestsPassed = $false
    }
    
    ##### Test sync functionality
    $syncResult = Test-SyncFunctionality
    if ($syncResult) {
        Write-Log "Sync functionality test passed" -Level "INFO"
        $memoryContent += "- ✅ Sync functionality is working properly\n"
        $successCount++
    }
    else {
        Write-Log "Sync functionality test failed" -Level "ERROR"
        $memoryContent += "- ❌ Sync functionality test failed\n"
        $errorCount++
        $allTestsPassed = $false
    }
    
    ##### Overall status
    if ($allTestsPassed) {
        $memoryContent += "- ✅ Overall: Sync system is working properly after path fixes\n"
    }
    else {
        $memoryContent += "- ❌ Overall: Sync system verification failed. See logs for details.\n"
    }
    
    ##### Update memory.md
    Update-MemoryMd -Content $memoryContent
}
catch {
    Write-Log "An error occurred during verification: $_" -Level "ERROR"
    $errorCount++
}
finally {
    Write-Log "Sync system verification completed with $successCount successes and $errorCount errors" -Level "INFO"
} 
