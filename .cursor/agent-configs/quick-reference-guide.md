# Multi-Agent Workflow Quick Reference Guide

## Agent Selection Guide

| Task Type | Recommended Agent | Key Capabilities |
|-----------|------------------|------------------|
| Project planning | Project Architect | Architecture design, requirements gathering |
| Feature implementation | Code Implementation Specialist | Coding, API development, database integration |
| Theme development | Theme Development Specialist | Theme creation, responsive design, customizer |
| Code review | Security & QA Analyst | Security review, quality assurance, testing |
| Documentation | Documentation Specialist | API docs, user guides, inline documentation |
| Plugin work | Plugin Integration Specialist | Plugin integration, customization, conflict resolution |

## Agent Activation Commands

| Agent | Activation Command |
|-------|-------------------|
| Project Architect | `Switch to Project Architect for [planning/architecture task]` |
| Code Implementation | `Switch to Code Implementation Specialist for [coding task]` |
| Theme Development | `Switch to Theme Development Specialist for [theme task]` |
| Security & QA | `Switch to Security & QA Analyst for [review task]` |
| Documentation | `Switch to Documentation Specialist for [documentation task]` |
| Plugin Integration | `Switch to Plugin Integration Specialist for [plugin task]` |

## Common Workflows

### New Feature Development

1. **Project Architect**: Define requirements and architecture
2. **Code Implementation**: Develop backend functionality
3. **Theme Development**: Create frontend components
4. **Security & QA**: Review code for security and quality
5. **Documentation**: Document feature usage and implementation

### Bug Fix Process

1. **Code Implementation**: Diagnose and fix the bug
2. **Security & QA**: Verify the fix
3. **Documentation**: Update documentation if behavior changes

### Theme Customization

1. **Project Architect**: Define design requirements
2. **Theme Development**: Implement theme changes
3. **Security & QA**: Test for responsive and accessibility issues
4. **Documentation**: Update theme documentation

## Handoff Quick Templates

### Basic Handoff Template

```
## HANDOFF: [Source Role] → [Target Role]

### Context
- Task: [Brief task description]
- Files: [Key file paths]

### Specific Request
[Clear description of what needs to be done]

### Key Information
- [Important point 1]
- [Important point 2]
- [Important point 3]

### Success Criteria
- [Success criterion 1]
- [Success criterion 2]
```

## Token Usage Tips

| Agent Role | Token Optimization Tips |
|------------|-------------------------|
| Project Architect | Use bullet points for requirements, reference design docs by URL |
| Code Implementation | Reference specific file sections, break complex tasks into steps |
| Theme Development | Focus on one component at a time, use CSS patterns over full rules |
| Security & QA | Focus on specific security concerns, use targeted code sections |
| Documentation | Document one feature at a time, use consistent templates |
| Plugin Integration | Focus on specific integration points, reference plugin docs by URL |

## Common Issues & Solutions

| Issue | Quick Solution |
|-------|----------------|
| Agent confusion | Restate role, reference agent configuration file |
| Context loss | Break into smaller tasks, repeat key information |
| Token limits | Monitor usage, start new sessions for major tasks |
| Style inconsistency | Reference coding standards, provide style examples |
| Handoff failures | Use standard templates, verify handoff receipt |

## File Locations

| Component | Location |
|-----------|----------|
| Agent Configurations | `.cursor/agent-configs/` |
| Token Monitoring Tools | `.cursor/performance-tools/` |
| Handoff Templates | `.cursor/agent-configs/agent-handoff-templates.md` |
| Training Guide | `.cursor/agent-configs/team-training-guide.md` |

## Support Resources

- **Documentation**: `.cursor/performance-tools/token-monitoring-guide.md`
- **Team Training**: `.cursor/agent-configs/team-training-guide.md`
- **Support**: Contact the cFish.io development team via Slack (#cursor-support) 