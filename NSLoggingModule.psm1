#region LOGGING

#region LOGGING VARIABLES

# Get the directory containing the script, with a fallback for interactive sessions
$scriptPath = if ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}
else {
    $PSScriptRoot
}

# Ensure $scriptPath is not null or empty
if (-not $scriptPath) {
    $scriptPath = (Get-Location).Path
}

# Get the script name without the extension
$scriptName = if ($MyInvocation.MyCommand.Path) {
    [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
}
else {
    "InteractiveSession"
}

# Get the computer name
$computerName = $Env:COMPUTERNAME

# Set the log file name based on the computer name, script name, and current date
$logFileName = "$computerName-$scriptName-$(Get-Date -Format 'dd-MM-yy').log"

# Set the log file path based on the script path and a "Logs" subfolder
$logFilePath = Join-Path -Path $scriptPath -ChildPath "Logs"

#endregion LOGGING VARIABLES

# Check if the log folder exists, and create it if it doesn't
if (-not (Test-Path -Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType Directory | Out-Null
}

#region LOGGING FUNCTIONS

# Function to create log entries
Function Log {
    <#
    .SYNOPSIS
    Creates a log entry.

    .DESCRIPTION
    This function creates a log entry with the current date and time in universal format and appends it to the log file.

    .PARAMETER message
    The message to log.

    .EXAMPLE
    Log -message "This is a log entry."
    #>    
    param (
        [string]$message  # Message to log
    )
    $currentTime = Get-Date -Format u  # Get the current date/time in universal format
    $outputString = "[$currentTime] $message"  # Format the log entry
    $outputString | Out-File -FilePath (Join-Path -Path $logFilePath -ChildPath $logFileName) -Append  # Append the log entry to the log file
}

# Function to log messages to both the console and the file
Function LogAndConsole {
    <#
    .SYNOPSIS
    Logs messages to both the console and the file.

    .DESCRIPTION
    This function logs messages to both the console with green text and to the log file.

    .PARAMETER message
    The message to log.

    .EXAMPLE
    LogAndConsole -message "This is a log entry."
    #>    
    param (
        [string]$message  # Message to log
    )
    Write-Host $message -ForegroundColor Green  # Log to console
    Log -message $message  # Log to file
}

# Function to delete old log files
Function DeleteOldLogFiles {
    <#
    .SYNOPSIS
    Deletes old log files.

    .DESCRIPTION
    This function deletes log files older than the specified number of days.

    .PARAMETER Days
    The number of days after which log files will be deleted. Default is 90 days.

    .EXAMPLE
    DeleteOldLogFiles -Days 30
    #>    
    param (
        [int]$Days = 90  # Number of days after which log files will be deleted, default is 90
    )
    $logFiles = Get-ChildItem -Path (Join-Path -Path $logFilePath -ChildPath "*.log")  # Get all log files
    foreach ($file in $logFiles) {
        if ($file.LastWriteTime -le (Get-Date).AddDays(-$Days)) {
            # Delete log files older than the specified number of days
            LogAndConsole -message "[+] Deleting old log file $file..."
            Remove-Item -Path $file.FullName  # Remove the old log file
        }
    }
}

#endregion LOGGING FUNCTIONS

#endregion LOGGING