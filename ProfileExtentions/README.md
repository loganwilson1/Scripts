# Profile Extensions
To collect all the other Profile Extentions, add these lines to your profile
```ps1
$profileExtentionsDir = "C:\Projects\Scripts\ProfileExtentions"
Get-ChildItem $profileExtentionsDir\*.ps1 | ForEach-Object { . $_ }
```