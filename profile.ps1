
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "K:\Users\braxt\mambaforge-pypy3\Scripts\conda.exe") {
    (& "K:\Users\braxt\mambaforge-pypy3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

