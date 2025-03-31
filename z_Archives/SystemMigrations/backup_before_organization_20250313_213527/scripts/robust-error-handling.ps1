# robust-error-handling.ps1
# Purpose: Templates and guidelines for implementing robust error handling in PowerShell scripts
# Ticket: CFIO-2025-04
# Created: 2025-03-13

# ========================================================================
# tYDiSync~ Robust Error Handling Templates and Best Practices
# ========================================================================

# This script provides templates and examples for implementing consistent
# error handling across all tYDiSync~ PowerShell scripts

# Set error preferences
$ErrorActionPreference = "Stop"  ##### Stop execution when errors occur that aren't handled in try/catch
Set-StrictMode -Version 3.0      ##### Enforce strict variable usage and other PowerShell best practices

##### ========================================================================
##### 1. Basic Try-Catch-Finally Template
##### ========================================================================

function Demo-BasicErrorHandling {
    param (
        [string]$FilePath
    )
    
    try {
        ##### Attempt to perform the operation
        Get-Content -Path $FilePath -ErrorAction Stop
        Write-Host "Successfully read file" -ForegroundColor Green
    }
    catch [System.IO.FileNotFoundException] {
        ##### Handle specific error type
        Write-Error "File not found: $FilePath"
        ##### You can choose to return, exit, or throw based on severity
        return $false
    }
    catch {
        ##### Handle any other errors
        $errorMessage = $_.Exception.Message
        Write-Error "An error occurred: $errorMessage"
        return $false
    }
    finally {
        ##### Clean up resources regardless of success/failure
        Write-Host "Operation completed" -ForegroundColor Gray
    }
    
    return $true
}

##### ========================================================================
##### 2. Advanced Error Handling with Logging
##### ========================================================================

function Write-ErrorLog {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        
        [Parameter(Mandatory=$false)]
        [string]$LogFile = "logs/error_log.txt",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("ERROR", "WARNING", "INFO")]
        [string]$Severity = "ERROR"
    )
    
    ##### Create log directory if it doesn't exist
    $logDir = Split-Path -Parent $LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Severity] $Message"
    
    ##### Add error details if provided
    if ($ErrorRecord) {
        $errorDetails = @(
            "Exception Type: $($ErrorRecord.Exception.GetType().FullName)",
            "Exception Message: $($ErrorRecord.Exception.Message)",
            "Script: $($ErrorRecord.InvocationInfo.ScriptName)",
            "Line Number: $($ErrorRecord.InvocationInfo.ScriptLineNumber)",
            "Position: $($ErrorRecord.InvocationInfo.PositionMessage)",
            "Stack Trace: $($ErrorRecord.ScriptStackTrace)"
        ) -join "`n    "
        
        $logEntry += "`n  Details:`n    $errorDetails"
    }
    
    ##### Write to log file
    Add-Content -Path $LogFile -Value $logEntry
    
    ##### Also output to console with appropriate color
    switch ($Severity) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "INFO" { Write-Host $Message -ForegroundColor White }
    }
}

function Demo-AdvancedErrorHandling {
    param (
        [string]$FilePath,
        [string]$LogFile = "logs/operation_log.txt"
    )
    
    try {
        ##### Validate input parameters
        if ([string]::IsNullOrEmpty($FilePath)) {
            throw [System.ArgumentException]::new("FilePath parameter cannot be null or empty")
        }
        
        ##### Attempt to perform the operation
        if (-not (Test-Path $FilePath)) {
            throw [System.IO.FileNotFoundException]::new("File not found", $FilePath)
        }
        
        $content = Get-Content -Path $FilePath -ErrorAction Stop
        Write-ErrorLog -Message "Successfully read file: $FilePath" -Severity "INFO" -LogFile $LogFile
        
        ##### Process content
        foreach ($line in $content) {
            ##### Additional operations that might fail
            try {
                ##### Process line
                ##### ...
            }
            catch {
                ##### Log warning but continue processing
                Write-ErrorLog -Message "Warning while processing line in $FilePath" -ErrorRecord $_ -Severity "WARNING" -LogFile $LogFile
                ##### Continue to next line
                continue
            }
        }
    }
    catch [System.ArgumentException] {
        ##### Handle invalid argument
        Write-ErrorLog -Message "Invalid argument" -ErrorRecord $_ -LogFile $LogFile
        return $false
    }
    catch [System.IO.FileNotFoundException] {
        ##### Handle file not found
        Write-ErrorLog -Message "File not found: $FilePath" -ErrorRecord $_ -LogFile $LogFile
        return $false
    }
    catch {
        ##### Handle any other errors
        Write-ErrorLog -Message "An unexpected error occurred while processing $FilePath" -ErrorRecord $_ -LogFile $LogFile
        return $false
    }
    
    return $true
}

##### ========================================================================
##### 3. Adding Error Handling to Existing Scripts
##### ========================================================================

<##### Steps to add robust error handling to existing scripts:

1. Set error preferences at the top of the script:
   $ErrorActionPreference = "Stop"
   Set-StrictMode -Version 3.0

2. Identify critical operations that should be wrapped in try-catch blocks
   - File operations
   - Network requests
   - Database operations
   - External process invocation

3. Use the appropriate error handling pattern based on the function's importance:
   - Simple functions: Basic try-catch
   - Complex or critical functions: Advanced error handling with logging

4. For each function, ensure:
   - Input validation occurs before operations
   - Specific error types are caught separately
   - Error details are logged appropriately
   - Resources are properly cleaned up in finally blocks
   - Appropriate return values indicate success/failure

5. Update function documentation to indicate error handling behavior:
   - What exceptions might be thrown
   - How failures are communicated to the caller
   - What cleanup operations are guaranteed
#>

##### ========================================================================
##### Usage Examples
##### ========================================================================

##### Example 1: Basic error handling
$result = Demo-BasicErrorHandling -FilePath "nonexistent-file.txt"
if (-not $result) {
    Write-Host "Basic error handling example failed" -ForegroundColor Yellow
}

##### Example 2: Advanced error handling with logging
$result = Demo-AdvancedErrorHandling -FilePath "nonexistent-file.txt" -LogFile "logs/example_log.txt"
if (-not $result) {
    Write-Host "Advanced error handling example failed" -ForegroundColor Yellow
}

##### For testing purposes, create a file and try again
$testFilePath = "temp-test-file.txt"
Set-Content -Path $testFilePath -Value "Test content`nLine 2`nLine 3"
$result = Demo-AdvancedErrorHandling -FilePath $testFilePath -LogFile "logs/example_log.txt"
if ($result) {
    Write-Host "Advanced error handling example succeeded with test file" -ForegroundColor Green
}

##### Clean up test file
if (Test-Path $testFilePath) {
    Remove-Item -Path $testFilePath
}

##### ========================================================================
##### New Enhanced Error Handling Template
##### ========================================================================

<##### .SYNOPSIS
    Robust Error Handling Template for tYDiSync~ PowerShell Scripts
.DESCRIPTION
    This script provides templates and functions for implementing robust error handling 
    across tYDiSync~ PowerShell scripts, with severity-based logging, detailed error reporting,
    and consistent error management practices.
.NOTES
    Version:        1.0
    Author:         tYFischEYe
    Creation Date:  2025-03-13
    Last Modified:  2025-03-13
#>

##### Set strict mode and error action preference for script-wide error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

##### Script Constants
${script}:LogFile = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "logs\error-handling-$(Get-Date -Format 'yyyyMMdd').log"
${script}:ScriptName = $MyInvocation.MyCommand.Name
${script}:SuccessColor = 'Green'
${script}:WarningColor = 'Yellow'
${script}:ErrorColor = 'Red'
${script}:InfoColor = 'Cyan'
${script}:DebugColor = 'Gray'

##### Create logs directory if it doesn't exist
$logsDir = Split-Path -Parent ${script}:LogFile
if (-not (Test-Path -Path $logsDir)) {
    New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
}

##### Function to write log messages with severity levels
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS', 'DEBUG')]
        [string]$Severity = 'INFO',
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole,
        
        [Parameter(Mandatory = $false)]
        [string]$LogFile = ${script}:LogFile
    )
    
    try {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logMessage = "[$timestamp] [$Severity] [${script}:ScriptName] $Message"
        
        ##### Ensure the log directory exists
        $logDirectory = Split-Path -Parent $LogFile
        if (-not (Test-Path -Path $logDirectory)) {
            New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
        }
        
        ##### Append to log file
        Add-Content -Path $LogFile -Value $logMessage -Force
        
        ##### Output to console unless NoConsole is specified
        if (-not $NoConsole) {
            $consoleColor = switch ($Severity) {
                'SUCCESS' { ${script}:SuccessColor }
                'WARNING' { ${script}:WarningColor }
                'ERROR' { ${script}:ErrorColor }
                'INFO' { ${script}:InfoColor }
                'DEBUG' { ${script}:DebugColor }
                default { 'White' }
            }
            
            Write-Host $logMessage -ForegroundColor $consoleColor
        }
    }
    catch {
        ##### Last resort error handling if logging fails
        Write-Host "Failed to write log: $_" -ForegroundColor ${script}:ErrorColor
    }
}

##### Function to get detailed error information
function Get-DetailedErrorInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    try {
        $errorDetails = [PSCustomObject]@{
            Message = $ErrorRecord.Exception.Message
            Category = $ErrorRecord.CategoryInfo.Category
            FullyQualifiedErrorId = $ErrorRecord.FullyQualifiedErrorId
            ScriptName = $ErrorRecord.InvocationInfo.ScriptName
            ScriptLineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
            Line = $ErrorRecord.InvocationInfo.Line.Trim()
            PositionMessage = $ErrorRecord.InvocationInfo.PositionMessage
            StackTrace = $ErrorRecord.ScriptStackTrace
        }
        
        return $errorDetails
    }
    catch {
        Write-Log "Failed to get detailed error info: $_" 'ERROR'
        return $null
    }
}

##### Function to handle errors with consistent formatting and detailed information
function Handle-Error {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        
        [Parameter(Mandatory = $false)]
        [string]$CustomMessage = "",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('CONTINUE', 'EXIT')]
        [string]$Action = 'CONTINUE'
    )
    
    try {
        $errorInfo = Get-DetailedErrorInfo -ErrorRecord $ErrorRecord
        
        $errorMessage = if ([string]::IsNullOrEmpty($CustomMessage)) {
            "ERROR: $($errorInfo.Message)"
        } else {
            "ERROR: $CustomMessage - $($errorInfo.Message)"
        }
        
        ##### Log the main error message
        Write-Log $errorMessage 'ERROR'
        
        ##### Log detailed error information
        Write-Log "Error Details:" 'ERROR' -NoConsole
        Write-Log "- Category: $($errorInfo.Category)" 'ERROR' -NoConsole
        Write-Log "- Script: $($errorInfo.ScriptName)" 'ERROR' -NoConsole
        Write-Log "- Line Number: $($errorInfo.ScriptLineNumber)" 'ERROR' -NoConsole
        Write-Log "- Line: $($errorInfo.Line)" 'ERROR' -NoConsole
        Write-Log "- Stack Trace: $($errorInfo.StackTrace)" 'ERROR' -NoConsole
        
        ##### Take action based on the specified parameter
        if ($Action -eq 'EXIT') {
            Write-Log "Exiting script due to critical error." 'ERROR'
            exit 1
        }
    }
    catch {
        ##### Last resort error handling if the error handler itself fails
        Write-Host "Critical failure in error handler: $_" -ForegroundColor ${script}:ErrorColor
        if ($Action -eq 'EXIT') {
            exit 1
        }
    }
}

##### Function to apply a consistent try-catch-finally template for file operations
function Try-FileOperation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$Operation,
        
        [Parameter(Mandatory = $true)]
        [string]$OperationName,
        
        [Parameter(Mandatory = $false)]
        [scriptblock]$FinallyBlock = {},
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('CONTINUE', 'EXIT')]
        [string]$OnErrorAction = 'CONTINUE'
    )
    
    try {
        Write-Log "Starting $OperationName..." 'INFO'
        
        ##### Execute the operation
        $result = & $Operation
        
        Write-Log "$OperationName completed successfully." 'SUCCESS'
        return $result
    }
    catch {
        Handle-Error -ErrorRecord $_ -CustomMessage "Error during $OperationName" -Action $OnErrorAction
        return $null
    }
    finally {
        ##### Execute the finally block
        & $FinallyBlock
    }
}

##### Function to scan a PowerShell script and apply error handling template
function Apply-ErrorHandlingTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $false)]
        [string]$BackupDirectory = (Join-Path -Path $PSScriptRoot -ChildPath "backups")
    )
    
    try {
        ##### Make sure the script exists
        if (-not (Test-Path -Path $ScriptPath)) {
            Write-Log "Script not found: $ScriptPath" 'ERROR'
            return $false
        }
        
        ##### Create backup directory if it doesn't exist
        if (-not (Test-Path -Path $BackupDirectory)) {
            New-Item -Path $BackupDirectory -ItemType Directory -Force | Out-Null
            Write-Log "Created backup directory: $BackupDirectory" 'INFO'
        }
        
        ##### Create a backup of the original script
        $scriptName = Split-Path -Leaf $ScriptPath
        $backupPath = Join-Path -Path $BackupDirectory -ChildPath "$scriptName.bak"
        Copy-Item -Path $ScriptPath -Destination $backupPath -Force
        Write-Log "Created backup at: $backupPath" 'INFO'
        
        ##### Read the script content
        $content = Get-Content -Path $ScriptPath -Raw
        
        ##### Apply error handling template modifications
        $modified = $false
        
        ##### Check for $ErrorActionPreference and add if missing
        if ($content -notmatch "\`$ErrorActionPreference\s*=") {
            $header = @"
##### Set error action preference for consistent error handling
`$ErrorActionPreference = 'Stop'

"@
            $content = $header + $content
            $modified = $true
            Write-Log "Added ErrorActionPreference to $scriptName" 'INFO'
        }
        
        ##### Check for logging function and add if missing
        if ($content -notmatch "function\s+Write-Log\s*\{") {
            $logFunction = @"

##### Function to write log messages
function Write-Log {
    param (
        [Parameter(Mandatory = `$true)]
        [string]`$Message,
        
        [Parameter(Mandatory = `$false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS', 'DEBUG')]
        [string]`$Severity = 'INFO'
    )
    
    `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    `$logMessage = "[`$timestamp] [`$Severity] [$(Split-Path -Leaf `$PSCommandPath)] `$Message"
    
    ##### Define colors for console output
    `$consoleColor = switch (`$Severity) {
        'SUCCESS' { 'Green' }
        'WARNING' { 'Yellow' }
        'ERROR' { 'Red' }
        'INFO' { 'Cyan' }
        'DEBUG' { 'Gray' }
        default { 'White' }
    }
    
    ##### Output to console
    Write-Host `$logMessage -ForegroundColor `$consoleColor
    
    ##### Append to log file if needed
    ##### Add-Content -Path `$LogFile -Value `$logMessage
}

"@
            # Insert the function after any comment blocks at the top
            $commentEnd = $content -match "^#>[\r\n]+"
            if ($commentEnd) {
                $splitPoint = $content.IndexOf("#>") + 2
                $content = $content.Substring(0, $splitPoint) + "`n" + $logFunction + $content.Substring($splitPoint)
            } else {
                $content = $logFunction + $content
            }
            $modified = $true
            Write-Log "Added Write-Log function to $scriptName" 'INFO'
        }
        
        ##### Check for error handling in major code blocks
        if ($content -notmatch "try\s*\{") {
            ##### This is a more complex operation that would require parsing the script
            ##### We'll just log for now and suggest manual review
            Write-Log "Script $scriptName does not contain try-catch blocks. Manual review recommended." 'WARNING'
        }
        
        ##### If modifications were made, save the updated content
        if ($modified) {
            Set-Content -Path $ScriptPath -Value $content
            Write-Log "Applied error handling template to $scriptName" 'SUCCESS'
            return $true
        } else {
            Write-Log "No changes needed for $scriptName" 'INFO'
            return $false
        }
    }
    catch {
        Handle-Error -ErrorRecord $_ -CustomMessage "Failed to apply error handling template to $ScriptPath"
        return $false
    }
}

##### Template: Basic Try-Catch-Finally Pattern
function Template-BasicErrorHandling {
    @"
# Basic Try-Catch-Finally Pattern
try {
    # Main operation code here
    Write-Log "Starting operation..." 'INFO'
    
    ##### Your code here
    
    Write-Log "Operation completed successfully" 'SUCCESS'
}
catch {
    ##### Error handling
    `$errorMessage = `$_.Exception.Message
    Write-Log "Error occurred: `$errorMessage" 'ERROR'
    
    ##### Optional: Output detailed error information
    Write-Log "Error details: Line `$(`$_.InvocationInfo.ScriptLineNumber), `$(`$_.InvocationInfo.Line)" 'ERROR'
    Write-Log "Stack trace: `$(`$_.ScriptStackTrace)" 'ERROR'
}
finally {
    ##### Cleanup code that should always run
    Write-Log "Performing cleanup operations" 'INFO'
    
    ##### Your cleanup code here
}
"@
}

# Template: File Operation With Error Handling
function Template-FileOperationErrorHandling {
    @"
##### File Operation With Error Handling
function Safe-FileOperation {
    param (
        [string]`$FilePath,
        [string]`$Operation = "read"  ##### Options: read, write, delete
    )
    
    try {
        Write-Log "Starting `$Operation operation on `$FilePath" 'INFO'
        
        ##### Check if file exists for operations that require it
        if (`$Operation -ne "write" -and -not (Test-Path -Path `$FilePath)) {
            throw "File not found: `$FilePath"
        }
        
        ##### Perform the requested operation
        switch (`$Operation) {
            "read" {
                `$content = Get-Content -Path `$FilePath -Raw
                Write-Log "Successfully read `$FilePath" 'SUCCESS'
                return `$content
            }
            "write" {
                ##### Example: Set-Content -Path `$FilePath -Value `$YourContent
                Write-Log "Successfully wrote to `$FilePath" 'SUCCESS'
            }
            "delete" {
                Remove-Item -Path `$FilePath -Force
                Write-Log "Successfully deleted `$FilePath" 'SUCCESS'
            }
            default {
                throw "Unsupported operation: `$Operation"
            }
        }
    }
    catch {
        Write-Log "Error during `$Operation operation on `$FilePath: `$(`$_.Exception.Message)" 'ERROR'
        Write-Log "Error details: Line `$(`$_.InvocationInfo.ScriptLineNumber), `$(`$_.InvocationInfo.Line)" 'ERROR'
        return `$null
    }
}
"@
}

##### Template: API Call With Error Handling
function Template-ApiCallErrorHandling {
    @"
# API Call With Error Handling
function Invoke-SafeApiCall {
    param (
        [string]`$Url,
        [string]`$Method = "GET",
        [object]`$Body = `$null,
        [int]`$MaxRetries = 3,
        [int]`$RetryDelaySeconds = 2
    )
    
    `$retryCount = 0
    do {
        try {
            Write-Log "Sending `$Method request to `$Url (Attempt `$(`$retryCount + 1))" 'INFO'
            
            `$params = @{
                Uri = `$Url
                Method = `$Method
                ContentType = "application/json"
                UseBasicParsing = `$true
                ErrorAction = "Stop"
            }
            
            if (`$null -ne `$Body) {
                `$params.Body = ConvertTo-Json -InputObject `$Body -Depth 10
            }
            
            `$response = Invoke-RestMethod @params
            Write-Log "`$Method request to `$Url completed successfully" 'SUCCESS'
            return `$response
        }
        catch {
            `$retryCount++
            `$errorMessage = `$_.Exception.Message
            
            if (`$retryCount -lt `$MaxRetries) {
                Write-Log "Error calling `$Url: `$errorMessage. Retrying in `$RetryDelaySeconds seconds..." 'WARNING'
                Start-Sleep -Seconds `$RetryDelaySeconds
            }
            else {
                Write-Log "Failed to call `$Url after `$MaxRetries attempts: `$errorMessage" 'ERROR'
                Write-Log "Error details: Line `$(`$_.InvocationInfo.ScriptLineNumber), `$(`$_.InvocationInfo.Line)" 'ERROR'
                return `$null
            }
        }
    } while (`$retryCount -lt `$MaxRetries)
}
"@
}

##### Main execution block with error handling
try {
    Write-Log "Starting Robust Error Handling Template Example" 'INFO'
    
    ##### Example usage of Try-FileOperation
    $exampleResult = Try-FileOperation -Operation {
        ##### Sample operation
        $testFile = Join-Path -Path ${env}:TEMP -ChildPath "tydisync-error-handling-test.txt"
        Set-Content -Path $testFile -Value "This is a test file for error handling."
        Get-Content -Path $testFile -Raw
    } -OperationName "Example File Test" -FinallyBlock {
        ##### Cleanup
        $testFile = Join-Path -Path ${env}:TEMP -ChildPath "tydisync-error-handling-test.txt"
        if (Test-Path -Path $testFile) {
            Remove-Item -Path $testFile -Force
        }
    }
    
    if ($null -ne $exampleResult) {
        Write-Log "Example successfully completed and returned: $exampleResult" 'SUCCESS'
    }
    
    ##### Display templates
    Write-Log "Basic Error Handling Template:" 'INFO'
    Write-Host (Template-BasicErrorHandling) -ForegroundColor Gray
    
    Write-Log "File Operation Error Handling Template:" 'INFO'
    Write-Host (Template-FileOperationErrorHandling) -ForegroundColor Gray
    
    Write-Log "API Call Error Handling Template:" 'INFO'
    Write-Host (Template-ApiCallErrorHandling) -ForegroundColor Gray
    
    Write-Log "Robust Error Handling Template Example Completed" 'SUCCESS'
}
catch {
    Handle-Error -ErrorRecord $_ -CustomMessage "Error in main error handling template example" -Action 'EXIT'
} 
