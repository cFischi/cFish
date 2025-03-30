# Token Budget Guidelines for WordPress Development

## Understanding Token Usage

Tokens are the units of text processing that AI models like Claude use to understand and generate content. Managing token usage effectively can:

1. Reduce costs
2. Improve response quality
3. Reduce response time
4. Enable handling of larger projects

One token is approximately 4 characters or 3/4 of a word in English.

## Token Budget by Task Type

| Task Type | Complexity | Input Token Budget | Output Token Budget | Total Budget | Notes |
|-----------|------------|-------------------|-------------------|--------------|-------|
| **Architecture Planning** | Low | 1,500 | 2,500 | 4,000 | Simple feature or component |
| **Architecture Planning** | Medium | 3,000 | 5,000 | 8,000 | Multi-component feature |
| **Architecture Planning** | High | 6,000 | 8,000 | 14,000 | Full project architecture |
| **Code Implementation** | Low | 2,000 | 3,000 | 5,000 | Single function or small component |
| **Code Implementation** | Medium | 4,000 | 6,000 | 10,000 | Multiple functions or class |
| **Code Implementation** | High | 8,000 | 10,000 | 18,000 | Complex feature implementation |
| **Theme Development** | Low | 2,000 | 3,000 | 5,000 | Simple template or style changes |
| **Theme Development** | Medium | 4,000 | 6,000 | 10,000 | Multiple template modifications |
| **Theme Development** | High | 8,000 | 10,000 | 18,000 | Full theme development |
| **Security Review** | Low | 2,000 | 2,000 | 4,000 | Single function review |
| **Security Review** | Medium | 4,000 | 3,000 | 7,000 | Component security audit |
| **Security Review** | High | 8,000 | 5,000 | 13,000 | Full feature security audit |
| **Documentation** | Low | 1,000 | 2,000 | 3,000 | Single function documentation |
| **Documentation** | Medium | 2,000 | 4,000 | 6,000 | Component documentation |
| **Documentation** | High | 4,000 | 8,000 | 12,000 | Full feature documentation |
| **Plugin Integration** | Low | 2,000 | 2,000 | 4,000 | Simple plugin configuration |
| **Plugin Integration** | Medium | 4,000 | 3,000 | 7,000 | Plugin customization |
| **Plugin Integration** | High | 6,000 | 5,000 | 11,000 | Complex plugin integration |

## Token Optimization Strategies

### General Strategies
1. **Focus requests specifically** - Avoid vague or open-ended requests
2. **Break complex tasks into smaller ones** - Sequential focused requests often use fewer tokens
3. **Use specialized agents** - Different agents for different tasks reduces context needed
4. **Leverage templates** - Standardized formats reduce tokens needed for instruction
5. **Reduce repetitive context** - Avoid repeating information across requests

### Code-Specific Strategies
1. **Provide only relevant code sections** - Don't include unrelated code
2. **Use directives for code style** - "Follow WordPress coding standards" instead of including all standards
3. **Reference existing patterns** - "Implement like X function" instead of describing pattern in detail
4. **Focus on one component at a time** - Don't request implementation of multiple components simultaneously
5. **Create utility functions first** - Reuse these functions in later requests

### Documentation Strategies
1. **Define documentation structure up front** - Reduces tokens needed for formatting discussion
2. **Use placeholders for repeated elements** - Define once, then reference
3. **Focus on unique content** - Generate boilerplate sections last
4. **Use structured formats** - Tables and lists are more token-efficient than prose
5. **Generate documentation in logical chunks** - User docs, admin docs, and developer docs separately

## WordPress-Specific Optimization

### Plugin Development
- Focus requests on specific WordPress hooks or functions
- Reference WordPress Plugin API instead of explaining concepts
- Use step-by-step implementation for complex plugins

### Theme Development
- Focus on template parts individually rather than whole templates
- Request styles in chunks organized by component
- Reference WordPress Theme Handbook concepts by name

### Custom Post Types
- Request registration code, admin columns, and meta boxes separately
- Focus output on unique aspects rather than boilerplate
- Leverage existing patterns where possible

## Monitoring and Reporting

The token-logger.js utility provides detailed reporting on token usage. Key metrics to monitor:

1. **Token utilization ratio** - Actual tokens used vs. budget
2. **Token distribution** - Input vs. Output token usage
3. **Task efficiency** - Token usage compared to similar past tasks
4. **Agent efficiency** - Comparison of agents for similar tasks
5. **Project averages** - Baseline for future planning

## Escalation Guidelines

When a task exceeds token budget:

1. **10% over budget** - Review optimization opportunities before continuing
2. **25% over budget** - Restructure task into smaller components
3. **50% over budget** - Consider alternative implementation approach
4. **100% over budget** - Escalate to team lead for review and restructuring

## Implementation Process

1. **Estimation** - Use token-counter.js to estimate token requirements
2. **Budgeting** - Assign token budget based on task type and complexity
3. **Monitoring** - Track token usage during implementation with token-logger.js
4. **Optimization** - Apply strategies when approaching budget limits
5. **Reporting** - Record token usage for future reference and planning
6. **Refinement** - Adjust guidelines based on actual usage patterns

## Related Resources
- [token-counter.js Documentation](.cursor/performance-tools/token-counter.js)
- [token-logger.js Documentation](.cursor/performance-tools/token-logger.js)
- [Token Monitoring Guide](.cursor/performance-tools/token-monitoring-guide.md) 