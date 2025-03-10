<# 
    ==========================================================================================
    Script Name: RecycleBinCleanup.ps1
    Description: Deletes Recycle Bin items older than 30 days from all local drives (C:, D:, etc.).
    Version:     1.2
    Author:      Stan Livetsky
    Date:        2025-03-10
    ==========================================================================================
    Change Log:
    ------------------------------------------------------------------------------------------
    Version 1.0 - Initial script to delete old Recycle Bin items from C: drive.
    Version 1.1 - Added support for multiple drives (C:, D:, E:), improved logging.
    Version 1.2 - Fixed issue detecting Recycle Bin, excluded network/mapped drives.
    ==========================================================================================
#>

# Define log file path
$LogFile = "C:\Logs\RecycleBinCleanup.log"

# Function to log messages
Function Write-Log {
    Param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
}

# Start log entry
Write-Log "================================================================================"
Write-Log "Recycle Bin cleanup script started."
Write-Log "================================================================================"

# Get all LOCAL drives (exclude network/mapped drives)
$Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\" -and $_.Description -ne "Network Drive" }

# Loop through each drive to find and process Recycle Bin folders
foreach ($Drive in $Drives) {
    $RecycleBinPath = "$($Drive.Root)\$Recycle.Bin"

    # Ensure we check for the folder properly
    $RecycleBins = Get-ChildItem -Path $Drive.Root -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq '$Recycle.Bin' -and $_.PSIsContainer }

    if ($RecycleBins) {
        Write-Log "Processing Recycle Bin on drive: $($Drive.Root)"

        foreach ($bin in $RecycleBins) {
            Write-Log "Checking Recycle Bin folder: $($bin.FullName)"

            # Find and delete items older than 30 days
            $OldFiles = Get-ChildItem "$($bin.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }

            if ($OldFiles.Count -gt 0) {
                Write-Log "Found $($OldFiles.Count) old items in $($bin.FullName), deleting..."
                
                try {
                    $OldFiles | Remove-Item -Recurse -Force -ErrorAction Stop
                    Write-Log "Successfully deleted $($OldFiles.Count) items from $($bin.FullName)."
                } catch {
                    Write-Log "ERROR: Failed to delete files in $($bin.FullName) - $_"
                }
            } else {
                Write-Log "No old items found in $($bin.FullName)."
            }
        }
    } else {
        Write-Log "Skipping drive $($Drive.Root) - No Recycle Bin detected."
    }
}

Write-Log "================================================================================"
Write-Log "Recycle Bin cleanup completed."
Write-Log "================================================================================"