# PowerShell script to set up MD-JSON Sync to run when Cursor is launched
# Run this script as Administrator

# Get the current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$workingDir = (Get-Item -Path $scriptPath).FullName

# Create the task name
$taskName = "MD-JSON-Sync-Cursor-Integration"

##### Get the path to the batch file
$batchPath = Join-Path -Path $workingDir -ChildPath "start-enhanced-sync.bat"

##### Create the task action
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$batchPath`"" -WorkingDirectory $workingDir

##### Trigger when Cursor is launched (based on process start)
$triggerProcess = New-ScheduledTaskTrigger -AtLogOn

##### Task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -RunOnlyIfNetworkAvailable

##### Create the task
$principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Highest

##### Register the task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggerProcess -Settings $settings -Principal $principal -Force

Write-Host "MD-JSON Sync System has been configured to start when Cursor is launched."
Write-Host "You can run the sync system manually by executing start-enhanced-sync.bat" 
