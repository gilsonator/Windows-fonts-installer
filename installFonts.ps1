<#
.SYNOPSIS
    Simple font installer.

.DESCRIPTION
    Depending on user or admin privileges, this script copies font files (*.ttf) to the appropriate Windows directory 
    and updates the relevant Windows Registry entries.

    By David Gilson

.PARAMETER SourcePath
    Location of the font files (*.ttf) to install.

.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-itemproperty?view=powershell-7.4

.EXAMPLE
    .\installFonts.ps1 -SourcePath 'D:\Development\PowerShell\fonts\testFonts\'

    Searches for *.ttf files in the specified location and copies them to the relevant Windows Font Path.
    If running in elevated mode, installs for all users.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SourcePath
)

#Clear-Host

if ($PSVersionTable.OS -notlike "*Windows*") {
    throw "This script can only be run on Windows."
} 

$sourcePath = New-Object System.IO.DirectoryInfo($SourcePath) | ForEach-Object { $_.FullName }

$FontRegistryPathHash = @{
    CurrentUser = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    AllUsers    = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
}

$FontFolderPathHash = @{
    CurrentUser = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    AllUsers    = "$($env:windir)\Fonts" # [System.Environment]::GetFolderPath('Fonts')
}

# Check if running as admin
# one way:
# $isAdmin = ([Security.Principal.WindowsPrincipal] `
#     [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# better way:
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# TODO: Setup testing for DEV
# $isAdmin = $true

$fontsPath = if ($isAdmin) { $FontFolderPathHash.AllUsers } else { $FontFolderPathHash.CurrentUser }

if ($isAdmin) { $(Write-Host -ForegroundColor Red “NOTE: Running in elevated mode will install for all users!”) }

# TODO: Dev
#$fontsPath = "D:\Development\tmp"

Write-Host "Do you want to install font files from: " -NoNewline
Write-Host "`"$sourcePath`"" -ForegroundColor Yellow -NoNewline
Write-Host " to: " -NoNewline
Write-Host "`"$fontsPath`"" -ForegroundColor Yellow -NoNewline
Write-Host "? (Y/N): " -NoNewline
$confirmation = Read-Host

if ($confirmation -eq 'Y') {
    $fontFiles = Get-ChildItem -Path $sourcePath -Filter '*.ttf'
        if ($fontFiles.Count -gt 0) {
            $totalFiles = $fontFiles.Count
            $currentFile = 0

            $fontFiles | ForEach-Object {
                $currentFile++
                $percentComplete = ($currentFile / $totalFiles) * 100
                Write-Progress -Activity "Installing Fonts" -Status "Installing $($_.Name)" -PercentComplete $percentComplete
                Copy-Item -Path $_.FullName -Destination $fontsPath

                # if admin then just fileName else path to users font path
                $regValue = if ($isAdmin) { $fontFileName } else { $fontsPath }
                $regPath  = if ($isAdmin) { $FontRegistryPathHash.AllUsers } else { $FontRegistryPathHash.CurrentUser }
                $params = @{
                    Name         = 'TrueType Font'
                    Path         = $regPath
                    PropertyType = 'string'
                    Value        = $regValue
                    Force        = $true
                    ErrorAction  = 'Stop'
                }
                $tmp = New-ItemProperty @params

                Start-Sleep -Milliseconds 1000
            }
            $output = "Operation complete, $totalFiles Fonts installed." 
        } else {
            $output = "No fonts found in: $sourcePath" 
        }
} else {
    $output = "Operation cancelled by user." 
}
Write-Host
Write-Host $output -ForegroundColor Blue
