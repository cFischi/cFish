#Requires -Version 7.0

<#
.SYNOPSIS
    tYDiSync~ Differential Update Engine for optimizing file synchronization.
.DESCRIPTION
    This module provides differential update capabilities to tYDiSync~, allowing only changed
    portions of files to be transferred instead of entire files. This significantly improves
    performance for large files with small changes.
.NOTES
    Version:        0.1.0
    Author:         tYDiSync~ Team
    Creation Date:  2025-03-13
    Platform:       Cross-platform (Windows, Linux)
#>

# Import platform detection module
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$platformModulePath = Join-Path -Path $scriptPath -ChildPath "..\scripts\PlatformDetection.psm1"
Import-Module $platformModulePath -ErrorAction Stop

##### Configuration
${global}:DifferentialConfig = @{
    ChunkSizeKB = 64                  ##### Default chunk size in KB
    Algorithm = "rolling"             ##### Chunking algorithm: fixed, rolling, content-aware
    CompressionLevel = "medium"       ##### Compression level: none, low, medium, high
    MinFileSizeKB = 256               ##### Minimum file size to use differential updates (in KB)
    CacheEnabled = $true              ##### Enable caching of file signatures
    CacheDirectory = "cache"          ##### Directory to store cached signatures
    Threads = 4                       ##### Number of threads for parallel processing
}

##### Ensure cache directory exists
function Initialize-DifferentialEngine {
    param (
        [hashtable]$Config = @{}
    )

    ##### Apply custom configuration if provided
    if ($Config.Count -gt 0) {
        foreach ($key in $Config.Keys) {
            if (${global}:DifferentialConfig.ContainsKey($key)) {
                ${global}:DifferentialConfig[$key] = $Config[$key]
            }
        }
    }

    ##### Create cache directory if enabled
    if (${global}:DifferentialConfig.CacheEnabled) {
        $cachePath = Join-Path -Path $scriptPath -ChildPath ${global}:DifferentialConfig.CacheDirectory
        if (-not (Test-Path -Path $cachePath)) {
            New-Item -Path $cachePath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created differential cache directory: $cachePath"
        }
    }

    Write-Verbose "Differential engine initialized with configuration:"
    Write-Verbose (${global}:DifferentialConfig | ConvertTo-Json)
}

##### Calculate file signature (hash of chunks)
function Get-FileSignature {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [int]$ChunkSizeKB = ${global}:DifferentialConfig.ChunkSizeKB,
        
        [Parameter(Mandatory = $false)]
        [string]$Algorithm = ${global}:DifferentialConfig.Algorithm
    )

    ##### Check if file exists
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        Write-Error "File not found: $FilePath"
        return $null
    }

    ##### Check if cached signature exists
    $useCached = $false
    if (${global}:DifferentialConfig.CacheEnabled) {
        $fileInfo = Get-Item -Path $FilePath
        $fileHash = Get-FileHash -Path $FilePath -Algorithm MD5
        $cacheFileName = "$($fileInfo.Name)_$($fileHash.Hash)_$ChunkSizeKB.sig"
        $cachePath = Join-Path -Path $scriptPath -ChildPath ${global}:DifferentialConfig.CacheDirectory | Join-Path -ChildPath $cacheFileName
        
        if (Test-Path -Path $cachePath -PathType Leaf) {
            try {
                $signature = Get-Content -Path $cachePath -Raw | ConvertFrom-Json
                Write-Verbose "Using cached signature for $FilePath"
                return $signature
            }
            catch {
                Write-Verbose "Error reading cached signature: $_"
                ##### Continue with calculating new signature
            }
        }
    }

    ##### Calculate signature based on algorithm
    $chunkSize = $ChunkSizeKB * 1KB
    $signatures = @()
    $fileStream = [System.IO.File]::OpenRead($FilePath)
    
    try {
        $buffer = New-Object byte[] $chunkSize
        $bytesRead = 0
        $chunkIndex = 0
        
        while (($bytesRead = $fileStream.Read($buffer, 0, $chunkSize)) -gt 0) {
            ##### If we read less than chunk size, resize buffer
            if ($bytesRead -lt $chunkSize) {
                $actualBuffer = New-Object byte[] $bytesRead
                [Array]::Copy($buffer, $actualBuffer, $bytesRead)
                $buffer = $actualBuffer
            }
            
            ##### Calculate hash for this chunk
            $hashAlgo = [System.Security.Cryptography.SHA256]::Create()
            $hash = [System.BitConverter]::ToString($hashAlgo.ComputeHash($buffer)) -replace '-'
            
            ##### Add to signatures
            $signatures += [PSCustomObject]@{
                Index = $chunkIndex
                Offset = $chunkIndex * $chunkSize
                Size = $bytesRead
                Hash = $hash
            }
            
            $chunkIndex++
        }
    }
    finally {
        $fileStream.Close()
        $fileStream.Dispose()
    }
    
    ##### Create signature object
    $fileInfo = Get-Item -Path $FilePath
    $signature = [PSCustomObject]@{
        FilePath = $FilePath
        FileName = $fileInfo.Name
        FileSize = $fileInfo.Length
        LastModified = $fileInfo.LastWriteTimeUtc.ToString('o')
        ChunkSizeKB = $ChunkSizeKB
        Algorithm = $Algorithm
        Chunks = $signatures
    }
    
    ##### Cache signature if enabled
    if (${global}:DifferentialConfig.CacheEnabled) {
        try {
            $signature | ConvertTo-Json -Depth 10 | Set-Content -Path $cachePath -Force
            Write-Verbose "Cached signature for $FilePath at $cachePath"
        }
        catch {
            Write-Verbose "Error caching signature: $_"
        }
    }
    
    return $signature
}

##### Compare two file signatures to find differences
function Compare-FileSignatures {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$SourceSignature,
        
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$TargetSignature
    )
    
    ##### Validate signatures
    if (-not $SourceSignature -or -not $TargetSignature) {
        Write-Error "Invalid file signatures provided"
        return $null
    }
    
    ##### Find changed and new chunks
    $changedChunks = @()
    $targetChunksByHash = @{}
    
    ##### Create hashtable of target chunks by hash
    foreach ($chunk in $TargetSignature.Chunks) {
        $targetChunksByHash[$chunk.Hash] = $chunk
    }
    
    ##### Compare source chunks with target chunks
    foreach ($sourceChunk in $SourceSignature.Chunks) {
        if (-not $targetChunksByHash.ContainsKey($sourceChunk.Hash)) {
            ##### Chunk has changed or is new
            $changedChunks += $sourceChunk
        }
    }
    
    ##### Create delta object
    $delta = [PSCustomObject]@{
        SourceFile = $SourceSignature.FilePath
        TargetFile = $TargetSignature.FilePath
        SourceFileSize = $SourceSignature.FileSize
        TargetFileSize = $TargetSignature.FileSize
        ChangedChunks = $changedChunks
        ChunkSizeKB = $SourceSignature.ChunkSizeKB
        TotalChunks = $SourceSignature.Chunks.Count
        ChangedChunkCount = $changedChunks.Count
        DeltaPercentage = [math]::Round(($changedChunks.Count / $SourceSignature.Chunks.Count) * 100, 2)
    }
    
    return $delta
}

##### Create a delta file containing only the changed chunks
function New-DeltaFile {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Delta,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )
    
    ##### Validate delta
    if (-not $Delta -or -not $Delta.ChangedChunks) {
        Write-Error "Invalid delta object provided"
        return $false
    }
    
    ##### Create delta file structure
    $deltaObj = [PSCustomObject]@{
        SourceFile = $Delta.SourceFile
        TargetFile = $Delta.TargetFile
        SourceFileSize = $Delta.SourceFileSize
        TargetFileSize = $Delta.TargetFileSize
        ChunkSizeKB = $Delta.ChunkSizeKB
        CreatedAt = [DateTime]::UtcNow.ToString('o')
        Chunks = @()
    }
    
    ##### Read source file and extract changed chunks
    $chunkSize = $Delta.ChunkSizeKB * 1KB
    $fileStream = [System.IO.File]::OpenRead($Delta.SourceFile)
    
    try {
        foreach ($chunk in $Delta.ChangedChunks) {
            $buffer = New-Object byte[] $chunk.Size
            $fileStream.Position = $chunk.Offset
            $bytesRead = $fileStream.Read($buffer, 0, $chunk.Size)
            
            ##### Convert to Base64 for JSON storage
            $base64Data = [Convert]::ToBase64String($buffer)
            
            ##### Add to delta
            $deltaObj.Chunks += [PSCustomObject]@{
                Index = $chunk.Index
                Offset = $chunk.Offset
                Size = $chunk.Size
                Hash = $chunk.Hash
                Data = $base64Data
            }
        }
        
        ##### Save delta file
        $deltaObj | ConvertTo-Json -Depth 10 -Compress:$false | Set-Content -Path $OutputPath -Force
        
        return $true
    }
    catch {
        Write-Error "Error creating delta file: $_"
        return $false
    }
    finally {
        $fileStream.Close()
        $fileStream.Dispose()
    }
}

##### Apply a delta file to update a target file
function Apply-DeltaFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeltaFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$TargetFilePath
    )
    
    ##### Check if files exist
    if (-not (Test-Path -Path $DeltaFilePath -PathType Leaf)) {
        Write-Error "Delta file not found: $DeltaFilePath"
        return $false
    }
    
    ##### Load delta file
    try {
        $delta = Get-Content -Path $DeltaFilePath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Error "Error reading delta file: $_"
        return $false
    }
    
    ##### Create target file if it doesn't exist
    $createNew = -not (Test-Path -Path $TargetFilePath -PathType Leaf)
    
    ##### Open or create target file
    try {
        if ($createNew) {
            ##### Creating a new file with the same size as source
            $targetStream = [System.IO.File]::Create($TargetFilePath)
            $targetStream.SetLength($delta.SourceFileSize)
        }
        else {
            ##### Opening existing file
            $targetStream = [System.IO.File]::OpenWrite($TargetFilePath)
            
            ##### Resize if needed
            if ($targetStream.Length -ne $delta.SourceFileSize) {
                $targetStream.SetLength($delta.SourceFileSize)
            }
        }
        
        ##### Apply chunks
        foreach ($chunk in $delta.Chunks) {
            ##### Convert Base64 back to bytes
            $buffer = [Convert]::FromBase64String($chunk.Data)
            
            ##### Write to target file
            $targetStream.Position = $chunk.Offset
            $targetStream.Write($buffer, 0, $buffer.Length)
        }
        
        return $true
    }
    catch {
        Write-Error "Error applying delta file: $_"
        return $false
    }
    finally {
        if ($targetStream) {
            $targetStream.Close()
            $targetStream.Dispose()
        }
    }
}

# Determine if differential update should be used for a file
function Should-UseDifferentialUpdate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    # Check if file exists
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        return $false
    }
    
    # Get file size
    $fileInfo = Get-Item -Path $FilePath
    $fileSizeKB = $fileInfo.Length / 1KB
    
    # Check against minimum size
    return ($fileSizeKB -ge ${global}:DifferentialConfig.MinFileSizeKB)
}

# Export functions
Export-ModuleMember -Function @(
    'Initialize-DifferentialEngine',
    'Get-FileSignature',
    'Compare-FileSignatures',
    'New-DeltaFile',
    'Apply-DeltaFile',
    'Should-UseDifferentialUpdate'
) 
