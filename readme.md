# Enhanced PowerShell Profile

A PowerShell profile that supercharges your workflow with [Zoxide](https://github.com/ajeetdsouza/zoxide), [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh), [Azure Predictor](https://docs.microsoft.com/en-us/azure/azure-cli/azure-cli-prediction), intelligent aliases, and custom functions.

## Table of Contents

- [Enhanced PowerShell Profile](#enhanced-powershell-profile)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
  - [Usage](#usage)
  - [Customization](#customization)
  - [Dependencies](#dependencies)
  - [Credits](#credits)

## Features

- **Effortless Navigation**: Accelerate directory changes with Zoxide's smart directory jumping.
- **Stylish Terminal**: Elevate your PowerShell prompt with oh-my-posh and the visually appealing Catppuccin Frappe theme.
- **Azure AI Assistance**: Streamline Azure CLI interactions with the intelligent tab completion and suggestions powered by Az.Tools.Predictor.
- **Optimized Aliases**: Execute common Git commands efficiently with short, intuitive aliases (gs, up, down, stat, br).
- **Handy Utility Functions**: Simplify repository creation with the New-GitHubRepo function, leveraging the GitHub CLI.

## Installation

### Prerequisites

- [Zoxide](https://github.com/ajeetdsouza/zoxide): Follow installation instructions.
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh): Follow installation instructions.
- [Az.Tools.Predictor](https://docs.microsoft.com/en-us/azure/azure-cli/azure-cli-prediction): Install via PowerShell: `Install-Module Az.Tools.Predictor`.
- [GitHub CLI](https://cli.github.com/): Required for the New-GitHubRepo function.

### Steps

1. **Download the Script Files**:
   - Clone this repository or download the following files:
     - `my_powershell_profile.ps1` (or your preferred name)
     - `zoxide_init.ps1`
     - `catppuccin_frappe.omp.json`

2. **Place Files**: Place the downloaded files in an appropriate directory in your PowerShell profile path (find it by running `$PROFILE`).

3. **Edit Profile**:
   - Open your PowerShell profile (`$PROFILE`) in a text editor.
   - Add the following lines of code to your profile:

       ```powershell
       # Initialize zoxide
       Invoke-Expression (& { (zoxide init powershell | Out-String) })

       # Import zoxide configuration
       . "$PSScriptRoot\zoxide_init.ps1"

       # Initialize oh-my-posh
       oh-my-posh --init --shell pwsh --config "$PSScriptRoot\catppuccin_frappe.omp.json" | Invoke-Expression

       # Import Az.Tools.Predictor module
       Import-Module Az.Tools.Predictor

       # ... other profile settings
       ```

## Usage

- **Zoxide**:
- Start typing a directory path or keywords, then tab to autocomplete with Zoxide's suggestions.
- Use `z` to jump to previously visited directories.

- **Git Aliases**: Refer to the alias descriptions within the script.

- **New-GitHubRepo Function**: Use this function to create new GitHub repositories directly from your PowerShell environment.

![Usage Screenshot](path/to/usage-screenshot.png)

## Customization

- Explore further customization options for Zoxide, oh-my-posh, and the Azure Predictor.
- Modify or create new aliases and custom functions in your profile.

![Customization Screenshot](path/to/customization-screenshot.png)

## Dependencies

- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh)
- [Az.Tools.Predictor](https://docs.microsoft.com/en-us/azure/azure-cli/azure-cli-prediction) (Installed with PowerShell)
- [GitHub CLI](https://cli.github.com/) (Optional, for New-GitHubRepo function)

## Credits

Credit to the creators of Zoxide, oh-my-posh, and Azure Predictor for their awesome tools.

Feel free to copy and adapt this PowerShell profile to suit your needs!
