<#
.Synopsis
    Returns a hashtable of all values between min and max, containining an array of all their prime common denominators.
    
.Description
    TODO:
.Link
    Get-PrimeNumbers.ps1
.Example
    TODO:
#>

[CmdletBinding()]
param(
    [parameter(Position = 0)][int]$Min = 1,
    [parameter(Position = 1)][int]$Max = 1000,
    # System function configs
    $MinimumInt = 1
)

if ($Min -lt $MinimumInt -or $Max -lt $MinimumInt) 
{
    throw "Both parameters must be greater than 0."
}

[int[]]$primeNumbers = Get-PrimeNumbers.ps1 -Min 1 -Max $Max
$NumberDenominators = @()

function Get-PrimeDenominators() {
    param(
        [parameter(Position = 0, Mandatory = $true)][int]$Number,
        [parameter(Position = 1, Mandatory = $true)][int[]]$PrimeNumbers,
        # System function configs
        $MinimumInt = 1
    )
    $NumberInfo = [Ordered]@{
        Number = $Number
        CommonPrimeDenominators = @()
    }
    $denominator = $Number
    $primeNumbersToTest = $primeNumbers | Where-Object { $_ -le $denominator } | Sort-Object -Descending
    for ($i = 0; $i -lt $primeNumbersToTest.Length; $i++) {
        $primeNumberUnderTest = $primeNumbersToTest[$i]
        if ($denominator % $primeNumberUnderTest -eq 0) {
            # add to the $NumberDenominators
            $NumberInfo.CommonPrimeDenominators += $primeNumberUnderTest
            # Set the new denominator
            $denominator = ($denominator / $primeNumberUnderTest)
            # Start the loop over again
            $i = 0
        }
    }
    Write-Verbose("Debug")

    return $NumberInfo
}

# for each value between $Min and $Max determine if the number is prime
for ($i = $Min; $i -le $Max; $i++) {
    # For each number, get the common prime denominators
    # TODO: This is already in a for loop. The function can just live here
    $NumberDenominators += Get-PrimeDenominators -Number $i -PrimeNumbers $primeNumbers
}
$csvPath = "./PrimeDenominators.csv"

$csvShape = $NumberDenominators | ForEach-Object {
    @{
        Number = $_.Number
        CommonPrimeDenominators = $_.CommonPrimeDenominators | Join-String -Separator "," 
    }
}
      

$csvShape | Export-Csv -Path $csvPath -NoTypeInformation -UseQuotes Always