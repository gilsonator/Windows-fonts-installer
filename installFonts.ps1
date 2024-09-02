<#
.SYNOPSIS
    Simple font installer.

.DESCRIPTION
    This script copies font files (*.ttf) to the relevant Windows location, based on user account or admin privileges.

    By David Gilson

.PARAMETER SourcePath
    Location of the font files (*.ttf) to install.

.EXAMPLE
    installFonts.ps1 -SourcePath '.\MesloLGS NF\'

    Searches for *.ttf files in the specified location and copies them to the Windows Font Path.
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

# Check if running as admin and set the appropriate fonts path
$isAdmin = ([Security.Principal.WindowsPrincipal] `
     [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# TODO: DEV
# $isAdmin = $true

$FontsPath = if ($isAdmin) {
    [System.Environment]::GetFolderPath('Fonts')
} else {
    $("$env:LOCALAPPDATA\Microsoft\Windows\Fonts")
}

$($isAdmin ? $(Write-Host -ForegroundColor Red “NOTE: Running in elevated mode will install for all users!”) : "" )

# TODO: Dev
#$FontsPath = "D:\Development\tmp"

Write-Host "Do you want to install font files from: " -NoNewline
Write-Host "`"$sourcePath`"" -ForegroundColor Yellow -NoNewline
Write-Host " to: " -NoNewline
Write-Host "`"$FontsPath`"" -ForegroundColor Yellow -NoNewline
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
                Write-Progress -Activity "Copying Fonts" -Status "Copying $($_.Name)" -PercentComplete $percentComplete
                Copy-Item -Path $_.FullName -Destination $FontsPath
                Start-Sleep -Milliseconds 1000
            }
        } else {
            Write-Host "No fonts found in: $sourcePath" -ForegroundColor Blue
        }
    Write-Host "Operation complete, $totalFiles Fonts installed." -ForegroundColor Blue
} else {
    Write-Host "Operation cancelled by user." -ForegroundColor Blue
}
Write-Host ""