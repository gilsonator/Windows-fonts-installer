# Simple Windows Font Installer.

This script copies font files `(*.ttf)` to the relevant Windows location, either user's Fonts folder, or the System Fonts folder.

## Example
```PowerShell
.\installFonts.ps1 -SourcePath 'D:\Development\PowerShell\fonts\testFonts\'
```
Searches for `*.ttf` files in the location privided in `-SourcePath` parameter, then copies found font files to the Windows Font Path. 
    
### Notes
* Checks if running on a Windows OS.
* Checks if script is run in an elevated mode.
  
If running in elevated mode, installs fonts found for all users.
