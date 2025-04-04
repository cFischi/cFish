# library-organizer.ps1
# .cursor Library Organization System
# Purpose: Creates a modular structure for the .cursor library with minimal cross-dependencies
# Created: 05-07-2025

[CmdletBinding()]
param(
    [Parameter()]
    [string]$CursorRoot = (Resolve-Path "$PSScriptRoot\.."),
    
    [Parameter()]
    [switch]$CreateBackup = $true,
    
    [Parameter()]
    [switch]$DryRun = $false,
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\logs\library-organizer.log"
)

# Ensure log directory exists
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created log directory: $logDir"
    } 
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

# Helper Functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry
        
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
    catch {
        Write-Error "Failed to write to log: $($_.Exception.Message)"
    }
}

function Backup-CursorLibrary {
    param(
        [string]$BackupPath = "$CursorRoot\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    )
    
    try {
        if ($DryRun) {
            Write-Log "DRY RUN: Would create backup at $BackupPath" "INFO"
            return @{
                Success = $true
                Path = "DRY RUN"
            }
        }
        
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
        }
        
        Write-Log "Creating backup of .cursor library..." "INFO"
        
        # Copy files rather than moving to preserve originals
        Get-ChildItem -Path $CursorRoot -Exclude "backup-*" | Copy-Item -Destination $BackupPath -Recurse -Force
        
        Write-Log "Backup created successfully at $BackupPath" "SUCCESS"
        
        return @{
            Success = $true
            Path = $BackupPath
        }
    }
    catch {
        Write-Log "Failed to create backup: $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Get-LibraryStructure {
    try {
        $structure = @{
            Core = @{
                Path = "core"
                Description = "Core functionality files with minimal dependencies"
                Files = @()
            }
            Scripts = @{
                Path = "scripts"
                Description = "Utility scripts and tools"
                Files = @()
            }
            Modules = @{
                Path = "modules"
                Description = "Modular components with clear boundaries"
                Files = @()
            }
            Config = @{
                Path = "config"
                Description = "Configuration files and settings"
                Files = @()
            }
            Docs = @{
                Path = "docs"
                Description = "Documentation and references"
                Files = @()
            }
            Logs = @{
                Path = "logs"
                Description = "Log files and audit trails"
                Files = @()
            }
            Recovery = @{
                Path = "recovery"
                Description = "Recovery points and backups"
                Files = @()
            }
            Tests = @{
                Path = "tests"
                Description = "Test scripts and validation tools"
                Files = @()
            }
        }
        
        # Define file patterns for categorization
        $filePatterns = @{
            Core = @("*.json", "package.json", "tsconfig.json", "*.config.js")
            Scripts = @("*.ps1", "*.sh", "*.bat", "*.cmd")
            Modules = @("*.js", "*.ts", "*.jsx", "*.tsx", "*.module.css")
            Config = @("*.config.*", "*.settings.*", "*.ini", "*.env")
            Docs = @("*.md", "*.txt", "*.pdf", "*.docx")
            Logs = @("*.log", "log-*.*", "*-log.*")
            Recovery = @("backup-*.*", "*.bak", "*.backup")
            Tests = @("*.test.*", "*.spec.*", "*-test.*", "*-spec.*")
        }
        
        return @{
            Structure = $structure
            Patterns = $filePatterns
        }
    }
    catch {
        Write-Log "Failed to generate library structure: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Categorize-Files {
    param(
        [string]$Path = $CursorRoot,
        [hashtable]$Patterns
    )
    
    try {
        $files = Get-ChildItem -Path $Path -Recurse -File
        $categorized = @{}
        $uncategorized = @()
        
        foreach ($category in $Patterns.Keys) {
            $categorized[$category] = @()
            
            foreach ($pattern in $Patterns[$category]) {
                $matchingFiles = $files | Where-Object { $_.Name -like $pattern -or $_.FullName -like "*\$pattern" }
                $categorized[$category] += $matchingFiles
            }
        }
        
        # Find uncategorized files
        $allCategorized = @()
        foreach ($category in $categorized.Keys) {
            $allCategorized += $categorized[$category]
        }
        
        $uncategorized = $files | Where-Object { $allCategorized -notcontains $_ }
        
        return @{
            Categorized = $categorized
            Uncategorized = $uncategorized
        }
    }
    catch {
        Write-Log "Failed to categorize files: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Create-LibraryStructure {
    param(
        [hashtable]$Structure,
        [hashtable]$CategorizedFiles
    )
    
    try {
        if ($DryRun) {
            Write-Log "DRY RUN: Library structure creation simulation" "INFO"
            
            foreach ($category in $Structure.Keys) {
                $categoryPath = Join-Path -Path $CursorRoot -ChildPath $Structure[$category].Path
                Write-Log "DRY RUN: Would create directory: $categoryPath" "INFO"
                
                $files = $CategorizedFiles.Categorized[$category]
                if ($files.Count -gt 0) {
                    Write-Log "DRY RUN: Would move $($files.Count) files to $categoryPath" "INFO"
                }
            }
            
            if ($CategorizedFiles.Uncategorized.Count -gt 0) {
                Write-Log "DRY RUN: $($CategorizedFiles.Uncategorized.Count) files would remain uncategorized" "WARNING"
            }
            
            return @{
                Success = $true
                Message = "Dry run completed successfully"
            }
        }
        
        # Create the structure
        foreach ($category in $Structure.Keys) {
            $categoryPath = Join-Path -Path $CursorRoot -ChildPath $Structure[$category].Path
            
            if (-not (Test-Path $categoryPath)) {
                New-Item -Path $categoryPath -ItemType Directory -Force | Out-Null
                Write-Log "Created directory: $categoryPath" "SUCCESS"
            }
            else {
                Write-Log "Directory already exists: $categoryPath" "INFO"
            }
            
            # Create a .info file to document the directory purpose
            $infoPath = Join-Path -Path $categoryPath -ChildPath ".info"
            @"
Category: $category
Description: $($Structure[$category].Description)
Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@ | Out-File -FilePath $infoPath -Encoding utf8
            
            # Move files to their respective categories
            $files = $CategorizedFiles.Categorized[$category]
            foreach ($file in $files) {
                $destinationPath = Join-Path -Path $categoryPath -ChildPath $file.Name
                
                # Skip if file already in correct location
                if ($file.Directory.FullName -eq $categoryPath) {
                    continue
                }
                
                # Handle file name conflicts
                if (Test-Path $destinationPath) {
                    $newName = "{0}_{1}{2}" -f $file.BaseName, (Get-Date -Format "yyyyMMddHHmmss"), $file.Extension
                    $destinationPath = Join-Path -Path $categoryPath -ChildPath $newName
                    Write-Log "File name conflict, renaming to $newName" "WARNING"
                }
                
                # Copy instead of move to avoid breaking dependencies
                Copy-Item -Path $file.FullName -Destination $destinationPath -Force
                Write-Log "Copied file: $($file.Name) to $categoryPath" "INFO"
            }
        }
        
        # Create manifest of uncategorized files
        if ($CategorizedFiles.Uncategorized.Count -gt 0) {
            $manifestPath = Join-Path -Path $CursorRoot -ChildPath "uncategorized-files.txt"
            "# Uncategorized Files" | Out-File -FilePath $manifestPath -Encoding utf8
            "# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $manifestPath -Encoding utf8 -Append
            "" | Out-File -FilePath $manifestPath -Encoding utf8 -Append
            
            foreach ($file in $CategorizedFiles.Uncategorized) {
                $relativePath = $file.FullName.Replace($CursorRoot, "").TrimStart("\")
                $relativePath | Out-File -FilePath $manifestPath -Encoding utf8 -Append
            }
            
            Write-Log "Created manifest of uncategorized files: $manifestPath" "WARNING"
            Write-Log "$($CategorizedFiles.Uncategorized.Count) files remain uncategorized" "WARNING"
        }
        
        return @{
            Success = $true
            Message = "Library structure created successfully"
        }
    }
    catch {
        Write-Log "Failed to create library structure: $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Create-DependencyManifest {
    param(
        [hashtable]$Structure
    )
    
    try {
        $manifestPath = Join-Path -Path $CursorRoot -ChildPath "dependency-manifest.json"
        
        $manifest = @{
            generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            structure = @{}
            dependencies = @{}
        }
        
        foreach ($category in $Structure.Keys) {
            $categoryPath = Join-Path -Path $CursorRoot -ChildPath $Structure[$category].Path
            
            $manifest.structure[$category] = @{
                path = $Structure[$category].Path
                description = $Structure[$category].Description
            }
            
            # Search for package.json files to identify dependencies
            $packageFiles = Get-ChildItem -Path $categoryPath -Filter "package.json" -Recurse -ErrorAction SilentlyContinue
            foreach ($packageFile in $packageFiles) {
                try {
                    $packageJson = Get-Content -Path $packageFile.FullName -Raw | ConvertFrom-Json
                    
                    if ($packageJson.dependencies -or $packageJson.devDependencies) {
                        $relativePath = $packageFile.FullName.Replace($CursorRoot, "").TrimStart("\")
                        $manifest.dependencies[$relativePath] = @{
                            dependencies = if ($packageJson.dependencies) { $packageJson.dependencies } else { @{} }
                            devDependencies = if ($packageJson.devDependencies) { $packageJson.devDependencies } else { @{} }
                        }
                    }
                }
                catch {
                    Write-Log "Error parsing $($packageFile.FullName): $($_.Exception.Message)" "WARNING"
                }
            }
        }
        
        if ($DryRun) {
            Write-Log "DRY RUN: Would create dependency manifest at $manifestPath" "INFO"
        }
        else {
            $manifest | ConvertTo-Json -Depth 10 | Out-File -FilePath $manifestPath -Encoding utf8
            Write-Log "Created dependency manifest: $manifestPath" "SUCCESS"
        }
        
        return @{
            Success = $true
            Path = $manifestPath
        }
    }
    catch {
        Write-Log "Failed to create dependency manifest: $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Main execution
try {
    Write-Log "===== Library Organizer Started =====" "INFO"
    Write-Log "Cursor Root: $CursorRoot" "INFO"
    Write-Log "Create Backup: $CreateBackup" "INFO"
    Write-Log "Dry Run: $DryRun" "INFO"
    
    # Create backup if requested
    if ($CreateBackup) {
        $backupResult = Backup-CursorLibrary
        if (-not $backupResult.Success) {
            Write-Log "Failed to create backup, aborting" "ERROR"
            exit 1
        }
    }
    
    # Get library structure definition
    $libraryStructure = Get-LibraryStructure
    if ($null -eq $libraryStructure) {
        Write-Log "Failed to generate library structure, aborting" "ERROR"
        exit 1
    }
    
    # Categorize files
    Write-Log "Categorizing files..." "INFO"
    $categorizedFiles = Categorize-Files -Path $CursorRoot -Patterns $libraryStructure.Patterns
    if ($null -eq $categorizedFiles) {
        Write-Log "Failed to categorize files, aborting" "ERROR"
        exit 1
    }
    
    # Generate file statistics
    $totalFiles = 0
    $categorizedCount = 0
    
    foreach ($category in $categorizedFiles.Categorized.Keys) {
        $count = $categorizedFiles.Categorized[$category].Count
        $categorizedCount += $count
        Write-Log "Category '$category': $count files" "INFO"
    }
    
    $uncategorizedCount = $categorizedFiles.Uncategorized.Count
    $totalFiles = $categorizedCount + $uncategorizedCount
    
    Write-Log "File categorization summary:" "INFO"
    Write-Log "Total files: $totalFiles" "INFO"
    Write-Log "Categorized: $categorizedCount" "INFO"
    Write-Log "Uncategorized: $uncategorizedCount" "INFO"
    Write-Log "Categorization rate: $([math]::Round(($categorizedCount / $totalFiles) * 100, 2))%" "INFO"
    
    # Create library structure
    Write-Log "Creating library structure..." "INFO"
    $structureResult = Create-LibraryStructure -Structure $libraryStructure.Structure -CategorizedFiles $categorizedFiles
    
    if (-not $structureResult.Success) {
        Write-Log "Failed to create library structure: $($structureResult.Error)" "ERROR"
        exit 1
    }
    
    # Create dependency manifest
    Write-Log "Creating dependency manifest..." "INFO"
    $manifestResult = Create-DependencyManifest -Structure $libraryStructure.Structure
    
    if (-not $manifestResult.Success) {
        Write-Log "Failed to create dependency manifest: $($manifestResult.Error)" "WARNING"
    }
    
    Write-Log "===== Library Organizer Completed =====" "SUCCESS"
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
} 