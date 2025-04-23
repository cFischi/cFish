# Project Architect Quick Reference Cheat Sheet

## Core Responsibilities
- Define project architecture and structure
- Establish technical requirements and constraints
- Make high-level design decisions
- Create project roadmaps and milestones
- Evaluate technical feasibility of features

## Common Tasks
- **Project Initialization**
  - Theme/plugin architecture planning
  - Technology stack selection
  - Dependency management planning
  - Database schema design

- **Technical Decision Making**
  - Framework/library selection
  - Performance strategy planning
  - Scalability considerations
  - Security architecture planning

- **Project Management**
  - Task breakdown and estimation
  - Technical risk assessment
  - Resource allocation planning
  - Implementation sequence planning

## Key Commands & Actions
- `/architect plan [feature]` - Generate architecture plan for a feature
- `/architect review [component]` - Analyze component design
- `/architect tech-stack` - Evaluate technology stack options
- `/architect dependencies` - Analyze dependency relationships
- `/architect schema` - Design or review database schema

## Typical Prompts
1. "Design a WordPress plugin architecture for [feature]"
2. "Evaluate the technical feasibility of implementing [feature]"
3. "Create a database schema for [feature] with performance considerations"
4. "Plan the implementation sequence for [feature] with dependencies"
5. "Identify potential technical risks for implementing [feature]"

## Handoff Templates

### To Code Implementation Specialist
```
## Project Architect → Code Implementation Specialist

### Feature Specification: [Feature Name]
- Technical requirements: [List key requirements]
- Architecture design: [Brief architecture description]
- Implementation constraints: [List constraints]
- API endpoints: [List required endpoints]
- Database interactions: [Describe DB interactions]
- Dependencies: [List dependencies]

### Key Implementation Guidelines
- [Guideline 1]
- [Guideline 2]
- [Guideline 3]

### Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

### To Security & QA Analyst
```
## Project Architect → Security & QA Analyst

### Feature Architecture Review: [Feature Name]
- Architecture overview: [Brief description]
- Security considerations: [List security considerations]
- Performance requirements: [List performance requirements]
- Critical paths: [Describe critical paths]
- Data handling: [Describe data handling]

### Security Review Focus Areas
- [Area 1]
- [Area 2]
- [Area 3]

### Quality Assurance Priorities
- [Priority 1]
- [Priority 2]
- [Priority 3]
```

## Best Practices
1. Start with a clear understanding of business requirements
2. Always validate technical decisions against project constraints
3. Document architectural decisions with rationales
4. Consider scalability from the beginning
5. Plan for security at the architecture level
6. Create clear, testable acceptance criteria
7. Establish coding standards and conventions early

## Token Optimization Tips
1. Provide clear, structured requirements
2. Use diagrams and visual representations where possible
3. Define architecture in modular components
4. Be specific about technical constraints
5. Provide examples of similar implementations when available

## Related Documentation
- [Technical Architecture Guidelines](link)
- [Coding Standards Documentation](link)
- [Project Planning Templates](link)
- [WordPress Best Practices](link) 