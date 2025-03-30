# Advanced Multi-Agent Setup for WordPress Development

## Overview
This document provides a comprehensive guide for setting up a multi-agent workflow using Cursor AI for WordPress development at cFish.io. A multi-agent approach allows for specialized roles that enhance productivity, quality, and security.

## Multi-Agent Architecture

### Core Agent Roles

#### 1. Project Architect
**Responsibility**: High-level design, system architecture, and technical decisions
**Prompt Style**: Strategic, focused on patterns and best practices
**Model**: claude-3.5-sonnet or o1-preview (for complex architecture)

#### 2. Code Implementation Specialist
**Responsibility**: Core coding tasks, implementing features, fixing bugs
**Prompt Style**: Task-focused, procedural, specific implementation details
**Model**: claude-3.5-sonnet

#### 3. Security & QA Analyst
**Responsibility**: Code review, security audits, testing
**Prompt Style**: Critical, interrogative, edge-case focused
**Model**: o1-mini (for reasoning-focused analysis)

#### 4. Documentation Specialist
**Responsibility**: Creating/updating documentation, examples, comments
**Prompt Style**: Explanatory, comprehensive, educational
**Model**: claude-3.5-sonnet

### Agent Configuration

Each agent should have a dedicated Composer session with:
- Clear role description in the prompt
- Specific instructions about responsibilities
- Links to relevant documentation
- Custom .cursorrules tailored to the agent's role

## Setup Process

### 1. Create Agent-Specific .cursorrules Files

Create separate .cursorrules files for each agent role:

#### Project Architect (.cursorrules-architect)
```json
{
  "agentRole": "Project Architect",
  "responsibilities": [
    "Design system architecture",
    "Make technical decisions",
    "Define coding patterns",
    "Ensure scalability and maintainability"
  ],
  "wordpress": {
    "corePrinciples": [
      "Use OOP for better modularity and maintainability",
      "Follow WordPress coding standards consistently",
      "Leverage WordPress hooks appropriately",
      "Design for extensibility"
    ]
  },
  "communicationStyle": "Strategic, big-picture focused",
  "outputFormat": "Architecture diagrams, pattern descriptions, technical specifications"
}
```

#### Code Implementation Specialist (.cursorrules-developer)
```json
{
  "agentRole": "Code Implementation Specialist",
  "responsibilities": [
    "Write efficient, clean code",
    "Implement features based on specifications",
    "Fix bugs and issues",
    "Follow WordPress best practices"
  ],
  "wordpress": {
    "securityPractices": [
      "Database: Use $wpdb->prepare() for ALL queries",
      "Input: sanitize_* functions before processing",
      "Output: esc_* functions before display",
      "Forms: wp_nonce_* functions for verification"
    ],
    "codingConventions": {
      "database": "Use $wpdb->prepare() for all dynamic queries",
      "hooks": "Add hooks using proper array syntax: add_action('init', [$this, 'method_name'], 10)",
      "security": "Always verify nonces and sanitize input, escape output"
    }
  },
  "communicationStyle": "Practical, implementation-focused",
  "outputFormat": "Code blocks, implementation explanations"
}
```

#### Security & QA Analyst (.cursorrules-qa)
```json
{
  "agentRole": "Security & QA Analyst",
  "responsibilities": [
    "Review code for security vulnerabilities",
    "Identify potential bugs and edge cases",
    "Develop test cases",
    "Ensure code quality standards"
  ],
  "security": {
    "dataValidation": "Always validate and sanitize user input",
    "outputEscaping": "Always escape output before display",
    "queryPreparation": "Use prepared statements for all database queries",
    "nonceVerification": "Implement nonce verification for all forms",
    "capabilityChecks": "Check user capabilities before performing actions"
  },
  "communicationStyle": "Critical, detail-oriented, security-focused",
  "outputFormat": "Test cases, security reports, code reviews"
}
```

#### Documentation Specialist (.cursorrules-docs)
```json
{
  "agentRole": "Documentation Specialist",
  "responsibilities": [
    "Create comprehensive documentation",
    "Update existing documentation",
    "Generate examples and tutorials",
    "Ensure documentation follows standards"
  ],
  "documentationPractices": {
    "memoryMdUpdates": {
      "format": "## [Title] (MM-DD-2025)\\n- [Bullet points with key information]\\n- [More bullet points as needed]\\n\\n_Updated MM-DD-2025 | AI: Cursor (Claude 3.7 Sonnet)_"
    },
    "changelogMdUpdates": {
      "format": "## [Version] - [2025-MM-DD]\\n\\n### Added\\n- [New features]\\n\\n### Changed\\n- [Changes to existing functionality]\\n\\n### Fixed\\n- [Bug fixes]"
    }
  },
  "communicationStyle": "Clear, educational, comprehensive",
  "outputFormat": "Documentation files, tutorials, examples"
}
```

### 2. Create Agent Setup Script (agent-setup.ps1)

```powershell
# agent-setup.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("architect", "developer", "qa", "docs")]
    [string]$AgentType,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

# Define agent configurations
$agentConfigs = @{
    "architect" = @{
        "name" = "Project Architect";
        "rulesFile" = ".cursorrules-architect";
        "composerFile" = "architect-session.cursor";
        "model" = "claude-3.5-sonnet";
    };
    "developer" = @{
        "name" = "Code Implementation Specialist";
        "rulesFile" = ".cursorrules-developer";
        "composerFile" = "developer-session.cursor";
        "model" = "claude-3.5-sonnet";
    };
    "qa" = @{
        "name" = "Security & QA Analyst";
        "rulesFile" = ".cursorrules-qa";
        "composerFile" = "qa-session.cursor";
        "model" = "o1-mini";
    };
    "docs" = @{
        "name" = "Documentation Specialist";
        "rulesFile" = ".cursorrules-docs";
        "composerFile" = "docs-session.cursor";
        "model" = "claude-3.5-sonnet";
    };
}

$config = $agentConfigs[$AgentType]

# Create symbolic link to use agent-specific rules
if (Test-Path "$ProjectPath\.cursorrules") {
    Rename-Item -Path "$ProjectPath\.cursorrules" -NewName ".cursorrules.backup" -Force
}

Copy-Item -Path "$ProjectPath\$($config.rulesFile)" -Destination "$ProjectPath\.cursorrules" -Force

Write-Host "Agent Setup Complete:"
Write-Host "Type: $($config.name)"
Write-Host "Rules: $($config.rulesFile)"
Write-Host "Model: $($config.model)"
Write-Host ""
Write-Host "Start a new Composer session and configure it to use $($config.model)"
```

### 3. Create Agent Workflow Script (agent-workflow.ps1)

```powershell
# agent-workflow.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [Parameter(Mandatory=$true)]
    [string]$TaskName,
    
    [Parameter(Mandatory=$false)]
    [string]$TaskDescription = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Priority = "Medium"
)

# Create task directory
$taskPath = Join-Path -Path $ProjectPath -ChildPath "tasks\$TaskName"
New-Item -Path $taskPath -ItemType Directory -Force | Out-Null

# Create task specification file
$specContent = @"
# Task: $TaskName
**Priority:** $Priority
**Created:** $(Get-Date -Format "MM-dd-yyyy")

## Description
$TaskDescription

## Agent Assignments

### Project Architect
- [ ] Define architecture and patterns
- [ ] Identify technical constraints
- [ ] Establish implementation strategy

### Code Implementation Specialist
- [ ] Implement core functionality
- [ ] Integrate with existing systems
- [ ] Fix identified issues

### Security & QA Analyst
- [ ] Create test cases
- [ ] Conduct security review
- [ ] Verify implementation quality

### Documentation Specialist
- [ ] Document the feature
- [ ] Update relevant documentation
- [ ] Create usage examples

## Workflow Status
- [ ] Architecture definition (Architect)
- [ ] Implementation plan (Architect → Developer)
- [ ] Core implementation (Developer)
- [ ] Test creation (QA)
- [ ] Implementation testing (QA → Developer)
- [ ] Documentation (Docs)
- [ ] Final review (All)

## Notes
<!-- Add task notes here -->
"@

Set-Content -Path "$taskPath\specification.md" -Value $specContent

# Create agent-specific task files
$agentTypes = @("architect", "developer", "qa", "docs")
foreach ($agent in $agentTypes) {
    $agentTaskContent = @"
# $TaskName - $(switch($agent) {
    "architect" {"Project Architect"}
    "developer" {"Code Implementation Specialist"}
    "qa" {"Security & QA Analyst"}
    "docs" {"Documentation Specialist"}
    default {"Unknown Role"}
}) Tasks

## Responsibilities
<!-- Add specific tasks for this agent -->

## Work Notes
<!-- Add work notes here -->

## Deliverables
<!-- List expected deliverables -->
"@

    Set-Content -Path "$taskPath\$agent-tasks.md" -Value $agentTaskContent
}

Write-Host "Task '$TaskName' created successfully."
Write-Host "Task files are located at: $taskPath"
```

## Workflow Process

### 1. Project Initialization

1. **Create Project Structure**
   - Define overall architecture
   - Establish component boundaries
   - Create initial documentation

2. **Role Assignment**
   - Configure each agent with appropriate rules
   - Set up dedicated Composer sessions
   - Establish communication protocol between agents

### 2. Task Execution Flow

For each development task:

1. **Architect Phase**
   - Architect defines specifications and design patterns
   - Creates architecture diagrams and component relationships
   - Establishes implementation strategy

2. **Developer Phase**
   - Developer implements based on architect's specifications
   - Creates initial implementation
   - Documents code-level details

3. **QA Phase**
   - QA creates test cases
   - Reviews implementation for security issues
   - Provides feedback on implementation

4. **Developer Refinement**
   - Developer addresses QA feedback
   - Refines implementation
   - Ensures all tests pass

5. **Documentation Phase**
   - Documentation specialist creates user documentation
   - Updates changelog and memory files
   - Creates examples and tutorials

6. **Final Review**
   - All agents review the complete implementation
   - Address any remaining issues
   - Sign off on the completed task

## Communication Between Agents

### Handoff Documentation

Create standardized handoff documents for transitioning work between agents:

```markdown
# Task Handoff: [Task Name]

## From: [Source Agent Role]
## To: [Target Agent Role]
## Date: [MM-DD-YYYY]

## Work Completed
- [List of completed items]

## Known Issues
- [List of known issues or limitations]

## Next Steps
- [List of recommended next steps]

## Questions/Clarifications
- [List of questions or points needing clarification]
```

### Cross-Agent Reference System

Establish a system for agents to reference each other's work:

1. Use a consistent file naming convention: `[task]-[agent]-[artifact].md`
2. Create a central task registry that all agents can reference
3. Document dependencies between agent outputs

## Best Practices

### Agent Isolation

1. Keep agent sessions separate to maintain clear roles
2. Avoid sharing complete context between agents (compartmentalization)
3. Use specific handoff documents to transfer knowledge

### Context Management

1. Each agent should have role-specific context
2. Maintain shared knowledge in centralized documentation
3. Use specialized context files for each agent role

### Workflow Optimization

1. Run agents in parallel when tasks permit
2. Use sequential workflows for dependent tasks
3. Consider periodic "sync" meetings between agents to align understanding

## Example Multi-Agent Session

### Architect Session

```
I am the Project Architect agent for the WordPress custom post type registration task.

Based on the requirements, I need to design an extensible and maintainable custom post type registration system.

Here's my proposed architecture:
1. Create a base abstract class for all custom post types
2. Implement a registration factory to manage CPT instances
3. Develop an interface for standardized methods
4. Establish a hook system for extending CPT behavior

Please implement this architecture following WordPress best practices.
```

### Developer Session

```
I am the Code Implementation Specialist agent. I'll implement the custom post type registration system based on the architecture defined by the Project Architect.

Let me start by creating the abstract base class and implementing the factory pattern as specified. I'll ensure all code follows WordPress security practices and coding standards.
```

### QA Session

```
I am the Security & QA Analyst agent. I'll review the custom post type implementation for security issues and create a comprehensive testing strategy.

My review will focus on:
1. Proper sanitization of inputs
2. Correct capability checks
3. Secure handling of meta data
4. Testing boundary conditions
5. Verifying hook implementations
```

### Documentation Session

```
I am the Documentation Specialist agent. I'll create comprehensive documentation for the custom post type registration system.

My documentation will include:
1. Usage examples for developers
2. API reference for all methods
3. Hook documentation
4. Integration examples
5. Updates to memory.md and changelog.md
```

## Tools and Resources

### Agent Management Dashboard

Consider creating a simple HTML dashboard for tracking agent tasks and status:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Multi-Agent Dashboard</title>
    <style>
        /* Dashboard styles */
    </style>
</head>
<body>
    <h1>Multi-Agent Dashboard</h1>
    <div class="task-list">
        <!-- Task cards go here -->
    </div>
    <div class="agent-status">
        <!-- Agent status indicators -->
    </div>
</body>
</html>
```

### Agent Context Files

Create role-specific context files to help each agent understand their responsibilities:

- `architect-context.md`: System architecture, design patterns, constraints
- `developer-context.md`: Implementation details, coding standards, examples
- `qa-context.md`: Testing strategies, security checklists, common issues
- `docs-context.md`: Documentation standards, templates, examples

## Conclusion

This multi-agent setup provides a structured approach to WordPress development that leverages specialized AI roles to improve quality, security, and efficiency. By clearly defining responsibilities and workflows, teams can maximize the value of AI assistance while maintaining high standards for code quality and security.

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 