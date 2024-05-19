# Set $PSUserProfile
$env:PSUserProfile = "~\OneDrive\Documents\PowerShell"

. "$PSScriptRoot\Scripts\functions.ps1"
. "$PSScriptRoot\Scripts\aliases.ps1"

# Set NVM_DIR environment variable
$env:NVM_DIR = "$HOME\.nvm"

# Load nvm if available
if (Test-Path "$env:NVM_DIR\nvm.ps1") {
    . "$env:NVM_DIR\nvm.ps1"
}

# Load nvm bash_completion if available
if (Test-Path "$env:NVM_DIR\nvm-bash-completion.ps1") {
    . "$env:NVM_DIR\nvm-bash-completion.ps1"
}

# Initialize zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Import miniconda/conda/mamba configuration
if (Test-Path "$PSScriptRoot\Scripts\conda_init.ps1") {
    Write-Host "conda_init.ps1 found, importing."
    . "$PSScriptRoot\Scripts\conda_init.ps1"
}
else {
    Write-Host "conda_init.ps1 not found, skipping import."
}

# Initialize oh-my-posh
#if (Test-Path "$PSScriptRoot\Scripts\catppuccin_frappe.omp.json") {
#    Write-Host "catppuccin_frappe.omp.json found, initializing oh-my-posh."
#    oh-my-posh --init --shell pwsh --config "$PSScriptRoot\Scripts\catppuccin_frappe.omp.json" | Invoke-Expression
#}
#else {
#    Write-Host "catppuccin_frappe.omp.json not found, skipping oh-my-posh initialization."
#}

Import-Module -Name PSReadLine
Import-Module Az.Tools.Predictor
# Set PSReadLine key handlers and options
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Tab -Function ForwardChar
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# Enable Starship (https://starship.rs/)
# * If using starship, zoxide must be initialized after starship

# Import miniconda/conda/mamba configuration
if (Test-Path "$PSScriptRoot\Scripts\init_starship.ps1") {
    Write-Host "init_starship.ps1 found, importing."
    . "$PSScriptRoot\Scripts\init_starship.ps1"
}
else {
    Write-Host "init_starship.ps1 not found, skipping import."
}

if (Test-Path "$PSScriptRoot\Scripts\starship_suggestions.ps1") {
    . "$PSScriptRoot\Scripts\starship_suggestions.ps1"
    Write-Host "starship_suggestions.ps1 found, importing."
}
else {
    Write-Host "starship_suggestions.ps1 not found, skipping import."

}

# Github copilot alias
$GH_COPILOT_PROFILE = Join-Path (Split-Path $PROFILE) -ChildPath "Scripts\gh-copilot.ps1"
$GH_COPILOT_IMPORT_CMD = ". `"$GH_COPILOT_PROFILE`""

# Create or overwrite the gh-copilot.ps1 file
@"
function ghce { gh copilot explain @args }
function ghcs { gh copilot suggest @args }
"@ > $GH_COPILOT_PROFILE

# Corrected command to check if the import command already exists in the profile
if (-not (Select-String -Path $PROFILE -Pattern ([regex]::Escape($GH_COPILOT_IMPORT_CMD)))) {
    $GH_COPILOT_IMPORT_CMD >> $PROFILE
}

# Import zoxide configuration
# * If using starship, zoxide must be initialized after starship
if (Test-Path "$PSScriptRoot\Scripts\zoxide_init.ps1") {
    . "$PSScriptRoot\Scripts\zoxide_init.ps1"
    Write-Host "zoxide_init.ps1 found, importing."
}
else {
    Write-Host "zoxide_init.ps1 not found, skipping import."
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
. "C:\Users\braxt\OneDrive\Documents\PowerShell\Scripts\gh-copilot.ps1"

. "C:\Users\braxt\.config\path.ps1"
