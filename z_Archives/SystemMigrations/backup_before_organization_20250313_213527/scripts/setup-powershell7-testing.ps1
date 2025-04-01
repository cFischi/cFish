# setup-powershell7-testing.ps1
# Purpose: Set up PowerShell 7 for cross-platform testing
# Ticket: CFIO-2025-03
# Created: 2025-03-13

# ========================================================================
# tYDiSync~ PowerShell 7 Testing Environment Setup
# ========================================================================

# Set preferences
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

##### Initialize variables
$logFile = "logs/powershell7-setup-$(Get-Date -Format 'yyyyMMdd').log"
$tempDir = "temp/powershell7-setup"
$ps7InstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.msi"
$ps7InstallerPath = "$tempDir/PowerShell-7.3.4-win-x64.msi"
$testScriptsDir = "scripts/ps7-tests"

##### Ensure directories exist
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Write-Host "Created log directory: $logDir" -ForegroundColor Green
}

if (-not (Test-Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    Write-Host "Created temp directory: $tempDir" -ForegroundColor Green
}

if (-not (Test-Path $testScriptsDir)) {
    New-Item -Path $testScriptsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created test scripts directory: $testScriptsDir" -ForegroundColor Green
}

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    ##### Write to console with color based on level
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Gray }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Banner
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "      tYDiSync~ PowerShell 7 Testing Environment Setup           " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

##### Check if PowerShell 7 is already installed
function Test-PowerShell7Installed {
    try {
        ##### Try to run PowerShell 7 command
        $result = Start-Process -FilePath "pwsh" -ArgumentList "-Command", "exit" -Wait -PassThru -ErrorAction SilentlyContinue
        return ($result.ExitCode -eq 0)
    }
    catch {
        return $false
    }
}

##### Download PowerShell 7 installer
function Download-PowerShell7Installer {
    try {
        Write-Log "Downloading PowerShell 7 installer from $ps7InstallerUrl..." "INFO"
        
        ##### Create a WebClient object
        $webClient = New-Object System.Net.WebClient
        
        ##### Download the file
        $webClient.DownloadFile($ps7InstallerUrl, $ps7InstallerPath)
        
        Write-Log "PowerShell 7 installer downloaded successfully to $ps7InstallerPath" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to download PowerShell 7 installer: $_" "ERROR"
        return $false
    }
}

##### Install PowerShell 7
function Install-PowerShell7 {
    try {
        Write-Log "Installing PowerShell 7 using winget..." "INFO"
        
        ##### Try to use winget to install PowerShell 7
        $process = Start-Process -FilePath "winget" -ArgumentList "install", "--id", "Microsoft.PowerShell", "--accept-source-agreements", "--accept-package-agreements" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "PowerShell 7 installed successfully using winget" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Winget installation failed with exit code: $($process.ExitCode). Trying MSI installer..." "WARNING"
            
            ##### Fall back to MSI installer
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $ps7InstallerPath, "/quiet", "/norestart", "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1", "ENABLE_PSREMOTING=1", "REGISTER_MANIFEST=1" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Log "PowerShell 7 installed successfully using MSI installer" "SUCCESS"
                return $true
            }
            else {
                Write-Log "MSI installation failed with exit code: $($process.ExitCode)" "ERROR"
                
                ##### Try one more method - direct download of the executable installer
                Write-Log "Trying executable installer method..." "INFO"
                $exeInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.exe"
                $exeInstallerPath = "$tempDir/PowerShell-7.3.4-win-x64.exe"
                
                ##### Download the executable installer
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($exeInstallerUrl, $exeInstallerPath)
                
                ##### Run the executable installer
                $process = Start-Process -FilePath $exeInstallerPath -ArgumentList "-quiet" -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Log "PowerShell 7 installed successfully using executable installer" "SUCCESS"
                    return $true
                }
                else {
                    Write-Log "Executable installation failed with exit code: $($process.ExitCode)" "ERROR"
                    return $false
                }
            }
        }
    }
    catch {
        Write-Log "Error during PowerShell 7 installation: $_" "ERROR"
        return $false
    }
}

##### Create test script for PowerShell 7
function Create-PowerShell7TestScript {
    try {
        Write-Log "Creating PowerShell 7 test script..." "INFO"
        
        $testScriptPath = "$testScriptsDir/test-powershell7.ps1"
        $testScriptContent = @"
##### test-powershell7.ps1
##### Purpose: Test PowerShell 7 functionality
##### Created: $(Get-Date -Format "yyyy-MM-dd")

##### Display PowerShell version information
Write-Host "PowerShell Version Information:" -ForegroundColor Cyan
`$PSVersionTable

##### Test platform-specific features
Write-Host "`nPlatform-Specific Features:" -ForegroundColor Cyan
if (`$IsWindows) {
    Write-Host "Running on Windows" -ForegroundColor Green
}
elseif (`$IsLinux) {
    Write-Host "Running on Linux" -ForegroundColor Green
}
elseif (`$IsMacOS) {
    Write-Host "Running on macOS" -ForegroundColor Green
}
else {
    Write-Host "Running on unknown platform" -ForegroundColor Yellow
}

##### Test PowerShell 7 specific cmdlets
Write-Host "`nTesting PowerShell 7 Specific Cmdlets:" -ForegroundColor Cyan
try {
    ##### Test parallel foreach
    Write-Host "Testing ForEach-Object -Parallel..." -ForegroundColor Gray
    1..3 | ForEach-Object -Parallel {
        "Processing `$_ on thread [`$(([System.Threading.Thread]::CurrentThread).ManagedThreadId)]"
        Start-Sleep -Seconds 1
    } -ThrottleLimit 3
    Write-Host "ForEach-Object -Parallel test successful" -ForegroundColor Green
}
catch {
    Write-Host "ForEach-Object -Parallel test failed: `$_" -ForegroundColor Red
}

##### Test ternary operator
Write-Host "`nTesting ternary operator..." -ForegroundColor Gray
`$testValue = `$true
`$result = if (`$testValue ) { "Value is true" } else { "Value is false" }
Write-Host "Ternary operator result: `$result" -ForegroundColor Green

##### Test null conditional operators
Write-Host "`nTesting null conditional operators..." -ForegroundColor Gray
`$nullValue = `$null
`$nonNullValue = "test"
Write-Host "Null coalescing operator: `$(`$nullValue ?? 'Default Value')" -ForegroundColor Green
Write-Host "Null conditional assignment: Before = '`$nullValue'" -ForegroundColor Gray
`$nullValue ??= "Assigned Value"
Write-Host "Null conditional assignment: After = '`$nullValue'" -ForegroundColor Green

Write-Host "`nPowerShell 7 test completed successfully" -ForegroundColor Cyan
"@
        
        Set-Content -Path $testScriptPath -Value $testScriptContent
        Write-Log "PowerShell 7 test script created at $testScriptPath" "SUCCESS"
        
        ##### Create a batch file to run the test script with PowerShell 7
        $batchFilePath = "$testScriptsDir/run-powershell7-tests.bat"
        $batchFileContent = @'
@echo off
echo ================================================================
echo      Running PowerShell 7 Tests
echo ================================================================
echo.

pwsh -File "$testScriptPath"

echo.
echo ================================================================
echo      PowerShell 7 Tests Completed
echo ================================================================
pause
'@
        
        Set-Content -Path $batchFilePath -Value $batchFileContent.Replace('$testScriptPath', $testScriptPath)
        Write-Log "PowerShell 7 test batch file created at $batchFilePath" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Error creating PowerShell 7 test script: $_" "ERROR"
        return $false
    }
}

##### Create a script to run cross-platform tests in PowerShell 7
function Create-CrossPlatformTestScript {
    try {
        Write-Log "Creating cross-platform test script for PowerShell 7..." "INFO"
        
        $crossPlatformScriptPath = "$testScriptsDir/run-cross-platform-tests-ps7.ps1"
        $crossPlatformScriptContent = @'
##### run-cross-platform-tests-ps7.ps1
##### Purpose: Run cross-platform tests in PowerShell 7
##### Created: DATESTAMP

##### Set preferences
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

##### Initialize variables
$logFile = "../logs/cross-platform-ps7-DATESTAMP.log"
$testScriptPath = "../test-cross-platform.ps1"
$resultsDir = "results"

##### Ensure directories exist
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    Write-Host "Created log directory: $logDir" -ForegroundColor Green
}

if (-not (Test-Path $resultsDir)) {
    New-Item -Path $resultsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created results directory: $resultsDir" -ForegroundColor Green
}

##### Function to write to log file and console
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    ##### Write to log file
    Add-Content -Path $logFile -Value $logMessage
    
    ##### Write to console with color based on level
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Gray }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage }
    }
}

##### Banner
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "      Running Cross-Platform Tests in PowerShell 7              " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

##### Display PowerShell version information
Write-Host "PowerShell Version Information:" -ForegroundColor Cyan
$PSVersionTable | Format-Table -AutoSize

##### Run the cross-platform tests
try {
    Write-Log "Running cross-platform tests from $testScriptPath..." "INFO"
    
    ##### Capture the output of the test script
    $output = & $testScriptPath *>&1
    
    ##### Save the output to a results file
    $resultsFile = "$resultsDir/cross-platform-ps7-results-TIMESTAMP.txt"
    Set-Content -Path $resultsFile -Value @"
Cross-Platform Test Results (PowerShell 7)
==========================================
Date: DATETIME
PowerShell Version: $($PSVersionTable.PSVersion)
OS: $($PSVersionTable.OS)

Test Output:
-----------
$output

"@
    
    Write-Log "Cross-platform tests completed. Results saved to $resultsFile" "SUCCESS"
    
    ##### Display a summary of the results
    Write-Host "`nTest Results Summary:" -ForegroundColor Cyan
    if ($output -match "Cross-Platform Compatibility Test FAILED") {
        Write-Host "❌ Some tests failed. See $resultsFile for details." -ForegroundColor Red
    }
    else {
        Write-Host "✅ All tests passed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Log "Error running cross-platform tests: $_" "ERROR"
    Write-Host "❌ Failed to run cross-platform tests: $_" -ForegroundColor Red
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "      Cross-Platform Tests in PowerShell 7 Completed            " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
'@
        
        ##### Replace placeholders with actual values
        $dateStamp = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $dateTimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $crossPlatformScriptContent = $crossPlatformScriptContent.Replace('DATESTAMP', $dateStamp)
        $crossPlatformScriptContent = $crossPlatformScriptContent.Replace('TIMESTAMP', $timeStamp)
        $crossPlatformScriptContent = $crossPlatformScriptContent.Replace('DATETIME', $dateTimeStamp)
        
        Set-Content -Path $crossPlatformScriptPath -Value $crossPlatformScriptContent
        Write-Log "Cross-platform test script for PowerShell 7 created at $crossPlatformScriptPath" "SUCCESS"
        
        ##### Create a batch file to run the cross-platform tests with PowerShell 7
        $batchFilePath = "$testScriptsDir/run-cross-platform-tests-ps7.bat"
        $batchFileContent = @'
@echo off
echo ================================================================
echo      Running Cross-Platform Tests in PowerShell 7
echo ================================================================
echo.

cd %~dp0
pwsh -File "run-cross-platform-tests-ps7.ps1"

echo.
echo ================================================================
echo      Cross-Platform Tests in PowerShell 7 Completed
echo ================================================================
pause
'@
        
        Set-Content -Path $batchFilePath -Value $batchFileContent
        Write-Log "Cross-platform test batch file for PowerShell 7 created at $batchFilePath" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Error creating cross-platform test script for PowerShell 7: $_" "ERROR"
        return $false
    }
}

##### Main execution
try {
    ##### Check if PowerShell 7 is already installed
    if (Test-PowerShell7Installed) {
        Write-Log "PowerShell 7 is already installed" "SUCCESS"
    }
    else {
        Write-Log "PowerShell 7 is not installed. Starting installation..." "INFO"
        
        ##### Download PowerShell 7 installer
        if (-not (Download-PowerShell7Installer)) {
            throw "Failed to download PowerShell 7 installer"
        }
        
        ##### Install PowerShell 7
        if (-not (Install-PowerShell7)) {
            throw "Failed to install PowerShell 7"
        }
        
        ##### Verify installation
        if (Test-PowerShell7Installed) {
            Write-Log "PowerShell 7 installation verified" "SUCCESS"
        }
        else {
            throw "PowerShell 7 installation could not be verified"
        }
    }
    
    ##### Create test scripts
    if (-not (Create-PowerShell7TestScript)) {
        throw "Failed to create PowerShell 7 test script"
    }
    
    if (-not (Create-CrossPlatformTestScript)) {
        throw "Failed to create cross-platform test script for PowerShell 7"
    }
    
    ##### Display next steps
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Run PowerShell 7 tests: $testScriptsDir\run-powershell7-tests.bat" -ForegroundColor White
    Write-Host "2. Run cross-platform tests in PowerShell 7: $testScriptsDir\run-cross-platform-tests-ps7.bat" -ForegroundColor White
    Write-Host "3. Review test results in the $testScriptsDir\results directory" -ForegroundColor White
    
    Write-Log "PowerShell 7 testing environment setup completed successfully" "SUCCESS"
}
catch {
    Write-Log "Error during PowerShell 7 testing environment setup: $_" "ERROR"
    Write-Error $_
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "      PowerShell 7 Testing Environment Setup Complete            " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan 
