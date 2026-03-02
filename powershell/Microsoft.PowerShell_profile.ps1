
Import-Module PSReadLine

# Search history with filter
Set-PSReadLineKeyHandler -Key UpArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward()
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
}

Set-PSReadLineKeyHandler -Key DownArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
}

# Use fzf tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Start zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function prompt {
    Write-Host "PS $(($executionContext.SessionState.Path.CurrentLocation.Path) -replace ([regex]::Escape($HOME)), '~')>" -NoNewline -ForegroundColor Magenta
    " "
}
