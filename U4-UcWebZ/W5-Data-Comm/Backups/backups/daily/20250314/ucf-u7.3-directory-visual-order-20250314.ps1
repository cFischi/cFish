# Directory Visual Organization Script
# ucf-u7.3-directory-visual-order-20250314.ps1
# This script displays directories in a custom order for better visual organization

function Show-CustomDirectoryOrder {
    param (
        [string]$RootPath = ".",
        [switch]$IncludeFiles
    )

    Write-Host "`n=== CFISH.IO DIRECTORY ORGANIZATION ===`n" -ForegroundColor Cyan

    ##### Define desired display order for top-level directories
    $directoryOrder = @(
        ".cursor",
        "_Resources",
        "docs",
        "Documentation"
        ##### U1-U7 directories will be placed here
        ##### Then wp-content, _Archives, and backup directories
    )
    
    ##### Get all items in the root directory
    $allItems = Get-ChildItem -Path $RootPath
    
    ##### Filter directories and files
    $directories = $allItems | Where-Object { $_.PSIsContainer }
    $files = $allItems | Where-Object { !$_.PSIsContainer }
    
    ##### Create ordered list to display
    $orderedDisplay = @()
    
    ##### First add specifically ordered directories from the top
    foreach ($dir in $directoryOrder) {
        $matchingDir = $directories | Where-Object { $_.Name -eq $dir }
        if ($matchingDir) {
            $orderedDisplay += $matchingDir
        }
    }
    
    ##### Add UcF department directories (U1-U7)
    $ucfDirs = $directories | Where-Object { $_.Name -match "^U[1-7]-" } | Sort-Object Name
    $orderedDisplay += $ucfDirs
    
    ##### Add wp-content
    $wpContent = $directories | Where-Object { $_.Name -eq "wp-content" }
    if ($wpContent) {
        $orderedDisplay += $wpContent
    }
    
    ##### Add _Archives
    $archives = $directories | Where-Object { $_.Name -eq "_Archives" }
    if ($archives) {
        $orderedDisplay += $archives
    }
    
    ##### Add backup directories
    $backupDirs = $directories | Where-Object { $_.Name -like "backup_*" } | Sort-Object Name
    $orderedDisplay += $backupDirs
    
    ##### Add any remaining directories not yet included
    $includedNames = $orderedDisplay.Name
    $remainingDirs = $directories | Where-Object { $includedNames -notcontains $_.Name }
    $orderedDisplay += ($remainingDirs | Sort-Object Name)
    
    ##### Display directories with formatting
    Write-Host "DIRECTORIES (in preferred order):" -ForegroundColor Green
    foreach ($dir in $orderedDisplay) {
        $dirSize = Get-DirectorySize -Directory $dir.FullName
        $formattedSize = Format-FileSize -Size $dirSize
        
        if ($directoryOrder -contains $dir.Name) {
            ##### Highlight specifically ordered directories
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor Cyan
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        elseif ($dir.Name -eq "wp-content") {
            ##### Format wp-content
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor Cyan
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        elseif ($dir.Name -eq "_Archives") {
            ##### Format _Archives
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor Cyan
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        elseif ($dir.Name -like "backup_*") {
            ##### Format backup directories
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor Yellow
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        elseif ($dir.Name -match "^U[1-7]-") {
            ##### Format UcF directories
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor Green
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        else {
            ##### Format other directories
            Write-Host "  [" -NoNewline -ForegroundColor Gray
            Write-Host "$($dir.Name)" -NoNewline -ForegroundColor White
            Write-Host "]" -NoNewline -ForegroundColor Gray
        }
        
        Write-Host " ($formattedSize)" -ForegroundColor DarkGray
    }
    
    ##### Display files if requested
    if ($IncludeFiles) {
        Write-Host "`nFILES:" -ForegroundColor Magenta
        foreach ($file in ($files | Sort-Object Name)) {
            $formattedSize = Format-FileSize -Size $file.Length
            
            if ($file.Name -eq "memory.md" -or $file.Name -eq "changelog.md") {
                ##### Highlight key files
                Write-Host "  [" -NoNewline -ForegroundColor Gray
                Write-Host "$($file.Name)" -NoNewline -ForegroundColor Magenta
                Write-Host "]" -NoNewline -ForegroundColor Gray
            }
            else {
                Write-Host "  [" -NoNewline -ForegroundColor Gray
                Write-Host "$($file.Name)" -NoNewline -ForegroundColor White
                Write-Host "]" -NoNewline -ForegroundColor Gray
            }
            
            Write-Host " ($formattedSize)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "`n"
}

function Get-DirectorySize {
    param (
        [string]$Directory
    )
    
    $size = 0
    Get-ChildItem -Path $Directory -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $size += $_.Length }
    return $size
}

function Format-FileSize {
    param (
        [long]$Size
    )
    
    if ($Size -ge 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    }
    elseif ($Size -ge 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    }
    elseif ($Size -ge 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    }
    else {
        return "$Size bytes"
    }
}

function Create-DesktopShortcuts {
    param (
        [string]$RootPath = ".",
        [switch]$OpenInExplorer
    )
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutsFolder = Join-Path -Path $desktopPath -ChildPath "cFish.io Shortcuts"
    
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
            Create-Shortcut -TargetPath $matchingItem.FullName -ShortcutPath $shortcutPath
            $index++
        }
    }
    
    ##### Add UcF directories
    $ucfDirs = $rootItems | Where-Object { $_.Name -match "^U[1-7]-" -and $_.PSIsContainer } | Sort-Object Name
    foreach ($dir in $ucfDirs) {
        $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_$($dir.Name).lnk"
        Create-Shortcut -TargetPath $dir.FullName -ShortcutPath $shortcutPath
        $index++
    }
    
    ##### Add wp-content
    $wpContent = $rootItems | Where-Object { $_.Name -eq "wp-content" -and $_.PSIsContainer }
    if ($wpContent) {
        $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_wp-content.lnk"
        Create-Shortcut -TargetPath $wpContent.FullName -ShortcutPath $shortcutPath
        $index++
    }
    
    ##### Add _Archives
    $archives = $rootItems | Where-Object { $_.Name -eq "_Archives" -and $_.PSIsContainer }
    if ($archives) {
        $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}__Archives.lnk"
        Create-Shortcut -TargetPath $archives.FullName -ShortcutPath $shortcutPath
        $index++
    }
    
    ##### Add backup directories
    $backupDirs = $rootItems | Where-Object { $_.Name -like "backup_*" -and $_.PSIsContainer } | Sort-Object Name
    foreach ($dir in $backupDirs) {
        $shortcutPath = Join-Path -Path $shortcutsFolder -ChildPath "${index}_$($dir.Name).lnk"
        Create-Shortcut -TargetPath $dir.FullName -ShortcutPath $shortcutPath
        $index++
    }
    
    ##### Open the shortcuts folder in Explorer if requested
    if ($OpenInExplorer) {
        Start-Process "explorer.exe" -ArgumentList $shortcutsFolder
    }
    
    Write-Host "Created shortcuts in $shortcutsFolder in the desired order" -ForegroundColor Green
}

function Create-Shortcut {
    param (
        [string]$TargetPath,
        [string]$ShortcutPath
    )
    
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Save()
}

##### Show help information
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "CFISH.IO DIRECTORY VISUAL ORGANIZATION TOOL" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "This script provides several ways to visualize and navigate"
Write-Host "your cFish.io directory structure in your preferred order."
Write-Host
Write-Host "PREFERRED ORDER:" -ForegroundColor Yellow
Write-Host "1. .cursor" -ForegroundColor Green
Write-Host "2. _Resources" -ForegroundColor Green
Write-Host "3. docs and Documentation" -ForegroundColor Green
Write-Host "4. U1-U7 directories" -ForegroundColor Green
Write-Host "5. wp-content" -ForegroundColor Green
Write-Host "6. _Archives" -ForegroundColor Green
Write-Host "7. backup directories" -ForegroundColor Green
Write-Host "8. All other directories" -ForegroundColor Green
Write-Host
Write-Host "AVAILABLE COMMANDS:" -ForegroundColor Yellow
Write-Host "1. Show-CustomDirectoryOrder" -ForegroundColor Green
Write-Host "   Displays directories in your preferred order with sizes"
Write-Host "   Example: Show-CustomDirectoryOrder -IncludeFiles"
Write-Host
Write-Host "2. Create-DesktopShortcuts" -ForegroundColor Green
Write-Host "   Creates Windows shortcuts on your desktop in preferred order"
Write-Host "   Example: Create-DesktopShortcuts -OpenInExplorer"
Write-Host
Write-Host "=======================================================" -ForegroundColor Cyan

##### Only export functions when the script is being imported as a module
if ($MyInvocation.Line -match "Import-Module") {
    Export-ModuleMember -Function Show-CustomDirectoryOrder, Create-DesktopShortcuts
} 
