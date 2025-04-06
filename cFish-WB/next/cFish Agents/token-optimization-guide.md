# Token Optimization Guide for Large WordPress Projects

## Overview
This document provides strategies and best practices for optimizing token usage when working with Cursor AI on large WordPress projects. Effective token management improves AI performance, reduces costs, and enables more efficient development workflows.

## Understanding Token Limits

### Token Basics
- **What is a token?** Tokens are units of text used by AI models (roughly 4 characters per token in English)
- **Cursor token limits:** 
  - Chat mode: ~16,000-20,000 tokens per conversation
  - Composer mode: ~20,000-30,000 tokens per session (varies by model)
- **Token sources:**
  - Prompt text
  - Referenced file content
  - System instructions and rules
  - Conversation history
  - AI responses

### Token Usage Monitoring

1. **Visual indicators:**
   - Cursor displays token usage for each message
   - Warning indicators appear when approaching limits

2. **Track usage patterns:**
   - Different project types have different token profiles
   - WordPress themes typically use more tokens than plugins
   - Database-heavy features use fewer tokens than UI components

## Optimization Strategies

### 1. Focused Context Selection

#### Use Targeted File References
```
// INEFFICIENT (many tokens)
@functions.php @template-parts/content.php @template-parts/header.php @includes/customizer.php

// EFFICIENT (fewer tokens)
@template-parts/content.php 
```

#### Strategic Content Selection
```
// INEFFICIENT (entire file)
@style.css

// EFFICIENT (relevant section only)
Here's the navigation menu CSS:
```css
/* Navigation Menu */
.main-navigation {
  /* Only include relevant CSS */
}
```
```

### 2. Context Files and Documentation

#### Create Specialized Context Files
- **Pattern Documentation:**
  - Document design patterns in dedicated files
  - Reference pattern docs instead of implementation examples
  
- **API Documentation:**
  - Create summarized API references
  - Include only signatures and key notes, not examples

#### Examples
**Pattern context file (patterns-context.md):**
```markdown
# WordPress Design Patterns

## Factory Pattern
- Used for creating CPT registration objects
- Key methods: register(), unregister(), get_args()
- See: cpt-factory.php for implementation

## Observer Pattern
- Used for notification systems
- Implemented via WordPress hooks
- Key functions: add_action(), add_filter()
```

**Reference instead of code:**
```
// INEFFICIENT
I need to implement a factory pattern. Here's my current code:
@includes/factories/product-factory.php
@includes/factories/post-factory.php 
@includes/factories/user-factory.php

// EFFICIENT
I need to implement a factory pattern for custom taxonomies.
@patterns-context.md
```

### 3. Progressive Disclosure

#### Incremental Development Approach
1. Break tasks into smaller components
2. Complete one component before moving to the next
3. Start new conversations for different components
4. Use Composer checkpoints to manage progression

#### Example Workflow
```
// PHASE 1: Architecture (separate conversation)
Let's design the class structure for a custom taxonomy registration system.

// PHASE 2: Core Implementation (new conversation)
I've designed the architecture; now let's implement the core classes.

// PHASE 3: Testing (new conversation)
Now let's create tests for the taxonomy registration system.
```

### 4. Compression Techniques

#### Summarize Instead of Including
```
// INEFFICIENT
@long-context-file.md

// EFFICIENT  
The context file contains these key points:
1. Authentication uses JWT tokens
2. Custom post types need slug, name, and archive settings
3. Admin pages follow the tabs-based interface pattern
```

#### Use Terminology References
```
// INEFFICIENT
The "Featured Products" section needs custom fields for price, inventory, shipping dimensions (length, width, height), weight, manufacturer details, etc.

// EFFICIENT
The "Featured Products" section needs WooCommerce standard product fields (ref: wc-fields.md)
```

### 5. Codebase Navigation

#### Efficient Directory Exploration
```
// INEFFICIENT
List all files in the entire project

// EFFICIENT
List files in src/components/widgets
```

#### Strategic Search
```
// INEFFICIENT
Search for all instances of "product"

// EFFICIENT
Search for product registration functions in includes/post-types
```

### 6. Template and Snippet Usage

#### Create Code Snippet Libraries
Maintain snippet libraries for common patterns:

**wp-snippets.md:**
```markdown
## WordPress Registration Boilerplate
```php
register_post_type( 'product', [
    'labels' => [
        'name' => __( 'Products', 'textdomain' ),
        'singular_name' => __( 'Product', 'textdomain' ),
    ],
    'public' => true,
    'has_archive' => true,
    'supports' => ['title', 'editor', 'thumbnail'],
    'rewrite' => ['slug' => 'products'],
] );
```
```

#### Reference Snippets Instead of Regenerating
```
// INEFFICIENT
Create a custom post type registration function for "events"

// EFFICIENT
Create a custom post type for "events" based on the Registration Boilerplate in wp-snippets.md
```

### 7. Session Management Techniques

#### New Sessions for New Topics
- Start fresh conversations for unrelated tasks
- Create new Composer sessions for different components
- Export and archive completed sessions instead of continuing them

#### State Management
- Document current state in dedicated files
- Reference state documents instead of conversation history
- Use checkpoints in Composer to mark significant milestones

### 8. Model-Specific Optimizations

#### Model Selection
- **claude-3.5-sonnet:** Best general-purpose model for WordPress development
- **o1-mini:** More efficient for reasoning tasks (architecture, security review)
- **o1-preview:** For complex tasks requiring sophisticated reasoning

#### Adaptation Techniques
```
// FOR CLAUDE-3.5-SONNET
I need to implement a responsive navigation menu. Here's the design:
[Design details]

// FOR O1-MINI
Analyze this navigation menu implementation for edge cases and potential issues:
[Implementation details]
```

## WordPress-Specific Optimization Techniques

### 1. Code Organization Patterns

#### Component-Based Structure
Organize code into functional components with clear responsibility boundaries:

```
src/
├── post-types/
│   ├── class-product.php
│   ├── class-event.php
├── taxonomies/
│   ├── class-product-category.php
│   ├── class-event-type.php
└── ...
```

Reference only relevant component files, not entire directories.

#### Clean Imports and Dependencies
- Create clear dependency maps
- Document imported classes and functions
- Reference only necessary dependencies

### 2. WordPress Hook Documentation

#### Create Hook Reference Files
Document custom hooks in dedicated files:

**hook-reference.md:**
```markdown
## Action Hooks

### `my_theme_before_product_content`
Fires before the product content is displayed.
- `$product_id` (int) The product ID

### `my_theme_after_product_content`
Fires after the product content is displayed.
- `$product_id` (int) The product ID
```

Reference hook documentation instead of implementation details.

### 3. Database Schema Documentation

Create compact database schema references:

**db-schema.md:**
```markdown
## Custom Tables

### my_theme_product_meta
- product_id (BIGINT) - Foreign key to wp_posts.ID
- meta_key (VARCHAR) - Meta key name
- meta_value (LONGTEXT) - Meta value
```

Reference schema documentation instead of SQL creation code.

### 4. Template Part Management

Create template part maps for cleaner references:

**template-map.md:**
```markdown
## Template Parts

### Content Templates
- content-product.php: Standard product display
- content-product-featured.php: Featured product display

### Header Components
- header-main.php: Main site header
- header-minimal.php: Minimal header for landing pages
```

Reference the map instead of listing all template files.

## Advanced Techniques for Complex Projects

### 1. State Preservation via External Storage

#### Session State Files
Create and update state files outside the conversation:

**project-state.md:**
```markdown
## Current Implementation State
- ✅ Product CPT registered
- ✅ Product Category taxonomy created
- ✅ Basic template parts implemented
- ⚠️ Admin UI needs completion
- ❌ Frontend filters not implemented
```

Reference state instead of relying on conversation history.

### 2. Multi-Conversation Coordination

#### Task Subdivision Strategy
1. Create a master task list
2. Assign subtasks to separate conversations
3. Document dependencies between subtasks
4. Update a central progress tracker

**task-tracker.md:**
```markdown
## Product Feature Implementation

### Tasks
- [1] Architecture definition (DONE)
- [2] Database schema (DONE)
- [3] API endpoints (IN PROGRESS)
- [4] Admin UI (PENDING, depends on 3)
- [5] Frontend components (PENDING, depends on 3)
```

### 3. JSON-First Development

#### Define Components in JSON
Create JSON definitions for WordPress components:

**product-cpt.json:**
```json
{
  "post_type": "product",
  "args": {
    "labels": {
      "name": "Products",
      "singular_name": "Product"
    },
    "public": true,
    "has_archive": true,
    "supports": ["title", "editor", "thumbnail"],
    "rewrite": {"slug": "products"}
  }
}
```

Have AI implement based on JSON definitions rather than generating from scratch.

### 4. GraphViz Documentation

#### Visual Component Relationships
Use GraphViz/DOT syntax for compact relationship documentation:

**component-relationships.md:**
```
digraph {
  ProductCPT -> ProductFactory;
  ProductFactory -> ProductRenderer;
  ProductCPT -> ProductCategory;
  ProductCategory -> CategoryWidget;
}
```

Reference the visual documentation instead of explaining relationships in text.

## Practical Workflows

### 1. Theme Development Workflow

1. **Architecture Phase:**
   - Create component architecture in a dedicated conversation
   - Document architecture decisions in architecture.md
   - Reference architecture.md in subsequent conversations

2. **Component Implementation:**
   - Create separate conversations for:
     - Header components
     - Content templates
     - Sidebar components
     - Footer components
   - Document each component's API in component-api.md

3. **Integration Phase:**
   - Create a new conversation for integration
   - Reference component-api.md instead of implementation details
   - Focus on integration points and hooks

### 2. Plugin Development Workflow

1. **Feature Definition:**
   - Define plugin features in features.md
   - Prioritize and group related features

2. **Core Development:**
   - Implement core classes with minimal dependencies
   - Document class API in class-api.md

3. **Feature Implementation:**
   - Create separate conversations for each feature group
   - Reference class-api.md instead of class implementations
   - Document hooks and filters in hooks.md

4. **Admin UI Development:**
   - Separate conversation for admin UI components
   - Reference features.md and class-api.md
   - Focus on user interactions and validation

### 3. WooCommerce Extension Workflow

1. **Extension Planning:**
   - Document WooCommerce integration points in wc-integration-points.md
   - Define extension features in extension-features.md

2. **Core Functionality:**
   - Implement core extension classes with WooCommerce hooks
   - Document extension API in extension-api.md

3. **Frontend Components:**
   - Separate conversation for frontend components
   - Reference extension-api.md instead of implementation
   - Focus on template overrides and hooks

## Best Practices Summary

1. **Break it down:** Work on small, focused components
2. **Document don't include:** Create reference docs instead of including full code
3. **Single responsibility:** Each conversation should have a specific purpose
4. **Progressive implementation:** Build features in logical, incremental steps
5. **External state:** Maintain project state outside of conversations
6. **JSON definitions:** Define structures in JSON before implementation
7. **Visual documentation:** Use diagrams for complex relationships
8. **Template references:** Create and reference code templates
9. **Fresh starts:** Begin new conversations when changing focus

## Troubleshooting Token Issues

### 1. Signs of Token Limitations

- AI responses are cut off prematurely
- AI forgets context from earlier in the conversation
- AI struggles to complete complex tasks
- Response quality deteriorates over time
- AI fails to reference previously mentioned files

### 2. Immediate Solutions

- Start a new conversation with focused context
- Break current task into smaller steps
- Remove unnecessary file references
- Summarize rather than include large files
- Export current Composer session and start fresh

### 3. Long-Term Solutions

- Improve documentation strategy
- Create better context reference files
- Implement component-based architecture
- Develop specialized templates for common patterns
- Establish structured workflow for large projects

## Conclusion

Effective token optimization is crucial for successful WordPress development with Cursor AI. By implementing these strategies, you can maintain high-quality AI assistance even for complex, large-scale projects. Remember that token optimization is a continuous process that should evolve with your project's needs and complexity.

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 