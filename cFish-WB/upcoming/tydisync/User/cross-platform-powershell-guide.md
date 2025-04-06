# tYDiSync~ Cross-Platform PowerShell Development Guide

## Overview

This guide provides recommendations and best practices for developing PowerShell scripts that work consistently across different environments including Windows PowerShell 5.1, PowerShell Core (PowerShell 7+) on Windows, and PowerShell Core on Linux/macOS.

## Table of Contents

1. [Platform Detection](#platform-detection)
2. [Path Handling](#path-handling)
3. [Error Handling](#error-handling)
4. [Special Characters](#special-characters)
5. [Backup Functionality](#backup-functionality)
6. [Version-Specific Features](#version-specific-features)
7. [Testing Recommendations](#testing-recommendations)
8. [Environment Variables](#environment-variables)
9. [Common Pitfalls](#common-pitfalls)
10. [Resources](#resources)

## Platform Detection

### Recommended Approach

```powershell
# Get platform information
$isCore = $PSVersionTable.PSEdition -eq 'Core'
$platform = if ($isCore) { 
    if ($PSVersionTable.Platform -eq 'Unix') {
        if ($PSVersionTable.OS -like "*Linux*") { "Linux" }
        elseif ($PSVersionTable.OS -like "*Darwin*") { "macOS" }
        else { "PowerShell Core (Unix)" }
    } else {
        "PowerShell Core (Windows)"
    }
} else {
    "Windows PowerShell"
}
```

### Avoid Direct Variable References

Do not use `$IsLinux` or `$IsMacOS` variables directly as they are not available in Windows PowerShell 5.1. Instead:

```powershell
# BAD - Will fail on Windows PowerShell 5.1
if ($IsLinux) { # Linux-specific code }

# GOOD - Works across versions
$isCore = $PSVersionTable.PSEdition -eq 'Core'
if ($isCore -and $PSVersionTable.Platform -eq 'Unix') { # Unix-specific code }
```

## Path Handling

### Use Join-Path

Always use `Join-Path` cmdlet for path operations instead of string concatenation or hardcoded path separators:

```powershell
# BAD - Platform-specific
$path = "C:\Users\username\Documents"
$filePath = "$path\myfile.txt"  # Windows-specific

# GOOD - Cross-platform compatible
$path = Join-Path -Path $env:USERPROFILE -ChildPath "Documents"
$filePath = Join-Path -Path $path -ChildPath "myfile.txt"
```

### Handle Both Slash Types

Test and handle both forward (/) and backward (\\) slashes:

```powershell
# Test both slash types
$forwardSlashPath = $path.Replace('\', '/')
$backslashPath = $path.Replace('/', '\')

# Both should work
$forwardSlashWorks = Test-Path $forwardSlashPath
$backslashWorks = Test-Path $backslashPath
```

### Avoid Hardcoded Paths

Use environment variables and relative paths whenever possible:

```powershell
# BAD - Hardcoded Windows path
$logPath = "C:\Logs\myapp.log"

# GOOD - Cross-platform using environment variables
$logPath = Join-Path -Path $env:TEMP -ChildPath "myapp.log"
```

## Error Handling

### Consistent Error Action Preference

Set error preferences at the beginning of your script:

```powershell
# Set error handling preferences
$ErrorActionPreference = 'Stop'  # Makes non-terminating errors terminate
Set-StrictMode -Version Latest   # Enables strict mode for better error detection
```

### Use Try-Catch-Finally

Always use proper error handling with try-catch-finally blocks:

```powershell
try {
    # Code that might fail
    Get-Content -Path $nonExistentFile -ErrorAction Stop
}
catch {
    # Error handling
    Write-Host "Error occurred: $_" -ForegroundColor Red
    # Optional: Write to log, notify user, etc.
}
finally {
    # Cleanup code that always runs
    # Remove temporary files, close connections, etc.
}
```

### Preserve Original Error

When handling errors, preserve the original error information:

```powershell
try {
    # Code that might fail
}
catch {
    $errorMsg = "Custom error message: $($_.Exception.Message)"
    $errorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Host "Error at line $errorLine - $errorMsg" -ForegroundColor Red
    # You can also re-throw with additional context
    throw "Script failed: $errorMsg"
}
```

## Special Characters

### Handle Unicode Properly

Be careful with special characters in filenames and content:

```powershell
# Set proper encoding when working with files
Get-Content -Path $filePath -Encoding UTF8
Set-Content -Path $filePath -Value $content -Encoding UTF8
```

### Test Special Character Support

Test your scripts with filenames and content that include special characters:

```powershell
$specialFile = Join-Path -Path $testDir -ChildPath "special-char-tést.txt"
Set-Content -Path $specialFile -Value "Test content with special characters: ñáéíóúüñÑ"
```

## Backup Functionality

### Verify Backup Success

Always verify that backups were created successfully:

```powershell
$backupPath = "$filePath.bak"
Copy-Item -Path $filePath -Destination $backupPath -Force
$backupExists = Test-Path $backupPath
if (-not $backupExists) {
    throw "Backup failed: $backupPath does not exist"
}
```

### Verify Backup Content

Verify that backup content matches the original:

```powershell
$originalContent = Get-Content -Path $filePath -Raw
$backupContent = Get-Content -Path $backupPath -Raw
$contentMatches = ($originalContent -eq $backupContent)
if (-not $contentMatches) {
    throw "Backup content verification failed"
}
```

## Version-Specific Features

### Check PowerShell Version

Check the PowerShell version before using version-specific features:

```powershell
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+ specific code (e.g., using the ternary operator)
    $result = $condition ? $trueValue : $falseValue
}
else {
    # PowerShell 5.1 compatible code
    $result = if ($condition) { $trueValue } else { $falseValue }
}
```

### PowerShell 7 Specific Features

Features only available in PowerShell 7+:
- Ternary operator: `$result = $condition ? $trueValue : $falseValue`
- Null conditional operators: `$value = $object?.property`
- Parallel ForEach-Object: `$data | ForEach-Object -Parallel { ... }`
- Pipeline chain operators: `Command1 || Command2` and `Command1 && Command2`

### Safe Approach for Parallel Processing

```powershell
$parallelSupported = $null -ne (Get-Command -Name 'ForEach-Object' -ParameterName 'Parallel' -ErrorAction SilentlyContinue)

if ($parallelSupported) {
    # Use parallel processing
    $data | ForEach-Object -Parallel { ... }
}
else {
    # Fall back to sequential processing
    $data | ForEach-Object { ... }
}
```

## Testing Recommendations

### Test Across Environments

Test your scripts in multiple environments:
- Windows PowerShell 5.1
- PowerShell 7+ on Windows
- PowerShell 7+ on Linux (via WSL or native)
- PowerShell 7+ on macOS (if applicable)

### Create Automated Tests

Use Pester for automated testing:

```powershell
# Install Pester if needed
Install-Module -Name Pester -Force

# Basic test
Describe "Cross-Platform Tests" {
    Context "Path Handling" {
        It "Should handle forward slash paths" {
            $forwardSlashPath = "path/to/test"
            $result = Test-CustomPath -Path $forwardSlashPath
            $result | Should -Be $true
        }
    }
}
```

### Generate Test Reports

Generate reports of your test results:

```powershell
$reportPath = "results/test-report-$(Get-Date -Format 'yyyyMMdd').md"
$reportContent | Out-File -FilePath $reportPath -Encoding utf8 -Force
```

## Environment Variables

### Use Cross-Platform Environment Variables

Some environment variables work across platforms:

```powershell
$tempDir = $env:TEMP           # Windows-specific but often set on other platforms
$homeDir = $env:USERPROFILE    # Windows-specific
$homeDir = $env:HOME           # Linux/macOS specific
```

### Cross-Platform Home Directory

```powershell
$homeDir = if ($isCore -and $PSVersionTable.Platform -eq 'Unix') {
    $env:HOME
} else {
    $env:USERPROFILE
}
```

## Common Pitfalls

### Command Chaining Syntax

Windows PowerShell uses semicolons (`;`) for command chaining, not ampersands (`&&`):

```powershell
# BAD - Will cause errors in Windows PowerShell
Get-Item $file && Remove-Item $file

# GOOD - Works everywhere
Get-Item $file; Remove-Item $file
```

### Registry Access

Registry access is Windows-specific:

```powershell
# Windows-specific, wrap in platform check
if (-not $isCore -or ($isCore -and -not $PSVersionTable.Platform -eq 'Unix')) {
    # Windows registry operations
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
}
```

### File System Commands

Some file system operations require different cmdlets:

```powershell
# Windows-specific: uses ACLs
Get-Acl -Path $filePath

# Cross-platform alternative:
$fileInfo = Get-ChildItem -Path $filePath
```

## Resources

1. [Microsoft PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
2. [PowerShell 7 on GitHub](https://github.com/PowerShell/PowerShell)
3. [PowerShell Compatibility Layer Documentation](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell)
4. [Pester Testing Framework](https://pester.dev/docs/quick-start)

## Appendix: Testing Checklist

- [ ] Path handling with both forward and backslashes
- [ ] Special character support in filenames and content
- [ ] Error handling with try-catch-finally blocks
- [ ] Backup functionality with verification
- [ ] Platform-specific feature detection
- [ ] Environment variable usage
- [ ] Command chaining syntax
- [ ] Performance across different platforms

---

_Updated: 03-13-2025 | tYDiSync~ Cross-Platform Compatibility Team_ 