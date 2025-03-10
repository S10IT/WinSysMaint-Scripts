<# 
    ==========================================================================================
    Script Name: DownloadsCleanup.ps1
    Description: Deletes files older than 30 days from the Downloads folder of the current user.
    Version:     1.0
    Author:      Stan Livetsky
    Date:        2025-03-10
    ==========================================================================================
    Change Log:
    ------------------------------------------------------------------------------------------
    Version 1.0 - Initial script to delete files older than 30 days from the Downloads folder.
    ==========================================================================================
#>

# Define variables
$Days = 30
$DownloadFolder = "$env:USERPROFILE\Downloads"
$LogFile = "$env:TEMP\DownloadsCleanup.log"
$CurrentDate = Get-Date

# Ensure the log file exists
if (-not (Test-Path $LogFile)) {
    New-Item -ItemType File -Path $LogFile -Force | Out-Null
}

# Function to write to log
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Start cleanup process
Write-Log "Starting Downloads folder cleanup for $env:USERNAME"

# Check if Downloads folder exists
if (Test-Path $DownloadFolder) {
    # Get files older than the specified days
    $Files = Get-ChildItem -Path $DownloadFolder -File | Where-Object { ($CurrentDate - $_.LastWriteTime).Days -gt $Days }

    if ($Files.Count -gt 0) {
        foreach ($File in $Files) {
            try {
                Remove-Item -Path $File.FullName -Force -ErrorAction Stop
                Write-Log "Deleted: $($File.FullName)"
            } catch {
                Write-Log "ERROR deleting $($File.FullName) - $($_.Exception.Message)"
            }
        }
    } else {
        Write-Log "No files older than $Days days found in Downloads folder."
    }
} else {
    Write-Log "ERROR: Downloads folder not found for $env:USERNAME"
}

Write-Log "Downloads folder cleanup completed."