<#
.SYNOPSIS
Determines if the current directory or given directory is a git repository

.DESCRIPTION
Returns true or false

Accepts a parameter of the full file path to check, else uses the current file path

.PARAMETER Path
The path to check

.EXAMPLE
.\Get-IsGitRepository.ps1
Determines if current directory is a Git repository.

.\Get-IsGitRepository.ps1 -path 'C:/tools'
Determines if the path 'C:/tools' is a Git repository.

.NOTES
File: Get-IsGitRepository.ps1
Author: Logan Wilson
Copyright (c) 2024. All rights reserved.
#>

param(
    [parameter(Position = 0)][string]$Path = ''
)
# $Path = 'C:/projects/Scripts'
$startingDirectory = Get-Location
if ($Path -eq '') {
    $Path = $startingDirectory.Path
}
Set-Location $Path
$isGitRepo = git rev-parse --is-inside-work-tree 2>$null
Set-Location $startingDirectory

Write-Output ($isGitRepo -eq 'true')