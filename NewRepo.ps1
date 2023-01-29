<#
#>
Param
(
    [parameter(Position = 0, Mandatory = $true)][string]$RepoName,
    [parameter(Position = 1)][string]$GitUserName = 'loganwilson1'
)

if ($personalGitUserName -eq $null) {
    Write-Host "You need to add the `$personalGitUserName variable to your Microsoft.Powershell_Profile.ps1 file."
    break
}

Set-Location C:/projects
git clone https://github.com/$personalGitUserName/$RepoName
Set-Location $RepoName
git remote -v 

#Set-Alias -Name newrepo -Value New-Repo