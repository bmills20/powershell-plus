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
$zoxidePath = (Get-Command zoxide).Source

if (Test-Path $zoxidePath) {
    $acl = Get-Acl $zoxidePath
    $permissions = $acl.Access | Where-Object { $_.IdentityReference.Value -eq "$env:USERDOMAIN\$env:USERNAME" }
    
    if ($permissions.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Read -and
        $permissions.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::ExecuteFile) {
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    }
    else {
        Write-Output "Zoxide does not have the necessary permissions to run."
    }
}
else {
    Write-Output "Zoxide is not accessible."
}


# Import miniconda/conda/mamba configuration
if (Test-Path "$PSScriptRoot\Scripts\conda_init.ps1") {
    . "$PSScriptRoot\Scripts\conda_init.ps1"
}

Import-Module -Name PSReadLine
Import-Module Az.Tools.Predictor
# Set PSReadLine key handlers and options
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Tab -Function ForwardChar
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

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
. "$PSScriptRoot\gh-copilot.ps1"

. "C:\Users\braxt\.config\path.ps1"
. "C:\Users\braxt\OneDrive\Documents\PowerShell\Scripts\gh-copilot.ps1"
Import-Module posh-git
oh-my-posh init pwsh --config 'C:\Users\braxt\OneDrive\Documents\PowerShell\Scripts\pwsh10k.omp.json' | Invoke-Expression
