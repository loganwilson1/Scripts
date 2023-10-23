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

# TODO: This is a work in progress. The actual script I need should set the WindowsInstaller option, not the AlwaysInstallElevated option.
# Also, this script does not correclty set the initial registry values when the Policy Path does not exist. 

#Requires -Version 7
param (
    [ValidateSet("NotConfigured", "Enabled", "Disabled")]
    [string]$PolicySetting = "NotConfigured"
)

$PolicySetting = "Enabled"

$PolicyPath = "HKLM:\Software\Policies\Microsoft\Windows\Installer"
# TODO: Use the correct Policy Name
$PolicyName = "AlwaysInstallElevated"

# Function to modify the Windows Installer policy
Function Set-WindowsInstallerPolicy {
    param (
        [string]$PolicySetting
    )

    # Check if the policy path exists, and create it if it doesn't
    if (!(Test-Path $PolicyPath)) {
        # TODO: This isn't quite correct. Need to properly setup the Registry value 
        New-Item -Path $PolicyPath -Force
    }
    
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
            switch ($PolicySetting -eq "Disabled") { 
                $true { Invoke-PolicySettingModifiedSuccessfully }
                $false { Invoke-PolicySettingModifiedFailure }
                default {break}
            }
        }
        1 { 
            switch ($PolicySetting -eq "Enabled") {
                $true {Invoke-PolicySettingModifiedSuccessfully}
                $false {Invoke-PolicySettingModifiedFailure}
                default {break}
            }
        }
        default {
            switch ($PolicySetting -eq "NotConfigured") {
                $true {Invoke-PolicySettingModifiedSuccessfully}
                $false {Invoke-PolicySettingModifiedFailure}
                default {break}
            }
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