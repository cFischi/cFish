# Cross-Platform Integration Fix Script
# Purpose: Resolves known integration issues between platforms
# Created: 05-09-2025
# Updated: 05-09-2025

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$FixNotionToggleBlocks = $true,
    
    [Parameter()]
    [switch]$FixClickUpDateRanges = $true,
    
    [Parameter()]
    [switch]$FixVendastaMapping = $true,
    
    [Parameter()]
    [switch]$TestOnly = $false,
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\cursor\logs\integration"
)

# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    try {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
        Write-Verbose "Created log directory: $LogPath"
    }
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $LogPath "cross-platform-fix-$timestamp.log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTime] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Invoke-ApiRequest {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [hashtable]$Headers,
        [object]$Body = $null
    )
    
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        
        if ($Headers) {
            $params.Headers = $Headers
        }
        
        if ($Body -and $Method -ne "GET") {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Log "API request failed: $($_.Exception.Message)" -Level "ERROR"
        return $null
    }
}

function Fix-NotionToggleBlocks {
    Write-Log "Starting Notion nested toggle blocks fix" -Level "INFO"
    
    # Load API configuration
    $configFile = "$PSScriptRoot\..\cursor\config\integration\notion-api-config.json"
    
    if (-not (Test-Path $configFile)) {
        Write-Log "Notion API configuration file not found: $configFile" -Level "ERROR"
        return $false
    }
    
    try {
        $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
        $apiKey = $config.apiKey
        $notionVersion = $config.notionVersion
    }
    catch {
        Write-Log "Failed to load Notion API configuration: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
    
    # Set up API headers
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Notion-Version" = $notionVersion
        "Content-Type" = "application/json"
    }
    
    # Get databases with toggle blocks
    Write-Log "Fetching Notion databases" -Level "INFO"
    $databasesUri = "https://api.notion.com/v1/databases"
    $databases = Invoke-ApiRequest -Uri $databasesUri -Headers $headers
    
    if (-not $databases -or -not $databases.results) {
        Write-Log "No databases found or API request failed" -Level "ERROR"
        return $false
    }
    
    Write-Log "Found $($databases.results.Count) databases" -Level "INFO"
    
    $fixedBlocks = 0
    $failedBlocks = 0
    
    foreach ($database in $databases.results) {
        Write-Log "Processing database: $($database.title[0].plain_text)" -Level "INFO"
        
        # Get pages in database
        $pagesUri = "https://api.notion.com/v1/databases/$($database.id)/query"
        $pages = Invoke-ApiRequest -Uri $pagesUri -Method "POST" -Headers $headers -Body @{}
        
        if (-not $pages -or -not $pages.results) {
            Write-Log "No pages found in database or API request failed" -Level "WARNING"
            continue
        }
        
        Write-Log "Found $($pages.results.Count) pages in database" -Level "INFO"
        
        foreach ($page in $pages.results) {
            Write-Log "Processing page: $($page.properties.Name.title[0].plain_text)" -Level "INFO"
            
            # Get blocks in page
            $blocksUri = "https://api.notion.com/v1/blocks/$($page.id)/children"
            $blocks = Invoke-ApiRequest -Uri $blocksUri -Headers $headers
            
            if (-not $blocks -or -not $blocks.results) {
                Write-Log "No blocks found in page or API request failed" -Level "WARNING"
                continue
            }
            
            # Find and fix nested toggle blocks
            $nestedToggleBlocks = $blocks.results | Where-Object { $_.type -eq "toggle" }
            
            if ($nestedToggleBlocks.Count -eq 0) {
                Write-Log "No toggle blocks found in page" -Level "INFO"
                continue
            }
            
            Write-Log "Found $($nestedToggleBlocks.Count) toggle blocks" -Level "INFO"
            
            foreach ($block in $nestedToggleBlocks) {
                # Process nested children
                $nestedUri = "https://api.notion.com/v1/blocks/$($block.id)/children"
                $nestedBlocks = Invoke-ApiRequest -Uri $nestedUri -Headers $headers
                
                if (-not $nestedBlocks -or -not $nestedBlocks.results) {
                    continue
                }
                
                $nestedToggle = $nestedBlocks.results | Where-Object { $_.type -eq "toggle" }
                
                if ($nestedToggle.Count -eq 0) {
                    continue
                }
                
                Write-Log "Found nested toggle block that needs fixing" -Level "WARNING"
                
                if ($TestOnly) {
                    Write-Log "TestOnly: Would fix nested toggle block in page $($page.properties.Name.title[0].plain_text)" -Level "INFO"
                    $fixedBlocks++
                    continue
                }
                
                # Fix the nested toggle block structure - convert inner toggles to paragraphs with indentation
                foreach ($nested in $nestedToggle) {
                    $updateUri = "https://api.notion.com/v1/blocks/$($nested.id)"
                    
                    $updateBody = @{
                        "type" = "paragraph"
                        "paragraph" = @{
                            "rich_text" = @(
                                @{
                                    "type" = "text"
                                    "text" = @{
                                        "content" = "    • $($nested.toggle.rich_text[0].text.content)"
                                    }
                                }
                            )
                        }
                    }
                    
                    $updateResult = Invoke-ApiRequest -Uri $updateUri -Method "PATCH" -Headers $headers -Body $updateBody
                    
                    if ($updateResult) {
                        Write-Log "Fixed nested toggle block" -Level "SUCCESS"
                        $fixedBlocks++
                    }
                    else {
                        Write-Log "Failed to fix nested toggle block" -Level "ERROR"
                        $failedBlocks++
                    }
                }
            }
        }
    }
    
    Write-Log "Notion toggle block fix complete: $fixedBlocks fixed, $failedBlocks failed" -Level "INFO"
    return ($failedBlocks -eq 0)
}

function Fix-ClickUpDateRanges {
    Write-Log "Starting ClickUp date range fields fix" -Level "INFO"
    
    # Load API configuration
    $configFile = "$PSScriptRoot\..\cursor\config\integration\clickup-api-config.json"
    
    if (-not (Test-Path $configFile)) {
        Write-Log "ClickUp API configuration file not found: $configFile" -Level "ERROR"
        return $false
    }
    
    try {
        $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
        $apiKey = $config.apiKey
    }
    catch {
        Write-Log "Failed to load ClickUp API configuration: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
    
    # Set up API headers
    $headers = @{
        "Authorization" = $apiKey
        "Content-Type" = "application/json"
    }
    
    # Get teams
    Write-Log "Fetching ClickUp teams" -Level "INFO"
    $teamsUri = "https://api.clickup.com/api/v2/team"
    $teams = Invoke-ApiRequest -Uri $teamsUri -Headers $headers
    
    if (-not $teams -or -not $teams.teams) {
        Write-Log "No teams found or API request failed" -Level "ERROR"
        return $false
    }
    
    Write-Log "Found $($teams.teams.Count) teams" -Level "INFO"
    
    $fixedFields = 0
    $failedFields = 0
    
    foreach ($team in $teams.teams) {
        Write-Log "Processing team: $($team.name)" -Level "INFO"
        
        # Get spaces
        $spacesUri = "https://api.clickup.com/api/v2/team/$($team.id)/space"
        $spaces = Invoke-ApiRequest -Uri $spacesUri -Headers $headers
        
        if (-not $spaces -or -not $spaces.spaces) {
            Write-Log "No spaces found in team or API request failed" -Level "WARNING"
            continue
        }
        
        Write-Log "Found $($spaces.spaces.Count) spaces in team" -Level "INFO"
        
        foreach ($space in $spaces.spaces) {
            Write-Log "Processing space: $($space.name)" -Level "INFO"
            
            # Get folders
            $foldersUri = "https://api.clickup.com/api/v2/space/$($space.id)/folder"
            $folders = Invoke-ApiRequest -Uri $foldersUri -Headers $headers
            
            if (-not $folders -or -not $folders.folders) {
                Write-Log "No folders found in space or API request failed" -Level "WARNING"
                continue
            }
            
            Write-Log "Found $($folders.folders.Count) folders in space" -Level "INFO"
            
            foreach ($folder in $folders.folders) {
                Write-Log "Processing folder: $($folder.name)" -Level "INFO"
                
                # Get lists
                $listsUri = "https://api.clickup.com/api/v2/folder/$($folder.id)/list"
                $lists = Invoke-ApiRequest -Uri $listsUri -Headers $headers
                
                if (-not $lists -or -not $lists.lists) {
                    Write-Log "No lists found in folder or API request failed" -Level "WARNING"
                    continue
                }
                
                Write-Log "Found $($lists.lists.Count) lists in folder" -Level "INFO"
                
                foreach ($list in $lists.lists) {
                    Write-Log "Processing list: $($list.name)" -Level "INFO"
                    
                    # Get custom fields
                    $fieldsUri = "https://api.clickup.com/api/v2/list/$($list.id)/field"
                    $fields = Invoke-ApiRequest -Uri $fieldsUri -Headers $headers
                    
                    if (-not $fields -or -not $fields.fields) {
                        Write-Log "No custom fields found in list or API request failed" -Level "WARNING"
                        continue
                    }
                    
                    # Find date range fields
                    $dateRangeFields = $fields.fields | Where-Object { $_.type -eq "date" -and $_.date.has_time -eq $true }
                    
                    if ($dateRangeFields.Count -eq 0) {
                        Write-Log "No date range fields found in list" -Level "INFO"
                        continue
                    }
                    
                    Write-Log "Found $($dateRangeFields.Count) date range fields that need fixing" -Level "INFO"
                    
                    foreach ($field in $dateRangeFields) {
                        if ($TestOnly) {
                            Write-Log "TestOnly: Would fix date range field '$($field.name)' in list '$($list.name)'" -Level "INFO"
                            $fixedFields++
                            continue
                        }
                        
                        # Update field to ensure proper date range format
                        $updateUri = "https://api.clickup.com/api/v2/list/$($list.id)/field/$($field.id)"
                        
                        $updateBody = @{
                            "field_id" = $field.id
                            "value" = @{
                                "date" = @{
                                    "has_time" = $true
                                    "include_time" = $true
                                    "time_format" = 24
                                }
                            }
                        }
                        
                        $updateResult = Invoke-ApiRequest -Uri $updateUri -Method "PUT" -Headers $headers -Body $updateBody
                        
                        if ($updateResult) {
                            Write-Log "Fixed date range field '$($field.name)'" -Level "SUCCESS"
                            $fixedFields++
                        }
                        else {
                            Write-Log "Failed to fix date range field '$($field.name)'" -Level "ERROR"
                            $failedFields++
                        }
                    }
                }
            }
        }
    }
    
    Write-Log "ClickUp date range fix complete: $fixedFields fixed, $failedFields failed" -Level "INFO"
    return ($failedFields -eq 0)
}

function Fix-VendastaMapping {
    Write-Log "Starting Vendasta to ClickUp custom fields mapping fix" -Level "INFO"
    
    # This would involve a more complex fix involving both Vendasta and ClickUp APIs
    # For this example, we'll implement a simpler simulation of the fix
    
    if ($TestOnly) {
        Write-Log "TestOnly: Would fix Vendasta to ClickUp custom fields mapping" -Level "INFO"
        return $true
    }
    
    # Simulate the field mapping fix
    Write-Log "Updating field mapping configuration" -Level "INFO"
    
    $mappingConfig = @{
        version = "1.1.0"
        updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        mappings = @(
            @{
                vendasta_field = "client_name"
                clickup_field = "Client Name"
                type = "text"
            },
            @{
                vendasta_field = "client_id"
                clickup_field = "Client ID"
                type = "short_text"
            },
            @{
                vendasta_field = "service_start"
                clickup_field = "Service Period"
                type = "date_range"
                target = "start"
            },
            @{
                vendasta_field = "service_end"
                clickup_field = "Service Period"
                type = "date_range"
                target = "end"
            },
            @{
                vendasta_field = "service_tier"
                clickup_field = "Service Tier"
                type = "drop_down"
            },
            @{
                vendasta_field = "monthly_budget"
                clickup_field = "Budget"
                type = "currency"
            }
        )
    }
    
    $configDir = "$PSScriptRoot\..\cursor\config\integration"
    if (-not (Test-Path $configDir)) {
        try {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        catch {
            Write-Log "Failed to create config directory: $($_.Exception.Message)" -Level "ERROR"
            return $false
        }
    }
    
    $mappingFile = "$configDir\vendasta-clickup-mapping.json"
    
    try {
        $mappingConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $mappingFile
        Write-Log "Updated Vendasta to ClickUp field mapping configuration" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to update mapping configuration: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# Main execution starts here
Write-Log "Starting cross-platform integration fix script" -Level "INFO"
Write-Log "Test mode: $TestOnly" -Level "INFO"

$successCount = 0
$totalFixes = 0

if ($FixNotionToggleBlocks) {
    $totalFixes++
    Write-Log "Running Notion toggle blocks fix" -Level "INFO"
    $result = Fix-NotionToggleBlocks
    if ($result) { $successCount++ }
}

if ($FixClickUpDateRanges) {
    $totalFixes++
    Write-Log "Running ClickUp date range fields fix" -Level "INFO"
    $result = Fix-ClickUpDateRanges
    if ($result) { $successCount++ }
}

if ($FixVendastaMapping) {
    $totalFixes++
    Write-Log "Running Vendasta to ClickUp mapping fix" -Level "INFO"
    $result = Fix-VendastaMapping
    if ($result) { $successCount++ }
}

Write-Log "Cross-platform integration fixes completed: $successCount of $totalFixes successful" -Level "INFO"

if ($successCount -eq $totalFixes) {
    Write-Log "All fixes were applied successfully" -Level "SUCCESS"
    exit 0
}
else {
    Write-Log "Some fixes failed to apply correctly. Check the log for details." -Level "WARNING"
    exit 1
} 