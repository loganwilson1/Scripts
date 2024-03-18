<#
Clones a repo within the $personalGitUserName (set within the PS $Profile)

Future enhancements:
    - Make it automatically use a validate set of the list of all repos within the desired $GitUserName
    (would require Git Api, rest calls, or Git Powershell to accomplish)
#>
Param
(
    [parameter(Position = 0, Mandatory = $true)][string]$RepoName,
    [parameter(Position = 1)][string]$GitUserName = ''
)

if ($GitUserName -eq '') {
    if ($null -eq $personalGitUserName) {
        Write-Host "You need to add the `$personalGitUserName variable to your Microsoft.Powershell_Profile.ps1 file."
        break
    } else {
        $GitUserName = $personalGitUserName
    }
}


Set-Location C:/projects
git clone https://github.com/$personalGitUserName/$RepoName
Set-Location $RepoName
git remote -v