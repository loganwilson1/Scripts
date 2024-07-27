<# 
    This config file output configuration variables that are used by all the scripts in this PowerShell project.

    Config.ps1 retains the following variables
        $csvWaitTimesTodayFileName
        $csvWaitTimesTodayFilePath
        $csvWaitTimesArchiveFileName
        $csvWaitTimesArchiveFilePath
#>


$csvWaitTimesTodayFileName = "WaitTimes-Today.csv"
$csvWaitTimesArchiveFileName = "WaitTimes-Archive.csv"
$csvWaitTimesTodayFilePath = "$PSScriptRoot\$csvWaitTimesTodayFileName"
$csvWaitTimesArchiveFilePath = "$PSScriptRoot\$csvWaitTimesArchiveFileName"

Write-Host("Variables created by './config.ps1':")
Write-Host("csvWaitTimesTodayFileName = $csvWaitTimesTodayFileName")
Write-Host("csvWaitTimesTodayFilePath = $csvWaitTimesTodayFilePath")
Write-Host("csvWaitTimesArchiveFileName = $csvWaitTimesArchiveFileName")
Write-Host("csvWaitTimesArchiveFilePath = $csvWaitTimesArchiveFilePath")
