# PowerShell String Template Syntax Guide

## Overview

This document provides guidance on PowerShell string template syntax, with a focus on avoiding common linting errors in here-string blocks. It was created in response to specific issues encountered during the implementation of the cFish.io File Management System.

## Common Issues and Solutions

### Variable References Followed by Colons

**Issue:** When a variable is immediately followed by a colon in a here-string block, PowerShell linter will raise an error because it interprets the colon as a scope modifier rather than a literal character.

**Error Message:** 
```
Variable reference is not valid. ':' was not followed by a valid variable name character. Consider using ${} to delimit the name.
```

**Incorrect Usage:**
```powershell
$reportContent += @"
- $deptDir: $($deptCounts[$deptDir]) files
"@
```

**Correct Usage:**
```powershell
$reportContent += @"
- ${deptDir}: $($deptCounts[$deptDir]) files
"@
```

### Complex Expressions Followed by Colons

**Issue:** Similarly, when a complex expression like an if-statement is followed by a colon, you need to ensure proper variable delimitation.

**Incorrect Usage:**
```powershell
$logContent += @"
  - $secondaryFolder: $(if($secExists){"Created"}else{"Not created"})
"@
```

**Correct Usage:**
```powershell
$logContent += @"
  - ${secondaryFolder}: $(if($secExists){"Created"}else{"Not created"})
"@
```

## General Best Practices

1. **Always Use Curly Braces with Colons:** When a variable is followed by a colon, always use the `${}` syntax to delimit the variable name.

2. **Variable Expressions:** For complex expressions, use the `$()` syntax to evaluate the expression:
   ```powershell
   "The result is: $(2 + 2)"
   ```

3. **Escaping Characters:** To include a literal dollar sign in a string, use the backtick character:
   ```powershell
   "The cost is `$50"
   ```

4. **Here-String Considerations:**
   - Here-strings (@"..."@) allow variable expansion
   - Here-strings (@'...'@) with single quotes do not allow variable expansion
   - The closing quote must be at the start of a line with no leading whitespace

5. **Use VS Code with PowerShell Extension:** The PowerShell extension for VS Code provides real-time linting that can catch these issues during development.

## Implementation in cFish.io Scripts

The following scripts in the cFish.io File Management System implementation have been updated to follow these best practices:

1. `organize-cfish-io.ps1` - Fixed variable reference issue in report generation
2. `create-cfish-organization.ps1` - Fixed complex expression issue in log generation

## References

- [PowerShell About Quoting Rules](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules)
- [PowerShell About Special Characters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters)

---

_Updated 04-19-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 