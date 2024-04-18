# =============================================================================
# Initialization
# =============================================================================

# Initialize zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Import zoxide configuration
. "$PSScriptRoot\zoxide_init.ps1"

# Initialize oh-my-posh
oh-my-posh --init --shell pwsh --config "$PSScriptRoot\catppuccin_frappe.omp.json" | Invoke-Expression

# Import Az.Tools.Predictor module
Import-Module Az.Tools.Predictor

# =============================================================================
# PSReadLine Configuration
# =============================================================================

# Set PSReadLine key handlers
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Tab -Function ForwardChar

# Set PSReadLine options
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# =============================================================================
# Alias Definitions
# =============================================================================

# Function to execute git commands
# Full command: git
# Alias: gs
function gitFunction { git @args }
Set-Alias -Name "gs" -Value gitFunction

# Function to execute pnpm commands
# Full command: pnpm
# Alias: p
function pnpmFunction { pnpm @args }
Set-Alias -Name "p" -Value pnpmFunction

# Function to execute git push command
# Full command: git push
# Alias: up
function gitPushFunction { git push @args }
Set-Alias -Name "up" -Value gitPushFunction

# Function to execute git pull command
# Full command: git pull
# Alias: down
function gitPullFunction { git pull @args }
Set-Alias -Name "down" -Value gitPullFunction

# Function to execute git status command
# Full command: git status
# Alias: stat
function gitStatusFunction { git status @args }
Set-Alias -Name "stat" -Value gitStatusFunction

# Function to execute git checkout command with additional functionality for creating new branches
# Full command: git checkout
# Alias: br
function gitCheckoutFunction { 
    if ($args[0] -eq "new") {
        git checkout -b $args[1]
    }
    else {
        git checkout @args 
    }
}
Set-Alias -Name "br" -Value gitCheckoutFunction

function gitRemoveCached {

    # Find all ignored files in the repository
    $ignored_files = git ls-files --ignored --exclude-standard -c

    Write-Host "Found the following ignored files:"
    Write-Host $ignored_files

    # Loop through each ignored file
    foreach ($file in $ignored_files) {
        Write-Host "Removing $file from cache..."
        git rm --cached $file
        if ($?) {
            Write-Host "$file removed from cache successfully."
        }
        else {
            Write-Host "Failed to remove $file from cache."
        }
    }
}

Set-Alias -Name "rmc" -Value gitRemoveCached


# Function to create a GitHub repository upstream using the GitHub CLI
# Initializes a new git repository in the current directory and sets the remote origin to the newly created GitHub repository
# Full command: gh repo create
# Alias: New-Repo
Import-Module Pansies

$ThemeColors = @{
    Pink     = [RgbColor]"#F4B8E4"
    Lavender = [RgbColor]"#BABBF1"
    Blue     = [RgbColor]"#8CAAEE"
    Aqua     = [RgbColor]"#A9FFF7"
    Green    = [RgbColor]"#94FBAB"
    Purple   = [RgbColor]"#6F2DBD"
    Red      = [RgbColor]"#D33F49"
}

function New-GitHubRepo {
    # Fetch default GitHub username from Git config, inform the user, and ask for input if necessary
    $defaultUsername = gh api user --jq .login
    if ($defaultUsername) {
        $usernamePrompt = "Enter GitHub username"
        Write-Host $usernamePrompt": " -Fg $ThemeColors.Aqua -NoNewline
        Write-Host $defaultUsername -Fg $ThemeColors.Purple -NoNewline
        $cursor = $host.UI.RawUI.CursorPosition
        $username = Read-Host
        if ($username -ne "") {
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            [Console]::Write(" " * $defaultUsername.Length)
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            $username
        }
        elseif ($username -eq "") {
            $username = $defaultUsername
        }
    }
    else {
        $username = Read-Host "Enter your GitHub username"
    }
    Write-Host "Using GitHub username: " -Fg $ThemeColors.Aqua -NoNewline
    Write-Host $username -Fg $ThemeColors.Blue

    # Ask for repository name
    $repoName = Read-Host "Enter the name of the new repository"

    # Ask for repository visibility with default value
    $visibilityPrompt = "Enter repository visibility"
    $defaultVisibility = "private"
    Write-Host $visibilityPrompt": " -Fg $ThemeColors.Aqua -NoNewline
    Write-Host $defaultVisibility -Fg $ThemeColors.Purple -NoNewline
    $cursor = $host.UI.RawUI.CursorPosition
    $visibility = Read-Host
    if ($visibility -ne "") {
        [Console]::SetCursorPosition($cursor.X, $cursor.Y)
        [Console]::Write(" " * $defaultVisibility.Length)
        [Console]::SetCursorPosition($cursor.X, $cursor.Y)
        $visibility
    }
    elseif ($visibility -eq "") {
        $visibility = $defaultVisibility
    }
    while ($visibility -ne 'public' -and $visibility -ne 'private') {
        Write-Host "Invalid visibility. Please enter 'public' or 'private'." -Fg $ThemeColors.Purple
        Write-Host $visibilityPrompt": " -Fg $ThemeColors.Aqua -NoNewline
        Write-Host $defaultVisibility -Fg $ThemeColors.Purple -NoNewline
        $cursor = $host.UI.RawUI.CursorPosition
        $visibility = Read-Host
        if ($visibility -ne "") {
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            [Console]::Write(" " * $defaultVisibility.Length)
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            $visibility
        }
        elseif ($visibility -eq "") {
            $visibility = $defaultVisibility
        }
    }

    # Create the repository using the GitHub CLI
    Write-Host "Creating repository " -Fg $ThemeColors.Pink -NoNewline
    Write-Host $repoName -Fg $ThemeColors.Blue -NoNewline
    Write-Host "..." -Fg $ThemeColors.Pink
    $response = gh repo create $username/$repoName --$visibility --confirm

    # Check if the repository creation was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository created successfully!" -Fg $ThemeColors.Green
        $repoUrl = $response | Select-String -Pattern 'https://github.com/.*' | ForEach-Object { $_.Matches.Value }
        Write-Host "Repository URL: " -Fg $ThemeColors.Aqua -NoNewline
        Write-Host $repoUrl -Fg $ThemeColors.Green

        $useCurrentDirPrompt = "Do you want to use the current directory for the repository?"
        $defaultUseCurrentDir = "yes"
        Write-Host $useCurrentDirPrompt": " -Fg $ThemeColors.Aqua -NoNewline
        Write-Host $defaultUseCurrentDir -Fg $ThemeColors.Purple -NoNewline
        $cursor = $host.UI.RawUI.CursorPosition
        $useCurrentDir = Read-Host
        if ($useCurrentDir -ne "") {
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            [Console]::Write(" " * $defaultUseCurrentDir.Length)
            [Console]::SetCursorPosition($cursor.X, $cursor.Y)
            $useCurrentDir
        }
        elseif ($useCurrentDir -eq "") {
            $useCurrentDir = $defaultUseCurrentDir
        }

        if ($useCurrentDir -eq 'yes') {
            Write-Host "Initializing repository in the current directory..." -Fg $ThemeColors.Pink
            Write-Host "You can now use " -Fg $ThemeColors.Aqua -NoNewline
            Write-Host "Init-Repo" -Fg $ThemeColors.Blue -NoNewline
            Write-Host " to initialize the repository, create an initial commit, set upstream, and push." -Fg $ThemeColors.Aqua
        }
    }
    else {
        Write-Host "Failed to create repository." -Fg $ThemeColors.Red
        Write-Host "Please check your GitHub CLI configuration and try again." -Fg $ThemeColors.Red
    }
}

function Read-HostInput([string]$default) {
    $input = $null
    $key = $null
    while ($null -eq $key) {
        $key = $host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho")
        if ($key.VirtualKeyCode -eq 13) {
            # Enter
            break
        }
        elseif ($key.VirtualKeyCode -eq 8) {
            # Backspace
            if ($input.Length -gt 0) {
                $input = $input.Substring(0, $input.Length - 1)
                Write-Host "`b `b" -NoNewline
            }
        }
        else {
            $input += $key.KeyChar
            Write-Host $key.KeyChar -NoNewline
        }
    }
    if (-not $input) { $input = $default }
    return $input
}
Set-Alias -Name "New-Repo" -Value New-GitHubRepo

function Initialize-GitRepository {
    # Ask for the repository URL
    $repoUrl = Read-Host "Enter the repository URL"

    # Validate the repository URL
    if ($repoUrl -notmatch '^https://github\.com/.*') {
        Write-Host "Invalid repository URL. Please provide a valid GitHub repository URL." -Fg $ThemeColors.Red
        return
    }

    # Initialize the repository, create an initial commit, set upstream, and push
    Write-Host "Initializing repository in the current directory..." -Fg $ThemeColors.Pink
    git init
    
    # Stage all files for commit, excluding files specified in .gitignore if it exists
    if (Test-Path ".gitignore") {
        $files = git ls-files --others --exclude-standard
        if ($files) {
            git add $files
        }
        else {
            Write-Host "No files to commit. Skipping initial commit." -Fg $ThemeColors.Purple
            return
        }
    }
    else {
        git add .
    }
    
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin $repoUrl
    git push -u origin main

    Write-Host "Repository initialized, initial commit created, upstream set, and pushed to GitHub." -Fg $ThemeColors.Green
}

# Set alias for the Initialize-GitRepository function
Set-Alias -Name "Init-Repo" -Value Initialize-GitRepository

# =============================================================================
# Utility functions for zoxide.
# =============================================================================

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    }
    finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
    }
    else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add -- $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction SilentlyContinue -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path $args[0] -PathType Container)) {
        __zoxide_cd $args[0] $true
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result -- @args
        }
        else {
            $result = __zoxide_bin query -- @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i -- @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force