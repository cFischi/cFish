# Documentation Specialist Prompt Templates

These templates provide structured formats for common Documentation Specialist tasks in WordPress development. Using these templates helps ensure comprehensive technical documentation while reducing token usage.

## WordPress Plugin Documentation

```
# WordPress Plugin Documentation

## Plugin Name: [NAME]
## Version: [VERSION]
## Description: [BRIEF DESCRIPTION]

### Documentation Scope
- Developer Documentation: [YES/NO]
- User Documentation: [YES/NO]
- Admin Documentation: [YES/NO]
- API Documentation: [YES/NO]
- Installation Guide: [YES/NO]
- Upgrade Guide: [YES/NO]

### Target Audience
- Primary Audience: [AUDIENCE]
- Technical Level: [BEGINNER/INTERMEDIATE/ADVANCED]
- Preferred Format: [FORMAT]
- Documentation Goals: [GOALS]

### Plugin Functionality
- Core Features: [LIST FEATURES]
- Admin Settings: [SETTINGS OVERVIEW]
- Frontend Components: [COMPONENTS OVERVIEW]
- APIs/Hooks: [APIS/HOOKS OVERVIEW]
- Dependencies: [DEPENDENCIES]

### Documentation Request
Please create comprehensive WordPress plugin documentation with:

1. Clear plugin overview and purpose statement
2. Installation and configuration instructions
3. Feature usage instructions with examples and screenshots
4. Admin settings documentation with each option explained
5. Developer documentation including hooks, filters, and functions
6. Troubleshooting section for common issues
7. FAQ section addressing common questions
8. Version history and upgrade notes

Format the documentation following WordPress documentation standards with clear organization, appropriate headings, and consistent terminology.
```

## WordPress Theme Documentation

```
# WordPress Theme Documentation

## Theme Name: [NAME]
## Version: [VERSION]
## Description: [BRIEF DESCRIPTION]

### Documentation Scope
- User Documentation: [YES/NO]
- Developer Documentation: [YES/NO]
- Customization Guide: [YES/NO]
- Installation Guide: [YES/NO]
- Demo Content Setup: [YES/NO]
- Child Theme Guide: [YES/NO]

### Target Audience
- Primary Audience: [AUDIENCE]
- Technical Level: [BEGINNER/INTERMEDIATE/ADVANCED]
- Preferred Format: [FORMAT]
- Documentation Goals: [GOALS]

### Theme Functionality
- Theme Features: [LIST FEATURES]
- Customizer Options: [OPTIONS OVERVIEW]
- Templates Included: [TEMPLATES LIST]
- Custom Post Types: [CPT OVERVIEW]
- Widgets/Blocks: [WIDGETS/BLOCKS OVERVIEW]
- Plugin Dependencies: [DEPENDENCIES]

### Documentation Request
Please create comprehensive WordPress theme documentation with:

1. Theme overview and feature list
2. Installation and setup instructions
3. Customizer options explained with screenshots
4. Template usage and customization guidance
5. Widget and block usage instructions
6. Custom post type and taxonomy documentation
7. Developer notes for theme customization
8. Troubleshooting guide and FAQ section

Format the documentation following WordPress theme documentation standards with clear organization, visual aids, and consistent terminology.
```

## Function Documentation

```
# WordPress Function Documentation

## Function/Method Name: [NAME]
## File Location: [FILE PATH]
## Documentation Style: [PHPDOC/WPCS/OTHER]

### Function Context
```php
// Paste the function code here
```

### Function Purpose
[EXPLAIN THE GENERAL PURPOSE OF THIS FUNCTION]

### Integration Points
- Called From: [WHERE IS THIS FUNCTION CALLED]
- Dependencies: [WHAT DOES THIS FUNCTION DEPEND ON]
- Related Functions: [RELATED FUNCTIONS]
- Hook Context: [IF PART OF A HOOK, EXPLAIN]

### Documentation Request
Please create comprehensive documentation for this WordPress function with:

1. PHPDoc block with proper tags (@since, @param, @return, etc.)
2. Clear description of the function's purpose and behavior
3. Detailed parameter descriptions with types and constraints
4. Return value documentation with possible values
5. Usage examples demonstrating common use cases
6. Notes about potential edge cases or error conditions
7. Description of filters or actions within the function
8. Performance or security considerations

Ensure the documentation follows WordPress Documentation Standards and provides both technical accuracy and clarity.
```

## WordPress REST API Documentation

```
# WordPress REST API Documentation

## API Endpoint: [ENDPOINT PATH]
## API Version: [VERSION]
## HTTP Methods: [GET/POST/PUT/DELETE]

### Endpoint Purpose
[EXPLAIN THE PURPOSE OF THIS API ENDPOINT]

### Authentication Requirements
- Required Capabilities: [CAPABILITIES]
- Authentication Method: [METHOD]
- Nonce Requirements: [REQUIREMENTS]

### Request Parameters
- Parameter 1: [NAME] - [TYPE] - [REQUIRED/OPTIONAL] - [DESCRIPTION]
- Parameter 2: [NAME] - [TYPE] - [REQUIRED/OPTIONAL] - [DESCRIPTION]
- Parameter 3: [NAME] - [TYPE] - [REQUIRED/OPTIONAL] - [DESCRIPTION]

### Response Format
- Success Response: [STRUCTURE]
- Error Response: [STRUCTURE]

### Documentation Request
Please create comprehensive documentation for this WordPress REST API endpoint with:

1. Clear endpoint description and purpose
2. Authentication and permission requirements
3. Detailed parameter documentation with types, validation rules, and examples
4. Request format examples for each supported HTTP method
5. Response format documentation with field descriptions
6. Status and error code documentation
7. Usage examples with sample requests and responses
8. Security considerations and best practices

Format the documentation to be clear for both API consumers and developers, with code examples where appropriate.
```

## WordPress Hook Documentation

```
# WordPress Hook Documentation

## Hook Name: [NAME]
## Hook Type: [ACTION/FILTER]
## File Location: [FILE PATH]

### Hook Context
```php
// Paste the hook code here (where add_action/add_filter or do_action/apply_filters is called)
```

### Hook Purpose
[EXPLAIN THE PURPOSE OF THIS HOOK]

### Hook Parameters
- Parameter 1: [NAME] - [TYPE] - [DESCRIPTION]
- Parameter 2: [NAME] - [TYPE] - [DESCRIPTION]
- Parameter 3: [NAME] - [TYPE] - [DESCRIPTION]

### Hook Timing
- Execution Context: [WHEN IS THIS HOOK TRIGGERED]
- Execution Order: [PRIORITY CONSIDERATIONS]
- Frequency: [HOW OFTEN IS THIS HOOK TRIGGERED]

### Documentation Request
Please create comprehensive documentation for this WordPress hook with:

1. Clear hook description and purpose
2. Detailed parameter documentation with types and descriptions
3. Return value documentation for filters
4. Usage examples showing how to hook into this action/filter
5. Common use cases for this hook
6. Execution context and timing information
7. Related hooks that might be used together
8. Version information and deprecation notes if applicable

Ensure the documentation follows WordPress Hook Documentation Standards and provides both technical accuracy and practical examples.
```

## WordPress Admin Guide

```
# WordPress Admin Guide

## Feature Name: [NAME]
## Target Users: [USER ROLES]
## Feature Location: [LOCATION IN ADMIN]

### Feature Overview
[PROVIDE A BRIEF DESCRIPTION OF THE FEATURE]

### Key Functionality
- Function 1: [DESCRIPTION]
- Function 2: [DESCRIPTION]
- Function 3: [DESCRIPTION]

### User Permissions
- Required Capabilities: [CAPABILITIES]
- Role Restrictions: [RESTRICTIONS]
- Multi-site Considerations: [CONSIDERATIONS]

### Documentation Request
Please create a comprehensive WordPress admin guide for this feature with:

1. Clear explanation of the feature's purpose and benefits
2. Step-by-step instructions for accessing and using the feature
3. Detailed explanation of all available options and settings
4. Screenshots illustrating key interface elements and steps
5. Best practices for effective feature usage
6. Common troubleshooting tips and solutions
7. Relevant settings in other areas that affect this feature
8. Examples of typical use cases and workflows

Format the guide to be accessible to WordPress administrators with varying levels of technical expertise, using clear language and visual aids.
```

## Technical Blog Post

```
# WordPress Technical Blog Post

## Topic: [TOPIC]
## Target Audience: [AUDIENCE]
## Technical Level: [BEGINNER/INTERMEDIATE/ADVANCED]

### Content Goals
- Primary Goal: [MAIN GOAL]
- Key Takeaways: [LIST TAKEAWAYS]
- Call to Action: [CTA]

### Content Structure
- Introduction: [KEY POINTS]
- Background/Context: [KEY POINTS]
- Main Technical Content: [KEY POINTS]
- Examples/Code Samples: [KEY POINTS]
- Best Practices: [KEY POINTS]
- Conclusion: [KEY POINTS]

### Documentation Request
Please create a comprehensive WordPress technical blog post with:

1. Engaging introduction that explains the topic's relevance
2. Clear explanation of technical concepts with appropriate context
3. Step-by-step walkthrough of implementation or process
4. Code examples with explanations for technical implementation
5. Best practices and recommendations for real-world applications
6. Common pitfalls and how to avoid them
7. Comparison with alternative approaches where relevant
8. Summary of key points and next steps for readers

Format the post to be engaging and educational, with proper headings, code formatting, and visual structure. Maintain a balance between technical accuracy and readability.
```

## WordPress Shortcode Documentation

```
# WordPress Shortcode Documentation

## Shortcode Name: [NAME]
## Plugin/Theme: [SOURCE]
## Version: [VERSION]

### Shortcode Purpose
[EXPLAIN THE PURPOSE OF THIS SHORTCODE]

### Shortcode Parameters
- Parameter 1: [NAME] - [DEFAULT] - [REQUIRED/OPTIONAL] - [DESCRIPTION]
- Parameter 2: [NAME] - [DEFAULT] - [REQUIRED/OPTIONAL] - [DESCRIPTION]
- Parameter 3: [NAME] - [DEFAULT] - [REQUIRED/OPTIONAL] - [DESCRIPTION]

### Shortcode Content
- Accepts Content: [YES/NO]
- Content Purpose: [DESCRIPTION IF APPLICABLE]
- Content Formatting: [FORMATTING DETAILS]

### Documentation Request
Please create comprehensive documentation for this WordPress shortcode with:

1. Clear shortcode purpose and overview
2. Complete parameter documentation with defaults and examples
3. Explanation of shortcode content handling (if applicable)
4. Basic usage examples showing common configurations
5. Advanced usage examples for complex scenarios
6. Output explanation describing what the shortcode renders
7. Styling information for customizing the shortcode output
8. Troubleshooting tips for common issues

Format the documentation to be accessible to WordPress users with varying technical expertise, with clear examples and format.
```

## WordPress README.md Creation

```
# WordPress README.md Creation

## Project: [NAME]
## Project Type: [PLUGIN/THEME/OTHER]
## Version: [VERSION]

### Project Overview
[BRIEF PROJECT DESCRIPTION]

### Key Features
- Feature 1: [DESCRIPTION]
- Feature 2: [DESCRIPTION]
- Feature 3: [DESCRIPTION]

### Technical Requirements
- WordPress Version: [VERSION REQUIREMENT]
- PHP Version: [VERSION REQUIREMENT]
- Dependencies: [DEPENDENCIES]
- Browser Requirements: [BROWSER REQUIREMENTS]

### Documentation Request
Please create a comprehensive WordPress project README.md with:

1. Clear project title and description
2. Feature list highlighting key functionality
3. Detailed installation instructions
4. Configuration and setup guide
5. Usage instructions with examples
6. Frequently asked questions section
7. Troubleshooting information
8. Version history and changelog

Format the README following Markdown best practices with proper headings, lists, code blocks, and emphasis where appropriate. Optimize for both GitHub presentation and WordPress.org if applicable.
```

## User Tutorial Creation

```
# WordPress User Tutorial Creation

## Tutorial Topic: [TOPIC]
## Target Audience: [AUDIENCE]
## Difficulty Level: [BEGINNER/INTERMEDIATE/ADVANCED]

### Tutorial Goals
- Primary Goal: [MAIN GOAL]
- Learning Objectives: [LIST OBJECTIVES]
- Prerequisites: [PREREQUISITES]

### Tutorial Context
- WordPress Version: [VERSION]
- Plugin/Theme Context: [CONTEXT]
- Required Tools: [TOOLS]
- Environment Assumptions: [ASSUMPTIONS]

### Documentation Request
Please create a comprehensive WordPress user tutorial with:

1. Clear introduction explaining the tutorial purpose and benefits
2. Prerequisites and preparation steps
3. Step-by-step instructions with screenshots
4. Clear explanation of each step and its purpose
5. Tips and best practices throughout the tutorial
6. Common pitfalls and troubleshooting advice
7. Next steps and related learning resources
8. Summary of key points learned

Format the tutorial to be easy to follow for the target audience, with proper headings, numbered steps, visual aids, and clear explanations.
```

## API Reference Guide

```
# WordPress API Reference Guide

## API Name: [NAME]
## API Version: [VERSION]
## API Scope: [CORE/PLUGIN/THEME]

### API Purpose
[EXPLAIN THE PURPOSE OF THIS API]

### Key Concepts
- Concept 1: [DESCRIPTION]
- Concept 2: [DESCRIPTION]
- Concept 3: [DESCRIPTION]

### Authentication
- Authentication Methods: [METHODS]
- Required Credentials: [CREDENTIALS]
- Authorization Scope: [SCOPE]

### Documentation Request
Please create a comprehensive WordPress API reference guide with:

1. API overview and purpose explanation
2. Authentication and authorization requirements
3. Endpoint documentation with parameters and responses
4. Data types and structures used in the API
5. Error codes and handling information
6. Rate limiting and performance considerations
7. Security best practices for API usage
8. Integration examples showing common use cases

Format the documentation as a technical reference that is well-organized, with consistent structure for each endpoint or function, and clear examples.
```

## Best Practices for Using These Templates

1. **Be specific about documentation needs** - Clearly state the type of documentation needed
2. **Provide complete context** - Include code, feature descriptions, and project background
3. **Specify audience and format** - Indicate who the documentation is for and preferred format
4. **Include version information** - Specify relevant WordPress, PHP, and project versions
5. **Prioritize sections** - Indicate which aspects of the documentation are most important
6. **Reference existing documentation** - Link to related docs or style guides when applicable
7. **Specify screenshots/examples** - Indicate if specific screenshots or examples are needed
8. **Clarify technical depth** - Indicate how detailed technical explanations should be

## Next Steps After Template Use

1. **Review for accuracy** - Verify all technical information is correct
2. **Check for completeness** - Ensure all required sections are included
3. **Validate examples** - Test code examples to ensure they work as documented
4. **Format and style** - Apply consistent formatting and style
5. **Incorporate feedback** - Update documentation based on team feedback 