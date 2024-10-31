<#
Extentions for Git
#>

Import-Module posh-git # gets latest
# Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1' # gets posh-git 0.7.3.1

function gitPushf() {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    git push origin $currentBranch --force-with-lease
}

function gitSync() {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    git pull origin $currentBranch --rebase
    gitPushf
}

function Get-GitLogGraph() {
    param(
    [parameter(Position = 0)][Alias("n")][int]$NumberOfCommitsToDisplay = 7
    )
    git log -n $NumberOfCommitsToDisplay --oneline --graph --decorate
}
Set-Alias -Name gg -Value Get-GitLogGraph