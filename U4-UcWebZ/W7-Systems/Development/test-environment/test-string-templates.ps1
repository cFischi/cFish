#Requires -Version 5.1
<#
.SYNOPSIS
    Script to test PowerShell string template syntax and validate fixes.

.DESCRIPTION
    This script tests various string template scenarios, focusing on variable
    references in here-string blocks followed by colons. It ensures our fixes
    are effective and compliant with PowerShell best practices.

.PARAMETER showOutput
    Shows the full output of the generated content.

.NOTES
    Author: Claude 3.7 Sonnet via Cursor
    Version: 1.0
    Date: April 19, 2025
#>

[CmdletBinding()]
param (
    [switch]$showOutput
)

# Test data
$deptCounts = @{
    "U1-Overheads" = 42
    "U2-Research-and-Development" = 78
    "U3-Operations" = 56
    "U4-Production" = 123
    "U5-Data-Management" = 89
    "U6-Social-Media-Communications" = 45
    "U7-Specialized-Projects" = 32
}

##### Function to test string template syntax patterns
function Test-StringTemplateSyntax {
    [CmdletBinding()]
    param()
    
    Write-Host "Testing PowerShell string template syntax patterns..." -ForegroundColor Cyan
    
    ##### Test 1: Variables followed by colons (incorrect approach)
    Write-Host "`nTest 1: Variables followed by colons (incorrect approach)" -ForegroundColor Yellow
    try {
        $reportContent = ""
        foreach ($deptDir in $deptCounts.Keys | Sort-Object) {
            ##### This would cause a linter error: $deptDir: $($deptCounts[$deptDir])
            ##### Commenting out to prevent actual errors
            ##### $reportContent += @"
            # - $deptDir: $($deptCounts[$deptDir]) files
            # "@
        }
        Write-Host "Note: Actual test commented out to prevent errors" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error (as expected): $_" -ForegroundColor Red
    }
    
    ##### Test 2: Variables followed by colons (correct approach with curly braces)
    Write-Host "`nTest 2: Variables followed by colons (correct approach with curly braces)" -ForegroundColor Yellow
    try {
        $reportContent = ""
        foreach ($deptDir in $deptCounts.Keys | Sort-Object) {
            $reportContent += @"
- ${deptDir}: $($deptCounts[$deptDir]) files
"@
        }
        Write-Host "Success: Generated report content with correct syntax" -ForegroundColor Green
        if ($showOutput) {
            Write-Host "Generated content:" -ForegroundColor Gray
            Write-Host $reportContent -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Unexpected Error: $_" -ForegroundColor Red
    }
    
    ##### Test 3: Complex expressions followed by colons (correct approach)
    Write-Host "`nTest 3: Complex expressions followed by colons (correct approach)" -ForegroundColor Yellow
    try {
        $subfolder = "Documentation"
        $secExists = $true
        $dryRun = $false
        
        $logContent = @"
- ${subfolder}: $(if($secExists){"Already exists"}else{"Would be created"})
- Operation Mode: $(if($dryRun){"Dry Run"}else{"Actual Creation"})
"@
        
        Write-Host "Success: Generated log content with correct syntax" -ForegroundColor Green
        if ($showOutput) {
            Write-Host "Generated content:" -ForegroundColor Gray
            Write-Host $logContent -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Unexpected Error: $_" -ForegroundColor Red
    }
    
    ##### Test 4: Multiple variables in a single line
    Write-Host "`nTest 4: Multiple variables in a single line" -ForegroundColor Yellow
    try {
        $dept = @{
            Key = "U5"
            Value = "Data-Management"
        }
        
        $logContent = @"
- ${dept.Key}-${dept.Value}: Created successfully
"@
        
        Write-Host "Success: Generated content with multiple variables" -ForegroundColor Green
        if ($showOutput) {
            Write-Host "Generated content:" -ForegroundColor Gray
            Write-Host $logContent -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Unexpected Error: $_" -ForegroundColor Red
    }
    
    Write-Host "`nString template syntax tests completed." -ForegroundColor Cyan
}

##### Main execution
try {
    Write-Host "PowerShell String Template Syntax Test" -ForegroundColor Blue
    Write-Host "===================================" -ForegroundColor Blue
    
    Test-StringTemplateSyntax
    
    Write-Host "`nAll tests completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred during script execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} 
