# Simple Windows Font Installer.

This script copies font files (*.ttf) to the relevant Windows location, based on user account or admin privileges.

## Example
```PowerShell
.\installFonts.ps1 -SourcePath '.\MesloLGS NF\'
```
Searches for `*.ttf` files in the `-SourcePath` location and copies them to the Windows Font Path. 
    
### Notes
    If running in elevated mode, installs fonts found for all users.
