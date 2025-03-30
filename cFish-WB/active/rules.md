# cFish.io Cursor Project Rules
https://www.cursordirectory.com/
https://github.com/PatrickJS/awesome-cursorrules
## Resources
- [@https://cursorintro.com/mistakes-to-avoid](https://cursorintro.com/mistakes-to-avoid)
- [@https://cursorintro.com/best-practices](https://cursorintro.com/best-practices)
- [@https://github.com/PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules)
- [@https://www.cursordirectory.com/](https://www.cursordirectory.com/)
- [@https://ghuntley.com/specs](https://ghuntley.com/specs)
- [@https://ghuntley.com/stdlib](https://ghuntley.com/stdlib)

## Sources
- https://forum.cursor.com/t/rules-for-ai-are-there-limitations/40700
- https://forum.cursor.com/t/best-practices-cursorrules/41775
- https://www.builder.io/blog/cursor-tips
- https://www.prompthub.us/blog/top-cursor-rules-for-coding-agents
- https://forum.cursor.com/t/guardrails-against-large-scale-feature-removal/40374
- https://github.com/RenjiYuusei/CursorFocus
- https://extremelysunnyyk.medium.com/maximizing-your-cursor-use-advanced-prompting-cursor-rules-and-tooling-integration-496181fa919c
- https://dev.to/heymarkkop/cursor-tips-10f8
- https://forum.cursor.com/t/cursor-prompt-engineering-best-practices/1592
- https://ghuntley.com/stdlib/
- https://ghuntley.com/specs/

## Overview
This document contains comprehensive guidance for the cFish.io .cursorrules file, implementing the template in Section 3.3 of the cursor agent SOPs. The rules are organized into logical categories for better structure and maintainability.

## The StdLib Approach to Cursor Rules

### Understanding the StdLib Approach
- Treat Cursor rules as a comprehensive "standard library" (stdlib) of prompting rules
- Compose rules together like unix pipes for powerful interactions
- Focus on solving classes of problems rather than individual instances
- Use rules to program and fine-tune AI behavior for consistent results
- Leverage Cursor to create and update rules, building a self-improving system
- Think of rules as programming the LLM's behavior directly

### Rules Directory Structure
- Create a dedicated `.cursor/rules` directory for all rule files
- Implement a base rule instructing Cursor to store all new rules in this location
- Use YAML frontmatter to control rule application scope and behavior
- Organize rules by domain or technology with clear prefixes
- Store rules as separate `.mdc` files with appropriate naming
- Follow structured naming conventions for better organization

### Building Your StdLib
- Start with a foundational rule defining where to store rules:
```markdown
---
description: Cursor Rules Location
globs: *.mdc
---
# Cursor Rules Location

Rules for placing and organizing Cursor rule files in the repository.

<rule>
name: cursor_rules_location
description: Standards for placing Cursor rule files in the correct directory
filters:
  # Match any .mdc files
  - type: file_extension
    pattern: "\\.mdc$"
  # Match files that look like Cursor rules
  - type: content
    pattern: "(?s)<rule>.*?</rule>"
  # Match file creation events
  - type: event
    pattern: "file_create"

actions:
  - type: reject
    conditions:
      - pattern: "^(?!\\.\\/\\.cursor\\/rules\\/.*\\.mdc$)"
        message: "Cursor rule files (.mdc) must be placed in the .cursor/rules directory"

  - type: suggest
    message: |
      When creating Cursor rules:

      1. Always place rule files in PROJECT_ROOT/.cursor/rules/:
         ```
         .cursor/rules/
         ├── your-rule-name.mdc
         ├── another-rule.mdc
         └── ...
         ```

      2. Follow the naming convention:
         - Use kebab-case for filenames
         - Always use .mdc extension
         - Make names descriptive of the rule's purpose

      3. Directory structure:
         ```
         PROJECT_ROOT/
         ├── .cursor/
         │   └── rules/
         │       ├── your-rule-name.mdc
         │       └── ...
         └── ...
         ```

      4. Never place rule files:
         - In the project root
         - In subdirectories outside .cursor/rules
         - In any other location

examples:
  - input: |
      # Bad: Rule file in wrong location
      rules/my-rule.mdc
      my-rule.mdc
      .rules/my-rule.mdc

      # Good: Rule file in correct location
      .cursor/rules/my-rule.mdc
    output: "Correctly placed Cursor rule file"

metadata:
  priority: high
  version: 1.0
</rule>
```

### StdLib Rule Examples

#### Preventing Undesired Tools/Approaches
```markdown
---
description: No Bazel
globs: *
---
# No Bazel

Strictly prohibits any Bazel-related code, recommendations, or tooling.

<rule>
name: no_bazel
description: Strictly prohibits Bazel usage and recommendations
filters:
  # Match any Bazel-related terms
  - type: content
    pattern: "(?i)\\b(bazel|blaze|bzl|BUILD|WORKSPACE|starlark|\\.star)\\b"
  # Match build system recommendations
  - type: intent
    pattern: "build_system_recommendation"
  # Match file extensions
  - type: file_extension
    pattern: "\\.(bzl|star|bazel)$"
  # Match file names
  - type: file_name
    pattern: "^(BUILD|WORKSPACE)$"

actions:
  - type: reject
    message: |
      Bazel and related tools are not allowed in this codebase:
      - No Bazel build files or configurations
      - No Starlark (.star/.bzl) files
      - No Bazel-related tooling or dependencies
      - No recommendations of Bazel as a build system

      Please use Nix for build and dependency management.

  - type: suggest
    message: |
      Instead of Bazel, consider:
      - Nix for reproducible builds and dependencies
      - Make for simple build automation
      - Language-native build tools
      - Shell scripts for basic automation

examples:
  - input: "How should I structure the build?"
    output: "Use Nix for reproducible builds and dependency management. See our Nix documentation for examples."
  - input: "Can we add a Bazel rule?"
    output: "We use Nix overlays instead of Bazel rules. Please convert this to a Nix overlay."

metadata:
  priority: critical
  version: 2.0
</rule>
```

#### Automating License Headers
```markdown
---
description: Add License Header
globs: *
---
# Add License Header

Automatically add license headers to new files.

<rule>
name: add_license_header
description: Automatically add license headers to new files
filters:
  - type: file_extension
    pattern: "*"
  - type: event
    pattern: "file_create"
actions:
  - type: execute
    command: "depot-addlicense \"$FILE\""
  - type: suggest
    message: |
      License headers should follow these formats:

      Go files:
      ```go
      // Copyright (c) 2025 Geoffrey Huntley <ghuntley@ghuntley.com>. All rights reserved.
      // SPDX-License-Identifier: Proprietary
      ```

      Nix files:
      ```nix
      # Copyright (c) 2025 Geoffrey Huntley <ghuntley@ghuntley.com>. All rights reserved.
      # SPDX-License-Identifier: Proprietary
      ```

      Shell files:
      ```bash
      # Copyright (c) 2025 Geoffrey Huntley <ghuntley@ghuntley.com>. All rights reserved.
      # SPDX-License-Identifier: Proprietary
      ```
metadata:
  priority: high
  version: 1.0
</rule>
```

#### Automating Git Commits
```markdown
# Git Conventional Commits

Rule for automatically committing changes made by CursorAI using conventional commits format.

<rule>
name: conventional_commits
description: Automatically commit changes made by CursorAI using conventional commits format
filters:
  - type: event
    pattern: "build_success"
  - type: file_change
    pattern: "*"

actions:
  - type: execute
    command: |
      # Extract the change type and scope from the changes
      CHANGE_TYPE=""
      case "$CHANGE_DESCRIPTION" in
        *"add"*|*"create"*|*"implement"*) CHANGE_TYPE="feat";;
        *"fix"*|*"correct"*|*"resolve"*) CHANGE_TYPE="fix";;
        *"refactor"*|*"restructure"*) CHANGE_TYPE="refactor";;
        *"test"*) CHANGE_TYPE="test";;
        *"doc"*|*"comment"*) CHANGE_TYPE="docs";;
        *"style"*|*"format"*) CHANGE_TYPE="style";;
        *"perf"*|*"optimize"*) CHANGE_TYPE="perf";;
        *) CHANGE_TYPE="chore";;
      esac

      # Extract scope from file path
      SCOPE=$(dirname "$FILE" | tr '/' '-')

      # Commit the changes
      git add "$FILE"
      git commit -m "$CHANGE_TYPE($SCOPE): $CHANGE_DESCRIPTION"

  - type: suggest
    message: |
      Changes should be committed using conventional commits format:

      Format: <type>(<scope>): <description>

      Types:
      - feat: A new feature
      - fix: A bug fix
      - docs: Documentation only changes
      - style: Changes that do not affect the meaning of the code
      - refactor: A code change that neither fixes a bug nor adds a feature
      - perf: A code change that improves performance
      - test: Adding missing tests or correcting existing tests
      - chore: Changes to the build process or auxiliary tools

      The scope should be derived from the file path or affected component.
      The description should be clear and concise, written in imperative mood.

examples:
  - input: |
      # After adding a new function
      CHANGE_DESCRIPTION="add user authentication function"
      FILE="src/auth/login.ts"
    output: "feat(src-auth): add user authentication function"

  - input: |
      # After fixing a bug
      CHANGE_DESCRIPTION="fix incorrect date parsing"
      FILE="lib/utils/date.js"
    output: "fix(lib-utils): fix incorrect date parsing"

metadata:
  priority: high
  version: 1.0
</rule>
```

## Rules Structure

### 1. Edit Handling
- **Single-Pass Editing**: All necessary changes should be made in a single pass when possible
- **Grouping**: Related edits should be grouped together within the same file
- **Avoid Multiple Iterations**: Prevent making multiple separate edits to the same file
- **Markers**: Use clear edit markers and comments to indicate changes

### 2. Tool Usage Guidelines
- **File Operations**: Always verify file existence before attempting operations, use read_file before edit_file
- **Search Operations**: Use specific search terms to get precise results, verify results before acting
- **Code Analysis**: Verify syntax before making changes, analyze affected files

### 3. Error Prevention
- **Pre-Edit Checks**: Verify file context thoroughly, validate syntax, confirm understanding
- **Post-Edit Validation**: Check for introduced errors, verify references remain intact

### 4. Performance Optimization
- **Operation Batching**: Group related operations to reduce API calls
- **Resource Management**: Release resources promptly after use
- **Context Optimization**: Minimize token usage by focusing only on relevant context

### 5. Best Practices
- **Documentation**: Comment all significant changes with proper PHPDoc
- **Error Handling**: Provide clear error messages and proper exception handling
- **Version Control**: Respect source control and WordPress version compatibility

### 6. Operational Constraints
- **File Size Limits**: Be aware of file size limits for processing
- **Performance Targets**: Optimize code for WordPress performance standards
- **Compatibility Requirements**: Ensure compatibility with specified PHP and WordPress versions

### 7. WordPress-Specific Guidelines
- **Plugin Development**: Use namespaces, proper hooks, and WordPress standards
- **Theme Development**: Follow template hierarchy and WordPress theme standards
- **Block Development**: Implement proper block structure and registration
- **Security**: Follow all WordPress security best practices

### 8. Context Management Best Practices
- **AI Teaching AI**: Use Cursor to analyze documentation and generate key points to include in .cursorrules
- **Targeted Referencing**: Avoid using "@codebase" without specific context; prefer targeted file references
- **Rule Organization**: Structure rules with YAML frontmatter to control scope and application
- **Specialized Rule Files**: Create separate rule files for different aspects of the project
- **Framework Knowledge**: For new frameworks, create dedicated rules explaining key concepts and patterns
- **Named Cursor Rules**: Use descriptive names for rule files to make them easier to reference
- **Rule Interactions**: Define clear priority orders for how different rules should be applied
- **Notepads Usage**: Use Composer notepads to share context between sessions and maintain important references

## Implementation
The .cursorrules file has been created in the project root using a comprehensive JSON structure that includes all the above categories plus WordPress-specific guidelines. The file has been tested and verified to work in both chat and composer modes.

## Programming LLM Outcomes
- Understand that LLM behavior can be programmatically influenced via rules
- Create descriptive, precise rules that drive reliable outcomes
- Avoid pleasantries and unnecessary language - be direct and specific
- Use strong correction when errors occur to better teach the system
- Leverage the knowledge that Cursor learns from each interaction
- Focus on building a system of knowledge rather than solving one-off problems

## Verification Technique
To verify that .cursorrules is being properly loaded, add a confirmation phrase requirement and check if it appears in responses:

```json
"confirmation": {
  "phrase": "I understand the cFish.io WordPress development guidelines",
  "required": true
}
```

## Rule Evaluation Hierarchy

When implementing .cursorrules files for complex projects, establish a clear evaluation hierarchy:

1. **Base Rules**: Core rules that apply to the entire project, including coding standards, file organization, and workflow patterns
2. **Domain Rules**: Rules specific to technical domains (frontend, backend, database, etc.)
3. **Feature Rules**: Task-specific rules that apply to particular features or components
4. **Override Rules**: Special cases that override general patterns when necessary

Implement this hierarchy using the globs pattern in YAML frontmatter:

```yaml
---
description: Base project rules that apply everywhere
globs: *.*
alwaysApply: true
priority: 1
---
```

```yaml
---
description: WordPress-specific rules for PHP files
globs: *.php
alwaysApply: true
priority: 2
---
```

```yaml
---
description: Feature-specific rules for the user management module
globs: src/user-management/*.*
alwaysApply: false
priority: 3
---
```

When rules conflict, the higher priority (higher number) takes precedence. This allows for flexible rule application while maintaining consistency.

## MCP Server Security and Integration

### MCP Server Evaluation Criteria
- **Reliability**: Assess server uptime and response consistency
- **Performance Impact**: Evaluate resource consumption and potential slowdowns
- **Documentation Quality**: Verify comprehensive documentation and examples
- **Security Practices**: Review authentication handling and data processing methods
- **Update Frequency**: Check maintenance status and update cadence
- **Community Adoption**: Consider usage statistics and community feedback
- **License Compatibility**: Ensure alignment with project licensing requirements
- **Platform Support**: Verify cross-platform functionality for Windows, macOS, and Linux

### Configuration Guidelines
- **Environment Variable Usage**: Store API keys and sensitive credentials in environment variables
- **JSON Configuration Format**: Maintain consistent JSON structure for server definitions
- **Command Structure**: Use standardized format: `env API_KEY=<token> npx <mcp-server-package>`
- **Server Categorization**: Group servers by function type (file operations, external APIs, etc.)
- **Namespace Management**: Ensure unique tool names to prevent disambiguation failures
- **Enable/Disable Options**: Configure selective activation rather than removal/re-addition
- **Project-Level Configuration**: Implement directory-specific configurations when appropriate
- **Version Pinning**: Specify server versions to ensure stability

### Selected MCP Servers for cFish.io

#### Sequential Thinking MCP Server
- **Purpose**: Provides structured and flexible approach to problem-solving through sequential thought steps
- **Capabilities**: Breaks down complex tasks into stages, incorporates scoring and tagging
- **Usage Benefits**: 
  - Systematically analyzes problems before implementation
  - Creates structured plans with clear steps
  - Improves agent reasoning for complex tasks
  - Produces more reliable results for large file refactoring
- **Implementation Example**: When refactoring large files into multiple classes, the server helps:
  1. Analyze existing code structure
  2. Create logical separation of concerns
  3. Develop a step-by-step implementation plan
  4. Execute changes systematically

#### BrowserTools MCP Server
- **Purpose**: Allows agents to interact with web browsers
- **Capabilities**: Website interaction, form filling, screenshot capturing
- **Usage Benefits**:
  - Automates browser-based tasks
  - Provides visual feedback for testing
  - Enables web scraping and data collection

#### Package Version MCP Server
- **Purpose**: Enables lookup of package information
- **Capabilities**: Version checking, dependency analysis, compatibility verification
- **Usage Benefits**:
  - Ensures proper dependency management
  - Verifies compatibility between packages
  - Provides access to package documentation

#### GitHub MCP Server
- **Source**: [Smithery AI GitHub Server](https://smithery.ai/server/@smithery-ai/github)
- **Capabilities**: Repository management, issue tracking, PR creation, and code operations
- **Configuration**: `env GITHUB_PERSONAL_ACCESS_TOKEN=<token> npx @modelcontextprotocol/server-github`
- **Security Level**: High (requires repository access token)
- **Usage Guidelines**:
  - Limit token scope to necessary permissions only
  - Implement strict branch protection for production branches
  - Configure detailed logging for all GitHub operations
  - Create project-specific tokens with appropriate expirations

#### Notion MCP Server
- **Source**: [Suekou Notion Server](https://github.com/suekou/mcp-notion-server)
- **Capabilities**: Notion database management, page creation/editing, and block operations
- **Configuration**: `env NOTION_TOKEN=<token> npx mcp-notion-server`
- **Security Level**: High (requires Notion integration token)
- **Usage Guidelines**:
  - Create dedicated integration for each project
  - Implement workspace-specific permissions
  - Document all automated Notion interactions
  - Verify token access limitations before implementation

#### Console Log MCP Server
- **Source**: [CursorIntro Console Log](https://cursorintro.com/mcp-console-log)
- **Capabilities**: Enhanced logging, visualization, and debugging functionality
- **Configuration**: `npx mcp-console-log`
- **Security Level**: Low (local operations only)
- **Usage Guidelines**:
  - Implement structured logging formats
  - Configure appropriate log levels for different environments
  - Enable visualization for complex data structures
  - Integrate with existing logging frameworks

#### Puppeteer MCP Server
- **Source**: [CursorIntro Puppeteer](https://cursorintro.com/mcp-puppeteer)
- **Capabilities**: Browser automation, screenshot capture, PDF generation, and web scraping
- **Configuration**: `npx mcp-puppeteer`
- **Security Level**: Medium (network operations)
- **Usage Guidelines**:
  - Implement proper error handling for network operations
  - Configure appropriate timeouts for web interactions
  - Document automated browser workflows completely
  - Implement rate limiting for external site interactions
  - Adhere to terms of service for sites being accessed

### MCP Security Rules
- **Token Management**: Never store API tokens in .cursorrules or version control
- **Scope Limitation**: Configure minimal required permissions for each MCP server
- **Audit Logging**: Implement comprehensive logging for all MCP operations
- **Dependency Verification**: Verify MCP server dependencies before installation
- **Command Validation**: Review all commands before execution, especially for shell operations
- **Data Processing**: Validate all data processed by MCP servers before use
- **Network Operations**: Implement proper error handling and timeouts for all network calls
- **Service Protection**: Configure rate limiting for operations that interact with external services
- **Token Rotation**: Establish regular token rotation schedules for security
- **Vulnerability Scanning**: Regularly audit MCP server dependencies for vulnerabilities

## Advanced Rule Structure

Consider structuring complex rule systems into hierarchical JSON for better organization:

```json
{
  "global": {
    "coding": {
      "style": {
        "indentation": "2 spaces",
        "lineLength": 80,
        "naming": {
          "variables": "camelCase",
          "classes": "PascalCase",
          "constants": "UPPER_SNAKE_CASE"
        }
      },
      "patterns": {
        "prefer": [
          "Functional over imperative",
          "Composition over inheritance",
          "Early returns over nested conditions"
        ],
        "avoid": [
          "Global state",
          "Deep nesting",
          "Magic numbers"
        ]
      }
    },
    "workflow": {
      "commitStyle": "conventional",
      "branchModel": "feature/fix/hotfix prefix"
    }
  },
  "domains": {
    "frontend": {
      // Frontend-specific rules
    },
    "backend": {
      // Backend-specific rules
    },
    "database": {
      // Database-specific rules
    }
  },
  "features": {
    "auth": {
      // Authentication-specific rules
    },
    "user": {
      // User management-specific rules
    }
  }
}
```

This structure enables Cursor to understand the context and application of each rule more clearly, leading to more accurate code generation and analysis.

## Best Practices for Rule Configuration

### Rule Content Optimization
- **Maintain Concise Rule Sets**: Keep .cursorrules focused and minimal, avoiding unnecessary details and bloat
- **Use YAML Format**: Implement project rules using YAML format for better structure and readability
- **Automated Generation**: Consider automatically generating rules by crawling official documentation
- **Self-Improving Rules**: Configure the AI agent to improve its own rules after coding sessions
- **Modular Organization**: Separate Cursor rules for different libraries into distinct files
- **Regular Maintenance**: Consistently update and prune rules as your project evolves, removing outdated instructions
- **Standardized Documentation Structure**: Use consistent Markdown structure with defined sections 

### Rule Implementation Strategies
- **Template-Based Workflow**: Start with existing .cursorrules templates from cursor.directory and customize them
- **Interactive Questioning**: Add a rule requesting Cursor to ask clarifying questions when instructions are unclear
- **Reasoning-Based Prompts**: Structure prompts to encourage the AI to reason about code rather than just generate it
- **Constraint Implementation**: Define clear boundaries and rules for AI-powered code modifications
- **Implement Rate Limiting**: Consider client-side rate limiting rules if making excessive API calls
- **Progressive Reasoning**: Implement step-by-step reasoning with continuous self-questioning and revision
- **Context Verification**: Use visual markers (like animal emojis) to verify AI context retention

### Rule Verification and Testing
- **Repository Analysis**: Draw inspiration from analyzing large samples of public .cursorrules repositories
- **Performance Monitoring**: Implement tracking to measure rule effectiveness and optimize token usage
- **Model-Specific Rules**: Create separate .mdc rules files for different AI models (Anthropic and OpenAI)
- **Feedback Mechanisms**: Create rules that incorporate feedback loops from compiler errors, tests, and linter output

## Common Mistakes to Avoid

### 1. Context Management Mistakes
- **Using "@codebase" without specific context**: This forces AI to guess what's important
- **Not providing sufficient file context**: Open and reference all related files at once
- **Adding irrelevant context**: Too much context dilutes focus and wastes tokens
- **Not using descriptive references**: For clarity, use "this is the backend @/backend.py" instead of generic references
- **Ignoring file size limitations**: Not alerting the AI when files exceed normal context window size
- **Starting sessions without context**: Don't begin new development sessions without reviewing previous context and logs
- **Not checking for hallucinations**: Verify AI's claims about your codebase and APIs
- **Proceeding with confused context**: Don't continue with the same Composer session when it starts going in circles

### 2. Prompt Construction Mistakes
- **Vague or ambiguous instructions**: AI needs specific, clear directions
- **Providing too many instructions at once**: Complex requests should be broken down
- **Not referencing documentation**: Always point to relevant documentation for libraries/frameworks
- **Missing important project context**: AI needs to understand the overall architecture
- **No error handling guidance**: AI may skip proper error handling without explicit instructions
- **Using vague prompts**: Never use generic or unclear prompts like 'code stuff'
- **Assuming AI understanding**: Don't assume AI has correctly understood requirements without verification
- **Not breaking down complex tasks**: Don't request large feature sets at once
- **Accepting initial output without clarification**: Engage in clarifying questions rather than accepting first code generation attempt
- **Treating AI as a conversation partner**: Don't try to have normal conversations without proper context
- **Providing abstract explanations**: Don't provide abstract explanations without concrete code or specific details
- **Using AI as no-code solution**: Don't expect AI to replace learning programming fundamentals
- **Relying solely on AI for specifications**: Don't allow AI to modify or create initial human requirements

### 3. Rule Configuration Mistakes
- **Contradictory rules**: Ensure your rules don't conflict with each other
- **Overloading .cursorrules**: Keep rules focused and relevant
- **Incorrect rule placement**: .cursorrules should be in the root directory only
- **Not prioritizing rules**: Important rules should be listed first
- **Missing framework-specific guidance**: Include key patterns for your framework
- **Prevent Rule Overloading**: Don't include extensive specifications or large code blocks in .cursorrules
- **Avoid Multiple Folder-Level Rules**: Don't attempt to implement multiple .cursorrules in different folders
- **Unstructured Rule Definitions**: Don't create rule files without a clear structure or reasoning component
- **Avoid Generic Cursor Rules**: Don't rely on .cursorrules as the primary configuration method
- **Don't Skip .cursorrules Configuration**: Avoid working on projects without proper .cursorrules configuration
- **Avoid Moralizing Warnings**: Don't include phrases like 'it's important to note...' or 'remember that...' in rules
- **Avoid Relying Solely on Documentation Symbols**: Don't limit yourself to using only documentation symbols
- **Don't Rely on Generated Rules Without Review**: Avoid using automatically generated rules without verification
- **Avoid Direct Rule Implementation Without Documentation**: Don't create Cursor rules without referencing docs
- **Don't Skip Context Setup**: Avoid using Cursor without proper context and rules configuration
- **Avoid Sensitive Data Exposure**: Never include credentials, secrets, or private tokens in .cursorrules
- **Too many rules at once**: Don't create overly complex rule structures that might conflict
- **Outdated rules**: Update rules regularly as your project evolves
- **Insufficiently detailed rules**: Provide enough details for the AI to understand project conventions
- **Overspecific rules**: Don't make rules so specific that they limit AI flexibility inappropriately
- **Missing validation of rule effects**: Test how rules affect AI output before committing to them

### 4. Workflow Mistakes
- **Using AI pane instead of Composer**: Composer is preferable for complex, multi-file tasks
- **Not saving work frequently**: Save progress to prevent losing changes
- **Too many changes at once**: Break down complex changes into manageable parts
- **Using Cursor for UI when v0 is better**: Choose the right tool for visual design tasks
- **Not verifying AI output**: Always review generated code for accuracy and potential issues
- **Skipping verification steps**: Don't assume AI has completed all requirements without verification
- **Implementing large feature drops**: Break large features into smaller, manageable pieces
- **Skipping the overview phase**: Don't let AI generate code without understanding its planned approach
- **Neglecting changelog updates**: Always update changelog after code changes
- **Maintaining excessively long sessions**: Reset AI sessions periodically to avoid context issues
- **Using chat for complex problems**: Use Composer rather than Chat for significant technical issues
- **Making monolithic requests**: Don't ask for complete complex features in a single request
- **Skipping PRD creation**: Don't make AI requests without proper documentation and requirements
- **Not using version control**: Don't make AI-assisted changes without having a version control system in place
- **Avoiding direct code writing in chat**: Don't use Chat mode for substantial code changes
- **Ignoring design requirements**: Don't skip having clear design specifications before starting development
- **Relying on Chat for complex problem solving**: Use Composer for significant technical issues

### 5. Technical Implementation Mistakes
- **Not enabling "Iterate on Lints"**: This feature helps automatically fix coding standards issues
- **Ignoring version control integration**: Commit often to create safety checkpoints
- **Using single-file edits for multi-file changes**: Group related changes together
- **Not setting up proper linting tools**: Configure tools like PHPStan and PHPCS
- **Not using department-specific context**: Follow UcF department conventions when appropriate
- **Blindly applying AI fixes**: Don't implement AI-suggested fixes without understanding underlying issues
- **Relying solely on AI for complex systems**: Be cautious about using AI generation for safety-critical systems
- **Accepting AI code without understanding**: Don't implement AI-generated code without comprehending its structure
- **Ignoring code size limitations**: Be aware of AI tools' context window limitations for large codebases
- **Making unrestricted modifications**: Don't allow AI to make unrestricted changes without constraints
- **Allowing unrelated modifications**: Prevent AI from modifying code unrelated to current request
- **Allowing silent error handling**: Don't let AI handle errors without proper error reporting
- **Skipping reviews for AI code**: Don't bypass code review processes for AI-generated code
- **Neglecting security considerations**: Don't postpone security until after implementation
- **Making uncontrolled API requests**: Don't make API calls without rate limiting or throttling

### 6. Resource Management Mistakes
- **Exceeding API rate limits**: Implement proper handling for API usage limits
- **Ignoring cost considerations**: Consider budget implications when selecting AI models
- **Underestimating usage costs**: Set appropriate usage limits based on actual consumption patterns
- **Single-tool dependency**: Don't build critical workflows around a single proprietary tool
- **Not monitoring AI behavior**: Track and adjust AI tool behavior based on observed patterns
- **Ignoring tool degradation**: Don't continue using tools showing clear performance issues
- **Delaying tool evaluation**: Don't wait until tools become completely unusable before evaluating alternatives
- **Ignoring regional accessibility**: Consider pricing and accessibility differences in different markets

### 7. Testing and Quality Assurance Mistakes
- **Skipping test creation**: Don't write AI-generated code without test coverage
- **Neglecting documentation for AI-generated code**: Don't leave generated code without proper documentation
- **Unguided code generation**: Don't let AI generate code without clear test specifications
- **Treating AI code as production-ready**: Don't deploy Cursor-generated code without proper review and testing
- **Direct coding without tests**: Consider using test-driven development approach with AI
- **Skipping basic programming fundamentals**: Understand fundamentals before attempting complex applications
- **Not verifying security implications**: Ensure thorough security review of AI-generated code
- **Skipping cross-platform testing**: Test applications across all required platforms and environments
- **Relying on single model results**: Validate complex results using multiple AI models when appropriate
- **Neglecting user experience testing**: Balance technical correctness with usability testing

### 8. Environment and Configuration Mistakes
- **Unprotected Agent Mode**: Don't run Agent Mode without YOLO protection against accidental deletions
- **Skipping API key verification**: Always verify API key configuration before proceeding
- **Using untrusted MCP servers**: Don't implement MCP servers from unverified sources
- **Exposing sensitive data**: Never include credentials, secrets, or private tokens in .cursorrules
- **Complex menu hierarchies**: Don't bury frequently used features deep in nested menus
- **Relying on external dependencies**: Be cautious about requiring separate API keys for basic features
- **Unvalidated MCP integration**: Verify integrity and security of third-party MCP servers
- **Skipping codebase reindexing**: Regularly reindex your codebase in Cursor settings for comprehensive search
- **Using distracting applications**: Keep social media and other distractions closed during development
- **Neglecting multi-environment testing**: Test in different environments before deployment

## Structured Project Documentation
Maintain the following documentation alongside your rules:

- **Project_milestones.md**: Track project milestones and reference in .cursorrules
- **Documentation.md**: Keep detailed function and schema documentation up-to-date
- **Cursor_context.md**: Maintain a file that tracks the current state of the project
- **.plan and .progress**: Create files for workflow documentation and progress tracking
- **Feature documentation**: Create markdown files for each large feature with requirements
- **Skip Progress Review**: Don't proceed without reviewing changes in .progress file between steps

## Cursor Features & Capabilities

### Core IDE Features
- **Smart Autocomplete**: Analyzes code context for precise suggestions beyond simple word completion
- **Cursor Prediction**: Anticipates needed code based on cursor movement and suggests it proactively
- **Smart Rewrites**: Identifies and corrects code errors automatically
- **Multi-line Editing**: Enables simultaneous changes to multiple code areas
- **Code Generation**: Creates code based on analysis of recent changes and contextual patterns

### AI Chat & Query Features
- **Direct Code Interaction**: Ask specific questions about code like "Is there an error here?"
- **Codebase-wide Queries**: Use Ctrl+Enter to search entire codebase for relevant information
- **Specific Code References**: Use @ symbol as search tool to reference files during conversations
- **Image Upload**: Provide visual context through image uploading capability
- **Web Search Integration**: Use @Web command to obtain real-time information from internet

### Documentation Management
- **Library Documentation Access**: Reference popular libraries with @LibraryName command
- **Document Addition**: Add new documentation with @Docs → Add New Document
- **Organized Documentation**: Structure documentation for easy AI reference
- **Context Enhancement**: Reference documentation for additional context in complex tasks

## File Management Best Practices

### Optimal File Structure
- **Small Files**: Break large files (>1000 lines) into smaller modules (<100 lines) for better agent performance
- **Descriptive Naming**: Use clear, purpose-based naming to improve context understanding
- **Logical Grouping**: Organize by feature or domain rather than by type for better context retention
- **Hierarchical Organization**: Maintain clear directory structure with logical dependencies
- **Modular Architecture**: Create well-defined interfaces between components

### Project Organization for AI Collaboration
```
project-root/
├── .cursorrules                  # AI behavior configuration
├── .cursorignore                 # Files to exclude from AI access
├── docs/
│   ├── architecture.mermaid      # System architecture diagram
│   ├── technical.md              # Technical documentation
│   └── status.md                 # Progress tracking
├── tasks/
│   └── tasks.md                  # Development tasks
└── src/                          # Source code
```

## Tool-Specific Configuration

### .cursorignore Configuration
- By default, Cursor ignores all files in .gitignore
- Create .cursorignore to control AI access to files:
```
# Add directories or file patterns to ignore during indexing
vendor/
node_modules/
languages/
build/
!.cursor/scratchpad.md
```
- Use `!` prefix to explicitly include files that would otherwise be ignored

### Cursor Documentation Integration
- Add custom documentation to project context via Settings → Documentation
- Point to documentation base URL for AI indexing
- Reference documentation using @url in prompts
- Create dedicated rules files for different documentation aspects

## Specifications-Driven Development
- Create a "specs/" folder with domain-specific markdown files
- Organize each specification by domain topic with separate markdown files
- Create a central SPECS.md that links to all specification documents
- Use specifications as the foundation for the loopback workflow
- Structure specifications to be comprehensive and detailed
- Consider specifications as the driving force behind development
- Allow AI to help draft and organize specifications
- Use specification conversations before starting implementation
- Generate specifications hierarchically by domain:
  ```
  specs/
  ├── core/             # Core application functionality
  ├── domain-specific/  # Domain-specific features
  └── ui/               # User interface components
  ```

## Next Steps
1. **Regular Maintenance**: Update the .cursorrules file as the project evolves
2. **Team Training**: Ensure all team members understand how to work with the rules
3. **Performance Monitoring**: Track token usage and optimize rules as needed
4. **Integration**: Consider integrating with CursorFocus for automated rule updates
5. **AI Self-Improvement**: Have Cursor periodically review and suggest improvements to its own rules
6. **Rule Metrics**: Implement tracking to measure the effectiveness of different rules
7. **Iterative Refinement**: Continuously refine rules based on AI output quality
8. **Centralized Management**: Consider implementing a central rule repository for cross-project consistency

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## Common Mistakes in Using Cursor Rules

### Fundamental Misconceptions
- Using Cursor as a replacement for Google Search
- Underspecification of prompts and using low-level "implement XYZ" thinking
- Treating Cursor as just an IDE instead of an autonomous agent
- Not understanding that LLM behavior can be programmatically influenced
- Using unnecessary pleasantries ("please" and "can you") with the AI

### The StdLib Approach to Rules

#### Core Principles
- Build a comprehensive "standard library" (stdlib) of thousands of prompting rules
- Compose rules together like unix pipes for powerful interactions
- Focus on solving classes of problems rather than individual instances
- Program LLM behavior through carefully crafted rules
- Use rules to teach the AI and improve its accuracy over time
- Current foundational LLM models are at ~45% accuracy and require frequent steering

#### Building Your StdLib
1. Start with foundational rules (e.g., rules location, git commits)
2. Add domain-specific rules (e.g., language conventions, tooling preferences)
3. Create rules for automated workflows (e.g., license headers, testing)
4. Implement feedback loops to improve rule effectiveness
5. Have Cursor write and update rules based on its learnings
6. Build up abstraction levels incrementally

#### Specification-Driven Development
1. Create detailed specifications in a `specs/` directory
2. Organize specs by domain topic in separate markdown files
3. Maintain a central `SPECS.md` as an index
4. Use specifications as the foundation for development
5. Allow the AI to help draft and refine specifications

#### The Loopback Workflow
The core workflow for hands-free development:
```
Study @SPECS.md for functional specifications
Study @.cursor for technical requirements
Implement what is not implemented
Create tests
Run build verification
Run linting and resolve issues
```

If the AI goes off track:
1. Restart the chat session to clear context
2. Reapply the loopback prompt
3. Continue until everything is implemented correctly

#### Multi-Agent Development
- Use git worktree for separate working directories
- Launch multiple Cursor instances for parallel development
- Work on non-overlapping parts of the application
- Automate git commits and PR creation
- Create rules for branch reconciliation and merge conflict resolution

#### Specification Domains
Organize your application into distinct domains:
```
src/
├── core/           # Core application functionality
├── ai/mcp_tools/   # MCP tools implementation
└── ui/            # User interface components
```

Work on each domain independently:
1. Implement core functionality first
2. Create separate specification sets for each domain
3. Use multiple Cursor instances for parallel development
4. Maintain clear boundaries between domains

#### Best Practices for Rules
1. **Rule Creation**
   - Have Cursor write rules and update them with learnings
   - Create rules that solve entire classes of problems
   - Build up abstraction levels incrementally
   - Focus on reusable patterns and solutions

2. **Rule Organization**
   - Store all rules in `.cursor/rules/` directory
   - Use clear, descriptive filenames
   - Organize rules by domain or technology
   - Maintain rule priority hierarchy

3. **Rule Implementation**
   - Use YAML frontmatter for rule metadata
   - Include clear descriptions and examples
   - Define specific filters and actions
   - Implement proper error handling

4. **Rule Evolution**
   - Update rules based on AI performance
   - Document successful patterns
   - Remove outdated or ineffective rules
   - Maintain rule consistency across the project

#### Example Rule Structure
```yaml
---
description: Rule purpose and scope
globs: pattern to match files
priority: rule priority level
---
# Rule Title

Detailed description of rule purpose and behavior.

<rule>
name: rule_name
description: Specific rule description
filters:
  - type: filter_type
    pattern: "filter_pattern"
actions:
  - type: action_type
    command: "action_command"
    message: "action_message"
examples:
  - input: "example input"
    output: "expected output"
metadata:
  priority: priority_level
  version: version_number
</rule>
```

#### Feedback Loop Integration
- Use compiler errors for guidance (especially in Rust/Haskell)
- Implement property-based testing
- Integrate static analysis tools (e.g., SonarQube)
- Add security scanning tools to the feedback loop
- Create automated validation workflows

#### Language Considerations
- Prefer languages with strong type systems and good compiler errors
- Rust and Haskell are particularly well-suited due to:
  - Compiler soundness (if it compiles, it likely works)
  - Exceptional error messages
  - Strong type systems
  - Built-in testing frameworks
- Use property-based testing for thorough validation
- Leverage compiler feedback for automated fixes

## Next Steps
1. **Build Your StdLib**: Start creating your rule library incrementally
2. **Implement Feedback Loops**: Set up automated testing and validation
3. **Create Specification Structure**: Organize your specs by domain
4. **Configure Multi-Agent Setup**: Prepare for parallel development
5. **Establish Workflows**: Implement the loopback workflow pattern
6. **Monitor and Improve**: Track rule effectiveness and update as needed

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## Advanced Rule Patterns

### Dynamic Rule Generation
- Implement self-improving rule systems:
  ```markdown
  meta_rule:
    pattern_learning:
      - Monitor rule effectiveness
      - Identify improvement opportunities
      - Generate rule variations
      - Test and validate changes
    rule_evolution:
      - Track successful patterns
      - Remove ineffective rules
      - Merge complementary rules
      - Document rule history
  ```
- Create rule generation templates:
  - Define rule structure patterns
  - Create validation frameworks
  - Implement testing procedures
  - Document generation process

### Rule Interaction Management
- Create sophisticated rule interaction patterns:
  - Define rule precedence
  - Implement conflict resolution
  - Document dependencies
  - Track interaction effects
- Optimize rule relationships:
  - Create interaction maps
  - Define composition rules
  - Document override patterns
  - Monitor rule conflicts

### Context-Aware Rule Application
- Implement context-sensitive rule selection:
  ```markdown
  context_rules:
    evaluation:
      - Assess current context
      - Select applicable rules
      - Apply rule combinations
      - Monitor effectiveness
    adaptation:
      - Adjust to context changes
      - Update rule priorities
      - Modify rule parameters
      - Track adaptation results
  ```
- Create context optimization strategies:
  - Define context categories
  - Create selection criteria
  - Implement priority systems
  - Document context patterns

### Rule Performance Monitoring
```php
class RulePerformanceMonitor {
  private $metrics = [];
  
  public function track_rule_application($rule_id, $context) {
    $this->metrics[] = [
      'rule_id' => $rule_id,
      'context' => $context,
      'timestamp' => microtime(true),
      'outcome' => $this->evaluate_outcome()
    ];
  }
  
  public function analyze_rule_performance() {
    return [
      'effectiveness' => $this->calculate_effectiveness(),
      'context_fit' => $this->evaluate_context_match(),
      'interaction_impact' => $this->assess_interactions(),
      'adaptation_success' => $this->measure_adaptability()
    ];
  }
}
```

### Rule Evolution Strategies
- Implement rule improvement processes:
  - Create evolution criteria
  - Define success metrics
  - Track improvement impact
  - Document evolution patterns
- Optimize evolution workflow:
  - Regular rule review
  - Performance analysis
  - Adaptation tracking
  - Success validation

### Advanced Rule Composition
- Create sophisticated rule combinations:
  - Define composition patterns
  - Implement merge strategies
  - Document integration points
  - Track composition effects
- Optimize rule structure:
  - Create modular components
  - Define reuse patterns
  - Implement inheritance
  - Document dependencies

### Rule Validation Framework
- Implement comprehensive validation:
  - Create validation criteria
  - Define test scenarios
  - Implement verification
  - Document validation process
- Optimize validation workflow:
  - Automated testing
  - Performance impact
  - Conflict detection
  - Regression analysis

### Continuous Rule Optimization
- Implement ongoing improvement:
  - Monitor rule effectiveness
  - Identify optimization opportunities
  - Track improvement impact
  - Document success patterns
- Create optimization strategies:
  - Regular performance review
  - Rule refinement process
  - Impact assessment
  - Pattern recognition

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## Department-Specific Rules

### U1-Administration
- Business administration and overhead functions
- Trust structure management
- Financial operations and planning
- Organizational policy documentation
- Cross-departmental coordination

### U2-Research
- AI integration and R&D
- tYFeAiz collaboration framework
- Emerging technology research
- Innovation implementation
- Cross-platform integration

### U3-Operations
- Physical infrastructure management
- FiscHouse operations
- Hardware resource allocation
- Physical security measures
- Facility coordination

### U4-Production
- WordPress development standards
- Content management
- Production workflow
- Quality assurance
- Output efficiency

### U5-Data
- DMMS implementation
- Data flow management
- System synchronization
- Integration protocols
- Data security

### U6-Marketing
- FischEYe production design
- Social media management
- Brand identity
- Client communications
- Marketing automation

### U7-Systems
- Development standards
- Technical direction
- System architecture
- Infrastructure planning
- Specialized solutions

## Implementation Guidelines

### File Organization
```
.cursor/
├── rules/
│   ├── base/
│   │   ├── coding-standards.mdc
│   │   └── workflow.mdc
│   ├── departments/
│   │   ├── u1-administration.mdc
│   │   └── ...
│   ├── features/
│   │   ├── auth.mdc
│   │   └── user.mdc
│   └── meta/
│       └── rule-management.mdc
├── templates/
│   └── rule-template.mdc
└── config/
    └── rule-config.json
```

### Rule Configuration
```json
{
  "ruleConfig": {
    "validation": {
      "enabled": true,
      "frequency": "onCommit",
      "testCases": ["standard", "security", "wordpress"]
    },
    "performance": {
      "monitoring": true,
      "metrics": ["effectiveness", "contextFit", "impact"]
    },
    "evolution": {
      "autoImprovement": true,
      "reviewCycle": "weekly"
    }
  }
}
```

### Documentation Standards
- Follow UcF documentation format
- Include department-specific guidelines
- Maintain consistent structure
- Update regularly with changes
- Track version history

## Next Steps
1. Implement automated rule validation
2. Enhance department-specific rules
3. Create performance monitoring system
4. Develop rule evolution framework
5. Establish continuous improvement process

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## DMMS Integration Guidelines

### Phase 1: Foundation
- **Core Implementation**:
  - Basic data structure setup
  - Initial schema design
  - Base API endpoints
  - Fundamental security measures

### Phase 2: Enhancement
- **Advanced Features**:
  - Data relationship mapping
  - Complex query optimization
  - Cache implementation
  - Performance monitoring

### Phase 3: Security
- **Security Measures**:
  - End-to-end encryption
  - Access control matrices
  - Audit logging
  - Threat detection
  - Compliance verification

### Phase 4: Optimization
- **System Optimization**:
  - Query performance tuning
  - Index optimization
  - Cache strategy refinement
  - Load balancing setup

## Mobile-First Development

### Responsive Design Rules
- **Viewport Configuration**:
  ```php
  add_action('wp_head', function() {
    echo '<meta name="viewport" content="width=device-width, initial-scale=1">';
  });
  ```

### Mobile Performance
- **Image Optimization**:
  ```php
  add_filter('wp_get_attachment_image_attributes', function($attr) {
    $attr['loading'] = 'lazy';
    return $attr;
  });
  ```

### Touch Interface
- **Touch Event Handling**:
  ```javascript
  document.addEventListener('touchstart', function(e) {
    // Touch event handling
  }, {passive: true});
  ```

## tYFeAiz Live Boardz Integration

### Multi-Agent Collaboration
- **Agent Communication Protocol**:
  ```json
  {
    "agent_protocol": {
      "message_format": "JSON-RPC",
      "authentication": "JWT",
      "channels": ["main", "debug", "system"]
    }
  }
  ```

### Live Boardz Setup
- **Board Configuration**:
  ```yaml
  live_boardz:
    channels:
      - name: development
        agents: ["cursor", "tyfeaiz"]
      - name: review
        agents: ["cursor", "human"]
    sync:
      interval: 5000
      retry: 3
  ```

## Enhanced WordPress Components

### Custom Post Types
```php
function register_custom_post_types() {
  register_post_type('project', [
    'public' => true,
    'show_in_rest' => true,
    'supports' => ['title', 'editor', 'thumbnail'],
    'show_in_graphql' => true,
    'graphql_single_name' => 'project',
    'graphql_plural_name' => 'projects'
  ]);
}
add_action('init', 'register_custom_post_types');
```

### Custom Taxonomies
```php
function register_custom_taxonomies() {
  register_taxonomy('project_category', ['project'], [
    'hierarchical' => true,
    'show_in_rest' => true,
    'show_in_graphql' => true,
    'graphql_single_name' => 'projectCategory',
    'graphql_plural_name' => 'projectCategories'
  ]);
}
add_action('init', 'register_custom_taxonomies');
```

### REST API Extensions
```php
function register_rest_fields() {
  register_rest_field('project', 'meta_data', [
    'get_callback' => function($object) {
      return get_post_meta($object['id']);
    },
    'schema' => [
      'description' => 'Project meta data',
      'type' => 'object'
    ]
  ]);
}
add_action('rest_api_init', 'register_rest_fields');
```

### Block Development
```php
function register_custom_blocks() {
  register_block_type(__DIR__ . '/blocks/project-showcase', [
    'render_callback' => 'render_project_showcase'
  ]);
}
add_action('init', 'register_custom_blocks');
```

## Mobile-First Development Guidelines

### Core Principles
- Prioritize mobile optimization in all web development
- Design mobile interface first, then scale up for desktop/tablet
- Maintain consistent user experience across all devices
- Ensure desktop/tablet versions remain familiar to mobile layout
- Test responsive design at every development stage

### Implementation Strategy
```javascript
// Console logging for mobile-first development
console.log('[Mobile-First] Starting mobile layout implementation');
console.log('[Mobile-First] Device width:', window.innerWidth);
console.log('[Mobile-First] Viewport meta:', document.querySelector('meta[name="viewport"]'));

// Viewport configuration
document.head.innerHTML += `
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
`;
```

### Responsive Design Implementation
```javascript
// Console logging for responsive design checks
const checkResponsiveness = () => {
  console.log('[Responsive] Window size changed');
  console.log('[Responsive] New width:', window.innerWidth);
  console.log('[Responsive] New height:', window.innerHeight);
  console.log('[Responsive] Device pixel ratio:', window.devicePixelRatio);
};

window.addEventListener('resize', checkResponsiveness);
```

## Library Selection Guidelines

### Selection Criteria
- Only use libraries from current year (< 12 months old)
- Verify high download counts and community adoption
- Check GitHub stars and recent commit activity
- Review open issues and resolution rate
- Assess documentation quality and completeness

### Version Management
```javascript
// Console logging for library version checks
const checkLibraryVersions = (dependencies) => {
  console.log('[Libraries] Starting version check');
  Object.entries(dependencies).forEach(([name, version]) => {
    console.log(`[Libraries] Checking ${name}@${version}`);
    console.log(`[Libraries] Last update:`, new Date());
    console.log(`[Libraries] Download count:`, 'fetching...');
  });
};
```

## Deployment Strategy

### Continuous Deployment Workflow
1. Deploy initial application with first page
2. Re-deploy after each feature or library addition
3. Test in production environment after each deployment
4. Monitor performance metrics continuously

### Deployment Logging
```javascript
// Console logging for deployment process
const logDeployment = (version, features) => {
  console.log('[Deployment] Starting deployment process');
  console.log('[Deployment] Version:', version);
  console.log('[Deployment] New features:', features);
  console.log('[Deployment] Timestamp:', new Date().toISOString());
  console.log('[Deployment] Environment:', process.env.NODE_ENV);
};
```

## Session Management

### Chat Session Guidelines
- Create new chat/agent session for each feature completion
- Update workbench and memory files after each session
- Document problems, challenges, and successes
- Provide clear next steps for continuation

### Session Documentation
```javascript
// Console logging for session management
const logSessionEnd = (sessionData) => {
  console.log('[Session] Completing chat session');
  console.log('[Session] Duration:', sessionData.duration);
  console.log('[Session] Files modified:', sessionData.modifiedFiles);
  console.log('[Session] Memory updates:', sessionData.memoryUpdates);
  
  // Generate session summary
  const summary = {
    timestamp: new Date().toISOString(),
    completed: sessionData.completedTasks,
    challenges: sessionData.challenges,
    successes: sessionData.successes,
    nextSteps: sessionData.nextSteps
  };
  
  console.log('[Session] Summary:', JSON.stringify(summary, null, 2));
  return summary;
};
```

### Memory File Updates
```javascript
// Console logging for memory file updates
const updateMemoryFiles = (changes) => {
  console.log('[Memory] Starting memory file updates');
  console.log('[Memory] Changes to apply:', changes);
  console.log('[Memory] Timestamp:', new Date().toISOString());
  
  changes.forEach(change => {
    console.log('[Memory] Applying change:', change.description);
    console.log('[Memory] Target file:', change.file);
    console.log('[Memory] Status:', change.status);
  });
};
```
