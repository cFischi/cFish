# Cursor AI Quick Reference Guide

## Core Cursor Functions

### Chat Mode

| Action | Command/Shortcut | Description |
|--------|-----------------|-------------|
| Open Chat | `/` or click chat icon | Opens the chat panel to interact with AI |
| Include Current File | `@` | References the currently open file in your prompt |
| Include Open Editors | Type "open editors" | Includes all open editor tabs in your context |
| Clear Chat | "Clear Chat" button | Resets the conversation |
| Command Menu | `Ctrl+Shift+P` / `Cmd+Shift+P` | Opens command palette |
| Switch AI Models | Click model name | Switch between available AI models |

### Composer Mode

| Action | Command/Shortcut | Description |
|--------|-----------------|-------------|
| Open Composer | `Ctrl+K` / `Cmd+K` | Opens the Composer interface |
| Create New Session | `+` button in sidebar | Creates a new Composer session |
| Run Session | "Run" button | Execute the entire prompts in sequence |
| Continue Running | "Continue" button | Continue execution from current point |
| Checkpoint | Click "Checkpoint" button | Save the current state for later reverting |
| Revert to Checkpoint | Select checkpoint | Roll back to a previous checkpoint |

### Text Generation & Editing

| Action | Command/Shortcut | Description |
|--------|-----------------|-------------|
| Generate Code | `Ctrl+Enter` / `Cmd+Enter` | Generate code at cursor position |
| Generate in Line | `Ctrl+L` / `Cmd+L` | Generate code and insert in current line |
| Accept Suggestion | `Tab` | Accept current inline suggestion |
| Explain Code | Select code + `/explain` | Get explanation of selected code |
| Code Actions Menu | `Ctrl+.` / `Cmd+.` | Open AI code actions menu |
| Fix Issues | Right-click > "Fix with AI" | Let AI fix identified issues |

## .cursorrules Usage

### Activating Rules

1. Create a `.cursorrules` file in your project root
2. JSON format with configuration settings
3. Rules apply automatically to both Chat and Composer modes

### Testing Rules

Verify rules are active with:
- Confirmation phrase check
- Validate formatting follows rules
- Check error prevention behaviors

### Example Rule Structure

```json
{
  "wordpress": {
    "corePrinciples": [
      "Use OOP for better modularity and maintainability",
      "Follow WordPress coding standards consistently"
    ]
  },
  "editHandling": {
    "singlePass": "Make all necessary changes in a single pass when possible"
  }
}
```

## YOLO Mode

### Enabling YOLO Mode

1. Click on settings icon
2. Navigate to Cursor settings
3. Find YOLO mode settings
4. Configure allowed commands
5. Enable the feature

### YOLO Mode Best Practices

1. Always set specific permissions
2. Monitor initial executions
3. Be explicit about allowed command types
4. Use with test environments first
5. Review generated commands before permanent implementation

## CursorFocus Integration

### Setup

1. Clone from GitHub: `git clone https://github.com/RenjiYuusei/CursorFocus.git`
2. Run `npm install` in the repository
3. Configure for your project
4. Start tracking with `npm start`

### Usage

1. View project structure in focus-output directory
2. Reference tracking data in prompts
3. Leverage automatic .cursorrules updates
4. Use generated documentation

## TDD Workflow with Cursor

### Test Creation

1. Define requirements clearly
2. Ask Cursor to write tests first
3. Use the standardized prompt templates
4. Review test coverage and edge cases

### Implementation

1. Run tests (they should fail)
2. Ask Cursor to implement minimum code to pass tests
3. Run tests again (they should pass)
4. Request refactoring while maintaining test passing status

### Verification

1. Use pre-PR command to verify all tests pass
2. Review code quality and security
3. Commit changes with descriptive message

## Context Management

### Optimizing Token Usage

1. Only include relevant files
2. Use specialized readme files for context
3. Create context.md for project architecture
4. Reference open editors selectively

### Context Commands

| Action | Command/Example | Description |
|--------|-----------------|-------------|
| Include File | `@filename.php` | Include specific file |
| Reference Open Editors | "Consider my open editors" | Include all open files |
| Directory Context | "Look at files in src/components" | Focus on specific directory |
| Recent Files | "Check my recently edited files" | Include recently modified files |

## Troubleshooting

### Common Issues

1. **AI Not Following Rules**
   - Verify .cursorrules file format
   - Check file location (must be in project root)
   - Test with confirmation phrase

2. **High Token Usage**
   - Reduce context size
   - Use more specific references
   - Clear chat history for fresh context

3. **Performance Issues**
   - Start new Composer session when slow
   - Use lighter AI models for simpler tasks
   - Close unused editor tabs

4. **Command Execution Issues**
   - Verify YOLO permissions
   - Check command syntax
   - Review error messages

### Getting Help

- Visit [Cursor Forum](https://forum.cursor.com/) for community help
- Check [Cursor Documentation](https://cursor.sh/docs) for official guidance
- Use `/help` command for AI-based assistance

## WordPress-Specific Tips

1. Use proper security practices (nonce, sanitize, escape)
2. Follow WordPress coding standards
3. Leverage hooks appropriately
4. Implement OOP principles
5. Test all components thoroughly

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 