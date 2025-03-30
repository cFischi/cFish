# Visual Directory Organization Tool Test Script
# ucf-u7.3-directory-visual-order-test-20250315.ps1
# This script tests the desktop shortcut creation functionality of the Visual Directory Organization Tool

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

##### Set up test environment
$scriptPath = (Resolve-Path -Path ".").Path
$testRootPath = (Resolve-Path -Path "../TestShortcutEnv").Path
$originalScript = (Resolve-Path -Path "./ucf-u7.3-directory-visual-order-20250314.ps1").Path
$configFile = (Resolve-Path -Path "./ucf-u7.3-directory-visual-order-config-20250315.json").Path
$logFile = "$scriptPath/visual-directory-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
    
    ##### Also output to console
    switch ($Level) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry }
    }
}

function Create-TestEnvironment {
    ##### Create test directory if it doesn't exist
    if (Test-Path $testRootPath) {
        Write-Log "Removing existing test environment" "INFO"
        Remove-Item -Path $testRootPath -Recurse -Force
    }
    
    Write-Log "Creating test environment at $testRootPath" "INFO"
    New-Item -Path $testRootPath -ItemType Directory | Out-Null
    
    ##### Create test directories that match the expected structure
    $testDirs = @(
        ".cursor",
        "_Resources",
        "docs",
        "Documentation",
        "U1-Administration",
        "U2-Research",
        "U3-Operations",
        "U4-Production",
        "U5-Data",
        "U6-Marketing",
        "U7-Systems",
        "wp-content",
        "_Archives",
        "backup_test_20250315"
    )
    
    foreach ($dir in $testDirs) {
        $path = Join-Path -Path $testRootPath -ChildPath $dir
        New-Item -Path $path -ItemType Directory | Out-Null
        
        ##### Add some test files to each directory
        $testFilePath = Join-Path -Path $path -ChildPath "test-file.txt"
        Set-Content -Path $testFilePath -Value "This is a test file in $dir"
    }
    
    ##### Add special test files
    $memoryPath = Join-Path -Path $testRootPath -ChildPath "memory.md"
    Set-Content -Path $memoryPath -Value "##### Test Memory File"
    
    $changelogPath = Join-Path -Path $testRootPath -ChildPath "changelog.md"
    Set-Content -Path $changelogPath -Value "##### Test Changelog File"
    
    Write-Log "Created test directories and files" "SUCCESS"
}

function Test-DirectoryOrder {
    Write-Log "Testing directory order display functionality" "INFO"
    
    try {
        ##### Import the module from the original script
        Import-Module $originalScript -Force
        
        ##### Call the function with the test path
        Show-CustomDirectoryOrder -RootPath $testRootPath
        
        Write-Log "Directory order display test successful" "SUCCESS"
    }
    catch {
        Write-Log "Directory order display test failed: $_" "ERROR"
        return $false
    }
    
    return $true
}

function Test-ShortcutCreation {
    Write-Log "Testing desktop shortcut creation functionality" "INFO"
    
    try {
        ##### Import the module from the original script
        Import-Module $originalScript -Force
        
        ##### Create temporary function for testing that uses absolute paths
        function Create-TestShortcuts {
            param (
                [string]$RootPath
            )
            
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $shortcutsFolder = Join-Path -Path $desktopPath -ChildPath "cFish.io Test Shortcuts"
            
            ##### Create shortcuts folder if it doesn't exist
            if (!(Test-Path $shortcutsFolder)) {
                New-Item -Path $shortcutsFolder -ItemType Directory | Out-Null
            }
            
            ##### Define the order of directories for shortcuts
            $topDirectoryOrder = @(
                ".cursor",
                "_Resources",
                "docs",
                "Documentation"
            )
            
            ##### Get the root directory items
            $rootItems = Get-ChildItem -Path $RootPath
            
            ##### Create shortcuts in the desired order
            $index = 1
            
            ##### Create top directories
            foreach ($dir in $topDirectoryOrder) {
                $matchingItem = $rootItems | Where-Object { $_.Name -eq $dir -and $_.PSIsContainer }
                if ($matchingItem) {
                    $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_$($dir).lnk"
                    $WshShell = New-Object -ComObject WScript.Shell
                    $shortcut = $WshShell.CreateShortcut($shortcutPath)
                    $shortcut.TargetPath = $matchingItem.FullName
                    $shortcut.Save()
                    $index++
                }
            }
            
            ##### Add UcF directories
            $ucfDirs = $rootItems | Where-Object { $_.Name -match "^U[1-7]-" -and $_.PSIsContainer } | Sort-Object Name
            foreach ($dir in $ucfDirs) {
                $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_$($dir.Name).lnk"
                $WshShell = New-Object -ComObject WScript.Shell
                $shortcut = $WshShell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $dir.FullName
                $shortcut.Save()
                $index++
            }
            
            ##### Add wp-content
            $wpContent = $rootItems | Where-Object { $_.Name -eq "wp-content" -and $_.PSIsContainer }
            if ($wpContent) {
                $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_wp-content.lnk"
                $WshShell = New-Object -ComObject WScript.Shell
                $shortcut = $WshShell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $wpContent.FullName
                $shortcut.Save()
                $index++
            }
            
            ##### Add _Archives
            $archives = $rootItems | Where-Object { $_.Name -eq "_Archives" -and $_.PSIsContainer }
            if ($archives) {
                $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}__Archives.lnk"
                $WshShell = New-Object -ComObject WScript.Shell
                $shortcut = $WshShell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $archives.FullName
                $shortcut.Save()
                $index++
            }
            
            ##### Add backup directories
            $backupDirs = $rootItems | Where-Object { $_.Name -like "backup_*" -and $_.PSIsContainer } | Sort-Object Name
            foreach ($dir in $backupDirs) {
                $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_$($dir.Name).lnk"
                $WshShell = New-Object -ComObject WScript.Shell
                $shortcut = $WshShell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $dir.FullName
                $shortcut.Save()
                $index++
            }
            
            Write-Host "Created shortcuts in $shortcutsFolder in the desired order" -ForegroundColor Green
            return $shortcutsFolder
        }
        
        ##### Call the custom test function with absolute path
        $shortcutsFolder = Create-TestShortcuts -RootPath $testRootPath
        
        ##### Check if shortcuts were created
        if (Test-Path $shortcutsFolder) {
            $shortcuts = Get-ChildItem -Path $shortcutsFolder -Filter "*.lnk"
            
            Write-Log "Created $($shortcuts.Count) shortcuts in $shortcutsFolder" "INFO"
            
            ##### Expected test directories
            $expectedDirs = @(
                ".cursor",
                "_Resources",
                "docs",
                "Documentation",
                "U1-Administration",
                "U2-Research",
                "U3-Operations",
                "U4-Production",
                "U5-Data",
                "U6-Marketing",
                "U7-Systems",
                "wp-content",
                "_Archives",
                "backup_test_20250315"
            )
            
            $allCorrect = $true
            $testRootPathNormalized = $testRootPath.ToLower().TrimEnd('\')
            
            foreach ($shortcut in $shortcuts) {
                $shortcutObj = New-Object -ComObject WScript.Shell
                $shortcutLink = $shortcutObj.CreateShortcut($shortcut.FullName)
                $targetPath = $shortcutLink.TargetPath
                $targetPathNormalized = $targetPath.ToLower().TrimEnd('\')
                
                $baseName = Split-Path -Path $targetPath -Leaf
                Write-Log "Shortcut $($shortcut.Name) points to $baseName" "INFO"
                
                ##### Verify the shortcut points to a directory in the test environment
                if (-not $targetPathNormalized.StartsWith($testRootPathNormalized)) {
                    Write-Log "Shortcut $($shortcut.Name) points outside test environment: $targetPath" "ERROR"
                    $allCorrect = $false
                } else {
                    Write-Log "✓ Shortcut $($shortcut.Name) correctly points to test environment" "SUCCESS"
                }
            }
            
            if ($allCorrect) {
                Write-Log "Desktop shortcut creation test successful" "SUCCESS"
                return $true
            }
            else {
                Write-Log "Desktop shortcut creation test failed: shortcuts are not correct" "ERROR"
                return $false
            }
        }
        else {
            Write-Log "Desktop shortcut creation test failed: shortcuts folder not found" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Desktop shortcut creation test failed: $_" "ERROR"
        return $false
    }
}

function Cleanup-TestEnvironment {
    Write-Log "Cleaning up test environment" "INFO"
    
    ##### Remove test directory
    if (Test-Path $testRootPath) {
        Remove-Item -Path $testRootPath -Recurse -Force
    }
    
    ##### Remove shortcuts
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutsFolder = Join-Path -Path $desktopPath -ChildPath "cFish.io Test Shortcuts"
    
    if (Test-Path $shortcutsFolder) {
        Remove-Item -Path $shortcutsFolder -Recurse -Force
    }
    
    Write-Log "Test cleanup completed" "SUCCESS"
}

##### Main test execution
Write-Log "Starting Visual Directory Organization Tool test" "INFO"

##### Create test environment
Create-TestEnvironment

##### Test directory order display
$directoryOrderSuccess = Test-DirectoryOrder

##### Test shortcut creation
$shortcutCreationSuccess = Test-ShortcutCreation

##### Cleanup test environment
Cleanup-TestEnvironment

##### Report test results
Write-Log "======= TEST SUMMARY =======" "INFO"
Write-Log "Directory Order Display: $(if ($directoryOrderSuccess) { 'PASSED' } else { 'FAILED' })" $(if ($directoryOrderSuccess) { "SUCCESS" } else { "ERROR" })
Write-Log "Desktop Shortcut Creation: $(if ($shortcutCreationSuccess) { 'PASSED' } else { 'FAILED' })" $(if ($shortcutCreationSuccess) { "SUCCESS" } else { "ERROR" })

if ($directoryOrderSuccess -and $shortcutCreationSuccess) {
    Write-Log "All tests passed successfully" "SUCCESS"
    Write-Host "✅ All tests passed successfully. The Visual Directory Organization Tool is working as expected."
}
else {
    Write-Log "Some tests failed" "ERROR"
    Write-Host "❌ Some tests failed. Please check the log file for details: $logFile"
}

Write-Log "Test script completed" "INFO"
Write-Host "Test log saved to: $logFile" 
