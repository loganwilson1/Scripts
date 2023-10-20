<#
.SYNOPSIS
This PowerShell script allows you to modify the Windows Local Group Policy setting for Windows Installer.

.DESCRIPTION
The script sets the "Always install with elevated permissions" policy under "Computer Configuration" >> "Administrative Templates" >> "Windows Components" >> "Windows Installer." 
You can choose one of three available options: "NotConfigured," "Enabled," or "Disabled."

.PARAMETER PolicySetting
Specifies the setting for the policy. Valid values are "NotConfigured," "Enabled," or "Disabled." 
The default is "NotConfigured."

.EXAMPLE
.\Set-WindowsInstallerPolicy.ps1 -PolicySetting Enabled
This example sets the policy to "Enabled."

.EXAMPLE
.\Set-WindowsInstallerPolicy.ps1 -PolicySetting Disabled
This example sets the policy to "Disabled."

.EXAMPLE
.\Set-WindowsInstallerPolicy.ps1
This example sets the policy to "NotConfigured" (the default).

.NOTES
File Name      : Set-WindowsInstallerPolicy.ps1
Prerequisite   : Windows PowerShell
Copyright 2023 - Logan Wilson
#>

#Requires -Version 7
param (
    [ValidateSet("NotConfigured", "Enabled", "Disabled")]
    [string]$PolicySetting = "NotConfigured"
)

# Function to modify the Windows Installer policy
Function Set-WindowsInstallerPolicy {
    param (
        [string]$PolicySetting
    )
    
    $PolicyPath = "HKLM:\Software\Policies\Microsoft\Windows\Installer"
    $PolicyName = "AlwaysInstallElevated"

    switch ($PolicySetting) {
        "Enabled" {
            Write-Host "Setting 'Always install with elevated permissions' to Enabled."
            Set-ItemProperty -Path $PolicyPath -Name $PolicyName -Value 1
        }
        "Disabled" {
            Write-Host "Setting 'Always install with elevated permissions' to Disabled."
            Set-ItemProperty -Path $PolicyPath -Name $PolicyName -Value 0
        }
        "NotConfigured" {
            Write-Host "Setting 'Always install with elevated permissions' to Not Configured."
            Remove-ItemProperty -Path $PolicyPath -Name $PolicyName -ErrorAction SilentlyContinue
        }
    }
}

Function Test-WindowsInstallerPolicy {
    $result = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -ErrorAction SilentlyContinue)
    switch ($result.AlwaysInstallElevated ) {
        0 { 
            ($PolicySetting -eq "Disabled") 
                ? Invoke-PolicySettingModifiedSuccessfully
                : Invoke-PolicySettingModifiedFailure
        }
        1 { 
            ($PolicySetting -eq "Enabled")
                ? Invoke-PolicySettingModifiedSuccessfully
                : Invoke-PolicySettingModifiedFailure
        }
        default {
            ($PolicySetting -eq "NotConfigured")
                ? Invoke-PolicySettingModifiedSuccessfully
                : Invoke-PolicySettingModifiedFailure
        }
    }
}

Function Invoke-PolicySettingModifiedSuccessfully {
    Write-Host "Policy setting modified successfully."
    $restartChoice = Read-Host "Do you want to restart the computer? (Y/N)"
    if ($restartChoice -eq "Y" -or $restartChoice -eq "y") {
        Write-Host "Restarting the computer..."
        Restart-Computer -Force
    } else {
        Write-Host "No restart requested."
    }
}

Function Invoke-PolicySettingModifiedFailure {
    Write-Host "Failed to modify the policy setting."
}

# Set the Windows Installer policy
Set-WindowsInstallerPolicy -PolicySetting $PolicySetting

# Check if the policy was set successfully
Test-WindowsInstallerPolicy