# Plugin Integration Specialist Prompt Templates

These templates provide structured formats for common Plugin Integration Specialist tasks in WordPress development. Using these templates helps ensure comprehensive plugin evaluation, implementation, and customization while reducing token usage.

## Plugin Evaluation

```
# WordPress Plugin Evaluation

## Plugin Name: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Project Requirements
- Core Functionality Needed: [FUNCTIONALITY DESCRIPTION]
- Integration Requirements: [INTEGRATION DETAILS]
- Performance Requirements: [PERFORMANCE DETAILS]
- Security Requirements: [SECURITY DETAILS]
- Budget Constraints: [BUDGET DETAILS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Existing Plugins: [PLUGIN LIST]
- Active Theme: [THEME]
- Hosting Limitations: [LIMITATIONS]

### Evaluation Request
Please provide a comprehensive evaluation of this WordPress plugin with:

1. Analysis of plugin features against project requirements
2. Security assessment including code quality and vulnerability history
3. Performance impact evaluation on site loading and server resources
4. Compatibility analysis with existing plugins and theme
5. Integration complexity assessment for the current project
6. Customization potential for project-specific requirements
7. Support and maintenance evaluation based on update history
8. Alternative plugin recommendations for comparison

Include specific ratings (1-5) for security, performance, compatibility, and customization potential, with detailed justification for each rating.
```

## Plugin Implementation Plan

```
# WordPress Plugin Implementation Plan

## Plugin Name: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Implementation Goals
- Primary Functionality: [FUNCTIONALITY DESCRIPTION]
- Integration Points: [INTEGRATION POINTS]
- Configuration Requirements: [CONFIGURATION DETAILS]
- User Training Needs: [TRAINING DETAILS]
- Timeline Requirements: [TIMELINE]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Existing Plugins: [PLUGIN LIST]
- Active Theme: [THEME]
- Database Details: [DB DETAILS]

### Implementation Request
Please create a comprehensive WordPress plugin implementation plan with:

1. Pre-installation preparation steps including backups and compatibility checks
2. Detailed installation procedure with configuration recommendations
3. Critical settings and options with recommended values
4. Integration approach with existing site functionality
5. Custom code requirements for full integration
6. Testing strategy for functionality verification
7. User training outline for admin and end-users
8. Post-implementation monitoring and maintenance plan

Provide specific code examples for any custom integration code, and include timeline estimates for each implementation phase.
```

## Plugin Customization

```
# WordPress Plugin Customization

## Plugin Name: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Customization Requirements
- Desired Modifications: [MODIFICATION DETAILS]
- Functional Changes: [FUNCTIONAL CHANGES]
- UI/UX Changes: [UI/UX CHANGES]
- Integration Requirements: [INTEGRATION DETAILS]
- Avoiding Core Modifications: [YES/NO]

### Technical Details
- Plugin Structure: [STRUCTURE DESCRIPTION]
- Available Hooks: [HOOK LIST]
- Template System: [TEMPLATE DETAILS]
- Current Customizations: [EXISTING CUSTOMIZATIONS]
- Update Considerations: [UPDATE DETAILS]

### Customization Request
Please create a comprehensive WordPress plugin customization plan with:

1. Analysis of available customization methods (hooks, templates, child plugins)
2. Recommended customization approach with rationale
3. Detailed code examples for required modifications
4. File structure for custom code implementation
5. Installation and activation instructions for customizations
6. Testing approach for customization verification
7. Update-safe implementation strategy
8. Documentation for future maintenance

Focus on minimizing core plugin modifications while achieving all requirements, and clearly document any unavoidable core changes.
```

## Plugin Conflict Resolution

```
# WordPress Plugin Conflict Resolution

## Conflicting Plugins
- Plugin 1: [NAME] - [VERSION]
- Plugin 2: [NAME] - [VERSION]

### Conflict Symptoms
- Issue Description: [ISSUE DETAILS]
- Error Messages: [ERROR MESSAGES]
- Affected Functionality: [AFFECTED FUNCTIONALITY]
- Reproduction Steps: [REPRODUCTION STEPS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Theme: [THEME]
- Other Plugins: [PLUGIN LIST]
- Debug Information: [DEBUG DETAILS]

### Resolution Request
Please provide a comprehensive WordPress plugin conflict resolution plan with:

1. Analysis of the root cause of the conflict
2. Identification of specific code or resource conflicts
3. Potential resolution approaches (priority, hooks, code modifications)
4. Recommended solution with detailed implementation steps
5. Code examples for any required modifications
6. Testing procedure to verify resolution
7. Alternative approaches if primary solution has limitations
8. Prevention strategies for future conflicts

Include specific code examples for any custom solutions, and clearly indicate any trade-offs between different resolution approaches.
```

## Plugin Extension Development

```
# WordPress Plugin Extension Development

## Base Plugin: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Extension Requirements
- Required Functionality: [FUNCTIONALITY DETAILS]
- Integration Points: [INTEGRATION DETAILS]
- User Interface Needs: [UI REQUIREMENTS]
- Performance Considerations: [PERFORMANCE DETAILS]
- Compatibility Requirements: [COMPATIBILITY DETAILS]

### Technical Details
- Plugin Extension System: [EXTENSION DETAILS]
- Available Hooks: [HOOK LIST]
- Data Structures: [DATA DETAILS]
- API Endpoints: [API DETAILS]
- Existing Extensions: [EXISTING EXTENSIONS]

### Development Request
Please create a comprehensive WordPress plugin extension development plan with:

1. Extension architecture design aligned with base plugin patterns
2. Implementation approach using available extension points
3. Code structure following WordPress standards
4. Required hooks and filters with implementation details
5. Database modifications or custom tables if needed
6. Admin interface integration with code examples
7. Frontend integration with code examples
8. Testing and deployment strategy

Focus on creating a maintainable extension that respects the base plugin's architecture and update cycle, with proper documentation for future maintenance.
```

## Plugin Migration Plan

```
# WordPress Plugin Migration Plan

## Current Plugin: [NAME] - [VERSION]
## Target Plugin: [NAME] - [VERSION]
## Project: [PROJECT NAME]

### Migration Requirements
- Functionality Preservation: [FUNCTIONALITY DETAILS]
- Data Migration Needs: [DATA DETAILS]
- Timeline Constraints: [TIMELINE]
- Downtime Limitations: [DOWNTIME REQUIREMENTS]
- Testing Requirements: [TESTING DETAILS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Database Details: [DB DETAILS]
- Server Environment: [ENVIRONMENT]
- Site Scale: [SCALE DETAILS]
- Custom Integrations: [INTEGRATION DETAILS]

### Migration Request
Please create a comprehensive WordPress plugin migration plan with:

1. Pre-migration analysis comparing feature sets and data structures
2. Data mapping between current and target plugin
3. Step-by-step migration procedure with rollback points
4. Custom scripts or tools needed for data transformation
5. Testing strategy for functionality verification
6. User training requirements for new plugin interface
7. Post-migration verification checklist
8. Timeline with detailed phases and estimated durations

Include specific code examples for data migration scripts, and clearly identify potential risks with mitigation strategies.
```

## Plugin Security Hardening

```
# WordPress Plugin Security Hardening

## Plugin Name: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Security Requirements
- Security Concerns: [SECURITY CONCERNS]
- Vulnerability History: [VULNERABILITY DETAILS]
- Sensitive Data Handling: [DATA DETAILS]
- Compliance Requirements: [COMPLIANCE DETAILS]
- User Role Considerations: [ROLE DETAILS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Security Plugins: [SECURITY PLUGINS]
- Access Patterns: [ACCESS DETAILS]
- Custom Modifications: [MODIFICATION DETAILS]

### Hardening Request
Please create a comprehensive WordPress plugin security hardening plan with:

1. Vulnerability assessment of current plugin implementation
2. Input validation and sanitization enhancements
3. Output escaping improvements for XSS prevention
4. CSRF protection implementation or enhancement
5. Capability and role verification strengthening
6. SQL injection prevention measures
7. File operation security improvements
8. Third-party integration security recommendations

Provide specific code examples for each security enhancement, with clear before/after comparisons and implementation instructions.
```

## Plugin Performance Optimization

```
# WordPress Plugin Performance Optimization

## Plugin Name: [NAME]
## Version: [VERSION]
## Project: [PROJECT NAME]

### Performance Issues
- Current Performance: [PERFORMANCE DETAILS]
- Bottlenecks Identified: [BOTTLENECK DETAILS]
- Impact Areas: [IMPACT DETAILS]
- Scale Considerations: [SCALE DETAILS]
- Target Metrics: [TARGET METRICS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Resources: [RESOURCE DETAILS]
- Database Size: [DB SIZE]
- Caching Systems: [CACHING DETAILS]
- Existing Optimizations: [EXISTING OPTIMIZATIONS]

### Optimization Request
Please create a comprehensive WordPress plugin performance optimization plan with:

1. Performance analysis identifying specific bottlenecks
2. Database query optimization recommendations
3. Asset loading improvements for scripts and styles
4. Caching implementation or enhancement strategy
5. AJAX usage optimization where applicable
6. Resource-intensive operation improvements
7. Code-level optimization recommendations
8. Configuration adjustments for performance

Include specific code examples for key optimizations, with clear before/after comparisons and expected performance improvements.
```

## Plugin Update Management

```
# WordPress Plugin Update Management

## Plugin Name: [NAME]
## Current Version: [VERSION]
## Target Version: [VERSION]
## Project: [PROJECT NAME]

### Update Considerations
- Critical Updates: [CRITICAL DETAILS]
- Feature Updates: [FEATURE DETAILS]
- Custom Modifications: [MODIFICATION DETAILS]
- Compatibility Concerns: [COMPATIBILITY DETAILS]
- Downtime Limitations: [DOWNTIME REQUIREMENTS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Database Details: [DB DETAILS]
- Integration Points: [INTEGRATION DETAILS]
- Update History: [UPDATE HISTORY]

### Update Management Request
Please create a comprehensive WordPress plugin update management plan with:

1. Pre-update assessment of changes between versions
2. Impact analysis on custom modifications and integrations
3. Compatibility verification with WordPress and other plugins
4. Testing environment setup recommendations
5. Step-by-step update procedure with rollback strategy
6. Custom modification re-implementation approach
7. Testing strategy for functionality verification
8. Documentation updates for new features and changes

Provide a detailed timeline for the update process, and clearly identify risks with specific mitigation strategies.
```

## Plugin API Integration

```
# WordPress Plugin API Integration

## Plugin Name: [NAME]
## Version: [VERSION]
## API Name: [API NAME]

### Integration Requirements
- API Purpose: [PURPOSE DETAILS]
- Data Exchange Requirements: [DATA DETAILS]
- Authentication Method: [AUTH DETAILS]
- Rate Limits: [RATE LIMITS]
- Error Handling Requirements: [ERROR HANDLING DETAILS]
- Failover Requirements: [FAILOVER DETAILS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Plugin Extension Capabilities: [EXTENSION DETAILS]
- Existing Integrations: [EXISTING INTEGRATIONS]
- Data Storage Requirements: [STORAGE DETAILS]

### Integration Request
Please create a comprehensive WordPress plugin API integration plan with:

1. Analysis of plugin's existing API capabilities
2. Integration architecture design with data flow
3. Authentication implementation approach
4. Data mapping between plugin and external API
5. Error handling and logging strategy
6. Caching implementation for performance optimization
7. Failover and retry mechanism design
8. Testing strategy for integration verification

Include specific code examples for key integration components, with clear documentation for API endpoint usage and data handling.
```

## Multi-Plugin Integration Strategy

```
# WordPress Multi-Plugin Integration Strategy

## Plugins to Integrate
- Plugin 1: [NAME] - [VERSION] - [PURPOSE]
- Plugin 2: [NAME] - [VERSION] - [PURPOSE]
- Plugin 3: [NAME] - [VERSION] - [PURPOSE]

### Integration Goals
- Functional Requirements: [FUNCTIONAL DETAILS]
- Data Sharing Needs: [DATA SHARING DETAILS]
- User Experience Goals: [UX DETAILS]
- Performance Requirements: [PERFORMANCE DETAILS]
- Maintenance Considerations: [MAINTENANCE DETAILS]

### Technical Environment
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Theme Integration: [THEME DETAILS]
- Existing Integrations: [EXISTING INTEGRATIONS]

### Integration Strategy Request
Please create a comprehensive WordPress multi-plugin integration strategy with:

1. Analysis of plugin interaction points and potential conflicts
2. Data flow architecture between integrated plugins
3. Integration approach recommendations (hooks, custom code, bridge plugin)
4. Implementation plan with prioritized integration points
5. Custom code requirements with specific examples
6. Performance considerations for integrated solution
7. Testing strategy across all integration points
8. Maintenance approach for managing plugin updates

Focus on creating a maintainable integration that minimizes custom code while achieving all functional requirements.
```

## Best Practices for Using These Templates

1. **Be specific about plugin requirements** - Clearly state functionality needs and constraints
2. **Provide complete technical context** - Include WordPress version, PHP version, and hosting details
3. **Specify existing plugins and theme** - List current site components for compatibility assessment
4. **Include performance and security requirements** - State specific needs in these critical areas
5. **Prioritize integration points** - Indicate which aspects are most critical for integration
6. **Reference existing customizations** - When applicable, describe current modifications
7. **Specify timeline and budget constraints** - Include practical limitations that affect approach
8. **Indicate maintenance requirements** - Describe long-term support and update expectations

## Next Steps After Template Use

1. **Implementation planning** - Create a detailed plan with timeline and resources
2. **Environment preparation** - Set up development and testing environments
3. **Phased implementation** - Follow the recommended approach in logical phases
4. **Testing and verification** - Test all functionality against requirements
5. **Documentation** - Document all customizations and configuration details 