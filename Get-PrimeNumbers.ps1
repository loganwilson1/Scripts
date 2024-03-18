<#
.Synopsis
    Returns an array of all prime numbers between min and max variables. 
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
    [parameter(Position = 1)][int]$Max = 100,
    # System function configs
    $MinimumInt = 1
)

if ($Min -lt $MinimumInt -or $Max -lt $MinimumInt) 
{
    throw "Both parameters must be greater than 0."
}

function Test-IsPrime($number) {
    if ($number -le 1) {
        return $false
    }
    for ($i = 2; $i -lt $number; $i++) {
        if ($number % $i -eq 0) {
            return $false
        }
    }

    return $true
}

[int[]]$primeNumbers=@()

# for each value between $Min and $Max determine if the number is prime
for ($i = $Min; $i -le $Max; $i++) {
    if (Test-IsPrime $i) {
        $primeNumbers += $i
    }
}

Write-Verbose("Found $($primeNumbers.Length) prime numbers between $Min and $Max")

return $primeNumbers