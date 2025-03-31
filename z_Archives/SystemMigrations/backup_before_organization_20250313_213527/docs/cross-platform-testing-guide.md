# Cross-Platform Testing Guide for tYDiSync~

This guide outlines the steps to verify that tYDiSync~ PowerShell scripts work correctly across different platforms.

## Testing Environments

Test the scripts in the following environments:

1. **Windows PowerShell 5.1** (Default Windows environment)
2. **PowerShell 7+ on Windows**
3. **PowerShell 7+ on WSL** (Windows Subsystem for Linux)
4. **PowerShell 7+ on macOS** (if available)

## Test Script

A basic test script is provided at `scripts/test-cross-platform.ps1` that checks:
- Path handling compatibility
- File creation and reading
- Backup functionality
- Content verification

## Testing Steps

### 1. Windows PowerShell 5.1

```powershell
# Open Windows PowerShell 5.1
powershell -ExecutionPolicy Bypass -File scripts/test-cross-platform.ps1
```

### 2. PowerShell 7+ on Windows

```powershell
# Open PowerShell 7+
pwsh -ExecutionPolicy Bypass -File scripts/test-cross-platform.ps1
```

### 3. PowerShell 7+ on WSL

```bash
# In WSL bash terminal
pwsh -ExecutionPolicy Bypass -File /mnt/c/Users/Chris/cFish.io/scripts/test-cross-platform.ps1
```

### 4. PowerShell 7+ on macOS

```bash
# On macOS terminal
pwsh -ExecutionPolicy Bypass -File /path/to/cFish.io/scripts/test-cross-platform.ps1
```

## Common Issues and Solutions

### Path Separators

PowerShell is designed to handle both forward slashes (/) and backslashes (\\) in paths, but for maximum compatibility:

- Use `Join-Path` instead of string concatenation
- Avoid hardcoded path separators
- Use `[System.IO.Path]::Combine()` for complex paths

### File Encodings

- Default to UTF-8 encoding when creating files
- Use the `-Encoding` parameter with `Set-Content` and `Get-Content`
- Example: `Set-Content -Path $file -Value $content -Encoding UTF8`

### Command Chaining

- Use semicolons (;) for command chaining in PowerShell, not ampersands (&&)
- Example: `cd directory; .\script.ps1` (NOT `cd directory && .\script.ps1`)

### Environment Variables

- Use `$env:` prefix for environment variables
- Check if variables exist before using them
- Example: `if ($env:TEMP) { $tempPath = $env:TEMP }`

## Reporting Results

After running tests in each environment:

1. Document the results in memory.md
2. Report any issues in the GitHub issue tracker
3. Update the cross-platform compatibility status in the project documentation

## Next Steps

Once cross-platform compatibility is verified, proceed with:

1. Adding more robust error handling
2. Creating Pester unit tests
3. Implementing automated linting