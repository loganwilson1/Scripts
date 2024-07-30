<#
    GENERAL OVERVIEW:
    - Make a call to wait times API for Disneyland and for DCA
    - Foreach ride in the desired list of rides to record, make a wait time record
    - Save the records to an ongoing CSV

#>
$taskRunTime = Get-Date
$waitTimesServer = "https://queue-times.com"
$desiredParkNames = @(
    "Disneyland", 
    "Disney California Adventure"
    )
$csvWaitTimesLastUpdatedOutputName = "WaitTimesLastUpdated.csv" ## TODO: Rework this if the unique record solution doesn't work well.

# Dot-source the configuration file
. "$PSScriptRoot/config.ps1"
<#
    Config.ps1 retains the following variables
        $csvWaitTimesTodayFileName
        $csvWaitTimesTodayFilePath
        $csvWaitTimesArchiveFileName
        $csvWaitTimesArchiveFilePath

#>

# Begin Testing to reduce calls to API

function Get-StubbedDisneylandParks() {

    $dl = [PSCustomObject]@{id=16; name="Disneyland"; country="United States"; continent="North America"; latitude=33.8104856; longitude=-117.9190001; timezone="America/Los_Angeles"}
    $dca = [PSCustomObject]@{id=17; name="Disney California Adventure"; country="United States"; continent="North America"; latitude=33.8058755; longitude=-117.9194899; timezone="America/Los_Angeles"}


    $stubbedParks = [PSCustomObject]@{
        id = 2;
        name="Walt Disney Attractions";
        parks=[Object[]]@($dl, $dca)}

    return $stubbedParks
}

# End Testing to reduce calls to API

## Begin internal functions region

function Get-IsDuringOperatingHours() {
        # Get the current datetime
        $currentDateTime = Get-Date

        # Define the start and end hours
        $startHour = 8   # 8 AM
        $endHour = 24    # Midnight (00:00 of the next day)
    
        # Check if the current time is within the specified range
        if ($currentDateTime.Hour -ge $startHour -and $currentDateTime.Hour -lt $endHour) {
            return $true
        } else {
            return $false
        }
}

function Invoke-GetRequest {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    try {
        # Create a web request
        Write-Verbose("Making GET request to $Url")
        $response = Invoke-RestMethod -Uri $Url -Method Get

        return $response
    }
    catch {
        # Handle exceptions
        $functionName = $MyInvocation.MyCommand.Name
        Write-Error "Error occurred in $functionName with Url $($Url): $_"
    }
}

function Get-ParksList() {
    # # stubbed testing - DO NOT COMMIT!
    # return Get-StubbedDisneylandParks

    # Url to get parks list
    $url = "$($waitTimesServer)/parks.json"
    $parks = Invoke-GetRequest -Url $url

    return $parks
}

filter Get-WaitTimesForPark() {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName= $true)][int]$id
    )

    process {
        $url = "$($waitTimesServer)/parks/$($id)/queue_times.json"
        $parksList = Invoke-GetRequest -Url $url
    
        return $parksList
    }
}

function Convert-UtcToPacificDateTime($utcDateTime) {
    # Get the Pacific Time zone
    $pacificTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
    
    # Convert UTC to Pacific Time
    $pacificDateTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($utcDateTime, $pacificTimeZone)

    return $pacificDateTime
}

filter Get-RestructuredWaitTimes() {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName= $true)][string]$name,
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName= $true)][int]$id
    )

    process {
        $parkName = $name

        Write-Host("Processing Park: $parkName")
        $restructuredRidesList = [Object[]]@()
        $rides = Get-WaitTimesForPark -id $id
    
        foreach ($land in $rides.lands) {
            Write-Host("Processing Land: $($land.name)")
            foreach ($ride in $land.rides) {
                Write-Host("Processing Ride: $($ride.name)")
                $restructuredRide = $null
                $restructuredRide = [PSCustomObject]@{
                    Park = $parkName;
                    Land = $land.name;
                    Name = $ride.name;
                    IsOpen = $ride.is_open;
                    WaitTime = $ride.wait_time;
                    LastUpdated = Convert-UtcToPacificDateTime($ride.last_updated)
                    TaskRunTime = $taskRunTime
                }
                $restructuredRidesList += $restructuredRide
            }
        }

        <#
        TODO: Improve logic for determining if wait times should be updated.
            Each park and ride get updated from the server at different times
            So I can't just get the first LastUpdated datetime in the ride list and assume they all are the same
            And improved process would need to import all the ride info saved to csv, then find the last updated time for that specific ride.
            This might be resource intensive as the csv gets bigger.
            One solution would be to:
                Have a working csv for the day. 
                Then at the end of the day, a second script migrates all the records from the working csv into the archive csv for processing. 
                This would allow for data analysis of archived records without interferring with today's record saving
            A simpler solution for now is to just pull data every 10 minutes and assume the records have been updated. (Going with this for now)
        #>
        $lastUpdated = $restructuredRidesList[0].LastUpdated #rename to parkTimesLastUpdatedOnServer
        $shouldUpdateWaitTimesForParkName = $true
        # $shouldUpdateWaitTimesForParkName = Get-ShouldUpdateWaitTimesForParkName -ParkName $name -LastUpdatedDateTime $lastUpdated # SEE TODO ABOVE
        if ($shouldUpdateWaitTimesForParkName) {
            return $restructuredRidesList
        }
        else {
            Write-Verbose("LastUpdated datetime for $name is the same. Skipping this park.")
            return [Object[]]@()
        }

        return $restructuredRidesList
    }
}

function Get-ShouldUpdateWaitTimesForParkName {
    param (       
        [Parameter(Mandatory = $true)][string]$ParkName,
        [Parameter(Mandatory = $true)][datetime]$LastUpdatedDateTime
    )

    try {
        $csvWaitTimesLastUpdatedPath = "" # TODO: 
        # Import the CSV file into an array of objects
        $records = Import-Csv -Path $csvWaitTimesLastUpdatedPath

        # Find the record where the Park (name) property equals the ParkName
        $record = $records | Where-Object { $_.Park -eq $ParkName }
        if ($null -eq $record) {
            Write-Output "No record found with Name '$ParkName'."
            return $false
        }

        if ($record.LastUpdate -eq $LastUpdatedDateTime) {
            # do not store the records, and return false
            Write-Output "LastUpdated datetime for $ParkName is the same."
            return $false
        } else {
            $record.LastUpdated = $LastUpdatedDateTime
            ## RESAVE THE CSV
            $records | Export-Csv -Path $csvWaitTimesLastUpdatedPath -NoTypeInformation -Force
            return $true
        }
    }
    catch {
        # Handle exceptions
        Write-Error "Error occurred: $_"
    }
}

function Get-DisneylandParks() {
    $parks = Get-ParksList
    $waltDisneyParks = $parks 
        | Where-Object { $_.name -eq "Walt Disney Attractions"}
    
    # why do I need to create this variable in order to gain access to $desiredParks ???
    $parksToFilter = $desiredParkNames

    # Filter parks to desired parks and return their IDs
    $desiredParks = $waltDisneyParks.parks 
        | Where-Object { $parksToFilter -contains $_.name } 

    return $desiredParks
}

# This is the main entry point for the entire script
function Invoke-RecordWaitTimes() {
    $disneylandParks = Get-DisneylandParks

    $waitTimes = $disneylandParks | Get-RestructuredWaitTimes
    
    if ($waitTimes.Count -eq 0) {
        Write-Host("Nothing to update")
    } else {
        Write-Host("Exporting wait times to csv")
        $waitTimes | Export-Csv -Path $csvWaitTimesTodayFilePath -Append -NoTypeInformation -Force # -Encoding UTF8
        Write-Host("Exported a total of $($waitTimes.Count) wait times to $csvWaitTimesTodayFileName")
    }
}

## End internal functions region

if (Get-IsDuringOperatingHours) {
    Invoke-RecordWaitTimes
} else {
    Write-Host("The current time is not between 8am and midnight. Skipping exection.")
}

Write-Host("DONE")
