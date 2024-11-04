<#
.SYNOPSIS
Clones a GitHub repo

.DESCRIPTION
Clones a GitHub repo to the desired directory (to C:/projects if the $Directory path is not provided),
and optionally sets up a remote targetting the forkedFromUrl (if provided).

.PARAMETER RepoName
The name of the repo to clone. (REQUIRED)

.PARAMETER Directory
The directory to clone the repo to. (Optional)
Defaults to "C:/projects".

.PARAMETER ForkedFromUrl
URL from which the cloned repo was forked. (Optional)

.EXAMPLE
.\New-ClonedRepo.ps1 -RepoName Scripts
Clones the user's "Scripts" repo.

.\New-ClonedRepo.ps1 -RepoName Scripts -Directory C:/tools
Clones the user's "Scripts" repo to the path 'C:/tools'

.\New-ClonedRepo.ps1 -RepoName Scripts -ForkedFromUrl https://github.com/brianary/scripts
Clones the user's "Scripts" repo and sets up a remote called 'forkedFrom' that targets https://github.com/brianary/scripts

.NOTES
File: New-ClonedRepo.ps1
Author: Logan Wilson
Copyright (c) 2024. All rights reserved.
#>


<#
Future enhancements:
    - Make it automatically use a validate set of the list of all repos within the desired $GitUserName
    (would require Git Api, rest calls, or Git Powershell to accomplish)
#>
Param
(
    [parameter(Position = 0, Mandatory = $true)][string]$RepoName,
    [parameter(Position = 1)][string]$Directory = 'C:/projects',
    [parameter(Position = 2)][string]$ForkedFromUrl = ''
)


$gitUserName = Get-GitConfigUserName
Set-Location $Directory
$cloneUrl = "https://github.com/$gitUserName/$RepoName"
git clone $cloneUrl
Set-Location $RepoName

if ($null -ne $ForkedFromUrl) {
    git remote add forkedFrom $ForkedFromUrl
}

git remote -v