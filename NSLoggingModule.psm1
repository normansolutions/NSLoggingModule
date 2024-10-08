#region LOGGING

# Get the computer name
$computerName = $Env:COMPUTERNAME

#region LOGGING FUNCTIONS

# Function to create log entries
function Log {
    <#
    .SYNOPSIS
    Creates a log entry.
 
    .DESCRIPTION
    This function creates a log entry with the current date and time in universal format and appends it to the log file.
 
    .PARAMETER message
    The message to log.

    .PARAMETER logPath
    The path to log file. Default is Temp.
	
	.PARAMETER scriptName
    The name of the script. Default is -
 
    .EXAMPLE
    Log -message "This is a log entry." -logPath "./" -scriptName "logfile"
    #>
    param (
        [string]$message, # Message to log
        [string]$logPath = "$env:Temp\", # Log path   
        [string]$scriptName = "-" # File path  
    )
    
    # Set the log folder path based on the provided or default path, with a "Logs" subfolder
    $logFolder = Join-Path -Path $logPath -ChildPath "Logs"
    
    # Set the log file name based on the computer name, script name, and current date
    $logFileName = "$computerName-$scriptName-$(Get-Date -Format 'dd-MM-yy').log"

    # Check if the log folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory | Out-Null
    }
    
    # Create log entry
    $currentTime = Get-Date -Format u  # Get the current date/time in universal format
    $outputString = "[$currentTime] $message"  # Format the log entry
    $outputString | Out-File -FilePath (Join-Path -Path $logFolder -ChildPath $logFileName) -Append  # Append to log file
}

# Function to log messages to both the console and the file
function LogAndConsole {
    <#
    .SYNOPSIS
    Logs messages to both the console and the file.
 
    .DESCRIPTION
    This function logs messages to both the console with green text and to the log file.

    .PARAMETER message
    The message to log.
 
    .PARAMETER logPath
    The path to log file. Default is Temp.

	.PARAMETER scriptName
    The name of the script. Default is -
 
    .EXAMPLE
    Log -message "This is a log entry." -logPath "./" -scriptName "logfile"
    #>
    param (
        [string]$message, # Message to log
        [string]$logPath = "$env:Temp\", # Log path 
        [string]$scriptName = "-" # File path
    )

    Write-Host $message -ForegroundColor Green  # Log to console
    Log -message $message -logPath $logPath -scriptName $scriptName # Log to file
}

# Function to delete old log files
function DeleteOldLogFiles {
    <#
    .SYNOPSIS
    Deletes old log files.
 
    .DESCRIPTION
    This function deletes log files older than the specified number of days.
 
    .PARAMETER Days
    The number of days after which log files will be deleted. Default is 90 days.

    .PARAMETER logPath
    The path to log file. Default is Temp
 
    .EXAMPLE
    DeleteOldLogFiles -Days 30 -logPath "./"
    #>
    param (
        [int]$Days = 90, # Number of days after which log files will be deleted
        [string]$logPath = "$env:Temp\" # Log path  
    )

    # Set the log folder path based on the provided or default path
    $logFolder = Join-Path -Path $logPath -ChildPath "Logs"
    $logFiles = Get-ChildItem -Path (Join-Path -Path $logFolder -ChildPath "*.log")  # Get all log files

    foreach ($file in $logFiles) {
        if ($file.LastWriteTime -le (Get-Date).AddDays(-$Days)) {
            # Delete log files older than the specified number of days
            LogAndConsole -message "[+] Deleting old log file $file..." -logPath $logPath
            Remove-Item -Path $file.FullName  # Remove the old log file
        }
    }
}

#endregion LOGGING FUNCTIONS

#endregion LOGGING

# Export only the public function
Export-ModuleMember -Function Log, LogAndConsole, DeleteOldLogFiles

# Example usage
#
# $p = './' (store log path as variable)
# $s = "LogFileName" (store file name as variable)
# DeleteOldLogFiles -days 30 -logpath $p -scriptName $s (named parameters example)
# LogAndConsole "HelloTwo" $p (positional parameters example)
# Log "HelloTemp" (default file and path example)