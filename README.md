# Simple Windows Font Installer.

Depending on user or admin privileges, this script copies font files (*.ttf) to the appropriate Windows directory and updates the relevant Windows Registry entries.

## Example
```PowerShell
.\installFonts.ps1 -SourcePath 'D:\Development\PowerShell\fonts\testFonts\'
```
Searches for `*.ttf` files in the location privided in `-SourcePath` parameter, then copies found font files to the Windows Font Path. 
    
### Notes
* Checks if running on a Windows OS.
* Checks if script is run in an elevated mode.
  
If running in elevated mode, installs fonts found for all users.

---
I created this to outline my skills as part of my ongoing job search.