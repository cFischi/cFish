# Cursor Extension Inventory and Binary Search

## Overview

This document provides an inventory of all Cursor extensions and a binary search methodology to identify problematic extensions that may be causing performance issues.

## Extension Inventory

Total Extensions: 84

### Extensions by Category

#### Other (10 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| project-manager | alefragnani | 12.8.0 | Cursor |
| foam-vscode | foam | 0.26.8 | Cursor |
| codespaces | GitHub | 1.17.3 | Cursor |
| remote-wsl | ms-vscode-remote | 0.81.8 | Cursor |
| live-server | ms-vscode | 0.4.15 | Cursor |
| vs-browser | Phu1237 | 2.2.0 | Cursor |
| project-manager | alefragnani | 12.8.0 | VSCode |
| codespaces | GitHub | 1.17.3 | VSCode |
| remote-wsl | ms-vscode-remote | 0.88.5 | VSCode |
| live-server | ms-vscode | 0.4.15 | VSCode |

#### Language (19 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| pyright | anysphere | 1.1.327 | Cursor |
| appmap | appland | 0.133.2 | Cursor |
| gitignore | codezombiech | 0.10.0 | Cursor |
| vscode-glimmer-syntax | lifeart | 1.0.35 | Cursor |
| pieces-vscode | MeshIntelligentTechnologiesInc | 2.0.4 | Cursor |
| python | ms-python | 2024.12.3 | Cursor |
| vscode-pylance | ms-python | 2024.8.1 | Cursor |
| roo-cline | RooVeterinaryInc | 3.8.6 | Cursor |
| appmap | appland | 0.133.1 | VSCode |
| codeium | Codeium | 1.40.1 | VSCode |
| gitignore | codezombiech | 0.10.0 | VSCode |
| continue | Continue | 0.8.66 | VSCode |
| continue | Continue | 1.0.3 | VSCode |
| vscode-glimmer-syntax | lifeart | 1.0.35 | VSCode |
| pieces-vscode | MeshIntelligentTechnologiesInc | 2.0.4 | VSCode |
| python | ms-python | 2024.22.2 | VSCode |
| python | ms-python | 2025.2.0 | VSCode |
| vscode-pylance | ms-python | 2025.3.1 | VSCode |
| roo-cline | RooVeterinaryInc | 3.8.4 | VSCode |

#### Linter/Formatter (19 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| Code-Mate | AyushSinghal | 2.9.14 | Cursor |
| vscode-intelephense-client | bmewburn | 1.14.3 | Cursor |
| vscode-markdownlint | DavidAnson | 0.59.0 | Cursor |
| vscode-ember | EmberTooling | 3.0.59 | Cursor |
| prettier-vscode | esbenp | 11.0.0 | Cursor |
| vscode-docker | ms-azuretools | 1.29.4 | Cursor |
| vscode-kubernetes-tools | ms-kubernetes-tools | 1.3.20 | Cursor |
| powershell | ms-vscode | 2025.0.0 | Cursor |
| vscode-yaml | redhat | 1.17.0 | Cursor |
| twinny | rjmacarthy | 3.22.26 | Cursor |
| Code-Mate | AyushSinghal | 2.9.14 | VSCode |
| vscode-markdownlint | DavidAnson | 0.59.0 | VSCode |
| vscode-ember | EmberTooling | 3.0.59 | VSCode |
| prettier-vscode | esbenp | 11.0.0 | VSCode |
| vscode-docker | ms-azuretools | 1.29.4 | VSCode |
| vscode-kubernetes-tools | ms-kubernetes-tools | 1.3.20 | VSCode |
| vscode-yaml | redhat | 1.17.0 | VSCode |
| twinny | rjmacarthy | 3.21.7 | VSCode |
| twinny | rjmacarthy | 3.22.19 | VSCode |

#### Snippet (4 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| ember-module-snippets | candidmetrics | 1.3.121 | Cursor |
| vscode-wordpress-hooks | johnbillion | 1.5.0 | Cursor |
| wordpress-toolbox | wordpresstoolbox | 1.3.15 | Cursor |
| ember-module-snippets | candidmetrics | 1.3.121 | VSCode |

#### Source Control (11 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| githistory | donjayamanne | 0.6.20 | Cursor |
| vscode-github-actions | github | 0.27.1 | Cursor |
| vscode-pull-request-github | GitHub | 0.100.3 | Cursor |
| vscode-pull-request-github | GitHub | 0.102.0 | Cursor |
| vscode-open-in-github | ziyasal | 1.4.1 | Cursor |
| githistory | donjayamanne | 0.6.20 | VSCode |
| vscode-github-actions | github | 0.27.1 | VSCode |
| vscode-pull-request-github | GitHub | 0.100.3 | VSCode |
| vscode-pull-request-github | GitHub | 0.102.0 | VSCode |
| vscode-pull-request-github | GitHub | 0.106.0 | VSCode |
| vscode-open-in-github | ziyasal | 1.3.6 | VSCode |

#### Extension Pack (2 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| emberjs | EmberTooling | 2.0.6 | Cursor |
| emberjs | EmberTooling | 2.0.6 | VSCode |

#### AI Assistant (14 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| EntelligenceAI | EntelligenceAI | 0.0.49 | Cursor |
| claude-dev-experimental | kodu-ai | 2.3.11 | Cursor |
| rainbow-csv | mechatroner | 3.18.0 | Cursor |
| remote-containers | ms-vscode-remote | 0.394.0 | Cursor |
| EntelligenceAI | EntelligenceAI | 0.0.49 | VSCode |
| copilot | GitHub | 1.270.0 | VSCode |
| copilot | GitHub | 1.277.0 | VSCode |
| copilot-chat | GitHub | 0.23.2 | VSCode |
| copilot-chat | GitHub | 0.24.1 | VSCode |
| copilot-chat | GitHub | 0.25.0 | VSCode |
| copilot-workspace | github | 0.5.4 | VSCode |
| claude-dev-experimental | kodu-ai | 2.3.9 | VSCode |
| remote-containers | ms-vscode-remote | 0.401.0 | VSCode |
| cody-ai | sourcegraph | 1.74.0 | VSCode |

#### Debugging/Testing (5 extensions)

| Name | Publisher | Version | Source |
|------|-----------|---------|--------|
| debugpy | ms-python | 2024.6.0 | Cursor |
| cors-browser | Wscats | 1.0.11 | Cursor |
| php-debug | xdebug | 1.35.0 | Cursor |
| debugpy | ms-python | 2024.14.0 | VSCode |
| debugpy | ms-python | 2025.4.0 | VSCode |

## Binary Search Methodology

Binary search is an efficient approach to find problematic extensions by systematically testing groups of extensions.

1. Start by testing Cursor with all extensions disabled
   - Use cursor.exe --disable-extensions or the provided script
   - If performance is good, confirm extensions are the issue
   - If performance is still poor, look elsewhere for the cause

2. If extensions are confirmed as the cause:
   - Disable Group A extensions using disable-group-A.bat
   - Restart Cursor and monitor performance
   - If performance is good, the problem is in Group A
   - If performance is poor, the problem is in Group B

3. Continue binary search in the problematic group:
   - Split the group into two smaller groups
   - Test each group separately
   - Narrow down to specific problematic extensions

4. Restore all extensions when complete:
   - Use the enable scripts to restore disabled extensions
   - Restart Cursor to apply changes

## Available Scripts

- disable-group-A.bat: Disables all Group A extensions
- enable-group-A.bat: Restores all Group A extensions
- disable-group-B.bat: Disables all Group B extensions
- enable-group-B.bat: Restores all Group B extensions

