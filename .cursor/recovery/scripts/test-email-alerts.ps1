# Email Alert Test Script
# Purpose: Validates email configuration and sends test alerts
# Created: 05-09-2025
# Updated: 05-09-2025

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = "$PSScriptRoot\..\cursor\config\monitoring",
    
    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\..\cursor\logs\monitoring\email",
    
    [Parameter()]
    [switch]$TestAllLevels = $false,
    
    [Parameter()]
    [ValidateSet("WARNING", "CRITICAL", "EMERGENCY")]
    [string]$AlertLevel = "WARNING"
)

# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    try {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
        Write-Host "Created log directory: $LogPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create log directory: $($_.Exception.Message)"
        exit 1
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $LogPath "email-test-$timestamp.log"

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

function Test-SmtpConnection {
    param(
        [string]$SmtpServer,
        [int]$SmtpPort
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($SmtpServer, $SmtpPort)
        
        if ($tcpClient.Connected) {
            $tcpClient.Close()
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        Write-Log "Failed to connect to SMTP server: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Send-TestEmail {
    param(
        [string]$AlertLevel,
        [hashtable]$EmailConfig,
        [hashtable]$SampleMetrics
    )
    
    # Prepare email subject and body based on alert level
    $subject = "[$AlertLevel] TEST ALERT - $($env:COMPUTERNAME) - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    
    $body = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .alert { margin-bottom: 15px; padding: 10px; border-radius: 5px; }
        .WARNING { background-color: #fff3cd; border: 1px solid #ffeeba; }
        .CRITICAL { background-color: #f8d7da; border: 1px solid #f5c6cb; }
        .EMERGENCY { background-color: #d9534f; border: 1px solid #d43f3a; color: white; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>TEST ALERT: $($env:COMPUTERNAME)</h2>
    <p><strong>This is a TEST alert message. No action is required.</strong></p>
    
    <div class="alerts">
        <div class="alert $AlertLevel">
            <strong>[$AlertLevel] Memory:</strong> Test alert for email verification<br>
            <small>This is a test of the email alert system for the $AlertLevel level.</small>
        </div>
    </div>
    
    <h3>System Metrics (Sample)</h3>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>Memory Utilization</td><td>$($SampleMetrics.Memory.UtilizationPercent)%</td></tr>
        <tr><td>Memory Used/Total</td><td>$($SampleMetrics.Memory.UsedGB)GB / $($SampleMetrics.Memory.TotalGB)GB</td></tr>
        <tr><td>Process Count</td><td>$($SampleMetrics.Processes.Total)</td></tr>
        <tr><td>Cursor Instances</td><td>$($SampleMetrics.Processes.CursorInstances)</td></tr>
        <tr><td>CPU Utilization</td><td>$($SampleMetrics.CPU.UtilizationPercent)%</td></tr>
    </table>
    
    <p>Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    <p>This is a test email from the UcF System Monitoring Service.</p>
</body>
</html>
"@

    # Send email
    try {
        $smtpServer = $EmailConfig.SmtpServer
        $smtpPort = $EmailConfig.SmtpPort
        $fromAddress = $EmailConfig.FromAddress
        $recipients = $EmailConfig.Recipients -join ","
        
        $emailParams = @{
            From = $fromAddress
            To = $recipients
            Subject = $subject
            Body = $body
            BodyAsHtml = $true
            SmtpServer = $smtpServer
            Port = $smtpPort
            UseSsl = $EmailConfig.UseTLS
            ErrorAction = "Stop"
        }
        
        # If credentials are provided in the config, use them
        if ($EmailConfig.Credentials -and $EmailConfig.Credentials.Username -and $EmailConfig.Credentials.Password) {
            $securePassword = ConvertTo-SecureString $EmailConfig.Credentials.Password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential($EmailConfig.Credentials.Username, $securePassword)
            $emailParams.Add("Credential", $credentials)
        }
        
        Send-MailMessage @emailParams
        
        Write-Log "Sent test email for $AlertLevel level to $recipients" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to send test email: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# Main execution starts here
Write-Log "Starting email alert test" -Level "INFO"

# Load configuration
$alertConfigFile = Join-Path $ConfigPath "alert-config.json"

if (-not (Test-Path $alertConfigFile)) {
    Write-Log "Alert configuration file not found: $alertConfigFile" -Level "ERROR"
    exit 1
}

try {
    $alertConfig = Get-Content -Path $alertConfigFile -Raw | ConvertFrom-Json
    Write-Log "Loaded alert configuration from $alertConfigFile" -Level "INFO"
}
catch {
    Write-Log "Failed to load alert configuration: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}

# Verify email configuration
if (-not $alertConfig.Channels.Email.Enabled) {
    Write-Log "Email alerts are disabled in configuration. Enable them to test." -Level "WARNING"
    exit 0
}

$emailConfig = @{
    SmtpServer = $alertConfig.Channels.Email.SmtpServer
    SmtpPort = $alertConfig.Channels.Email.SmtpPort
    FromAddress = $alertConfig.Channels.Email.FromAddress
    Recipients = $alertConfig.Channels.Email.Recipients
    UseTLS = $alertConfig.Channels.Email.UseTLS
}

if ($alertConfig.Channels.Email.Credentials) {
    $emailConfig.Credentials = @{
        Username = $alertConfig.Channels.Email.Credentials.Username
        Password = $alertConfig.Channels.Email.Credentials.Password
    }
}

# Test SMTP connection
Write-Log "Testing connection to SMTP server: $($emailConfig.SmtpServer):$($emailConfig.SmtpPort)" -Level "INFO"
if (-not (Test-SmtpConnection -SmtpServer $emailConfig.SmtpServer -SmtpPort $emailConfig.SmtpPort)) {
    Write-Log "Failed to connect to SMTP server. Email test aborted." -Level "ERROR"
    exit 1
}
else {
    Write-Log "Successfully connected to SMTP server" -Level "SUCCESS"
}

# Create sample metrics for testing
$sampleMetrics = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ComputerName = $env:COMPUTERNAME
    Memory = @{
        TotalGB = 8
        FreeGB = 2
        UsedGB = 6
        UtilizationPercent = 75
    }
    Processes = @{
        Total = 150
        CursorInstances = 2
        TotalCursorMemoryMB = 250
        HighMemoryProcesses = 5
    }
    CPU = @{
        UtilizationPercent = 45
    }
    Disk = @(
        @{
            DriveLetter = "C:"
            SizeGB = 500
            FreeGB = 150
            UsedPercent = 70
        }
    )
}

# Send test emails
$success = $true

if ($TestAllLevels) {
    Write-Log "Testing all alert levels" -Level "INFO"
    $levels = @("WARNING", "CRITICAL", "EMERGENCY")
    
    foreach ($level in $levels) {
        $result = Send-TestEmail -AlertLevel $level -EmailConfig $emailConfig -SampleMetrics $sampleMetrics
        if (-not $result) {
            $success = $false
        }
        # Slight delay between emails
        Start-Sleep -Seconds 2
    }
}
else {
    Write-Log "Testing $AlertLevel level alert" -Level "INFO"
    $success = Send-TestEmail -AlertLevel $AlertLevel -EmailConfig $emailConfig -SampleMetrics $sampleMetrics
}

# Report final status
if ($success) {
    Write-Log "Email alert test completed successfully" -Level "SUCCESS"
    exit 0
}
else {
    Write-Log "Email alert test completed with errors" -Level "ERROR"
    exit 1
} 