<#
Get-Projects

Returns a dictionary of all projects in C:/projects with key value pairs of project Name and project FullName (path)
Used in concert with Switch-Project.ps1
#>
$projectsPath = "C:/projects"
$projects = [ordered]@{} 
Get-ChildItem -Path $projectsPath | ForEach-Object { $projects.Add($_.Name, $_.FullName) }

return $projects