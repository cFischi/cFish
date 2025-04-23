# Project Architect Prompt Templates

These templates provide structured formats for common Project Architect tasks in WordPress development. Using these templates helps ensure comprehensive requirements and reduces token usage.

## Plugin Architecture Planning

```
# WordPress Plugin Architecture Planning

## Plugin Name: [NAME]
## Version: [VERSION]
## Description: [BRIEF DESCRIPTION]

### Core Requirements
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

### User Experience Goals
- [GOAL 1]
- [GOAL 2]
- [GOAL 3]

### Technical Scope
- WordPress Version Compatibility: [VERSION RANGE]
- PHP Version Requirements: [VERSION RANGE]
- Browser Compatibility: [BROWSERS]
- Database Requirements: [REQUIREMENTS]
- Third-party API Dependencies: [DEPENDENCIES]

### Architecture Components
Please design a comprehensive WordPress plugin architecture with the following:

1. Core plugin class structure
2. Key functionality modules
3. Admin vs. Frontend components
4. Database schema (tables, options, post meta)
5. WordPress hook integration (actions/filters)
6. Security considerations
7. Performance optimization approach
8. Extension/customization support

Focus on maintainability, WordPress best practices, and scalability.
```

## Theme Architecture Planning

```
# WordPress Theme Architecture Planning

## Theme Name: [NAME]
## Version: [VERSION]
## Description: [BRIEF DESCRIPTION]

### Core Requirements
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

### Visual Design Goals
- [GOAL 1]
- [GOAL 2]
- [GOAL 3]

### Technical Scope
- WordPress Version Compatibility: [VERSION RANGE]
- PHP Version Requirements: [VERSION RANGE]
- Browser Compatibility: [BROWSERS]
- Required Plugins: [PLUGINS]
- Block Editor Support: [REQUIREMENTS]

### Architecture Components
Please design a comprehensive WordPress theme architecture with the following:

1. Template hierarchy implementation
2. Core theme components (header, footer, etc.)
3. Template parts organization
4. CSS/JS organization
5. Theme customization approach
6. Block editor integration strategy
7. Performance optimization approach
8. Mobile responsiveness strategy

Focus on WordPress standards, visual consistency, and user experience.
```

## Database Schema Design

```
# WordPress Database Schema Design

## Feature Name: [NAME]
## Description: [BRIEF DESCRIPTION]

### Functional Requirements
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

### Data Requirements
- [DATA TYPE 1]: [DESCRIPTION]
- [DATA TYPE 2]: [DESCRIPTION]
- [DATA TYPE 3]: [DESCRIPTION]

### Storage Approaches to Consider
- WordPress Custom Post Types
- Custom Database Tables
- WordPress Options API
- WordPress Metadata APIs

### Database Schema Design Request
Please design an optimal database schema for this feature considering:

1. Data structure (tables, fields, relationships)
2. Primary/foreign keys and indexes
3. Data types and constraints
4. Query optimization considerations
5. Migration and upgrade strategy
6. WordPress integration points
7. Sample queries for common operations
8. Scaling considerations for large datasets

Provide justification for custom tables vs. WordPress native storage options.
```

## API Integration Architecture

```
# WordPress API Integration Architecture

## API Name: [NAME]
## API Documentation: [URL/REFERENCE]
## Integration Purpose: [BRIEF DESCRIPTION]

### Integration Requirements
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

### Data Exchange Requirements
- [INPUT DATA 1]: [DESCRIPTION]
- [OUTPUT DATA 1]: [DESCRIPTION]
- [WEBHOOK 1]: [DESCRIPTION]

### Technical Considerations
- Authentication Method: [METHOD]
- Rate Limits: [LIMITS]
- Error Handling Requirements: [REQUIREMENTS]
- Data Caching Needs: [CACHING REQUIREMENTS]

### API Integration Design Request
Please design a WordPress integration architecture for this API with:

1. Core integration class structure
2. Authentication implementation approach
3. Request/response handling framework
4. Error management strategy
5. Caching implementation
6. Logging and debugging approach
7. WordPress admin interface integration
8. Performance optimization considerations

Focus on maintainability, error resilience, and WordPress best practices.
```

## Technical Feasibility Assessment

```
# WordPress Technical Feasibility Assessment

## Feature Request: [FEATURE]
## Business Priority: [PRIORITY]
## Target Timeline: [TIMELINE]

### Feature Description
[DETAILED DESCRIPTION]

### Success Criteria
- [CRITERION 1]
- [CRITERION 2]
- [CRITERION 3]

### Current Environment
- WordPress Version: [VERSION]
- Theme: [THEME]
- Active Plugins: [PLUGINS]
- Server Environment: [ENVIRONMENT]
- PHP Version: [VERSION]

### Feasibility Assessment Request
Please provide a comprehensive technical feasibility assessment including:

1. Technical approach options with pros/cons
2. Implementation complexity assessment (1-10 scale)
3. Required resources and skills
4. Estimated development effort
5. Technical risks and mitigations
6. Dependencies and prerequisites
7. Maintenance considerations
8. Alternative approaches if primary approach is infeasible

Include specific WordPress considerations and potential limitations.
```

## Project Breakdown and Estimation

```
# WordPress Project Breakdown and Estimation

## Project Name: [NAME]
## Description: [DESCRIPTION]
## Target Completion: [TIMELINE]

### Project Goals
- [GOAL 1]
- [GOAL 2]
- [GOAL 3]

### Major Features
- [FEATURE 1]
- [FEATURE 2]
- [FEATURE 3]

### Current Environment
- WordPress Version: [VERSION]
- Theme: [THEME]
- Active Plugins: [PLUGINS]
- Server Environment: [ENVIRONMENT]

### Project Breakdown Request
Please provide a detailed project breakdown including:

1. Major development components/modules
2. Task breakdown with granular estimates
3. Critical path identification
4. Required resources and skills
5. Development phases and milestones
6. Dependencies between components
7. Testing requirements and approach
8. Deployment approach and considerations

Focus on realistic estimations considering WordPress-specific development factors.
```

## Performance Optimization Strategy

```
# WordPress Performance Optimization Strategy

## Website/Application: [NAME]
## Current Issues: [ISSUES]
## Performance Targets: [TARGETS]

### Current Environment
- WordPress Version: [VERSION]
- Theme: [THEME]
- Active Plugins: [PLUGINS]
- Server Environment: [ENVIRONMENT]
- Traffic Patterns: [PATTERNS]

### Critical Functionality
- [FUNCTION 1]
- [FUNCTION 2]
- [FUNCTION 3]

### Performance Strategy Request
Please design a comprehensive WordPress performance optimization strategy including:

1. Database query optimization approach
2. Frontend optimization recommendations
3. Caching strategy (page, object, database)
4. Asset delivery optimization
5. PHP execution optimization
6. Server configuration recommendations
7. Content delivery optimization
8. Measurement and monitoring approach

Prioritize recommendations based on impact and implementation difficulty.
```

## Security Architecture Review

```
# WordPress Security Architecture Review

## Application: [NAME]
## Current Security Measures: [MEASURES]
## Security Incidents: [INCIDENTS]

### Critical Functionality
- [FUNCTION 1]
- [FUNCTION 2]
- [FUNCTION 3]

### Sensitive Data Handled
- [DATA TYPE 1]
- [DATA TYPE 2]
- [DATA TYPE 3]

### Security Review Request
Please provide a comprehensive WordPress security architecture review including:

1. Authentication and authorization assessment
2. Input sanitization and validation review
3. Output escaping assessment
4. Database interaction security review
5. File operation security evaluation
6. Third-party integration security assessment
7. WordPress core and plugin security review
8. Server and infrastructure recommendations

Prioritize findings by risk level and provide specific remediation recommendations.
```

## Implementation Plan Development

```
# WordPress Implementation Plan Development

## Project: [NAME]
## Timeline: [TIMELINE]
## Team Composition: [TEAM]

### Major Features
- [FEATURE 1]
- [FEATURE 2]
- [FEATURE 3]

### Technical Environment
- WordPress Version: [VERSION]
- Development Workflow: [WORKFLOW]
- Deployment Process: [PROCESS]
- Testing Approach: [APPROACH]

### Implementation Plan Request
Please develop a detailed WordPress implementation plan including:

1. Development phases with timelines
2. Task dependencies and critical path
3. Resource allocation recommendations
4. Development environment setup
5. Code management and version control approach
6. Testing strategy (unit, integration, user)
7. Deployment and rollback procedures
8. Post-launch monitoring and support plan

Focus on WordPress best practices and efficient implementation approaches.
```

## Plugin Integration Assessment

```
# WordPress Plugin Integration Assessment

## Plugin: [NAME]
## Version: [VERSION]
## Plugin Documentation: [URL]

### Integration Purpose
[PURPOSE]

### Current Environment
- WordPress Version: [VERSION]
- Theme: [THEME]
- Active Plugins: [PLUGINS]
- Server Environment: [ENVIRONMENT]

### Integration Requirements
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

### Integration Assessment Request
Please provide a comprehensive assessment of integrating this plugin including:

1. Plugin quality and reliability evaluation
2. Compatibility analysis with current environment
3. Performance impact assessment
4. Security evaluation
5. Required customizations
6. Integration complexity (1-10 scale)
7. Alternative approaches or plugins
8. Long-term maintenance considerations

Recommend for or against integration with detailed justification.
```

## Best Practices for Using These Templates

1. **Fill in all placeholders** - Replace [BRACKETED] text with specific information
2. **Add context when relevant** - Include links to designs, previous discussions, or requirements
3. **Be specific about constraints** - Technical limitations, timelines, and priorities help focus design
4. **Prioritize requirements** - Indicate which requirements are must-have vs. nice-to-have
5. **Include business context** - Help the AI understand why certain decisions matter
6. **Reference existing patterns** - When applicable, reference existing code or architecture
7. **Specify output format preferences** - Request diagrams, code snippets, or prose as needed
8. **Indicate level of detail needed** - Specify whether you need high-level or detailed output

## Next Steps After Template Use

1. **Review the output** against project requirements and constraints
2. **Share with stakeholders** for validation of technical approach
3. **Convert to specifications** for implementation team
4. **Create task breakdown** based on the architectural design
5. **Document architectural decisions** in project documentation 