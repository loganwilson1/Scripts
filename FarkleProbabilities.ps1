param (
    [int]$NumberOfDice = 1,
    [int]$NumberOfFacesPerDie = 6
)

# Array to store combinations
$global:Combinations = @()

function Get-DiceCombinations {
    param (
        [int]$DiceCount,
        [object[]]$Combination
    )

    if ($DiceCount -eq 0) {
        if ($global:Combinations.Length % 1000 -eq 0) { Write-Host("Processed $($global:Combinations.Length) combinations")}

        $global:Combinations += @{
            Combination = $Combination
            IsScoringRoll = Get-IsScoringRoll -array $Combination
        }
    }
    else {
        for ($i = 1; $i -le 6; $i++) {
            Get-DiceCombinations -DiceCount ($DiceCount - 1) -Combination ($Combination + $i)
        }
    }
}

function Get-IsScoringRoll {
    param (
        [int[]]$array
    )

    $groupedCounts = $array | Group-Object | Sort-Object Name | Sort-Object Count -Descending 
    # Has a 1 or a 5
    if (($groupedCounts | Where-Object { $_.Name -eq "1" -or $_.Name -eq "5" }).Length -gt 0) 
    { return $true }
    # At least three of a kind
    if ($groupedCounts[0].Count -eq 3) 
        { return $true }
    # Three sets of pairs
    if ($groupedCounts.Length -eq 3 -and $groupedCounts[0].Count -eq 2 -and $groupedCounts[1].Count -eq 2 -and $groupedCounts[2].Count -eq 2) 
        { return $true }
    # is a straight
    if ($groupedCounts.Length -eq $NumberOfFacesPerDie)
        { return $true }


    else 
        { return $false }
}

# Check if NumberOfDice is provided
if (-not $NumberOfDice) {
    Write-Host "Please provide NumberOfDice parameter."
}
else {
    Get-DiceCombinations -DiceCount $NumberOfDice
}

# Output the result
# $global:Combinations
$numberOfCombinations = $global:Combinations.Length
$countOfScoringRolls = ($global:Combinations | Where-Object { $_.IsScoringRoll }).Count
$probablityOfFarkle = 1 - ($countOfScoringRolls / $numberOfCombinations)

Write-Host("Total possibilities: $numberOfCombinations")
Write-Host("Number of scoring rolls: $countOfScoringRolls)")
Write-Host("Probability of Farkle: $probablityOfFarkle")
# Write-Host("Done")

<#
6 dice:
    Total possibilities: 46656
    Number of scoring rolls: 44960)
    Probability of Farkle: 0.0363511659807956

5 dice:
    Total possibilities: 7776
    Number of scoring rolls: 7112)
    Probability of Farkle: 0.0853909465020576

4 dice:
    Total possibilities: 1296
    Number of scoring rolls: 1088)
    Probability of Farkle: 0.160493827160494

3 dice:
    Total possibilities: 216
    Number of scoring rolls: 156)
    Probability of Farkle: 0.277777777777778

2 dice:
    Total possibilities: 36
    Number of scoring rolls: 20)
    Probability of Farkle: 0.444444444444444

1 dice:
    Total possibilities: 6
    Number of scoring rolls: 2)
    Probability of Farkle: 0.666666666666667
#>
