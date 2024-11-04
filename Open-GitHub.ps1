<#
.SYNOPSIS
Opens GitHub in the browser.

.DESCRIPTION
Opens GitHub in the browser. If the current location is a git repo AND the user has configured their git username,
    then the current user's git repo will be opened, otherwise the GitHub main page.

.PARAMETER PrFlag
Flag to start a GitHub PR

.EXAMPLE
.\Open-GitHub.ps1 -PrFlag
Opens GitHub start PR page

.EXAMPLE
.\Open-GitHub.ps1
Opens GitHub

.NOTES
File: Open-GitHub.ps1
Author: Logan Wilson
Copyright (c) 2024. All rights reserved.
#>    

param(
    [parameter(Position = 0)][switch]$PrFlag
)
$gitHubBaseAddress = "https://github.com"
$isGitRepo = Get-IsGitRepository
$gitUserName =  Get-GitConfigUserName
if ($isGitRepo -and $null -ne $gitUserName) {
    $gitRepoName = (Get-Item (git.exe rev-parse --show-toplevel)).BaseName
    if ($PrFlag) {
        # Open GitHub PR 
        $gitBranch = git rev-parse --abbrev-ref HEAD
        $url = $gitHubBaseAddress+"/"+$gitUserName+"/"+$gitRepoName+"/compare/main..."+$gitBranch  # TODO": Enable compare branch
        Start-Process $url
    }
    else {
        # Open GitHub Repo
        $url = $gitHubBaseAddress+"/"+$gitUserName+"/"+$gitRepoName
        Start-Process $url
    }
}
else {
    # Open GitHub
    Start-Process $gitHubBaseAddress
}