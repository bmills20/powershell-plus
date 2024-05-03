# Set $PSUserProfile
$env:PSUserProfile = "~\OneDrive\Documents\PowerShell"

. "$PSScriptRoot\functions.ps1"
. "$PSScriptRoot\aliases.ps1"

# Initialize zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Import miniconda/conda/mamba configuration
if (Test-Path "$PSScriptRoot\conda_init.ps1") {
    Write-Host "conda_init.ps1 found, importing."
    . "$PSScriptRoot\conda_init.ps1"
}
else {
    Write-Host "conda_init.ps1 not found, skipping import."
}

# Initialize oh-my-posh
if (Test-Path "$PSScriptRoot\catppuccin_frappe.omp.json") {
    Write-Host "catppuccin_frappe.omp.json found, initializing oh-my-posh."
    oh-my-posh --init --shell pwsh --config "$PSScriptRoot\catppuccin_frappe.omp.json" | Invoke-Expression
}
else {
    Write-Host "catppuccin_frappe.omp.json not found, skipping oh-my-posh initialization."
}

# Set PSReadLine key handlers and options
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Tab -Function ForwardChar
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# Enable Starship (https://starship.rs/)
# * If using starship, zoxide must be initialized after starship
Invoke-Expression (&starship init powershell)



# Import zoxide configuration
# * If using starship, zoxide must be initialized after starship
if (Test-Path "$PSScriptRoot\zoxide_init.ps1") {
    . "$PSScriptRoot\zoxide_init.ps1"
    Write-Host "zoxide_init.ps1 found, importing."
}
else {
    Write-Host "zoxide_init.ps1 not found, skipping import."
}