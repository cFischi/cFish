# Local AI Model Benchmarking Script
# File: ucf-u7.3-model-benchmarking-20250506.ps1
# Description: Script for benchmarking performance of local AI models
# @package cFish.io
# @since 05-06-2025
# @author AI: Cursor (Claude 3.7 Sonnet)

# Enable strict typing
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Define benchmark parameters
$BenchmarkPrompts = @(
    @{
        Name = "Simple Factual Query";
        Prompt = "What is the capital of France? Keep your answer brief.";
        Description = "Tests simple knowledge retrieval";
        ExpectedResponseLength = "Short (10-30 tokens)";
    },
    @{
        Name = "Medium Explanation";
        Prompt = "Explain how photosynthesis works in 3-5 sentences.";
        Description = "Tests ability to generate medium-length explanations";
        ExpectedResponseLength = "Medium (50-100 tokens)";
    },
    @{
        Name = "Complex Reasoning";
        Prompt = "Discuss three ways artificial intelligence might impact job markets in the next decade. Provide specific examples.";
        Description = "Tests complex reasoning and structured output";
        ExpectedResponseLength = "Long (200-300 tokens)";
    },
    @{
        Name = "Creative Writing";
        Prompt = "Write a short poem about autumn leaves.";
        Description = "Tests creative capabilities";
        ExpectedResponseLength = "Medium (50-100 tokens)";
    },
    @{
        Name = "Code Generation";
        Prompt = "Write a Python function that calculates the Fibonacci sequence up to n terms.";
        Description = "Tests code generation abilities";
        ExpectedResponseLength = "Medium (100-200 tokens)";
    }
)

$ModelConfigurations = @(
    @{
        Name = "Llama 3 8B Instruct";
        ContextLength = 2048;
        Temperature = 0.7;
        TopP = 0.9;
        ThreadCount = 10;
    },
    @{
        Name = "Nous Hermes 2 Mistral DPO";
        ContextLength = 2048;
        Temperature = 0.7;
        TopP = 0.9;
        ThreadCount = 10;
    },
    @{
        Name = "Orca Mini 3B";
        ContextLength = 2048;
        Temperature = 0.7;
        TopP = 0.9;
        ThreadCount = 10;
    }
)

# Function to display benchmark instructions
function Show-BenchmarkInstructions {
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "LOCAL AI MODEL BENCHMARKING INSTRUCTIONS" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    
    Write-Host "`nThis script will guide you through benchmarking your local AI models." -ForegroundColor Cyan
    Write-Host "The benchmark includes $($BenchmarkPrompts.Count) test prompts to evaluate performance." -ForegroundColor Cyan
    
    Write-Host "`nBefore starting:" -ForegroundColor Yellow
    Write-Host "1. Ensure GPT4All is installed and configured" -ForegroundColor Yellow
    Write-Host "2. Download the recommended models (Llama 3 8B, Nous Hermes 2, Orca Mini 3B)" -ForegroundColor Yellow
    Write-Host "3. Close other memory-intensive applications" -ForegroundColor Yellow
    Write-Host "4. Configure each model with the recommended settings" -ForegroundColor Yellow
    
    Write-Host "`nDuring the benchmark:" -ForegroundColor Yellow
    Write-Host "1. For each prompt, note the response time and quality" -ForegroundColor Yellow
    Write-Host "2. Record system resource usage (CPU, RAM) during generation" -ForegroundColor Yellow
    Write-Host "3. Note any issues or performance problems" -ForegroundColor Yellow
    
    Write-Host "`nThe results will help you determine which model works best for different tasks." -ForegroundColor Cyan
    
    Write-Host "`nPress any key to continue with the benchmark..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Function to display benchmark prompts and record results
function Run-ModelBenchmark {
    $benchmarkResults = @()
    $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Create results directory if it doesn't exist
    $resultsDir = "C:\Users\Chris\cFish.io\U7-Systems\LocalAI\benchmark-results"
    if (-not (Test-Path $resultsDir)) {
        New-Item -ItemType Directory -Path $resultsDir | Out-Null
    }
    
    $resultsFile = "$resultsDir\benchmark-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    
    # Create CSV header
    "Date,Model,Prompt,ResponseTime,TokensPerSecond,ResponseQuality,CPUUsage,RAMUsage,Notes" | Out-File -FilePath $resultsFile
    
    foreach ($model in $ModelConfigurations) {
        Write-Host "`n============================================================" -ForegroundColor Green
        Write-Host "BENCHMARKING MODEL: $($model.Name)" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        
        Write-Host "`nConfigure GPT4All with these settings:" -ForegroundColor Yellow
        Write-Host "  Model: $($model.Name)" -ForegroundColor Cyan
        Write-Host "  Context Length: $($model.ContextLength)" -ForegroundColor Cyan
        Write-Host "  Temperature: $($model.Temperature)" -ForegroundColor Cyan
        Write-Host "  Top P: $($model.TopP)" -ForegroundColor Cyan
        Write-Host "  Thread Count: $($model.ThreadCount)" -ForegroundColor Cyan
        
        Write-Host "`nStart GPT4All and select this model before continuing." -ForegroundColor Yellow
        Write-Host "Press any key when ready to begin testing with this model..." -ForegroundColor Green
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        foreach ($prompt in $BenchmarkPrompts) {
            Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
            Write-Host "PROMPT: $($prompt.Name)" -ForegroundColor Cyan
            Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
            
            Write-Host "`nDescription: $($prompt.Description)" -ForegroundColor White
            Write-Host "Expected Length: $($prompt.ExpectedResponseLength)" -ForegroundColor White
            
            Write-Host "`nPrompt to enter in GPT4All:" -ForegroundColor Yellow
            Write-Host $prompt.Prompt -ForegroundColor White
            
            Write-Host "`nStart a timer when you submit the prompt." -ForegroundColor Yellow
            Write-Host "After the response is complete, please enter the following information:" -ForegroundColor Yellow
            
            # Collect response time
            $responseTimeInput = Read-Host "`nResponse time in seconds (e.g., 15.5)"
            $responseTime = [double]$responseTimeInput
            
            # Collect token generation speed
            $tokensPerSecondInput = Read-Host "Estimated tokens per second (e.g., 2.5)"
            $tokensPerSecond = [double]$tokensPerSecondInput
            
            # Collect response quality rating
            $responseQualityInput = Read-Host "Response quality (1-10, with 10 being excellent)"
            $responseQuality = [int]$responseQualityInput
            
            # Collect resource usage
            $cpuUsageInput = Read-Host "Peak CPU usage during generation (percentage, e.g., 75)"
            $cpuUsage = [int]$cpuUsageInput
            
            $ramUsageInput = Read-Host "Peak RAM usage during generation (GB, e.g., 8.5)"
            $ramUsage = [double]$ramUsageInput
            
            # Collect notes
            $notes = Read-Host "Any observations or issues (press Enter if none)"
            
            # Save result to array
            $result = [PSCustomObject]@{
                Date = $currentDate
                Model = $model.Name
                Prompt = $prompt.Name
                ResponseTime = $responseTime
                TokensPerSecond = $tokensPerSecond
                ResponseQuality = $responseQuality
                CPUUsage = $cpuUsage
                RAMUsage = $ramUsage
                Notes = $notes
            }
            
            $benchmarkResults += $result
            
            # Save to CSV as we go
            "$($result.Date),$($result.Model),$($result.Prompt),$($result.ResponseTime),$($result.TokensPerSecond),$($result.ResponseQuality),$($result.CPUUsage),$($result.RAMUsage),$($result.Notes)" | Out-File -FilePath $resultsFile -Append
            
            Write-Host "`nResult recorded. Moving to next prompt..." -ForegroundColor Green
        }
        
        Write-Host "`nCompleted all prompts for $($model.Name)." -ForegroundColor Green
        Write-Host "Please switch to the next model in GPT4All." -ForegroundColor Yellow
    }
    
    return $benchmarkResults, $resultsFile
}

# Function to display benchmark summary
function Show-BenchmarkSummary {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Results,
        [Parameter(Mandatory=$true)]
        [string]$ResultsFile
    )
    
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "BENCHMARK SUMMARY" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    
    # Group results by model
    $modelGroups = $Results | Group-Object -Property Model
    
    foreach ($modelGroup in $modelGroups) {
        Write-Host "`n## $($modelGroup.Name)" -ForegroundColor Cyan
        
        # Calculate averages
        $avgResponseTime = ($modelGroup.Group | Measure-Object -Property ResponseTime -Average).Average
        $avgTokensPerSecond = ($modelGroup.Group | Measure-Object -Property TokensPerSecond -Average).Average
        $avgResponseQuality = ($modelGroup.Group | Measure-Object -Property ResponseQuality -Average).Average
        $avgCPUUsage = ($modelGroup.Group | Measure-Object -Property CPUUsage -Average).Average
        $avgRAMUsage = ($modelGroup.Group | Measure-Object -Property RAMUsage -Average).Average
        
        Write-Host "Average Response Time: $([math]::Round($avgResponseTime, 2)) seconds" -ForegroundColor White
        Write-Host "Average Tokens Per Second: $([math]::Round($avgTokensPerSecond, 2))" -ForegroundColor White
        Write-Host "Average Response Quality: $([math]::Round($avgResponseQuality, 2))/10" -ForegroundColor White
        Write-Host "Average CPU Usage: $([math]::Round($avgCPUUsage, 2))%" -ForegroundColor White
        Write-Host "Average RAM Usage: $([math]::Round($avgRAMUsage, 2)) GB" -ForegroundColor White
        
        # Best and worst prompts
        $bestPrompt = $modelGroup.Group | Sort-Object -Property ResponseQuality -Descending | Select-Object -First 1
        $worstPrompt = $modelGroup.Group | Sort-Object -Property ResponseQuality | Select-Object -First 1
        
        Write-Host "`nBest Performance: $($bestPrompt.Prompt) (Quality: $($bestPrompt.ResponseQuality)/10)" -ForegroundColor Green
        Write-Host "Worst Performance: $($worstPrompt.Prompt) (Quality: $($worstPrompt.ResponseQuality)/10)" -ForegroundColor Yellow
        
        Write-Host "`nPrompt-Specific Performance:" -ForegroundColor White
        foreach ($promptType in ($modelGroup.Group | Select-Object -Property Prompt -Unique)) {
            $promptResults = $modelGroup.Group | Where-Object { $_.Prompt -eq $promptType.Prompt }
            $promptResponseTime = ($promptResults | Measure-Object -Property ResponseTime -Average).Average
            $promptQuality = ($promptResults | Measure-Object -Property ResponseQuality -Average).Average
            
            Write-Host "  $($promptType.Prompt): $([math]::Round($promptQuality, 1))/10 quality in $([math]::Round($promptResponseTime, 1)) seconds" -ForegroundColor White
        }
    }
    
    # Overall model comparison
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "MODEL COMPARISON" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    
    $modelComparison = $modelGroups | ForEach-Object {
        $avgResponseTime = ($_.Group | Measure-Object -Property ResponseTime -Average).Average
        $avgQuality = ($_.Group | Measure-Object -Property ResponseQuality -Average).Average
        $avgTokensPerSecond = ($_.Group | Measure-Object -Property TokensPerSecond -Average).Average
        
        [PSCustomObject]@{
            Model = $_.Name
            AvgResponseTime = $avgResponseTime
            AvgQuality = $avgQuality
            AvgTokensPerSecond = $avgTokensPerSecond
        }
    }
    
    # Best for quality
    $bestQualityModel = $modelComparison | Sort-Object -Property AvgQuality -Descending | Select-Object -First 1
    Write-Host "`nBest for Quality: $($bestQualityModel.Model) (Avg Quality: $([math]::Round($bestQualityModel.AvgQuality, 2))/10)" -ForegroundColor Green
    
    # Best for speed
    $bestSpeedModel = $modelComparison | Sort-Object -Property AvgTokensPerSecond -Descending | Select-Object -First 1
    Write-Host "Best for Speed: $($bestSpeedModel.Model) (Avg Tokens/Sec: $([math]::Round($bestSpeedModel.AvgTokensPerSecond, 2)))" -ForegroundColor Green
    
    # Generate recommendations
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "RECOMMENDATIONS" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    
    Write-Host "`nBased on benchmark results, we recommend:" -ForegroundColor White
    Write-Host "- For general use: $($bestQualityModel.Model)" -ForegroundColor White
    Write-Host "- For tasks needing quick responses: $($bestSpeedModel.Model)" -ForegroundColor White
    
    Write-Host "`nDetailed task-specific recommendations:" -ForegroundColor White
    
    # Find best model for each prompt type
    foreach ($promptType in ($Results | Select-Object -Property Prompt -Unique)) {
        $bestModelForPrompt = $Results | 
            Where-Object { $_.Prompt -eq $promptType.Prompt } | 
            Sort-Object -Property ResponseQuality -Descending | 
            Select-Object -First 1
        
        Write-Host "- For $($promptType.Prompt): $($bestModelForPrompt.Model) (Quality: $($bestModelForPrompt.ResponseQuality)/10)" -ForegroundColor White
    }
    
    Write-Host "`nBenchmark results saved to: $ResultsFile" -ForegroundColor Cyan
    
    # Generate markdown report
    $markdownReport = "$($ResultsFile.Replace('.csv', '.md'))"
    
    Write-Host "`nGenerating detailed markdown report..." -ForegroundColor Yellow
    
    $markdownContent = @"
# Local AI Model Benchmark Results
**Date:** $(Get-Date -Format "yyyy-MM-dd")

## Overview
This document presents the benchmark results for local AI models running on the cFish.io system hardware.

## System Specifications
- **CPU:** Intel i7-3960X @ 3.30GHz, 6 Core(s), 12 Logical Processor(s)
- **RAM:** 32.0 GB
- **GPU:** GTX 680
- **Storage:** 500GB SSD

## Benchmark Summary

"@
    
    foreach ($modelGroup in $modelGroups) {
        $avgResponseTime = ($modelGroup.Group | Measure-Object -Property ResponseTime -Average).Average
        $avgTokensPerSecond = ($modelGroup.Group | Measure-Object -Property TokensPerSecond -Average).Average
        $avgResponseQuality = ($modelGroup.Group | Measure-Object -Property ResponseQuality -Average).Average
        $avgCPUUsage = ($modelGroup.Group | Measure-Object -Property CPUUsage -Average).Average
        $avgRAMUsage = ($modelGroup.Group | Measure-Object -Property RAMUsage -Average).Average
        
        $markdownContent += @"

### $($modelGroup.Name)

#### Performance Metrics
- **Average Response Time:** $([math]::Round($avgResponseTime, 2)) seconds
- **Average Tokens Per Second:** $([math]::Round($avgTokensPerSecond, 2))
- **Average Response Quality:** $([math]::Round($avgResponseQuality, 2))/10
- **Average CPU Usage:** $([math]::Round($avgCPUUsage, 2))%
- **Average RAM Usage:** $([math]::Round($avgRAMUsage, 2)) GB

#### Prompt-Specific Performance

| Prompt Type | Quality (1-10) | Response Time (sec) |
|-------------|----------------|---------------------|

"@
        
        foreach ($promptType in ($modelGroup.Group | Select-Object -Property Prompt -Unique)) {
            $promptResults = $modelGroup.Group | Where-Object { $_.Prompt -eq $promptType.Prompt }
            $promptResponseTime = ($promptResults | Measure-Object -Property ResponseTime -Average).Average
            $promptQuality = ($promptResults | Measure-Object -Property ResponseQuality -Average).Average
            
            $markdownContent += "| $($promptType.Prompt) | $([math]::Round($promptQuality, 1)) | $([math]::Round($promptResponseTime, 1)) |\n"
        }
    }
    
    $markdownContent += @"

## Model Comparison

| Model | Avg Quality (1-10) | Avg Tokens/Sec | Avg Response Time (sec) |
|-------|-------------------|----------------|-------------------------|

"@
    
    foreach ($model in $modelComparison) {
        $markdownContent += "| $($model.Model) | $([math]::Round($model.AvgQuality, 2)) | $([math]::Round($model.AvgTokensPerSecond, 2)) | $([math]::Round($model.AvgResponseTime, 2)) |\n"
    }
    
    $markdownContent += @"

## Recommendations

Based on benchmark results, we recommend:

- **For general use:** $($bestQualityModel.Model)
- **For tasks needing quick responses:** $($bestSpeedModel.Model)

### Task-Specific Recommendations

"@
    
    foreach ($promptType in ($Results | Select-Object -Property Prompt -Unique)) {
        $bestModelForPrompt = $Results | 
            Where-Object { $_.Prompt -eq $promptType.Prompt } | 
            Sort-Object -Property ResponseQuality -Descending | 
            Select-Object -First 1
        
        $markdownContent += "- **For $($promptType.Prompt):** $($bestModelForPrompt.Model) (Quality: $($bestModelForPrompt.ResponseQuality)/10)\n"
    }
    
    $markdownContent += @"

## Raw Data
Full benchmark data is available in: $ResultsFile

_Updated $(Get-Date -Format "MM-dd-yyyy") | AI: Cursor (Claude 3.7 Sonnet)_
"@
    
    $markdownContent | Out-File -FilePath $markdownReport
    
    Write-Host "`nMarkdown report saved to: $markdownReport" -ForegroundColor Cyan
    Write-Host "`nBenchmark summary complete." -ForegroundColor Green
}

# Main execution
Show-BenchmarkInstructions

$benchmarkResults, $resultsFile = Run-ModelBenchmark

Show-BenchmarkSummary -Results $benchmarkResults -ResultsFile $resultsFile 