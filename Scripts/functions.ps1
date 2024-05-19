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

function listFolders {
    Get-ChildItem -Directory -Depth 2 | Where-Object {
        $excludedFolders = @('node_modules', '.next', 'dist', '.pnpm', '.npm', '.turbo')
        $pathParts = $_.FullName -split '\\'
        $hasExcludedFolder = $false
        foreach ($folder in $excludedFolders) {
            if ($pathParts -contains $folder) {
                $hasExcludedFolder = $true
                break
            }
        }
        -not $hasExcludedFolder
    } | Select-Object -ExpandProperty FullName
}

Set-Alias -Name "List-Folders" -Value listFolders


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

Set-Alias -Name "Init-Repo" -Value Initialize-GitRepository

function Help {
    $ThemeColors = @{
        Pink     = [RgbColor]"#F4B8E4"
        Lavender = [RgbColor]"#BABBF1"
        Blue     = [RgbColor]"#8CAAEE"
        Aqua     = [RgbColor]"#A9FFF7"
        Green    = [RgbColor]"#94FBAB"
        Purple   = [RgbColor]"#6F2DBD"
        Red      = [RgbColor]"#D33F49"
    }

    Write-Host "powershell-plus Help" -ForegroundColor $ThemeColors.Pink -BackgroundColor $ThemeColors.Purple

    Write-Host "" # Empty line for spacing

    # -----------------------------------------------
    # General Commands
    # -----------------------------------------------
    Write-Host "General Commands:" -ForegroundColor $ThemeColors.Aqua 
    Write-Host "  help       - This help menu" -ForegroundColor $ThemeColors.Blue
    Write-Host "  cls        - Clear the screen" -ForegroundColor $ThemeColors.Blue
    Write-Host "  z          - Jump to a directory using zoxide" -ForegroundColor $ThemeColors.Blue
    Write-Host "  zi         - Jump to a directory (interactive search)" -ForegroundColor $ThemeColors.Blue 

    Write-Host "" # Empty line for spacing

    # -----------------------------------------------
    # Git Commands
    # -----------------------------------------------
    Write-Host "Git Commands:" -ForegroundColor $ThemeColors.Aqua 
    Write-Host "  gs         - git status" -ForegroundColor $ThemeColors.Blue
    Write-Host "  up         - git push" -ForegroundColor $ThemeColors.Blue
    Write-Host "  down       - git pull" -ForegroundColor $ThemeColors.Blue
    Write-Host "  br         - git checkout (with new branch creation)" -ForegroundColor $ThemeColors.Blue
    Write-Host "  rmc        - Remove cached ignored files from Git" -ForegroundColor $ThemeColors.Blue
    Write-Host "  New-Repo   - Create a new GitHub repo and initialize Git locally" -ForegroundColor $ThemeColors.Blue
    Write-Host "  Init-Repo  - Initialize a Git repo in the current directory" -ForegroundColor $ThemeColors.Blue

    Write-Host "" # Empty line for spacing

    # -----------------------------------------------
    # GitHub Copilot Commands
    # -----------------------------------------------
    Write-Host "GitHub Copilot Commands:" -ForegroundColor $ThemeColors.Aqua 
    Write-Host "  sg / rec-git  - Get GitHub Copilot suggestions for Git" -ForegroundColor $ThemeColors.Blue
    Write-Host "  sh / rec-gh   - Get GitHub Copilot suggestions for GitHub" -ForegroundColor $ThemeColors.Blue
    Write-Host "  ss / rec      - Get GitHub Copilot suggestions for shell" -ForegroundColor $ThemeColors.Blue

    Write-Host "" # Empty line for spacing
}