
# Make necessary directories
# Symlink file if it doesn't exist already
function New-SymLink($Path, $Target)
{
    if (Test-Path $Path)
    { 
        Write-Host "Skipping: $Path"
        return 
    }

    New-Item -ItemType Directory (Split-Path $Path) -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path $Path -Target (Resolve-Path $Target).Path | Out-Null
    Write-Host "Linked: $Path"
}

# Install apps
winget install Neovim.Neovim
winget install marlocarlo.psmux
winget install sharkdp.fd
winget install ajeetdsouza.zoxide
winget install junegunn.fzf
winget install Microsoft.PowerShell

# Install powershell modules
Install-Module -Name PSFzf
Install-Module -Name PSReadLine

# Symlink config files
New-SymLink "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "..\powershell\Microsoft.PowerShell_profile.ps1"
New-SymLink "$HOME\AppData\Local\nvim\init.lua" "..\nvim\init.lua"
New-SymLink "$HOME\.config\psmux\psmux.conf" "..\tmux\tmux.conf"

Write-Host "All done. Please update the terminal to use plain Powershell by default"
