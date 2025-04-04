# test-installation-scripts.ps1
# Comprehensive testing framework for installation scripts

param (
    [string]$TestOutputDir = ".cursor/test-output",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Configuration
$config = @{
    TestOutputDir = $TestOutputDir
    LogDir = "$TestOutputDir/logs"
    ReportDir = "$TestOutputDir/reports"
    TempDir = "$TestOutputDir/temp"
    ScriptsToTest = @(
        @{
            Name = "npm-memory-manager.ps1"
            Path = "scripts/npm-memory-manager.ps1"
            TestModule = ".cursor/scripts/test-npm-memory-manager.ps1"
        },
        @{
            Name = "safe-npm.ps1"
            Path = "scripts/safe-npm.ps1"
            TestCases = @(
                @{ Command = "install --save-dev jest"; ExpectedResult = $true },
                @{ Command = "install bad-package --no-validation"; ExpectedToFail = $true }
            )
        },
        @{
            Name = "install-modules.ps1"
            Path = "scripts/install-modules.ps1"
            TestCases = @(
                @{ Modules = @("PSScriptAnalyzer"); SkipPublisherCheck = $true; ExpectedResult = $true }
            )
        },
        @{
            Name = "resource-monitor.ps1"
            Path = "scripts/resource-monitor.ps1"
            TestMode = "Passive" # Just check if it runs without errors
        }
    )
    MockData = @{
        ProcessList = @(
            @{ Name = "npm"; Id = 1001; Memory = 100MB; CPU = 2 },
            @{ Name = "node"; Id = 1002; Memory = 200MB; CPU = 5 },
            @{ Name = "chrome"; Id = 1003; Memory = 500MB; CPU = 10 }
        )
        MemoryStatus = @{
            Total = 16GB
            Free = 4GB
            Load = 75
        }
    }
}

# Setup test environment
function Initialize-TestEnvironment {
    # Create necessary directories
    $dirs = @(
        $config.TestOutputDir,
        $config.LogDir,
        $config.ReportDir,
        $config.TempDir
    )
    
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # Initialize test report
    $reportFile = "$($config.ReportDir)/test-report.xml"
    @"
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
</testsuites>
"@ | Set-Content -Path $reportFile
    
    # Setup log file
    $logFile = "$($config.LogDir)/test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    "" | Set-Content -Path $logFile
    
    Write-Log "Test environment initialized."
    Write-Log "Test output directory: $($config.TestOutputDir)"
    Write-Log "Log file: $logFile"
    Write-Log "Report file: $reportFile"
    
    return @{
        LogFile = $logFile
        ReportFile = $reportFile
    }
}

# Log function
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    $logFile = "$($config.LogDir)/test-$(Get-Date -Format 'yyyyMMdd').log"
    $logMessage | Out-File -Append -FilePath $logFile
    
    # Write to console with colors
    switch ($Level) {
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Add test result to report
function Add-TestResult {
    param(
        [string]$Name,
        [string]$ScriptName,
        [bool]$Success,
        [string]$Message,
        [int]$Duration = 0
    )
    
    $reportFile = "$($config.ReportDir)/test-report.xml"
    [xml]$xml = Get-Content -Path $reportFile
    
    # Find or create testsuite for this script
    $testSuite = $xml.testsuites.testsuite | Where-Object { $_.name -eq $ScriptName }
    if (-not $testSuite) {
        $testSuite = $xml.CreateElement("testsuite")
        $testSuite.SetAttribute("name", $ScriptName)
        $testSuite.SetAttribute("tests", "0")
        $testSuite.SetAttribute("failures", "0")
        $testSuite.SetAttribute("errors", "0")
        $testSuite.SetAttribute("time", "0")
        [void]$xml.testsuites.AppendChild($testSuite)
    }
    
    # Update testsuite attributes
    $testSuite.SetAttribute("tests", ([int]$testSuite.tests + 1).ToString())
    if (-not $Success) {
        $testSuite.SetAttribute("failures", ([int]$testSuite.failures + 1).ToString())
    }
    $testSuite.SetAttribute("time", ([double]$testSuite.time + $Duration).ToString("0.000"))
    
    # Create testcase
    $testCase = $xml.CreateElement("testcase")
    $testCase.SetAttribute("name", $Name)
    $testCase.SetAttribute("classname", $ScriptName)
    $testCase.SetAttribute("time", $Duration.ToString("0.000"))
    
    # Add failure information if test failed
    if (-not $Success) {
        $failure = $xml.CreateElement("failure")
        $failure.SetAttribute("message", $Message)
        [void]$testCase.AppendChild($failure)
    }
    
    [void]$testSuite.AppendChild($testCase)
    $xml.Save($reportFile)
    
    # Log the result
    $level = if ($Success) { "SUCCESS" } else { "ERROR" }
    Write-Log "Test [$ScriptName] - [$Name]: $Message" -Level $level
}

# Mock functions for testing
function Setup-MockFunctions {
    # Mock Get-Process
    function global:Get-Process {
        param($Name, $Id)
        
        $processes = $config.MockData.ProcessList | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Id = $_.Id
                WorkingSet64 = $_.Memory
                CPU = $_.CPU
                HandleCount = 100
                Path = "C:\mock\$($_.Name).exe"
            }
        }
        
        if ($Name) {
            return $processes | Where-Object { $_.Name -like $Name }
        }
        if ($Id) {
            return $processes | Where-Object { $_.Id -eq $Id }
        }
        
        return $processes
    }
    
    # Mock Get-CimInstance
    function global:Get-CimInstance {
        param($ClassName)
        
        switch ($ClassName) {
            "Win32_OperatingSystem" {
                return [PSCustomObject]@{
                    FreePhysicalMemory = $config.MockData.MemoryStatus.Free / 1KB  # WMI returns in KB
                    TotalVisibleMemorySize = $config.MockData.MemoryStatus.Total / 1KB
                    LastBootUpTime = (Get-Date).AddDays(-1)
                }
            }
            "Win32_ComputerSystem" {
                return [PSCustomObject]@{
                    TotalPhysicalMemory = $config.MockData.MemoryStatus.Total
                    Model = "Mock Computer System"
                    Manufacturer = "Mock Manufacturer"
                }
            }
            default {
                throw "Unexpected CIM class: $ClassName"
            }
        }
    }
    
    # Mock Get-WmiObject for legacy scripts
    function global:Get-WmiObject {
        param($Class)
        
        return Get-CimInstance -ClassName $Class
    }
    
    # Mock npm commands
    function global:npm {
        param($Command, $Package, [Parameter(ValueFromRemainingArguments=$true)]$RemainingArgs)
        
        $cmdLine = "npm $Command $Package " + ($RemainingArgs -join " ")
        Write-Log "Executing mock npm: $cmdLine" -Level "INFO"
        
        if ($Command -eq "install" -and $Package -eq "bad-package") {
            Write-Error "Package not found: bad-package"
            return $false
        }
        
        # Mock package installation
        if ($Command -eq "install" -or $Command -eq "i") {
            Start-Sleep -Seconds 1
            return "Added $Package to node_modules"
        }
        
        # Mock npm config commands
        if ($Command -eq "config") {
            if ($Package -eq "get") {
                switch ($RemainingArgs[0]) {
                    "cache" { return "$($config.TempDir)\npm-cache" }
                    "tmp" { return "$($config.TempDir)\npm-temp" }
                    default { return "mock-config-value" }
                }
            }
            elseif ($Package -eq "set") {
                return "Mock: Set config $($RemainingArgs[0]) to $($RemainingArgs[1])"
            }
        }
        
        # Mock other commands
        return "Mock npm command: $cmdLine"
    }
    
    # Mock PowerShell commands
    function global:Install-Module {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Name,
            [switch]$Force,
            [switch]$SkipPublisherCheck
        )
        
        Write-Log "Mock Install-Module: $Name (Force: $Force, SkipPublisherCheck: $SkipPublisherCheck)" -Level "INFO"
        
        if ($Name -eq "NonExistentModule") {
            Write-Error "Module $Name not found."
            return $false
        }
        
        Start-Sleep -Seconds 1
        return $true
    }
    
    # Mock Invoke-Expression to prevent actual execution
    function global:Invoke-Expression {
        param([string]$Command)
        
        Write-Log "Mock Invoke-Expression: $Command" -Level "INFO"
        
        if ($Command -like "*bad-package*") {
            Write-Error "Error executing command: $Command"
            return $false
        }
        
        return "Mock execution: $Command"
    }
    
    Write-Log "Mock functions set up." -Level "INFO"
}

# Test a specific script with test cases
function Test-Script {
    param(
        [hashtable]$ScriptInfo
    )
    
    Write-Log "Testing script: $($ScriptInfo.Name)" -Level "INFO"
    
    $scriptPath = $ScriptInfo.Path
    if (-not (Test-Path $scriptPath)) {
        Write-Log "Script not found: $scriptPath" -Level "ERROR"
        Add-TestResult -Name "ScriptExistence" -ScriptName $ScriptInfo.Name -Success $false -Message "Script not found: $scriptPath"
        return $false
    }
    
    # If there's a dedicated test module, use it
    if ($ScriptInfo.TestModule -and (Test-Path $ScriptInfo.TestModule)) {
        Write-Log "Running dedicated test module: $($ScriptInfo.TestModule)" -Level "INFO"
        
        try {
            $start = Get-Date
            & $ScriptInfo.TestModule -SourceScript $scriptPath -TestOutputDir "$($config.TestOutputDir)/module-test"
            $success = $LASTEXITCODE -eq 0
            $end = Get-Date
            $duration = ($end - $start).TotalSeconds
            
            $message = if ($success) { "Test module executed successfully" } else { "Test module failed" }
            Add-TestResult -Name "ModuleTest" -ScriptName $ScriptInfo.Name -Success $success -Message $message -Duration $duration
            
            return $success
        }
        catch {
            Write-Log "Error running test module: $_" -Level "ERROR"
            Add-TestResult -Name "ModuleTest" -ScriptName $ScriptInfo.Name -Success $false -Message "Error: $_"
            return $false
        }
    }
    
    # Test script directly using test cases
    if ($ScriptInfo.TestCases) {
        $allPassed = $true
        
        foreach ($test in $ScriptInfo.TestCases) {
            $testName = if ($test.Command) { $test.Command } else { "Default" }
            Write-Log "Running test case: $testName" -Level "INFO"
            
            try {
                $start = Get-Date
                
                # Prepare arguments based on test case
                $scriptArgs = @{}
                foreach ($key in $test.Keys) {
                    if ($key -ne "ExpectedResult" -and $key -ne "ExpectedToFail" -and $key -ne "Command") {
                        $scriptArgs[$key] = $test[$key]
                    }
                }
                
                # Add Command for scripts that expect it
                if ($test.Command) {
                    $scriptArgs["Command"] = $test.Command
                }
                
                # Execute the script with arguments
                $result = & $scriptPath @scriptArgs
                $success = $true
                
                # Check if the result matches expectations
                if ($test.ContainsKey("ExpectedResult")) {
                    $success = $result -eq $test.ExpectedResult
                }
                
                # Invert success if we're expecting a failure
                if ($test.ContainsKey("ExpectedToFail") -and $test.ExpectedToFail) {
                    $success = -not $success
                }
                
                $end = Get-Date
                $duration = ($end - $start).TotalSeconds
                
                $message = if ($success) { "Test case passed" } else { "Test case failed: Expected $($test.ExpectedResult), got $result" }
                Add-TestResult -Name $testName -ScriptName $ScriptInfo.Name -Success $success -Message $message -Duration $duration
                
                if (-not $success) {
                    $allPassed = $false
                }
            }
            catch {
                Write-Log "Error running test case: $_" -Level "ERROR"
                Add-TestResult -Name $testName -ScriptName $ScriptInfo.Name -Success $false -Message "Error: $_"
                $allPassed = $false
            }
        }
        
        return $allPassed
    }
    
    # Passive test mode - just check if the script runs without errors
    if ($ScriptInfo.TestMode -eq "Passive") {
        try {
            $start = Get-Date
            & $scriptPath -TestMode
            $success = $LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE
            $end = Get-Date
            $duration = ($end - $start).TotalSeconds
            
            $message = if ($success) { "Script executed successfully" } else { "Script failed with exit code $LASTEXITCODE" }
            Add-TestResult -Name "PassiveTest" -ScriptName $ScriptInfo.Name -Success $success -Message $message -Duration $duration
            
            return $success
        }
        catch {
            Write-Log "Error running script: $_" -Level "ERROR"
            Add-TestResult -Name "PassiveTest" -ScriptName $ScriptInfo.Name -Success $false -Message "Error: $_"
            return $false
        }
    }
    
    # Default test - just check if the script exists and can be loaded
    try {
        $start = Get-Date
        . $scriptPath
        $success = $true
        $end = Get-Date
        $duration = ($end - $start).TotalSeconds
        
        Add-TestResult -Name "Load" -ScriptName $ScriptInfo.Name -Success $true -Message "Script loaded successfully" -Duration $duration
        
        return $true
    }
    catch {
        Write-Log "Error loading script: $_" -Level "ERROR"
        Add-TestResult -Name "Load" -ScriptName $ScriptInfo.Name -Success $false -Message "Error: $_"
        return $false
    }
}

# Generate HTML report
function Generate-HtmlReport {
    param(
        [string]$XmlReportPath,
        [string]$OutputPath
    )
    
    Write-Log "Generating HTML report..." -Level "INFO"
    
    [xml]$xml = Get-Content -Path $XmlReportPath
    
    $totalTests = 0
    $totalFailures = 0
    
    $testSuites = $xml.testsuites.testsuite
    $testSuites | ForEach-Object {
        $totalTests += [int]$_.tests
        $totalFailures += [int]$_.failures
    }
    
    $passRate = if ($totalTests -gt 0) { 
        [math]::Round(100 * ($totalTests - $totalFailures) / $totalTests, 2) 
    } else { 
        0 
    }
    
    $suiteHtml = ""
    $testSuites | ForEach-Object {
        $suiteName = $_.name
        $suiteTests = [int]$_.tests
        $suiteFailures = [int]$_.failures
        $suiteTime = [double]$_.time
        
        $caseHtml = ""
        $_.testcase | ForEach-Object {
            $caseName = $_.name
            $caseTime = [double]$_.time
            $failed = $null -ne $_.failure
            $failureMessage = if ($failed) { $_.failure.message } else { "" }
            
            $caseClass = if ($failed) { "failed" } else { "passed" }
            
            $caseHtml += @"
            <tr class="$caseClass">
                <td>$caseName</td>
                <td>$($failed ? "FAILED" : "PASSED")</td>
                <td>$caseTime s</td>
                <td>$failureMessage</td>
            </tr>
"@
        }
        
        $suiteClass = if ($suiteFailures -gt 0) { "failed" } else { "passed" }
        
        $suiteHtml += @"
        <div class="test-suite $suiteClass">
            <h3>$suiteName</h3>
            <div class="suite-summary">
                <span>Tests: $suiteTests</span>
                <span>Failures: $suiteFailures</span>
                <span>Time: $suiteTime s</span>
            </div>
            <table class="test-cases">
                <tr>
                    <th>Name</th>
                    <th>Status</th>
                    <th>Time (s)</th>
                    <th>Message</th>
                </tr>
                $caseHtml
            </table>
        </div>
"@
    }
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Installation Scripts Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .summary { 
            background-color: #f5f5f5; 
            padding: 10px; 
            border-radius: 5px; 
            margin-bottom: 20px;
        }
        .passed { color: green; }
        .failed { color: red; }
        .test-suite { 
            border: 1px solid #ddd; 
            margin-bottom: 20px; 
            padding: 10px; 
            border-radius: 5px;
        }
        .test-suite.passed { border-left: 5px solid green; }
        .test-suite.failed { border-left: 5px solid red; }
        .suite-summary { 
            display: flex; 
            justify-content: space-between; 
            max-width: 300px; 
            margin-bottom: 10px;
        }
        .test-cases { 
            width: 100%; 
            border-collapse: collapse; 
        }
        .test-cases th, .test-cases td { 
            border: 1px solid #ddd; 
            padding: 8px; 
            text-align: left; 
        }
        .test-cases tr.passed td:nth-child(2) { color: green; }
        .test-cases tr.failed td:nth-child(2) { color: red; }
    </style>
</head>
<body>
    <h1>Installation Scripts Test Report</h1>
    <div class="summary">
        <p>Test run completed at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <p>Total Tests: $totalTests</p>
        <p>Passed: <span class="passed">$($totalTests - $totalFailures)</span></p>
        <p>Failed: <span class="failed">$totalFailures</span></p>
        <p>Pass Rate: <span class="$($passRate -ge 100 ? 'passed' : 'failed')">$passRate%</span></p>
    </div>
    
    $suiteHtml
</body>
</html>
"@
    
    $html | Set-Content -Path $OutputPath
    Write-Log "HTML report generated: $OutputPath" -Level "SUCCESS"
}

# Main test execution
function Start-TestExecution {
    Write-Log "Starting test execution..." -Level "INFO"
    
    $env = Initialize-TestEnvironment
    Setup-MockFunctions
    
    $allPassed = $true
    foreach ($script in $config.ScriptsToTest) {
        $result = Test-Script -ScriptInfo $script
        if (-not $result) {
            $allPassed = $false
        }
    }
    
    # Generate HTML report
    $htmlReportPath = "$($config.ReportDir)/test-report.html"
    Generate-HtmlReport -XmlReportPath $env.ReportFile -OutputPath $htmlReportPath
    
    # Log final status
    $status = if ($allPassed) { "SUCCESS" } else { "ERROR" }
    Write-Log "Test execution completed. All tests passed: $allPassed" -Level $status
    
    return $allPassed
}

# Run the tests
try {
    $success = Start-TestExecution
    exit $(if ($success) { 0 } else { 1 })
}
catch {
    Write-Log "Unhandled error in test execution: $_" -Level "ERROR"
    exit 1
} 