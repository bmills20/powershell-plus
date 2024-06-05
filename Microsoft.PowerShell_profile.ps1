# Set file paths
$functionsPath = "$PSScriptRoot\Scripts\functions.ps1"
$aliasesPath = "$PSScriptRoot\Scripts\aliases.ps1"
$nvmPath = "$HOME\.nvm"

# Lazy-load functions and aliases
function Import-MyFunctions {
    . $functionsPath
}

function Import-MyAliases {
    . $aliasesPath
}

# Load NVM only when needed
function Invoke-NVM {
    $detectedFolders = @('node_modules')
    $currentDirectory = Get-Location

    foreach ($folder in $detectedFolders) {
        if (Test-Path -Path (Join-Path -Path $currentDirectory -ChildPath $folder)) {
            if (Test-Path "$nvmPath\nvm.ps1") {
                . "$nvmPath\nvm.ps1"
            }
            if (Test-Path "$nvmPath\nvm-bash-completion.ps1") {
                . "$nvmPath\nvm-bash-completion.ps1"
            }
            break
        }
    }
}

if (!(Test-Path "./node_modules" -PathType Container)) { 
    write-host "-- Path not found"
}
else {
    write-host "-- Path found"
}

# Asynchronously load NVM
$nvmLoader = @{
    InvokeNVM = ${function:Invoke-NVM}
}

$nvmLoader | ForEach-Object -Parallel {
    # Set the necessary function in the parallel script block
    $InvokeNVM = $_.InvokeNVM

    # Invoke the Load-NVM function
    & $InvokeNVM
}

# Asynchronously load modules
$modules = @('PSReadLine', 'Az.Tools.Predictor', 'posh-git')

# ForEach-Object -Parallel is a cmdlet introduced in PowerShell 7.0 that allows you to execute a script block in parallel for each input object.
# It automatically distributes the processing of each object across multiple threads, enabling concurrent execution and potentially speeding up the processing time.
$modules | ForEach-Object -Parallel {
    Import-Module -Name $_
}

# Set PSReadLine options
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Tab -Function ForwardChar
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# Load other configurations
. "$PSScriptRoot\Scripts\conda_init.ps1"

# Initialize oh-my-posh
oh-my-posh init pwsh --config 'C:\Users\braxt\OneDrive\Documents\PowerShell\Scripts\pwsh10k.omp.json' | Invoke-Expression