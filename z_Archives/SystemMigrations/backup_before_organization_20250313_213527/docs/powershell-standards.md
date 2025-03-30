# PowerShell Coding Standards for tYDiSync~

This document outlines coding standards and best practices for PowerShell scripts in the tYDiSync~ project.

## Variable Naming

- Use PascalCase for function names and camelCase for variable names
- Use descriptive names that indicate purpose or content
- Avoid abbreviations unless they are well-known

```powershell
# Good
$fileName = "document.md"
$backupPath = Join-Path -Path $backupDir -ChildPath $fileName

# Avoid
$fn = "document.md" 
$bp = Join-Path -Path $bDir -ChildPath $fn
```

## Error Handling

### Variable References in Strings

PowerShell has specific rules for variable references in strings, particularly with special variables like `$_`:

```powershell
# AVOID - Will cause linter errors
Write-Log "Error: $_" 

# CORRECT - Use string concatenation
$errorMessage = $_.Exception.Message
Write-Log "Error: $errorMessage" 

# CORRECT - Use subexpression syntax
Write-Log "Error: $($_.Exception.Message)"

# ALTERNATIVE - Use separate parameters
Write-Log "Error occurred" "ERROR"
```

### Try-Catch Blocks

Always use try-catch blocks for operations that might fail:

```powershell
try {
    # Risky operation
    Copy-Item -Path $source -Destination $target -Force
} 
catch {
    # Handle error properly
    $errorMessage = $_.Exception.Message
    Write-Log "Failed to copy file: $errorMessage" "ERROR"
}
```

## Parameter Declarations

Use proper parameter declarations with type information:

```powershell
function Do-Something {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RequiredParam,
        
        [Parameter(Mandatory=$false)]
        [int]$OptionalParam = 0
    )
    
    # Function code
}
```

## Command Line Separators

Remember that PowerShell uses semicolons `;` not ampersands `&&` to chain commands:

```powershell
# INCORRECT - Will fail
cd directory && .\script.ps1

# CORRECT
cd directory; .\script.ps1
```

## File Paths

Use `Join-Path` rather than string concatenation for paths:

```powershell
# AVOID
$path = "$dir\$file"

# CORRECT
$path = Join-Path -Path $dir -ChildPath $file
```

## Logging and Output

- Use a consistent logging function throughout scripts
- Differentiate between error, warning, and informational messages
- Include timestamps in log messages

```powershell
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file and console with appropriate formatting
}
```

## Script Documentation

Every script should include a header comment block:

```powershell
# Script: example-script.ps1
# Description: This script processes files in a directory
# Author: tYDiSync~ Team
# Date: 2024-06-28
# Version: 1.0
```

## Testing Recommendations

- Test scripts in isolation before integrating
- Use `-WhatIf` parameter when available to see effects without executing
- For complex scripts, create unit tests using Pester framework 