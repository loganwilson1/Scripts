<#
.SYNOPSIS
Gets the user's GitHub username from git config

.NOTES
File: Get-GitConfigUserName.ps1
Author: Logan Wilson
Copyright (c) 2024. All rights reserved.
#>

$userName = git config --list | Where-Object { $_ -match '^user.name=' } | ForEach-Object { $_ -replace 'user.name=', '' }

return $userName