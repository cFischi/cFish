# System Optimization Script for Local AI
# File: ucf-u7.3-system-optimization-20250506.ps1
# Description: Optimizes system settings for running local AI models efficiently
# @package cFish.io
# @since 05-06-2025
# @author AI: Cursor (Claude 3.7 Sonnet)

# Enable strict typing
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Function to check GPU driver information
function Get-GPUDriverInfo {
    try {
        $gpuInfo = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" }
        if ($gpuInfo) {
            Write-Host "GPU Information:" -ForegroundColor Green
            Write-Host "  Name: $($gpuInfo.Name)" -ForegroundColor Cyan
            Write-Host "  Driver Version: $($gpuInfo.DriverVersion)" -ForegroundColor Cyan
            Write-Host "  Driver Date: $($gpuInfo.DriverDate)" -ForegroundColor Cyan
            Write-Host "  Video Processor: $($gpuInfo.VideoProcessor)" -ForegroundColor Cyan
            Write-Host "  Video Memory: $([math]::Round($gpuInfo.AdapterRAM / 1GB, 2)) GB" -ForegroundColor Cyan
            
            # Check NVIDIA website for latest drivers
            Write-Host "`nNOTE: Please check https://www.nvidia.com/Download/index.aspx for the latest drivers" -ForegroundColor Yellow
            Write-Host "      for your GPU: $($gpuInfo.Name)" -ForegroundColor Yellow
        } else {
            Write-Host "No NVIDIA GPU detected." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error getting GPU information: $_" -ForegroundColor Red
    }
}

# Function to check and recommend virtual memory settings
function Check-VirtualMemory {
    try {
        $pageFileInfo = Get-WmiObject Win32_PageFileUsage
        $currentSize = $pageFileInfo.AllocatedBaseSize
        $recommendedSize = 16384 # 16 GB in MB
        
        Write-Host "`nVirtual Memory (Page File) Information:" -ForegroundColor Green
        Write-Host "  Current Size: $currentSize MB" -ForegroundColor Cyan
        
        if ($currentSize -lt $recommendedSize) {
            Write-Host "  Recommended Size: $recommendedSize MB (16 GB)" -ForegroundColor Yellow
            Write-Host "`nThe current page file size is smaller than recommended." -ForegroundColor Red
            Write-Host "Please increase virtual memory using these steps:" -ForegroundColor Yellow
            Write-Host "  1. Open System Properties (Right-click on 'This PC' -> Properties -> Advanced system settings)" -ForegroundColor Yellow
            Write-Host "  2. Click on 'Settings' under 'Performance'" -ForegroundColor Yellow
            Write-Host "  3. Go to 'Advanced' tab -> 'Change' under 'Virtual memory'" -ForegroundColor Yellow
            Write-Host "  4. Uncheck 'Automatically manage paging file size for all drives'" -ForegroundColor Yellow
            Write-Host "  5. Select your system drive (usually C:)" -ForegroundColor Yellow
            Write-Host "  6. Select 'Custom size' and set both Initial and Maximum size to 16384 MB" -ForegroundColor Yellow
            Write-Host "  7. Click 'Set' then 'OK' on all dialogs" -ForegroundColor Yellow
            Write-Host "  8. Restart your computer when prompted" -ForegroundColor Yellow
        } else {
            Write-Host "  Virtual memory is adequately configured for AI workloads." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error checking virtual memory: $_" -ForegroundColor Red
    }
}

# Function to check and optimize power settings
function Check-PowerSettings {
    try {
        $activePlan = powercfg /getactivescheme
        
        Write-Host "`nPower Plan Settings:" -ForegroundColor Green
        Write-Host "  $activePlan" -ForegroundColor Cyan
        
        if ($activePlan -match "High performance") {
            Write-Host "  Power plan is already set to High Performance. Optimal for AI workloads." -ForegroundColor Green
        } else {
            Write-Host "  For optimal AI performance, consider changing to High Performance power plan." -ForegroundColor Yellow
            Write-Host "  Run 'powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' as Administrator to switch." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error checking power settings: $_" -ForegroundColor Red
    }
}

# Function to check system resource availability
function Check-SystemResources {
    try {
        # Check memory
        $osInfo = Get-WmiObject Win32_OperatingSystem
        $physicalMemory = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
        $freeMemory = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
        
        # Check disk space
        $diskInfo = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
        $totalDiskSpace = [math]::Round($diskInfo.Size / 1GB, 2)
        $freeDiskSpace = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        
        Write-Host "`nSystem Resource Information:" -ForegroundColor Green
        Write-Host "  Total Physical Memory: $physicalMemory GB" -ForegroundColor Cyan
        Write-Host "  Free Physical Memory: $freeMemory GB" -ForegroundColor Cyan
        Write-Host "  Total Disk Space (C:): $totalDiskSpace GB" -ForegroundColor Cyan
        Write-Host "  Free Disk Space (C:): $freeDiskSpace GB" -ForegroundColor Cyan
        
        # Check if resources meet requirements
        if ($freeMemory -lt 8) {
            Write-Host "  WARNING: Less than 8 GB of free memory available. Consider closing applications." -ForegroundColor Red
        } else {
            Write-Host "  Memory availability is sufficient for AI workloads." -ForegroundColor Green
        }
        
        if ($freeDiskSpace -lt 20) {
            Write-Host "  WARNING: Less than 20 GB of free disk space available." -ForegroundColor Red
            Write-Host "  Free up disk space before installing AI models." -ForegroundColor Yellow
        } else {
            Write-Host "  Disk space is sufficient for AI models installation." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error checking system resources: $_" -ForegroundColor Red
    }
}

# Function to recommend next steps
function Show-NextSteps {
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "NEXT STEPS FOR LOCAL AI IMPLEMENTATION:" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    
    Write-Host "1. Address any warnings mentioned above" -ForegroundColor Yellow
    Write-Host "2. Download GPT4All from: https://gpt4all.io" -ForegroundColor Yellow
    Write-Host "3. Install GPT4All with default settings" -ForegroundColor Yellow
    Write-Host "4. Configure GPT4All as recommended in the implementation document" -ForegroundColor Yellow
    Write-Host "5. Download the recommended models within the GPT4All application" -ForegroundColor Yellow
    
    Write-Host "`nFor detailed instructions, refer to:" -ForegroundColor Cyan
    Write-Host "C:\Users\Chris\cFish.io\U7-Systems\LocalAI\ucf-u7.3-local-ai-implementation-20250506.md" -ForegroundColor Cyan
    
    Write-Host "`nReminder: Run AI workloads with minimal background applications" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Green
}

# Main execution
Write-Host "============================================================" -ForegroundColor Green
Write-Host "SYSTEM OPTIMIZATION FOR LOCAL AI - ANALYSIS REPORT" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

Get-GPUDriverInfo
Check-VirtualMemory
Check-PowerSettings
Check-SystemResources
Show-NextSteps

# Export results to log file
$logPath = "C:\Users\Chris\cFish.io\U7-Systems\LocalAI\system-optimization-log.txt"
try {
    Start-Transcript -Path $logPath -Append
    Write-Host "`nSystem optimization analysis complete. Log saved to:" -ForegroundColor Green
    Write-Host $logPath -ForegroundColor Cyan
    Stop-Transcript
} catch {
    Write-Host "Error saving log: $_" -ForegroundColor Red
} 