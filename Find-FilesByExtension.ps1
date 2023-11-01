<#
.SYNOPSIS
Recursively scan for files by extension types and export to csv.

.DESCRIPTION
This script recursively scans a specified folder and its subfolders for files with specific extensions while excluding certain paths. 
The script excludes certain folders by FullName and Name (see the $ExcludedPaths variable).
Finally, the script exports a csv list of matching files to a CSV file named "FileSearch.csv".

The script accepts two parameters:
- $Path: The parent path from which to recursively scan for files.
- $FileExtensions: A comma-separated list of desired file extensions.

The script converts file extensions into an array and ensures that they start with a period if not already.

It defines paths to exclude from the recursive scan and initializes counters for the number of folders searched and stores matching files.

The script searches for matching files in the specified folder and its subfolders, 
adds matching files to the $FilesFound array, and increments the folder counter. 
After the search is complete, it exports the $FilesFound array to a CSV file named "FileSearch.csv" 
and displays the total number of folders searched.

.PARAMETER Path
The parent folder path from which to start the recursive search.

.PARAMETER FileExtensions
A comma-separated list of file extensions to search for. If an extension does not start with a period, the script will prepend one.

.EXAMPLE
.\Find-FilesByExtension.ps1 -Path "C:\temp\photos" -FileExtensions "jpg,png,doc"
Searches for JPG, PNG, and DOC files in the "C:\temp\photos" directory and its subfolders.

.NOTES
File: Find-FilesByExtension.ps1
Author: Logan Wilson
Copyright (c) 2023. All rights reserved.
#>

param(
    [parameter(Position = 0, Mandatory = $true)][string]$Path,
    [parameter(Position = 1, Mandatory = $true)][string[]]$FileExtensions
)

# Convert the comma-separated list of extensions into an array
$ExtensionsArray = $FileExtensions -split ',' | ForEach-Object {
    if (-not $_.StartsWith(".")) {
        # If the extension doesn't start with a period, prepend it
        ".$_"
    } else {
        $_
    }
}


# Define paths to exclude from recursive scanning
$ExcludedPaths = @(
    'C:\Windows',
    'node_modules'
    # Add other paths you want to exclude here
)

$FilesFound = @()
[int]$FolderCount = 0

# Function to recursively search for files
function Search-Files {
    param([string]$FolderPath)
    $global:FolderCount++
    Write-Host("Scanning $FolderPath")
    # Get all files in the current folder
    $files = Get-ChildItem -Path $FolderPath -File | Where-Object { $ExtensionsArray -contains $_.Extension }

    # Output the found files
    $files | ForEach-Object {
        Add-FileInfoToFilesFound -File $_
    }

    # Recursively search subfolders
    $subfolders = Get-ChildItem -Path $FolderPath -Directory | Where-Object { !($ExcludedPaths -contains $_.FullName -or $ExcludedPaths -contains $_.Name) }
    $subfolders | ForEach-Object {
        Search-Files -FolderPath $_.FullName
    }
}

function Add-FileInfoToFilesFound {
    param([object]$File)
    Write-Verbose "Found file: $($_.FullName)"
    $global:FilesFound += [Ordered]@{
        FullName = $_.FullName
        Name = $_.Name
        Extension = $_.Extension
        Length = $_.Length
        CreationTime = $_.CreationTime
    }
}

# Start the search from the specified path
Search-Files -FolderPath $Path

# Export
$csvExportPath = Join-Path -Path $Path -ChildPath "FileSearch.csv"
$FilesFound | Export-Csv -Path $csvExportPath -NoTypeInformation

# Summarize
Write-Host("Completed scan for the following file extensions: $ExtensionsArray")
Write-Host("Recursively searched through $FolderCount folders within $Path")
Write-Host("Found $($FilesFound.Length) files")
