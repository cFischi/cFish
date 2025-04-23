# Security & QA Analyst Prompt Templates

These templates provide structured formats for common Security & QA Analyst tasks in WordPress development. Using these templates helps ensure comprehensive security and quality assessments while reducing token usage.

## Security Code Review

```
# WordPress Security Code Review

## Code Context: [COMPONENT/FILE NAME]
## Project: [PROJECT NAME]

### Code Scope
```php
// Paste the code to review here, or describe the file/component
```

### Security Review Focus
- Input Validation: [YES/NO]
- Output Escaping: [YES/NO]
- Database Queries: [YES/NO]
- Authentication: [YES/NO]
- Authorization: [YES/NO]
- CSRF Protection: [YES/NO]
- File Operations: [YES/NO]
- API Endpoints: [YES/NO]

### Project Context
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- User Roles Involved: [ROLES]
- Data Sensitivity: [SENSITIVITY LEVEL]

### Review Request
Please perform a comprehensive security review of this WordPress code with:

1. Identification of all security vulnerabilities
2. Assessment of input validation and sanitization
3. Evaluation of output escaping practices
4. Analysis of SQL query security
5. Review of authentication and authorization checks
6. Assessment of CSRF protection implementation
7. Evaluation of file operation security
8. Clear explanation of each issue with severity rating

Provide recommendations for fixing each identified security issue following WordPress security best practices.
```

## WordPress Performance Review

```
# WordPress Performance Review

## Component: [COMPONENT NAME]
## Project: [PROJECT NAME]

### Code Scope
```php
// Paste the code to review here, or describe the file/component
```

### Performance Concerns
- Database Queries: [YES/NO]
- Asset Loading: [YES/NO]
- API Calls: [YES/NO]
- Loop Efficiency: [YES/NO]
- Caching Implementation: [YES/NO]
- Memory Usage: [YES/NO]
- DOM Operations: [YES/NO]
- Plugin Interactions: [YES/NO]

### Project Context
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Traffic Volume: [VOLUME ESTIMATE]

### Review Request
Please perform a comprehensive performance review of this WordPress code with:

1. Identification of performance bottlenecks
2. Analysis of database query efficiency
3. Evaluation of caching opportunities
4. Assessment of unnecessary processing or loops
5. Review of asset loading strategies
6. Analysis of memory usage patterns
7. Identification of redundant operations
8. Clear explanation of each issue with impact rating

Provide optimization recommendations for each identified performance issue following WordPress performance best practices.
```

## WordPress Coding Standards Review

```
# WordPress Coding Standards Review

## Component: [COMPONENT NAME]
## Project: [PROJECT NAME]

### Code Scope
```php
// Paste the code to review here, or describe the file/component
```

### Standards Focus
- PHP Coding Standards: [YES/NO]
- WordPress Coding Standards: [YES/NO]
- Inline Documentation: [YES/NO]
- Function/Class Structure: [YES/NO]
- Naming Conventions: [YES/NO]
- File Organization: [YES/NO]
- Hook Usage: [YES/NO]
- Internationalization: [YES/NO]

### Project Context
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Project Coding Guidelines: [GUIDELINES REFERENCE]

### Review Request
Please perform a comprehensive coding standards review of this WordPress code with:

1. Verification of compliance with WordPress Coding Standards
2. Assessment of PHP best practices implementation
3. Evaluation of inline documentation quality
4. Analysis of function and class organization
5. Review of naming conventions usage
6. Assessment of file structure and organization
7. Evaluation of hook usage patterns
8. Verification of proper internationalization

Provide recommendations for improving code quality and standards compliance following WordPress best practices.
```

## Accessibility Testing Plan

```
# WordPress Accessibility Testing Plan

## Component: [COMPONENT NAME]
## Project: [PROJECT NAME]

### Accessibility Requirements
- Target Compliance Level: [WCAG LEVEL]
- Screen Reader Support: [REQUIRED SUPPORT]
- Keyboard Navigation: [NAVIGATION REQUIREMENTS]
- Color Contrast: [CONTRAST REQUIREMENTS]
- Form Accessibility: [FORM REQUIREMENTS]
- Dynamic Content: [DYNAMIC CONTENT REQUIREMENTS]

### Component Description
[BRIEF DESCRIPTION OF COMPONENT FUNCTIONALITY]

### Testing Request
Please create a comprehensive accessibility testing plan for this WordPress component with:

1. Structured test cases for keyboard navigation
2. Screen reader testing procedures for key elements
3. Color contrast verification methodology
4. Form accessibility validation steps
5. Interactive element testing approach
6. ARIA implementation verification steps
7. Heading structure and document outline validation
8. Media accessibility verification

Include clear pass/fail criteria for each test case and reference WCAG guidelines where applicable.
```

## Test Case Development

```
# WordPress Test Case Development

## Feature: [FEATURE NAME]
## Project: [PROJECT NAME]

### Feature Description
[DETAILED DESCRIPTION OF FEATURE FUNCTIONALITY]

### Test Categories
- Functional Testing: [YES/NO]
- Edge Case Testing: [YES/NO]
- Performance Testing: [YES/NO]
- Security Testing: [YES/NO]
- Compatibility Testing: [YES/NO]
- User Experience Testing: [YES/NO]
- Integration Testing: [YES/NO]
- Regression Testing: [YES/NO]

### Project Context
- WordPress Version: [VERSION]
- Browser Requirements: [BROWSERS]
- Device Requirements: [DEVICES]
- User Roles: [ROLES]

### Test Case Request
Please develop comprehensive test cases for this WordPress feature with:

1. Functional test cases covering all core functionality
2. Edge case scenarios to test boundary conditions
3. Performance testing scenarios for key operations
4. Security test cases for potential vulnerabilities
5. Browser and device compatibility test scenarios
6. User experience test cases for key user flows
7. Integration test cases with dependent components
8. Regression test cases for previously fixed issues

Provide each test case with clear steps, expected results, and pass/fail criteria.
```

## Security Vulnerability Assessment

```
# WordPress Security Vulnerability Assessment

## Plugin/Theme: [NAME]
## Version: [VERSION]

### Component Description
[BRIEF DESCRIPTION OF PLUGIN/THEME FUNCTIONALITY]

### Assessment Scope
- Code Security: [YES/NO]
- Authentication/Authorization: [YES/NO]
- Data Protection: [YES/NO]
- Form Security: [YES/NO]
- API Security: [YES/NO]
- Third-party Dependencies: [YES/NO]
- Update Mechanism: [YES/NO]
- File Permissions: [YES/NO]

### Project Context
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Database Type: [DB TYPE]
- Server Environment: [ENVIRONMENT]

### Assessment Request
Please perform a comprehensive security vulnerability assessment for this WordPress plugin/theme with:

1. Analysis of common vulnerability types (XSS, CSRF, SQLi, etc.)
2. Review of authentication and authorization mechanisms
3. Assessment of data storage and protection practices
4. Evaluation of form processing security
5. Analysis of API endpoint security
6. Review of third-party dependency security
7. Assessment of update and installation mechanisms
8. Evaluation of file permission requirements

For each vulnerability, provide severity rating, exploit scenario, and remediation recommendations.
```

## Code Review Response

```
# WordPress Code Review Response

## Code Review Request: [REVIEW ID/REFERENCE]
## Feature: [FEATURE NAME]

### Code Review Findings
[SUMMARY OF CODE REVIEW FINDINGS]

### Security Issues
- High Severity Issues: [LIST/COUNT]
- Medium Severity Issues: [LIST/COUNT]
- Low Severity Issues: [LIST/COUNT]

### Quality Issues
- Critical Quality Issues: [LIST/COUNT]
- Major Quality Issues: [LIST/COUNT]
- Minor Quality Issues: [LIST/COUNT]

### Review Response
Please provide a comprehensive code review response addressing:

1. Prioritized list of all identified issues
2. Explanation of each security vulnerability with specific code references
3. Description of quality and standards issues with code examples
4. Specific recommendations for fixing each issue
5. Code examples demonstrating proper implementation
6. Explanation of best practices relevant to identified issues
7. Additional improvement suggestions beyond required fixes
8. Final assessment of code readiness for production

Structure your response to be constructive and educational, focusing on solutions rather than just problems.
```

## Bug Report Analysis

```
# WordPress Bug Report Analysis

## Bug ID: [BUG ID/REFERENCE]
## Component: [COMPONENT NAME]

### Bug Description
[DETAILED DESCRIPTION OF THE BUG]

### Reproduction Steps
1. [STEP 1]
2. [STEP 2]
3. [STEP 3]
...

### Environment Information
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Browser/Device: [BROWSER/DEVICE]
- Plugins Installed: [PLUGINS]
- Theme: [THEME]

### Analysis Request
Please provide a comprehensive analysis of this WordPress bug with:

1. Verification of reproduction steps and confirmation of the issue
2. Root cause analysis identifying the source of the problem
3. Assessment of the impact and severity of the bug
4. Identification of affected components or functionality
5. Explanation of the technical factors contributing to the issue
6. Recommended approach for fixing the bug
7. Potential implementation solution with code examples
8. Suggested testing approach to verify the fix

Focus on providing actionable insights that will help developers efficiently resolve the issue.
```

## Compatibility Testing Plan

```
# WordPress Compatibility Testing Plan

## Component: [COMPONENT NAME]
## Project: [PROJECT NAME]

### Compatibility Requirements
- WordPress Versions: [VERSIONS]
- PHP Versions: [VERSIONS]
- Database Types: [DB TYPES]
- Server Environments: [ENVIRONMENTS]
- Browsers: [BROWSERS]
- Devices: [DEVICES]
- Key Plugins: [PLUGINS]
- Popular Themes: [THEMES]

### Component Description
[BRIEF DESCRIPTION OF COMPONENT FUNCTIONALITY]

### Testing Request
Please create a comprehensive compatibility testing plan for this WordPress component with:

1. Test matrix covering all required compatibility combinations
2. Prioritized test scenarios based on user impact
3. Critical functionality test cases for each environment
4. Visual rendering test cases for browser/device combinations
5. Performance test cases across different environments
6. Integration test cases with key plugins and themes
7. Upgrade/downgrade test scenarios
8. Methodology for identifying and reporting compatibility issues

Include clear pass/fail criteria for each test case and prioritization of test scenarios.
```

## Security Audit Report

```
# WordPress Security Audit Report

## Project: [PROJECT NAME]
## Audit Scope: [SCOPE DESCRIPTION]

### Audit Context
- WordPress Version: [VERSION]
- PHP Version: [VERSION]
- Server Environment: [ENVIRONMENT]
- Installed Plugins: [PLUGINS]
- Active Theme: [THEME]
- Custom Code: [CUSTOM CODE DESCRIPTION]

### Audit Areas
- Authentication & Authorization: [YES/NO]
- Data Validation & Sanitization: [YES/NO]
- Database Security: [YES/NO]
- File System Security: [YES/NO]
- API Security: [YES/NO]
- Plugin & Theme Security: [YES/NO]
- Server Configuration: [YES/NO]
- Update Management: [YES/NO]

### Audit Report Request
Please provide a comprehensive WordPress security audit report including:

1. Executive summary of findings with overall security assessment
2. Detailed findings for each audit area with severity ratings
3. Specific vulnerabilities identified with affected components
4. Impact assessment for each vulnerability
5. Remediation recommendations with implementation guidance
6. Prioritized action plan for addressing security issues
7. Best practice recommendations beyond vulnerability fixes
8. Ongoing security maintenance recommendations

Structure the report for both technical and non-technical audiences with clear priorities.
```

## Best Practices for Using These Templates

1. **Be specific about security concerns** - Mention particular vulnerabilities you're concerned about
2. **Provide complete code context** - Include enough code for proper assessment
3. **Specify project constraints** - WordPress version, PHP version, and environment details
4. **Include relevant background** - Previous issues or specific areas of concern
5. **Prioritize review areas** - Indicate which aspects are most critical to review
6. **Reference existing standards** - When applicable, reference project-specific coding standards
7. **Specify audience for reports** - Indicate if reports should target developers or non-technical stakeholders
8. **Include testing context** - Mention testing resources available and testing environment

## Next Steps After Template Use

1. **Issue prioritization** - Prioritize identified issues based on severity and impact
2. **Action plan creation** - Create a plan to address identified issues
3. **Developer communication** - Share findings with development team in a constructive manner
4. **Fix verification** - Test and verify fixes for identified issues
5. **Knowledge sharing** - Document lessons learned for future reference 