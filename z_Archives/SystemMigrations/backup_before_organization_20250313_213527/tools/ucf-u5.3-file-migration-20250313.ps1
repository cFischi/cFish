# ucf-u5.3-file-migration-20250313.ps1
# This script migrates files to the standardized directory structure
# Following UcFish digital organization standards
# Department: U5 - Data Management
# Function: 3 - Data Migration

#-----------------------------------------------
# Configuration
#-----------------------------------------------
$CONFIG = @{
    LogFile = "logs/migration-$(Get-Date -Format 'yyyyMMdd').log"
    Simulated = $false ##### Set to $true to simulate without making changes
    CreateBackup = $true ##### Set to $true to create a backup before migration
}

#-----------------------------------------------
##### Initialize
#-----------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ErrorActionPreference = "Stop"
$successCount = 0
$errorCount = 0

##### Create log directory if it doesn't exist
$logDir = Split-Path -Parent $CONFIG.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

#-----------------------------------------------
##### Helper Functions
#-----------------------------------------------
function Write-MigrationLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { 
            Write-Host $logMessage -ForegroundColor Gray
        }
        "WARNING" { 
            Write-Host $logMessage -ForegroundColor Yellow
        }
        "ERROR" { 
            Write-Host $logMessage -ForegroundColor Red
            ${script}:errorCount++
        }
        "SUCCESS" {
            Write-Host $logMessage -ForegroundColor Green
            ${script}:successCount++
        }
    }
    
    Add-Content -Path $CONFIG.LogFile -Value $logMessage
}

function Backup-BeforeMigration {
    if ($CONFIG.CreateBackup) {
        Write-MigrationLog "Creating backup before migration..." -Level "INFO"
        try {
            ##### Run the backup script
            & ".\tools\daily-backup.ps1"
            Write-MigrationLog "Backup completed successfully" -Level "SUCCESS"
            return $true
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-MigrationLog "Failed to create backup - $errorMessage" -Level "ERROR"
            return $false
        }
    }
    return $true
}

function Move-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    try {
        ##### Create destination directory if it doesn't exist
        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            if (-not $CONFIG.Simulated) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Write-MigrationLog "Created directory: $destDir" -Level "INFO"
        }
        
        if ($CONFIG.Simulated) {
            Write-MigrationLog "SIMULATION: Would migrate: $Source -> $Destination" -Level "INFO"
            return $true
        }
        else {
            ##### Copy file to new location - use Copy instead of Move for safety
            Copy-Item -Path $Source -Destination $Destination -Force
            
            ##### Verify copy was successful
            if (Test-Path $Destination) {
                Write-MigrationLog "Successfully migrated: $Source -> $Destination" -Level "SUCCESS"
                return $true
            }
            else {
                Write-MigrationLog "Failed to migrate file" -Level "ERROR"
                return $false
            }
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-MigrationLog "Error migrating file - $errorMessage" -Level "ERROR"
        return $false
    }
}

#-----------------------------------------------
##### Migration Definitions
#-----------------------------------------------
##### Define the migrations to perform
##### Format: @{Source = "source/path"; Destination = "target/path"; Description = "Description"}
$migrations = @(
    ##### Examples - replace with actual migrations
    @{
        Source = "sync-system/tydisync-debug.log"
        Destination = "logs/sync-system/tyf-u5.1-tydisync-debug-20250313.log"
        Description = "Sync system debug log"
    },
    @{
        Source = "tydisync-powershell-cross-platform-summary.md"
        Destination = "docs/procedures/tyf-u2.4-powershell-cross-platform-summary-20250313.md"
        Description = "PowerShell cross-platform documentation"
    },
    @{
        Source = "start-assessment-phase.bat"
        Destination = "tools/ucf-u5.4-start-assessment-phase-20250313.bat"
        Description = "Assessment phase startup script"
    }
    ##### Add more migrations as needed
)

#-----------------------------------------------
##### Main Migration Process
#-----------------------------------------------
try {
    Write-MigrationLog "===== cFish.io File Migration - $timestamp =====" -Level "INFO"
    
    ##### Create backup if configured
    $backupSuccess = Backup-BeforeMigration
    if (-not $backupSuccess -and $CONFIG.CreateBackup) {
        Write-MigrationLog "Backup failed. Migration aborted for safety." -Level "ERROR"
        exit 1
    }
    
    ##### Mode notification
    if ($CONFIG.Simulated) {
        Write-MigrationLog "RUNNING IN SIMULATION MODE - No changes will be made" -Level "WARNING"
    }
    
    ##### Execute migrations
    $totalMigrations = $migrations.Count
    Write-MigrationLog "Starting migration of $totalMigrations files..." -Level "INFO"
    
    foreach ($migration in $migrations) {
        $source = $migration.Source
        $destination = $migration.Destination
        $description = $migration.Description
        
        Write-MigrationLog "Migrating: $description ($source)" -Level "INFO"
        
        ##### Check if source exists
        if (-not (Test-Path $source)) {
            Write-MigrationLog "Source file not found: $source" -Level "ERROR"
            continue
        }
        
        ##### Check if destination already exists
        if ((Test-Path $destination) -and -not $CONFIG.Simulated) {
            Write-MigrationLog "Destination already exists, will be overwritten: $destination" -Level "WARNING"
        }
        
        ##### Move the file
        Move-File -Source $source -Destination $destination
    }
    
    ##### Migration complete - summary
    Write-MigrationLog "===== Migration Complete: $successCount successful, $errorCount errors =====" -Level "INFO"
    
    ##### Run health check if not in simulation mode
    if (-not $CONFIG.Simulated) {
        Write-MigrationLog "Running health check..." -Level "INFO"
        & ".\tools\daily-health-check.ps1"
    }
    
    if ($errorCount -gt 0) {
        exit 1
    }
    else {
        exit 0
    }
}
catch {
    $errorMessage = $_.Exception.Message
    Write-MigrationLog "Critical error during migration process - $errorMessage" -Level "ERROR"
    exit 1
} 
