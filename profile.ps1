
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\tools\miniforge3\Scripts\conda.exe") {
    (& "C:\tools\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

