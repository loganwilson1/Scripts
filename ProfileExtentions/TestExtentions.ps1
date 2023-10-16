function TestWriteHost() {
    Write-Host("Hello World!")
}
function VsCodeSettings() {
    code '%APPDATA%\Code\User\settings.json'
}
function Get-ColorOnColorWriteHostCombinations() {
    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors)
    {
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
}