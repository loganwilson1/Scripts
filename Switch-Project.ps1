<#
.Synopsis
    Change directory between projects.
.Description
    Script used in concert with Get-Projects to switch between projects.
    This script is aliased as 'nav', since it navigates to the disired project.
    All new projects will automatically work when a new PS Session is loaded since Get-Projects iterates over all paths in the project folder.
.Link
    Get-Projects.ps1
.Example
    PS C:\>Switch-Project scripts
    Will change the current working directory to the directory of 'scripts'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ArgumentCompleter(
        {
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            (Get-Projects).keys | Where-Object { $_ -like "$wordToComplete*" }
        }
    )]
    [ValidateScript(
        {
            (Get-Projects).keys -Contains $_
        }
    )]
    [string] $Project
)    
Push-Location (Get-Projects)[$Project]

