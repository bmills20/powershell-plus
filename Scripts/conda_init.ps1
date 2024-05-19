
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "K:\tools\miniforge3\Scripts\conda.exe") {
    (& "K:\tools\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ? { $_ } | Invoke-Expression
}
#endregion

