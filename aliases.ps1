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

# Function to execute git add all files to commit
# Full command: git add .
# Alias: aa
function gitAddAll { git add . }
Set-Alias -Name "aa" -Value gitAddAll

# Function to execute git commit command with a message
# Full command: git commit -m "Your message"
# Alias: c
function gitCommitMessage { git commit -m $args }
Set-Alias -Name "c" -Value gitCommitMessage

# Function to execute gh copilot suggest command for git
# Full command: gh copilot suggest -t git
# Alias: sg
function ghCopilotSuggestGitFunction { gh copilot suggest -t git @args }
Set-Alias -Name "help-git" -Value ghCopilotSuggestGitFunction
Set-Alias -Name "sg" -Value ghCopilotSuggestGitFunction
Set-Alias -Name "rec-git" -Value ghCopilotSuggestGitFunction

# Function to execute gh copilot suggest command for gh
# Full command: gh copilot suggest -t gh
# Alias: sh
function ghCopilotSuggestGhFunction { gh copilot suggest -t gh @args }
Set-Alias -Name "help-github" -Value ghCopilotSuggestGhFunction
Set-Alias -Name "sgh" -Value ghCopilotSuggestGhFunction
Set-Alias -Name "rec-gh" -Value ghCopilotSuggestGhFunction

# Function to execute gh copilot suggest command for shell
# Full command: gh copilot suggest -t shell
# Alias: ss
function ghCopilotSuggestShellFunction { gh copilot suggest -t shell @args }
Set-Alias -Name "help-shell" -Value ghCopilotSuggestShellFunction
Set-Alias -Name "sh" -Value ghCopilotSuggestShellFunction
Set-Alias -Name "rec" -Value ghCopilotSuggestShellFunction
Set-Alias -Name "suggest" -Value ghCopilotSuggestShellFunction
