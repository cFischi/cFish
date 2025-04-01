# Git Workflow Troubleshooting Guide

## Overview

This document provides guidance for troubleshooting common issues with the Git workflow implementation after the script relocation to the `z_git-flo/gitflo_tools` directory.

## Common Issues and Solutions

### Keyboard Shortcut Not Working

**Symptoms:**
- Pressing Ctrl+Alt+L or Ctrl+Alt+K doesn't execute the Git scripts
- No response in terminal when using keyboard shortcuts

**Potential Causes:**
1. VS Code keybindings not properly updated
2. Syntax errors in keybindings.json
3. VS Code not recognizing updated keybindings
4. Scripts not found at expected locations

**Solutions:**
1. Verify keybindings.json has correct paths:
   ```json
   {
       "key": "ctrl+alt+l",
       "command": "workbench.action.terminal.sendSequence",
       "args": {
           "text": "powershell -Command \"& {.\\z_git-flo\\gitflo_tools\\cursor-pull.bat | Out-Host}\"\n"
       }
   }
   ```
2. Restart VS Code to apply keybinding changes
3. Run check-script-existence.ps1 to verify all scripts exist
4. Try executing the scripts directly from terminal

### Script Execution Failures

**Symptoms:**
- Error messages when trying to execute scripts
- "File not found" or "Access denied" errors
- Partial script execution that fails during operation

**Potential Causes:**
1. PowerShell execution policy restrictions
2. Incorrect paths in wrapper scripts
3. Working directory issues
4. Permission problems

**Solutions:**
1. Check PowerShell execution policy:
   ```powershell
   Get-ExecutionPolicy
   # If restricted, try:
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```
2. Verify wrapper scripts have correct paths:
   ```powershell
   # Should contain:
   & ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1"
   ```
3. Test script execution directly:
   ```powershell
   .\z_git-flo\gitflo_tools\push-helper-fixed.ps1
   ```
4. Run test-git-shortcuts.ps1 to diagnose execution flow

### Git Tracking Issues

**Symptoms:**
- Files show as deleted in Git status
- Relocated files not tracked properly
- Git operations unable to find tracked files

**Potential Causes:**
1. Files moved without Git tracking the move
2. Git references to old file locations
3. Repository structure differences between environments

**Solutions:**
1. Re-add moved files to Git tracking:
   ```bash
   git add z_git-flo/gitflo_tools/
   git commit -m "Re-add relocated Git workflow files"
   ```
2. Use Git move operation for future relocations:
   ```bash
   git mv old_path/file.ext new_path/file.ext
   ```
3. Check repository structure on both machines

### Cross-Computer Synchronization Problems

**Symptoms:**
- Script works on one computer but not the other
- Different behavior between desktop and laptop
- File path inconsistencies between environments

**Potential Causes:**
1. Repository structure differences
2. Path conventions (backward vs. forward slashes)
3. Different PowerShell versions
4. VS Code configuration variations

**Solutions:**
1. Verify repository structure:
   - Desktop should have: `C:\Users\Chris\cFish.io` (with `.git` directly inside)
   - Laptop should have: `C:\Users\Chris\cFish.io` (with `.git` directly inside)
   - Avoid nested repositories like: `C:\Users\Chris\cFish.io\cFish`
2. Use path-agnostic script detection:
   ```powershell
   $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
   $workspaceRoot = Resolve-Path "$scriptDir\..\.."
   ```
3. Test execution on both environments
4. Keep keybindings synchronized between machines

## Validation Process

Follow this process to validate the Git workflow implementation:

1. **Script Existence Check**
   ```powershell
   # Run script to verify all scripts exist
   .\check-script-existence.ps1
   ```

2. **Execution Flow Validation**
   ```powershell
   # Test all execution paths
   .\test-git-shortcuts.ps1
   ```

3. **Keybinding Verification**
   ```powershell
   # Check keybindings.json content
   Get-Content -Path $env:APPDATA\Code\User\keybindings.json
   ```

4. **Manual Shortcut Testing**
   - Open VS Code terminal
   - Press Ctrl+Alt+L to test pull functionality
   - Press Ctrl+Alt+K to test push functionality

5. **Cross-Environment Testing**
   - Perform all checks on both desktop and laptop
   - Verify behavior is consistent across environments
   - Test actual Git operations on both machines

## Advanced Troubleshooting

For persistent issues, try these advanced troubleshooting steps:

1. **Reinstall Wrapper Scripts**
   ```powershell
   # Create fresh wrapper for pull script
   @"
   @echo off
   REM Wrapper script for backward compatibility
   echo Redirecting to z_git-flo\gitflo_tools\cursor-pull.bat...
   z_git-flo\gitflo_tools\cursor-pull.bat
   "@ | Out-File -FilePath cursor-pull.bat -Encoding ascii
   
   # Create fresh wrapper for push script
   @"
   # Wrapper script for backward compatibility
   Write-Host "Redirecting to z_git-flo\gitflo_tools\push-helper-fixed.ps1..."
   & ".\z_git-flo\gitflo_tools\push-helper-fixed.ps1"
   "@ | Out-File -FilePath push-helper-fixed.ps1 -Encoding utf8
   ```

2. **Recreate VS Code Keybindings**
   ```powershell
   # Create keybindings.json with fixed content
   $keyBindings = @'
   [
       {
           "key": "ctrl+alt+l",
           "command": "workbench.action.terminal.sendSequence",
           "args": {
               "text": "powershell -Command \"& {.\\z_git-flo\\gitflo_tools\\cursor-pull.bat | Out-Host}\"\n"
           }
       },
       {
           "key": "ctrl+alt+k",
           "command": "workbench.action.terminal.sendSequence",
           "args": {
               "text": "powershell -ExecutionPolicy Bypass -File .\\z_git-flo\\gitflo_tools\\push-helper-fixed.ps1\n"
           }
       }
   ]
   '@
   $keyBindings | Out-File -FilePath $env:APPDATA\Code\User\keybindings.json -Encoding utf8
   ```

3. **Fix Script Path Handling**
   ```powershell
   # Update push script to handle paths better
   $pushScript = @'
   # Script for pushing changes to GitHub
   # Updated to be location-aware and work regardless of where it's called from
   
   # Determine the script's directory even if called from elsewhere
   $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
   $workspaceRoot = Resolve-Path "$scriptDir\..\.."
   
   # Switch to workspace root
   Push-Location $workspaceRoot
   
   # Rest of script...
   '@
   $pushScript | Out-File -FilePath z_git-flo\gitflo_tools\push-helper-fixed.ps1 -Encoding utf8 -Append
   ```

## Reporting Issues

When reporting issues with the Git workflow implementation, please include:

1. The exact error message or observed behavior
2. The environment where the issue occurs (desktop, laptop)
3. Steps you've already taken to troubleshoot
4. Results of running the validation scripts
5. Any recent changes to the scripts or environment

_Updated 05-29-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 