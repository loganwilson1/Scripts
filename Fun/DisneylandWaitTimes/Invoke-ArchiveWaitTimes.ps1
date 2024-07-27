# Define the paths to the CSV files


<#
    TODO:
    - Source config
    - test this script
#>

# Dot-source the configuration file
. "$PSScriptRoot/config.ps1"
<#
    Config.ps1 retains the following variables
        $csvWaitTimesTodayFileName
        $csvWaitTimesTodayFilePath
        $csvWaitTimesArchiveFileName
        $csvWaitTimesArchiveFilePath

#>

try {
    # Import the records from Today.csv
    $todayRecords = Import-Csv -Path $csvWaitTimesTodayFilePath
    # Remove duplicates
    $uniqueRecords = $todayRecords | Sort-Object LastUpdated, Park, Land, Name, IsOpen -Unique

    # Check if there are records to archive
    if ($todayRecords.Count -gt 0) {
        $uniqueRecords | Export-Csv -Path $csvWaitTimesArchiveFilePath -Append -NoTypeInformation -Force


        # # Check if Archive.csv exists
        # if (Test-Path -Path $archiveCsvPath) {
        #     # Append the records to Archive.csv
        #     $uniqueRecords | Export-Csv -Path $archiveCsvPath -Append -NoTypeInformation
        # } else {
        #     # Create Archive.csv with the records from Today.csv
        #     $uniqueRecords | Export-Csv -Path $archiveCsvPath -NoTypeInformation
        # }

        # TODO: Test this
        #Clear the contents of Today csv leaving only the header columns
        "Park,Land,Name,IsOpen,WaitTime,LastUpdated" | Out-File -FilePath $csvWaitTimesTodayFilePath # Uncomment this when done testing

        Write-Host("Total records in $($csvWaitTimesTodayFileName): $($todayRecords.Count)")
        Write-Host("Total unique records: $($uniqueRecords.Count)")
        Write-Host("$csvWaitTimesTodayFileName has been cleared.")
        Write-Output("$($uniqueRecords.Count) total records have been successfully archived to $csvWaitTimesArchiveFileName.")
    } else {
        Write-Output "$csvWaitTimesTodayFileName is empty. No records to archive."
    }
}
catch {
    Write-Error "An error occurred: $_"
}
