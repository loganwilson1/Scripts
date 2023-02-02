<#
Extentions for Git
#>

Import-Module posh-git
$personalGitUserName = "loganwilson1"

function gitPushf() {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    git push origin $currentBranch --force-with-lease
}

function gitSync() {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    git pull origin $currentBranch --rebase
    gitPushf
}