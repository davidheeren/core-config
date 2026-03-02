
# If you can't run the script, allow it for this session
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Make necessary directories
# Symlink file if it doesn't exist already
function New-SymLink($Path, $Target)
{
    if (Test-Path $Path)
    { 
        Write-Host
        Write-Host "$Path already exists:"
        Write-Host "[S] Skip  [F] Delete file  [D] Delete folder contents"
        $choice = Read-Host "Choice (default: S)"

        switch ($choice.ToUpper())
        {
            "F"
            {
                [System.IO.File]::Delete($Path) 
            }
            "D"
            {
                # This will fail on powershell dir if its the shell
                [System.IO.Directory]::Delete((Split-Path $Path), $true) 
            }
            default
            { 
                Write-Host "Skipping: $Path"
                return 
            }
        }
    }

    New-Item -ItemType Directory (Split-Path $Path) -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path $Path -Target (Resolve-Path $Target).Path | Out-Null
    Write-Host "Linked: $Path"
}

# Symlink config files
New-SymLink "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "..\powershell\Microsoft.PowerShell_profile.ps1"
New-SymLink "$HOME\AppData\Local\nvim\init.lua" "..\nvim\init.lua"
New-SymLink "$HOME\.config\psmux\psmux.conf" "..\tmux\tmux.conf"
New-SymLink "$HOME\AppData\Roaming\lf\lfrc" "..\lf\win-lfrc"
New-SymLink "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\global.ahk" "..\autohotkey\global.ahk"

# Install powershell modules
Install-Module -Name PSFzf -Force -Scope CurrentUser
Install-Module -Name PSReadLine -Force -Scope CurrentUser

# Nice for recycle using powershell terminal but not good for lf
# Install-Module -Name PoshFunctions -Force -Scope CurrentUser

# Install apps
winget install Neovim.Neovim
winget install marlocarlo.psmux
winget install sharkdp.fd
winget install ajeetdsouza.zoxide
winget install junegunn.fzf
winget install Microsoft.PowerShell
winget install AutoHotkey.AutoHotkey

# Start right now bc we symlink it to run on startup
..\autohotkey\global.ahk

Write-Host "All done"
Write-Host "Please update the terminal to use plain Powershell by default (pwsh)"
