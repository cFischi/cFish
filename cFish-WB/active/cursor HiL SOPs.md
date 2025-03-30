# cFish.io Cursor SOPs for UcF Cursor AI Human-in-the-Loop (HiL)

## Sources
- https://www.reddit.com/r/cursor/comments/1hf9x7s/nondeveloper_using_cursor_useful_and_not_at_the/ 
- https://www.reddit.com/r/cursor/comments/1i9jgja/share_your_cursor_workflow/ 
- https://www.reddit.com/r/cursor/comments/1ipqiyg/maximizing_cursor_ai_whats_your_best_workflow_hack/ 
- https://www.reddit.com/r/cursor/comments/1j4zwg6/comment/mgzpa38/
- https://dev.to/heymarkkop/cursor-tips-10f8
- https://forum.cursor.com/t/rules-for-ai-are-there-limitations/40700
- https://www.thepromptwarrior.com/p/cursor-ai-tutorial-for-beginners
- https://forum.cursor.com/t/best-practices-cursorrules/41775
- https://www.builder.io/blog/cursor-tips
- https://github.com/RenjiYuusei/CursorFocus
- https://drunk.support/how-we-use-ai-for-software-development/
- https://ghuntley.com/stdlib/
- https://ghuntley.com/specs/
- https://forum.cursor.com/t/cursor-prompt-engineering-best-practices/1592
- https://extremelysunnyyk.medium.com/maximizing-your-cursor-use-advanced-prompting-cursor-rules-and-tooling-integration-496181fa919c
- https://airbyte.com/blog/ai-prompt-best-practices-with-airbyte-cursor

## 1. Setup & Environment

### 1.1 Model Selection
- Use claude-3.5-sonnet as the default model for most tasks
- Switch to o1-mini for tasks requiring deeper thinking and reasoning
- Reserve o1-preview for highly complex tasks (note: higher cost at $0.40/request)
- Understand the strengths and limitations of each model
- Consider using reasoning models (r1, o3) in Chat mode specifically for planning projects
- For each model, track which types of tasks it performs best on
- Consider the price-performance ratio when selecting models for different task types
- Use a consistent model for related tasks to maintain stylistic consistency
- Avoid single model dependency - don't base your entire development strategy on just one AI model
- Don't automatically select models based solely on performance without considering price implications
- Avoid unnecessary model switching when the current model is handling a task well
- Don't assume context is always perfectly preserved between model switches

### 1.2 Setup Recommendations
- Keep the working directory clean and organized
- Follow established directory structure according to UcF conventions
- Enable Shadow Workspace if sufficient RAM is available
- Structure your project into modular components for easier management
- Break large files into smaller files (under 100 lines) for better AI performance
- Organize code in MVC-style patterns where possible for better AI understanding
- Remove distracting applications (social media, Reddit) from easy access during development
- Keep your workspace focused and free from unnecessary visual clutter
- Regularly reindex your codebase in Cursor settings for comprehensive search functionality

### 1.3 YOLO Mode Configuration
- Enable YOLO mode in Cursor settings for advanced automation
- Use YOLO mode to allow Cursor to run tests and fix issues automatically
- Configure a proper prompt for YOLO mode to specify allowed commands
- Sample YOLO prompt: "any kind of tests are always allowed like vitest, npm test, nr test, etc. also basic build commands like build, tsc, etc. creating files and making directories (like touch, mkdir, etc) is always ok too"
- Configure allow lists and deny lists for commands based on project requirements
- Enable "Iterate on Lints" to have the agent automatically fix coding standards issues
- Configure linting tools like PHPStan and PHPCS for WordPress development
- Configure PHPCS to use the WordPress.org coding standards ruleset for consistency
- Allow the agent to see linter error messages to enable self-correction

## 2. Project Context Management

### 2.1 Using .cursorrules
- Create a .cursorrules file in the root directory of your project
- Include specific guidance for how the AI should interact with your codebase
- Keep rules focused and relevant to your project
- Guide the AI to follow UcF coding standards and workflows
- Refer to examples at cursor.directory for effective rules structure
- Verify rules are active by including a confirmation phrase (e.g., "In every message you send, you must say 'OH BOY!'")
- Be aware that .cursorrules may work differently in chat mode vs. composer mode
- Place .cursorrules only in the root folder of the file explorer for proper functionality
- Create a `.cursorignore` file to control which files Cursor has access to, separate from `.gitignore`
- Use `.cursorignore` to include files like scratchpad.md that shouldn't be in version control
- Format rule files with YAML frontmatter to control behavior:
  ```markdown
  ---
  description: Description of what this rule file controls
  globs: *.php, *.js  # Apply to specific file patterns
  alwaysApply: true   # Apply to every request
  ---
  ```
- Create specialized rule files for different aspects of your project
- Reference rules within other rules using the syntax `[rule-name](mdc:project-path/.cursor/rules/rule-name.mdc)`

### 2.2 Markdown Documentation
- Create dedicated markdown files for comprehensive project context
- Maintain documentation of:
  - Component usage
  - API endpoints
  - Code conventions
  - Project structure
- Reference these files in your prompts with the @ symbol
- Keep documentation up-to-date as the project evolves
- Consider creating specialized readme files for different aspects of the project:
  - readme-milestones.md
  - readme-next-days-agenda.md
  - project-overview.md
- Create an `instructions.md` file in the project root for overall guidance to LLMs
- Maintain a `scratchpad.md` for long-running tasks that might span multiple conversations
- Reference documentation using `@filename.md` syntax in your prompts
- Add custom documentation to Cursor's context via Settings → Documentation
- Structure your scratchpad.md with clear sections:
  ```markdown
  current_task: "Brief description of the current task"
  status: in-progress|complete
  description: Detailed description of what needs to be done
  
  steps:
  [ ] Step 1 to complete the task
  [ ] Step 2 to complete the task
  [X] Completed step 3
  
  reflections:
  - Observations about the implementation
  - Challenges encountered
  
  decisions:
  - Implementation decisions and rationale
  ```

### 2.3 Context Optimization
- Be mindful of the 20,000 token limit in Cursor
- Include only relevant files and context in your prompts
- Open all related files and reference them with the "/" command
- Use "Reference Open Editors" to include all open files in context
- For complex projects, create a context.md file that summarizes critical information
- Explicitly inform the agent when working with files that exceed normal context window size
- Use @url to include external API documentation directly in the conversation context
- Avoid using "@codebase" without specific context; prefer targeted file references
- Golden rule: Add all related files at once to the context for comprehensive understanding
- When referring to files, be explicit about hierarchy: "this is the backend @/backend.py, this is the frontend @/frontend.js"
- Have some familiarity with the APIs or frameworks you're using to detect hallucinations
- Avoid ignoring code size limitations - don't use AI tools with insufficient context windows for large codebases
- Don't start sessions without context - always review previous context and logs
- Avoid proceeding with confused context - restart sessions if AI seems disoriented
- Don't add irrelevant information that dilutes focus and wastes tokens

### 2.4 Using CursorFocus
- Consider implementing CursorFocus tool for better project tracking
- CursorFocus automatically tracks project files, functions, and environment variables
- Updates every 60 seconds to keep you informed of changes
- Provides a lightweight focused view of your project structure
- Can help generate effective .cursorrules files based on your project structure

## 3. Effective Prompting Techniques

### 3.1 Detailed Requirements
- Provide clear, specific instructions in your prompts
- Break down complex requests into smaller, manageable tasks
- Reference documentation and related files for context
- Ask the AI to explain its approach before implementing changes
- Review and clarify any ambiguities or misconceptions
- Prefix implementation requests with "TASK:" for clear indication of action items
- Include specific file references and relationships in task descriptions
- For WordPress projects, specify any relevant plugin interactions
- When working with plugins, include information about nonce implementation patterns specific to that plugin
- Don't provide vague prompts - be specific and detailed in your requests
- Avoid assuming AI understanding without verification
- Don't skip overview phase - always have AI explain its planned approach before implementation
- Avoid undefined design requirements - have clear specifications before starting

### 3.2 Iterative Refinement
- Start with a clear initial request
- Review the AI's responses and provide feedback
- Refine your requests based on the AI's output
- Use follow-up prompts to correct or improve the implementation
- Request code review and improvements after initial implementation
- Switch to Chat mode (rather than Agent) for quick fixes to specific lines or issues
- Focus on fixing one issue at a time for clearer communication

### 3.3 Advanced Techniques
- Use voice-to-text tools like Wispr Flow for faster prompt creation
- Leverage other AI tools (like ChatGPT) to help craft complex prompts
- Document successful prompting patterns for reuse
- Link to official documentation for libraries and frameworks
- Use custom templates for frequently performed tasks
- Ask for code cleanup before adding new features to legacy files
- When working with large, older files, disable "Iterate on Lints" to prevent the agent getting stuck on fixing existing issues
- Structure critical prompts following this pattern:
  - Framework identification: [specify framework and version]
  - Component selection: [specify the component name/type]
  - Data requirements: [specify data streams or structures]
  - Task description: [clearly describe what needs to be done]
  - Output preferences: [define the expected output format]
  - Authentication handling: [specify how credentials should be managed]
  - Development preferences: [coding style, patterns, etc.]
  - Documentation links: [provide relevant docs to avoid hallucinations]

### 3.4 Chain-of-Thought and Few-Shot Prompting
- Use chain-of-thought prompting for complex tasks:
  - Ask the agent to "think step by step" before answering
  - Request a breakdown of the reasoning process
  - Have the agent explain its approach before implementation
- Implement few-shot prompting to guide the agent:
  - Provide 2-3 examples of desired input/output patterns
  - Format examples consistently to establish a clear pattern
  - Include both simple and complex examples to demonstrate scope
  - Use explicit markers to separate examples from the actual task
- Combine techniques for complex implementations:
  - Start with few-shot examples to establish patterns
  - Request chain-of-thought reasoning for the current task
  - Ask for verification of the approach before implementation
  - Request self-review after implementation

### 3.5 Test-Driven Development with AI
- For complex tasks, instruct Cursor to "Write tests first, then the code, then run the tests and update the code until tests pass"
- Let YOLO mode automatically iterate on the code until tests pass
- Build off existing test suites by asking to add more test cases
- Use a "pre-PR" command to run fast verification tests before committing
- Configure PHPStan and PHPCS for WordPress development to automatically enforce standards
- Avoid direct code writing without tests in large projects
- Don't rely on AI-generated code without proper test specifications
- Avoid skipping test creation for AI-generated code
- Don't treat AI-generated code as production-ready without thorough testing

## 4. Composer Usage

### 4.1 When to Use Composer
- Use Composer for more complex, multi-file tasks
- Leverage Composer when working on interrelated components
- Prefer Composer over Chat for tasks that might require revisions
- Use Composer when you need to track the evolution of a solution
- Switch to Chat mode for quick fixes to specific lines or small issues

### 4.2 Composer Best Practices
- Start new Composer sessions for fresh tasks to avoid context pollution
- Utilize checkpointing to revert to earlier states if needed
- Try multiple approaches by creating separate Composer threads
- Save all changes at once to test integrated functionality
- Use the side bar view for better workspace integration
- Monitor performance - start a new session if the current one becomes slow
- Be aware that .cursorrules may be processed differently in Composer vs. Chat
- Avoid using Composer on very large files (4000+ lines) as it may get confused
- Consider using notepads to share context between composer sessions
- Create specialized notepads with project-wide references and key file locations:
  ```
  the backend is @/backend
  the frontend is @/frontend
  the functions you need are probably in @/utility.ts
  ```
- Use notepads to store frequently referenced context or instructions
- Access notepads via the Composer interface for quick reference

### 4.3 Managing Composer Sessions
- Access the Composer control panel via the speedometer icon
- Create new sessions using the "+" button or "Create New" in the control panel
- Use Composer Notepads for frequently referenced context or instructions
- Close completed sessions to maintain performance
- Export valuable sessions for future reference
- Use new sessions for new features to maintain focus and performance

## 5. Non-Developer Usage Guidelines

### 5.1 Getting Started
- Begin with small, well-defined tasks before attempting larger projects
- Document successful approaches and techniques
- Build a library of effective prompts and patterns
- Learn the basic terminology of your project's technology stack
- Understand the structure and organization of your codebase
- Start with simple requests and grow in complexity as you gain experience
- Understand that AI doesn't replace work but significantly increases output

### 5.2 Troubleshooting
- When stuck, try breaking the problem into smaller parts
- Ask the AI to explain concepts or code you don't understand
- Request simpler explanations if the AI's response is too technical
- Save work frequently to avoid losing progress
- Create new Composer sessions if you hit unresolvable issues
- Use the Bug Finder feature (Command+Shift+P, type "bug finder") to detect potential issues
- Have Cursor add logging statements to help debug problems
- Watch for minor issues (like incorrect nonce handling) that may indicate deeper problems
- Switch between Chat and Agent modes depending on the complexity of the issue

### 5.3 Working with Developers
- Document AI interactions and share them with the development team
- Learn from the feedback and guidance of experienced developers
- Maintain a repository of successful workflows and approaches
- Communicate clearly about tasks and expectations
- Understand the limitations of AI-assisted development
- Collaborate on task definitions using the TASK: format for clearer communication

## 6. Project Management & Documentation

### 6.1 Change Management
- Make small, focused commits
- Document changes thoroughly in commit messages
- Update memory.md and changelog.md with each significant change
- Follow UcF documentation standards and formats
- Include reference links to supporting resources
- Use Cursor to help generate commit messages by reviewing changes
- Update readme.txt files with summaries of changes when tasks are complete

### 6.2 Knowledge Sharing
- Document successful workflows and techniques
- Create tutorials and guides for common tasks
- Share challenges and solutions with the team
- Build a repository of effective prompts and patterns
- Establish best practices for your specific project needs
- Schedule regular reviews of .cursorrules files to keep them relevant
- Track the evolution of your AI workflows to document improvements

### 6.3 .cursorrules Management Workflow
- Start with a template from dotcursorrules.com
- Use ChatGPT web UI for initial project planning and outlining
- Break down outlines into focused readme files
- Tell Cursor to scan your codebase and readme files for context
- After Q&A sessions, ask Cursor to modify the .cursorrules file
- Update .cursorrules every few days as the project evolves
- Create specialized rule files like `agent-workflow.md` for clearer guidance
- Define clear priority order for different types of directives:
  ```markdown
  ## Priority Order
  1. "TASK:" directives
  2. Code generation requests
  3. General inquiries
  ```

## 7. Security & Quality Assurance

### 7.1 Security Practices
- Never expose sensitive information in prompts or rules
- Follow UcF security protocols for handling credentials
- Verify AI-generated security implementations
- Review generated code for security vulnerabilities
- Implement WordPress security best practices consistently
- Pay special attention to plugin-specific security patterns (like nonce implementation)
- Be vigilant about platform-specific security considerations

### 7.2 Quality Control
- Test all AI-generated code thoroughly
- Request the AI to review its own implementations
- Verify compatibility with existing codebase
- Follow established coding standards
- Maintain documentation of testing procedures and results
- Babysit AI during complex tasks - be ready to interrupt if it goes off track
- Create a "pre-PR" command to run verification tests before submitting
- Leverage "Iterate on Lints" with PHPStan and PHPCS for WordPress coding standards

### 7.1 Code Protection
- Implement guardrails against large-scale feature removal
- Be cautious of AI suggesting external tools or services without proper vetting
- Consider implementing file locks for critical files that shouldn't be modified
- Verify all external connections suggested by the AI before implementing
- Be especially careful with shell commands and external connections
- Be watchful for minor issues that may indicate deeper problems (e.g., incorrect nonce handling)
- Don't allow AI to make unrestricted changes to code without constraints
- Avoid uncontrolled file operations - never allow AI to create or delete files without review
- Prevent unrelated code modifications during specific tasks
- Don't allow silent error handling in AI-generated code

## 8. Resource Management

### 8.1 File Organization Practices
- Break large files (1000+ lines) into smaller, more focused files
- Use descriptive file names that clearly indicate functionality
- Organize code in MVC-style patterns where possible
- Refactor legacy code toward smaller file sizes before adding new features
- Alert the agent when working with files that exceed normal context window size

### 8.2 Productivity Optimization
- Create a standardized workflow for handling TASK: requests
- Maintain a scratchpad.md file for tracking progress in long-running tasks
- Consider implementing MPC (Model Context Protocol) servers for specialized capabilities
- Keep track of r/cursor on Reddit and the Cursor changelog for new features and tips
- Look for YouTube videos about Cursor hacks and best practices for continuous improvement
- Understand that workflow optimization is rapidly evolving; be prepared to update your approach frequently

## 9. Advanced Task Management

### 9.1 Structured Task Workflow
- Implement a consistent workflow for task implementation:
  1. Receive task with "TASK:" prefix
  2. Have agent analyze relevant files and create a plan in scratchpad.md
  3. Review and approve the plan
  4. Create Git branch for the feature (manually or via agent)
  5. Execute implementation steps with regular updates to scratchpad.md
  6. Final review and readme.txt updates when complete
- Use this workflow consistently for better task tracking and completion

### 9.2 Rule Priority Management
- Establish clear rule priority in your agent-workflow.md file:
  ```markdown
  ## Priority Order
  1. "TASK:" directives (see task-directives.mdc)
  2. Code generation requests (follow patterns in relevant rule files)
  3. General inquiries (reference instructions.md)
  ```
- Reference this priority order in your rules to ensure consistent handling
- Ensure agents follow the established priority for more predictable behavior

### 9.3 Custom Documentation Integration
- Add your project documentation to Cursor's context through Settings → Documentation
- Point to your documentation base URL to make it available to the AI
- Reference specific documentation pages with @url in your prompts
- Create dedicated rules files for different documentation aspects
- Keep your documentation structure aligned with your .cursorrules organization
- Regularly validate that the agent is properly utilizing your documentation

## 10. Advanced Agent Usage Strategies

### 10.1 Reframing Cursor as an Autonomous Agent
- Stop treating Cursor as a simple IDE or search tool
- View Cursor as an autonomous agent capable of programmatic behavior
- Avoid relying solely on AI tools - don't let them handle all problem-solving aspects
- Don't prioritize speed over understanding - take time to comprehend what AI generates
- Avoid blindly applying AI fixes without understanding underlying issues
- Don't complete reliance on AI tools - remember they supplement but don't replace expertise
- Avoid letting AI work completely autonomously without supervision
- Focus on teaching patterns and approaches rather than solving individual problems
- Think of each interaction as programming the LLM's behavior
- Provide detailed corrections that explain why something is wrong and how to fix it
- Balance directness with courtesy - studies suggest that using names and "please"/"thank you" can improve compliance in some contexts
- Focus on precision over politeness for technical tasks
- When correcting the agent, explain not just what went wrong but the underlying pattern to avoid

### 10.2 Systematic Knowledge Building
- Build your knowledge library incrementally with each interaction
- When encountering a problem, solve it by teaching Cursor a general solution
- Have Cursor update its own knowledge when it makes mistakes
- Develop solutions for classes of problems rather than individual instances
- Document successful patterns and update .cursorrules accordingly
- Focus on tasks that build reusable knowledge
- Create a library of solved problems that can be referenced in future work
- Use the agent to help document its own learning process

### 10.3 Multi-Agent Coordination
- Learn to coordinate multiple agents working on different parts of a project
- Use git worktree to create separate working directories for different agents
- Create clear boundaries between components to enable parallel development
- Establish well-defined interfaces between components
- Implement a system for reconciling work from multiple agents
- Develop conventions for branch management and PR creation
- Consider using larger displays to handle multiple agents simultaneously
- Implement a coordination system where you act as the integrator

### 10.4 Feedback Loops and Quality Control
- Implement tight feedback loops with compiler errors, tests, and linters
- Create workflows that automatically verify agent output
- Use languages with strong type systems that provide actionable error messages
- Implement property-based testing for thorough validation
- Hook security scanning tools into your workflow
- Have agents explain their reasoning and approach before implementation
- Establish clear validation criteria for all agent-generated solutions
- Create automated mechanisms to ensure standards compliance

### 10.5 Working with Specifications
- Learn to write clear, detailed specifications that agents can follow
- Break complex tasks into well-defined components with clear boundaries
- Define interfaces between components to enable parallel development
- Use MPC (Model Context Protocol) servers for specialized capabilities
- Understand that the quality of your specifications directly impacts agent performance
- Focus on high-level design while letting agents handle implementation details
- Maintain a system for tracking and updating specifications
- Create a feedback loop where specification quality improves based on results

### 10.5.5 MCP Security Considerations
- API key management practices:
  - Store all API keys in environment variables
  - Never hardcode credentials in source code
  - Implement key rotation schedules
  - Use separate keys for development and production
  - Monitor key usage and implement rate limiting
- Risk level table for different MCP types:
  | MCP Type | Risk Level | Security Requirements |
  |----------|------------|----------------------|
  | Local Processing | Low | Basic authentication |
  | Network Access | Medium | TLS, API key auth |
  | File System | High | Strict permissions, audit logging |
  | Database | Critical | Encryption, access control |
- Configuration security best practices:
  - Use .env files for sensitive configuration
  - Implement configuration validation
  - Encrypt sensitive configuration values
  - Regular security audits of configurations
  - Version control for configuration changes
- Cross-platform security implications:
  - Consistent security standards across platforms
  - Platform-specific security controls
  - Integration point security validation
  - Cross-platform authentication flow
  - Data encryption in transit
- Human-in-the-loop protocols:
  - Required human approval for sensitive operations
  - Clear security escalation procedures
  - Audit logging of human interventions
  - Regular security training and updates
  - Incident response procedures

### 10.6 Buildtime vs. Runtime HITL Approaches
- Understand the difference between buildtime and runtime human-in-the-loop approaches:
  - Buildtime HITL: Humans provide specifications and verify output after completion
  - Runtime HITL: Humans actively guide and steer the AI during implementation
- For routine tasks with established patterns, prefer buildtime HITL:
  - Write detailed specifications 
  - Allow agent to work autonomously using the loopback workflow
  - Verify and correct output when complete
- For complex or novel tasks, use runtime HITL:
  - Provide incremental guidance
  - Review intermediate decisions
  - Steer the implementation process actively
- Start with runtime HITL when establishing patterns, then transition to buildtime HITL
- Document successful workflows to accelerate transition from runtime to buildtime
- For optimal productivity, minimize runtime HITL interventions where possible

### 10.7 Minimal Intervention Supervision
- Develop a supervision style that maximizes agent autonomy while maintaining quality
- Set clear boundaries for what the agent can do without supervision
- Create a "supervision checklist" for critical points requiring human review:
  - Initial specification review
  - Architecture and design decisions
  - External integrations and security implementations
  - Final implementation verification
- Define "guardrails" that trigger human review when crossed:
  - Certain file types or directories being modified
  - Large-scale refactoring proposals
  - External API or service integration
  - Significant security implementations
- Use a "trust but verify" approach with increasing autonomy over time
- Document when intervention was needed to improve future automation
- Create a feedback cycle that reduces supervision needs over time

### 10.8 Specification Refinement Process
- Master the iterative specification refinement process:
  1. Draft initial specifications with the agent's assistance
  2. Have the agent identify gaps, ambiguities, or inconsistencies
  3. Refine specifications collaboratively
  4. Finalize specifications before implementation
- Ask directed questions to improve specifications:
  - "What edge cases are not addressed in these specifications?"
  - "What performance considerations are missing?"
  - "What security implications need to be addressed?"
- Let the agent help create detailed acceptance criteria for each feature
- Create clear boundaries between components to enable parallel development
- Maintain a specification refinement log to track evolution of requirements
- Emphasize precision and clarity in specifications to minimize runtime intervention
- Use the agent to transform vague requirements into precise specifications
- Have the agent create visual diagrams or flowcharts for complex specifications

### 10.9 Human-Agent Collaboration Rituals
- Establish consistent rituals for human-agent collaboration:
  - Morning planning: Review specifications and plan implementation approach
  - Mid-day check-in: Verify progress and adjust course if needed
  - Evening review: Assess completed work and plan next steps
- Keep interaction logs to identify patterns that can be automated
- Document successful prompting patterns that produce reliable results
- Set clear expectations for what "done" means for each task
- Establish a vocabulary for different intervention types:
  - Quick check: Agent continues while human reviews
  - Full stop: Agent waits for human approval before continuing
  - Redirect: Human steers agent in a different direction
- Automate routine feedback patterns with specialized rules
- Document when human intervention was needed and why
- Create a feedback loop that systematically reduces required interventions

## 11. AI MVP Development Process

### 11.1 Planning and Requirements
- Begin with a thorough assessment of business needs and technical feasibility
- Establish clear, measurable goals for the AI MVP
- Prioritize features based on core functionality requirements
- Define acceptance criteria for each feature before implementation begins
- Create a structured requirements document that serves as the foundation for development
- Use Cursor to help draft and organize the initial specifications
- Identify key stakeholders and their specific requirements early in the process
- Plan for voice, video, or LLM integrations based on project requirements
- Establish a clear timeline with defined milestones and checkpoints
- Don't skip PRD creation - always create proper requirements documentation
- Avoid monolithic requests - break complex features into manageable pieces
- Don't rely solely on AI for specifications - maintain human control over requirements

### 11.2 Data Strategy and Model Selection
- Evaluate available data sources and quality before beginning implementation
- Determine which AI models are most appropriate for your specific use case
- Consider factors like cost, performance, and context window size when selecting models
- For WordPress projects, assess existing data structures and plugin compatibility
- Create a data preprocessing strategy for preparing training or fine-tuning datasets
- Document model selection decisions and rationales for future reference
- Consider developing a test dataset for consistent model evaluation
- Implement a monitoring strategy to track model performance over time
- Plan for data privacy and security considerations from the beginning

### 11.3 Agile Development Approach
- Implement short development cycles with frequent reviews
- Create a backlog of features prioritized by business value and technical feasibility
- Plan for daily check-ins to assess progress and address blockers
- Use Cursor Composer Agent for implementing well-defined features
- Have human developers review and refine AI-generated code
- Establish a process for handling feature pivots based on feedback
- Use git worktree to enable parallel development streams where appropriate
- Document learning and best practices as they emerge during development
- Maintain a consistent development environment across the team

### 11.4 Testing and Evaluation
- Implement both automated and human testing procedures
- Create a structured evaluation framework with clear metrics
- Consider both technical performance and user experience in evaluations
- Use human evaluators to assess AI outputs for quality and appropriateness
- Implement A/B testing for critical AI-driven features
- Document edge cases and failure modes as they're discovered
- Create a feedback loop that allows for rapid iteration based on test results
- Establish clear criteria for determining when a feature is complete
- Prepare evaluation reports that balance technical metrics with business outcomes

### 11.5 Deployment and Iteration
- Plan for gradual rollouts with defined user groups
- Establish clear monitoring criteria for production deployments
- Create a process for collecting and analyzing user feedback
- Set up analytics to track key performance indicators
- Define thresholds for triggering model updates or retraining
- Document the deployment process for future reference
- Plan for regular review cycles to assess overall MVP performance
- Establish a framework for prioritizing post-MVP enhancements
- Create a clear handoff process from the MVP phase to continued development

## 12. Using Cursor as a Universal AI Entry Point

### 12.1 Cursor for General Q&A
- Use Cursor Chat for answering general knowledge questions
- Take advantage of multiple model providers (OpenAI, Anthropic, etc.) within the same interface
- Preserve Q&A results as documents for future reference by using the Apply button
- For translations, use Cursor's diff view to create effective bilingual documents
- Combine language models with your own notes and documentation for personalized answers
- Use Cursor's built-in text comparison to review and refine AI responses

### 12.2 Extending Cursor with Custom Search Capability
- Create custom search tools for web browsing capability within Cursor
- Define search tools in `.cursorrules` file to extend Cursor's native abilities
- Customize search behavior for deeper result analysis (examining more than just top results)
- Configure search tools to iterate on keywords and generate comprehensive summaries
- For technical queries, configure search to prioritize English keywords even when prompted in other languages
- Implement domain-specific search optimizations for different query types

### 12.3 Private Document RAG with Cursor
- Leverage Cursor's built-in retrieval capabilities for non-code documentation
- Place reference documents in your workspace for Cursor to index and search
- Use Command+Enter (instead of just Enter) to trigger document search before generating responses
- Review retrieved documents in the interface to verify relevance
- Store generated insights as new documents that become part of the searchable knowledge base
- Use this approach to create a continuous knowledge management loop
- Integrate with knowledge management systems like Obsidian for enhanced functionality

### 12.4 Personalization and Memory
- Create custom prompts for personalized responses (e.g., responding in specific languages)
- Configure Cursor to search specific websites for particular topics
- Maintain a database of frequently used links and references within your workspace
- Add specific documents dynamically to provide additional context for queries
- Build up personalized knowledge over time through continued use
- Create specialized rules files for different types of queries and contexts
- Implement a structured system for organizing and accessing this accumulated knowledge

### 12.5 Limitations and Considerations
- Current Cursor implementations lack API access for programmatic integration
- No mobile version is currently available, limiting usage to desktop environments
- Don't exceed rate limits - implement proper handling for API usage constraints
- Avoid single-tool dependency - maintain alternatives for critical workflows
- Don't ignore free tier limitations - be aware of constraints before they impact work
- Avoid excessive costs - monitor usage and set appropriate limits
- Be aware of regional accessibility and price differences in different markets
- Consider API key security and rotation for production implementations
- For payment integrations, don't underestimate complexity even with AI assistance
- Consider these limitations when planning workflows that might need to extend beyond the desktop
- Keep track of ongoing developments in the Cursor ecosystem for future enhancements
- Where possible, implement workarounds for critical limitations using available tools

## 13. Cursor AI Interface and Interaction Features

### 13.1 Chat Interface Capabilities
- Interact directly with AI about your code through the Cursor chat interface
- Ask specific questions about your code like "Is there an error here?" or "How can I improve this function?"
- Use Ctrl+Enter to perform codebase-wide queries when you need information from across your project
- This allows AI to search through your entire codebase for relevant information
- Use the @ symbol as a search tool to refer to specific code fragments or files during conversations
- This enables quick access to relevant code files and symbols without leaving the chat
- Upload images through the image button (camera icon) below the chat interface
- Image uploads provide visual context that may be difficult to express with text alone
- Use the @Web command to obtain real-time information from the internet
- Start web searches by typing @Web followed by your question or research topic

### 13.2 Documentation Access and Management
- Access technical documentation directly within the development environment
- Reference library documentation using the @LibraryName command
- This provides relevant information about the library, including usage examples and best practices
- Add new documentation using @Docs → Add New Document
- Upload and organize guides, project specifications, and reference materials
- Organize documentation for easy access during development
- Create a consistent documentation structure for AI reference
- Reference documentation to provide additional context when working on complex tasks

### 13.3 Smart Code Features for WordPress Development
- Use smart autocomplete when working with WordPress-specific functions
- Have Cursor AI analyze the context of your code to offer precise suggestions
- Take advantage of cursor prediction as you move through WordPress files
- Leverage multi-line editing to make changes to multiple areas of a theme or plugin simultaneously
- Use smart rewrites to correct errors in your WordPress code
- Apply these features specifically to WordPress tasks:
  - Theme development and customization
  - Plugin creation and optimization
  - Widget implementation
  - Performance enhancements
  - Security improvements

## 14. UcF Ecosystem Integration

### 14.1 UcF Departmental Context Management
- Develop specialized prompt templates for each UcF department:
  - U1-Administration: Focus on overhead management, trust structure, and holding company functions
  - U2-Research: Emphasize AI integration, R&D, and tYFeAiz collaboration
  - U3-Operations: Center on physical operations, FiscHouse management, and facility coordination
  - U4-Production: Concentrate on WordPress development, UcWebZ, and content production
  - U5-Data: Highlight DSS (DispatcheZ, ServiceZ, Success) operations and data management
  - U6-Marketing: Emphasize FischEYe production design and social media communications
  - U7-Systems: Focus on tYberius Designz, development, and technical direction
- Implement context switching techniques for cross-departmental tasks:
  - Create clear delineation when transitioning between departmental contexts
  - Use department-specific prompt prefixes (e.g., [U4-TASK], [U7-TASK])
  - Include appropriate department headers in generated files
  - Maintain consistent department referencing in all communications
- Configure workspace organization to reflect departmental structure:
  - Organize open editors by department for better context management
  - Create department-specific .cursorrules files with appropriate rule inheritance
  - Use department-specific workbench references for historical context
  - Set up department-specific Git branches for parallel development
- Use specialized commands for departmental knowledge access:
  - Reference WB-memory.md files for department-specific historical knowledge
  - Include relevant README files from appropriate department directories
  - Access departmental documentation using @U[number]/Documentation/[filename] syntax
  - Tailor search patterns to focus on specific departments when needed
- Implement department-specific agent personalities:
  - Create specialized agents for each department with appropriate expertise
  - Configure agent behavior to match departmental priorities and philosophies
  - Develop specialized terminology and communication styles for each department
  - Document departmental communication patterns for consistent interactions
- Establish cross-departmental collaboration protocols:
  - Create standardized formats for inter-departmental requests
  - Define handoff procedures for work that crosses department boundaries
  - Document departmental dependencies and integration points
  - Develop consistent cross-referencing between departmental documentation

### 14.2 Cross-Platform Implementation Standards
- Develop consistent implementation approaches across all four cFish.io platforms:
  - WordPress (cFish.io): Focus on content management, custom post types, and theme customization
  - ClickUp (cFish.App): Emphasize task management, workflow automation, and project tracking
  - Notion (U.cFish.io): Highlight knowledge center organization, documentation, and wiki structure
  - Vendasta (cFish.Vip): Center on client solutions, CRM integration, and marketing automation
- Implement verification procedures for cross-platform consistency:
  - Create validation checklists for each platform
  - Test user interactions across all platforms for consistent experience
  - Verify data integrity during synchronization operations
  - Document platform-specific limitations and workarounds
- Maintain UI/UX consistency guidelines across platforms:
  - Document color palettes, typography, and design elements for each platform
  - Create component libraries that maintain visual coherence
  - Implement responsive design patterns consistently
  - Ensure accessibility standards compliance across all platforms
- Develop cross-platform testing strategies:
  - Create platform-specific test cases that verify common functionality
  - Implement automated tests for synchronization validation
  - Document manual testing procedures for cross-platform interactions
  - Establish performance benchmarks for each platform
- Create unified data models for cross-platform integration:
  - Design schema mappings between platforms for consistent data representation
  - Implement validation procedures for detecting schema drift
  - Document transformation rules for data moving between platforms
  - Create reference implementations for core data types
- Establish platform-specific development guidelines:
  - Create specialized Cursor prompt templates for each platform
  - Document platform-specific API usage patterns
  - Implement consistent error handling approaches across platforms
  - Define security standards appropriate to each platform
- Test user interactions across all platforms for consistent experience
- Verify data integrity during synchronization operations
- Document platform-specific limitations and workarounds
- Implement multi-environment testing before deployment
- Create specialized test cases for each supported platform
- Don't rely on testing in a single environment
- Avoid assuming functionality works identically across all platforms
- Test under various network conditions to ensure robustness

### 14.3 tYFeAiz Collaboration Framework
- Implement the "Live Boardz" multi-agent collaboration approach:
  - Configure Cursor for "Live Boardz" sessions with 3-9 AI agents
  - Assign specific roles to each agent based on the session requirements
  - Coordinate human-in-the-loop interaction points
  - Document session outcomes and learnings
- Create role definitions for specialized agents within the tYFeAiz framework:
  - Executive Agent: Strategic planning and high-level direction
  - Project Architect: System design and technical architecture
  - Implementation Engineer: Code generation and feature development
  - QA Analyst: Testing, validation, and quality assurance
  - Documentation Specialist: Technical writing and documentation
  - Security Expert: Security auditing and vulnerability assessment
  - UX Designer: User experience and interface design
  - Data Analyst: Data processing and analysis
  - Integration Specialist: Cross-platform integration and synchronization
- Establish handoff protocols between agents:
  - Define clear criteria for when work should transition between agents
  - Create standardized handoff templates with relevant context
  - Document the chain of reasoning and decisions for transparency
  - Implement validation checks before accepting handoffs
- Measure and optimize agent collaboration effectiveness:
  - Track key performance metrics for multi-agent sessions
  - Document successful collaboration patterns for future reference
  - Identify and address collaboration bottlenecks
  - Create continuous improvement mechanisms for the tYFeAiz system
- Design session management protocols:
  - Create clear session initialization procedures
  - Define roles and responsibilities for each agent type
  - Establish communication patterns between agents
  - Implement deliberation mechanisms for handling disagreements
  - Document decision-making frameworks for multi-agent consensus
- Create specialized templates for different session types:
  - Strategic planning sessions with executive focus
  - Implementation sessions focused on code generation
  - Review sessions for quality assurance and security
  - Documentation sessions for capturing knowledge and decisions
  - Integration sessions for cross-platform coordination

### 14.4 Documentation-as-Service Excellence
- Develop documentation standards that support the documentation-as-service business model:
  - Implement professional-grade documentation templates
  - Create client-ready documentation with appropriate branding
  - Develop metrics for documentation quality and completeness
  - Establish comprehensive documentation review procedures
- Structure documentation to showcase cFish.io's expertise:
  - Incorporate Dreamflo ~ philosophical principles in documentation structure
  - Demonstrate technical excellence through clear, precise documentation
  - Highlight unique methodologies and approaches
  - Create visually appealing documentation with professional formatting
- Implement knowledge management best practices:
  - Create comprehensive documentation hierarchies
  - Maintain consistent terminology and glossaries
  - Implement clear versioning and change tracking
  - Establish documentation update protocols
- Develop client-facing documentation packaging:
  - Create exportable documentation in multiple formats (PDF, HTML, etc.)
  - Implement documentation branding and customization
  - Develop client-specific documentation adaptations
  - Create documentation portfolio for marketing purposes
- Establish documentation quality assurance procedures:
  - Develop review checklists for different documentation types
  - Implement peer review processes for all client-facing documentation
  - Create verification procedures for technical accuracy
  - Document success criteria for documentation deliverables
- Implement documentation workflow management:
  - Design staged review processes for documentation development
  - Create milestone tracking for documentation projects
  - Implement feedback collection mechanisms from clients
  - Develop continuous improvement processes for documentation standards
- Create specialized documentation templates for different purposes:
  - Technical specifications with detailed implementation guidance
  - User guides with appropriate readability and comprehension levels
  - System architecture documents with clear visualizations
  - Operational playbooks with step-by-step procedures
  - Client handover packages with comprehensive knowledge transfer
  - Training materials with educational design principles

### 14.5 DMMS Integration with Cursor Workflows
- Integrate the Distributed Memory Management System (DMMS) with Cursor:
  - Configure Cursor to access department-specific memory.md files automatically
  - Implement bidirectional synchronization between Cursor edits and DMMS updates
  - Create automated versioning for documentation changed through Cursor
  - Establish DMMS metadata integration with Cursor file operations
- Implement memory file access optimization:
  - Develop intelligent retrieval mechanisms for relevant memory file sections
  - Create caching systems for frequently accessed memory content
  - Implement prioritization algorithms for memory context selection
  - Establish relevance scoring for memory file content
- Configure workflow integration between Cursor and DMMS:
  - Automate memory.md updates for Cursor-generated documentation
  - Create standardized entry formats for Cursor-driven memory updates
  - Implement validation procedures for memory content consistency
  - Develop conflict resolution procedures for concurrent edits
- Establish DMMS performance optimization for Cursor integration:
  - Design efficient retrieval patterns for large memory files
  - Implement progressive loading for memory file access
  - Create memory file indexing for faster search operations
  - Develop compression strategies for memory file storage
- Create DMMS security controls for Cursor access:
  - Implement role-based access controls for memory file operations
  - Create audit logging for all memory file modifications
  - Establish validation procedures for memory file integrity
  - Develop recovery mechanisms for unauthorized changes

## 15. Advanced Debugging Techniques

### 15.1 AI-Assisted Debugging Workflow
- Implement a systematic approach to debugging with Cursor:
  - Ask Cursor to identify potential issues by explaining the code's behavior
  - Request analysis of error messages or unexpected behavior
  - Have Cursor suggest debugging instrumentation (console logs, breakpoints)
  - Use the "Bug Finder" command (Command+Shift+P, then type "bug finder")
  - Ask Cursor to suggest unit tests that would catch the issue
- Use structured debug commands for more accurate AI assistance:
  ```
  DEBUG REQUEST:
  Code location: [file name and line numbers]
  Observed behavior: [what's happening]
  Expected behavior: [what should happen]
  Error message: [exact error text if applicable]
  Recent changes: [what changed recently that might be related]
  ```
- Follow a systematic debugging process:
  1. Isolate the problematic code section
  2. Ask Cursor to explain the code behavior line by line
  3. Request potential fixes for each hypothesis
  4. Test fixes incrementally
  5. Document the root cause and solution
- Avoid immediate code fixes - analyze root causes before implementing changes
- Don't focus on single-hypothesis fixation - consider multiple potential causes
- Avoid poor error handling - implement robust error reporting systems
- Don't neglect security considerations when debugging issues
- Avoid disconnected tooling - integrate debugging tools with existing workflows

### 15.2 Language-Specific Debugging Patterns
- When debugging WordPress PHP code:
  - Use `error_log()` for capturing debug information in server logs
  - Request Cursor to add `var_dump()` or `print_r()` with `die()` at strategic points
  - Ask Cursor to add WordPress-specific debug logging: `WP_DEBUG_LOG`, `WP_DEBUG_DISPLAY`
  - Use the "Debug Bar" or "Query Monitor" plugins for deeper analysis
  - Implement `try/catch` blocks with detailed exception logging
- For JavaScript debugging:
  - Have Cursor add `console.log()`, `console.trace()`, or `console.table()` statements
  - Implement debugger statements at key points
  - Add performance measurements with `console.time()` and `console.timeEnd()`
  - Utilize async stack traces for asynchronous code
  - Log state snapshots before and after key operations

### 15.3 Environment Diagnosis
- Ask Cursor to help diagnose environment-specific issues:
  - Generate environment validation scripts to verify PHP/WordPress versions
  - Create configuration compatibility checks for different hosting environments
  - Implement browser compatibility detection for front-end issues
  - Generate database verification queries to validate schema and data integrity
  - Create system resource monitoring to detect performance bottlenecks
- Generate environment diagnostic reports with detailed configuration information:
  ```php
  function generate_diagnostic_report() {
    $report = [
      'php_version' => phpversion(),
      'wp_version' => get_bloginfo('version'),
      'active_plugins' => get_option('active_plugins'),
      'theme' => wp_get_theme()->get('Name'),
      'memory_limit' => ini_get('memory_limit'),
      'post_max_size' => ini_get('post_max_size'),
      'max_execution_time' => ini_get('max_execution_time'),
      'server_software' => $_SERVER['SERVER_SOFTWARE'],
    ];
    return $report;
  }
  ```

### 15.4 AI-Enhanced Error Logging
- Implement enhanced error logging with AI analysis:
  - Ask Cursor to generate structured error logging frameworks
  - Create pattern detection systems to identify recurring issues
  - Implement contextual error capturing that includes state information
  - Generate error visualization components for faster comprehension
  - Develop heatmaps of error frequency across the codebase
- Implement a comprehensive error logging system with severity levels:
  ```php
  function ai_enhanced_error_log($message, $severity = 'info', $context = []) {
    $log_data = [
      'timestamp' => current_time('mysql'),
      'severity' => $severity,
      'message' => $message,
      'user_id' => get_current_user_id(),
      'url' => $_SERVER['REQUEST_URI'],
      'context' => json_encode($context),
    ];
    
    // Log to database or file
    // Add pattern detection and analysis
    
    return $log_data;
  }
  ```

### 15.5 Cross-Platform Debugging Strategies
- Implement debugging strategies across the four cFish.io platforms:
  - Create debug modes that activate verbose logging on all platforms
  - Implement cross-platform request tracing with unique identifiers
  - Generate data flow diagrams for complex cross-platform operations
  - Develop synchronization verification tools for data consistency checks
  - Create debug dashboards that aggregate information from all platforms
- Ask Cursor to create specialized debugging functions for cross-platform issues:
  ```php
  function trace_cross_platform_request($operation, $data) {
    $trace_id = uniqid('trace_');
    
    // Log to WordPress
    ai_enhanced_error_log("Cross-platform operation: $operation", 'debug', [
      'trace_id' => $trace_id,
      'platform' => 'wordpress',
      'data' => $data,
      'timestamp' => microtime(true),
    ]);
    
    // Include trace_id in requests to other platforms
    // Implement hooks for other platforms to log with same trace_id
    
    return $trace_id;
  }
  ```

## 16. Common HiL Mistakes to Avoid

### 16.1 Intervention Timing Mistakes
- **Intervening too early**: Allow the AI to fully explore a solution before interrupting
- **Waiting too long to intervene**: Step in immediately when AI is clearly heading in the wrong direction
- **Inconsistent review cadence**: Establish regular checkpoints to review AI progress
- **Over-reliance on automation**: Maintain appropriate human oversight for critical decisions
- **Micro-managing simple tasks**: Give AI autonomy for tasks it can reliably complete

### 16.2 Communication Mistakes
- **Ambiguous instructions**: Be clear and specific in your requirements
- **Inconsistent terminology**: Use consistent terms across conversations
- **Poor error feedback**: Explain what went wrong and why when providing corrections
- **Not teaching patterns**: Focus on explaining the underlying pattern rather than just fixing errors
- **Failing to set expectations**: Clearly communicate constraints and limitations upfront

### 16.3 Context Management Failures
- **Insufficient domain knowledge sharing**: Provide adequate background information
- **Not using reference files**: Create and reference markdown files for project context
- **Overloading with irrelevant information**: Include only relevant files and context
- **Ignoring token limitations**: Be mindful of the 20,000 token limit in Cursor
- **Not checking for hallucinations**: Verify AI's claims about your codebase and APIs

### 16.4 Process Mistakes
- **Starting with the wrong model**: Select appropriate models for different task types
- **Improper iteration on feedback**: Follow up with clear, directed improvements
- **Neglecting documentation updates**: Keep documentation aligned with code changes
- **Not saving Composer sessions**: Export valuable sessions before closing them
- **Insufficient testing of generated code**: Always verify AI-generated code thoroughly

### 16.5 Knowledge Building Failures
- **One-off solutions**: Develop solutions for classes of problems, not just single instances
- **Not updating rules and documentation**: Document successful patterns and approaches
- **Failing to track successful workflows**: Build a library of effective prompt patterns
- **Not sharing knowledge**: Communicate successful approaches with the team
- **Skipping post-implementation reviews**: Review completed tasks to identify improvements

### 16.6 YOLO Mode Mistakes
- **Inappropriate YOLO configuration**: Carefully configure allowed and denied commands
- **No protections for sensitive operations**: Create guardrails against dangerous operations
- **Inadequate monitoring of automated actions**: Watch what YOLO mode is doing
- **Over-reliance on automation**: Use YOLO selectively for appropriate tasks
- **Not reviewing automated changes**: Always verify automatically applied changes

### 16.7 Multi-Agent Coordination Issues
- **Unclear role boundaries**: Define clear responsibilities for each agent
- **Poor handoff procedures**: Create structured formats for work transitions
- **Lack of integration planning**: Plan how to reconcile work from multiple agents
- **Inconsistent standards across agents**: Maintain consistent guidelines for all agents
- **Missing oversight mechanism**: Establish clear human checkpoints for multi-agent work

## 17. Effective Human-AI Collaboration Strategies

### 17.1 Structured Project Organization
- Maintain a Project_milestones.md file referenced in .cursorrules for clear tracking
- Use incremental development rather than large feature drops for better control
- Break down tasks into well-defined, manageable pieces for more effective AI assistance
- Implement structured documentation that separates human input from AI-generated content
- Save discussions and decisions in design documents and commit them to code
- Document AI interactions and include them in your version history

### 17.2 AI Tool Management
- Treat AI coding tools as assistants rather than replacements for human judgment
- Maintain critical thinking while using AI tools and validate all AI-generated suggestions
- Choose AI models based on specific project needs rather than overall performance scores
- Use different AI models for different purposes based on their specific strengths
- Consider broader impact of changes throughout the codebase when implementing AI suggestions
- Maintain balance in tool usage while staying actively engaged in problem-solving
- Focus on fundamentals and deep understanding rather than quick AI-generated solutions

### 17.3 Planning and Validation Workflow
- Always request an overview of planned implementation before having AI generate code
- Review AI's understanding and refine requirements before proceeding with code generation
- Verify that AI has acknowledged all necessary files and dependencies before generation
- Create a comprehensive plan before starting implementation with AI
- Always review and verify code generated by AI tools before implementation
- Question and validate decisions with AI before writing any code
- Pre-implementation specification review is essential for high-quality output

### 17.4 Workflow Optimization
- Use Git or other version control systems when working with AI to maintain control
- Implement structured prompts to encourage AI to reason about code rather than just generate it
- Enable interactive questioning in Cursor AI by adding rules for clarifying unclear instructions
- Organize AI prompts into clear sections (Core Principles, Style Guidelines, Output Format, Key Requirements)
- Plan usage within free tier limits (15 requests/minute and 1,500 requests/day) to avoid disruptions
- Implement focused work intervals and batch AI assistance requests to minimize context switching
- Create progress tracking files (like .plan and .progress) for workflow documentation

### 17.5 Focus Areas for Human Intervention
- Focus on high-level architectural decisions rather than implementation details
- Prioritize deep understanding of programming fundamentals over quick AI-generated solutions
- Maintain realistic expectations about AI capabilities and code knowledge requirements
- Consider scaling and maintenance aspects when accepting AI-generated solutions
- Implement a "verify first" approach to all AI-generated code for correctness, efficiency, and security
- Maintain current documentation on all features to ensure future maintainability
- Verify AI-generated code undergoes the same rigorous review as human-written code

## 18. Project-Specific Best Practices

### 18.1 MVP Development
- Focus on building core features for MVP before expanding functionality
- Use AI-assisted development to quickly validate MVP concepts
- Design products with strong network effects to maintain competitive advantage
- Start with smaller, manageable components before attempting complex applications
- Evaluate project complexity and required technical knowledge realistically
- Prioritize problem identification and solution design over technical implementation
- Create a comprehensive testing strategy before launching

### 18.2 Production Readiness
- Ensure applications built with AI are thoroughly tested before deployment
- Implement a clear maintenance strategy that accounts for growing complexity
- Conduct appropriate testing across different operating systems and environments
- Implement automated code review checks before committing changes
- Set appropriate usage limits for AI development tools based on project needs
- Monitor AI tool usage costs and patterns to optimize expenses
- Test different AI coding assistants to find the best fit for workflow needs

### 18.3 Multi-Tool Integration
- Consider using multiple AI models and tools based on their specific strengths
- Select appropriate AI tools based on their framework support capabilities 
- Use a hybrid learning approach that accelerates learning while developing coding skills
- Leverage AI tools for accelerated learning without relying solely on them
- Framework-specific tool selection is crucial for optimal productivity
- Maintain alternative development approaches when using AI tools
- Integrate AI-assisted development into existing workflows for seamless operation

## 19. Enhanced Workflow Optimization

### 19.1 Task-Driven Development Process
- Structure development tasks with clear "TASK:" prefix:
  ```
  TASK: [Concise description of what needs to be implemented]
  
  [Detailed explanation including context, requirements, and any specific constraints]
  ```
- Ideal TASK workflow sequence:
  1. Agent searches relevant files to understand task context
  2. Agent writes summary into scratchpad.md and awaits review
  3. Upon approval, agent creates Git branch with feature name
  4. Agent works through tasks methodically, updating scratchpad
  5. Agent updates documentation with changes when complete
- Use consistent task formatting for better agent understanding
- Include file references and contextual information for complex tasks
- Specify requirements clearly with acceptance criteria when possible

### 19.2 Pre-Implementation Cleanup Strategy
- Clean up legacy code before new feature implementation:
  ```
  "Can you please review this file against our latest code and documentation standards, and update it accordingly before we begin work on a new feature."
  ```
- Consider temporarily disabling "Iterate on Lints" when initially working with:
  - Older files with many existing issues
  - Legacy code that doesn't follow current standards
  - Very large files (>1000 lines)
- Re-enable "Iterate on Lints" after initial cleanup for better ongoing standards compliance
- This approach prevents agents from getting stuck in lint-fixing loops and forgetting the primary task

### 19.3 Multi-Session Development
- For complex projects, split work across multiple sessions:
  - Use Chat mode for planning and architecture decisions
  - Switch to Agent mode for implementation
  - Return to Chat for quick fixes and refinements
- Use switching between reasoning models and implementation models:
  - Reasoning models (r1, o3) for planning in Chat mode
  - Implementation models for coding in Agent mode
- Consider Cursor's "auto-select" mode to optimize model selection
- Create clear boundaries between planning and implementation phases
- Document decisions made in each phase for consistent implementation

### 19.4 @ Command Optimization
- Enhance contextual understanding with @ commands:
  - Use @url to include API documentation
  - Include documentation references with @filename
  - Reference web resources with @Web
  - Reference library documentation with @LibraryName
- Use these commands strategically to provide:
  - Implementation guidelines
  - Security best practices
  - API usage examples
  - Design patterns

### 19.5 MCP Server Integration Workflow
- Implement proper MCP server usage workflow:
  1. Identify task requirements that would benefit from specialized MCP capability
  2. Select appropriate MCP server (Sequential Thinking, BrowserTools, etc.)
  3. Install and configure server with proper permissions
  4. Guide agent to utilize server for specific sub-tasks
  5. Review server outputs for quality and correctness
- Example server installation command:
  ```bash
  npm install -g sequential-thinking
  npx sequential-thinking
  ```
- Monitor MCP server calls during agent operation
- Review generated thought processes for complex tasks
- Verify implementation plans before allowing full execution

### 19.6 Advanced Debugging Collaboration
- Implement structured debug requests for more accurate AI assistance:
  ```
  DEBUG REQUEST:
  Code location: [file name and line numbers]
  Observed behavior: [what's happening]
  Expected behavior: [what should happen]
  Error message: [exact error text if applicable]
  Recent changes: [what changed recently that might be related]
  ```
- Follow a systematic debugging collaboration process:
  1. Isolate problematic code section
  2. Ask agent to explain code behavior line by line
  3. Request potential fixes for each hypothesis
  4. Test fixes incrementally
  5. Document root cause and solution
- Avoid immediate code fixes - analyze root causes collaboratively
- Consider multiple potential causes rather than fixating on a single hypothesis

## 20. Improved Documentation Practices

### 20.1 Structured Scratchpad Usage
- Create a structured scratchpad.md file with clear sections:
  ```markdown
  current_task: "Brief task description"
  status: in-progress|complete
  description: Detailed description of what needs to be done
  
  steps:
  [ ] Step 1 to complete the task
  [ ] Step 2 to complete the task
  [X] Completed step 3
  
  reflections:
  - Important observations about the implementation
  - Challenges encountered and how they were solved
  
  decisions:
  - Implementation decisions made and their rationale
  - Technical choices and their justifications
  ```
- Include scratchpad.md in .cursorignore but not in .gitignore:
  ```
  # .cursorignore
  vendor/
  node_modules/
  languages/
  build/
  !.cursor/scratchpad.md
  ```
- Use the scratchpad as a task progress tracker for long-running or complex tasks
- Review and approve the scratchpad plan before allowing agent to proceed with implementation
- Check scratchpad periodically during implementation to monitor progress

### 20.2 Implementation Documentation
- Request comprehensive documentation as part of implementation:
  - Update memory.md with detailed implementation notes
  - Generate changelog entries following project format
  - Update readme.txt with feature summaries
  - Create user-facing documentation when applicable
- Establish clear documentation requirements in task descriptions
- Review documentation quality as part of the acceptance process
- Ensure cross-referencing between related documentation elements

### 20.3 Instructions.md Management
- Create and maintain an instructions.md file in project root:
  - Document project standards and conventions
  - Define preferred implementation patterns
  - Outline security requirements
  - Specify documentation formats
- Reference instructions.md in agent interactions:
  ```
  Please refer to @instructions.md for our coding standards before implementing this feature.
  ```
- Update instructions.md regularly as project evolves
- Use instructions.md as foundation for more specific .cursorrules files

## 21. Productivity Enhancement Strategies

### 21.1 Output Optimization
- While AI generates 90-95% of code, human oversight remains essential:
  - Configure tools properly for optimal output
  - Review generated code thoroughly
  - Ask clarifying questions to guide implementation
  - Provide precise feedback for improvement
- Recognize that AI assistance increases output without reducing work:
  - More features can be implemented in same timeframe
  - Previously declined small requests become feasible
  - Internal tools can be more readily open-sourced
  - Documentation quality and completeness improves
- Focus on high-value human contributions:
  - Architecture decisions
  - Security review
  - User experience optimization
  - Business logic verification

### 21.2 Staying Current with AI Developments
- Monitor resources for latest AI development practices:
  - Cursor changelog for new features
  - r/cursor on Reddit for tips and best practices
  - YouTube tutorials for workflow optimization
  - cursor.directory for MCP servers and resources
- Implement continuous workflow improvement:
  - Test new features as they're released
  - Experiment with pre-release versions when available
  - Document successful patterns for team sharing
  - Update processes to leverage new capabilities

### 21.3 IDE Feature Optimization
- Leverage Cursor's core features effectively:
  - Smart Autocomplete for context-aware suggestions
  - Cursor Prediction for anticipating needed code
  - Smart Rewrites for error correction
  - Multi-line Editing for efficient changes
  - Code Generation based on contextual patterns
- Use AI chat features strategically:
  - Direct code interaction for specific questions
  - Codebase-wide queries with Ctrl+Enter
  - Specific code references with @ symbol
  - Web search integration with @Web command
  - Documentation access with @Docs command

## 22. Autonomous Agent Interaction Patterns

### 22.1 Shifting Mental Models
- Stop treating Cursor as just an IDE or search tool
- View Cursor as an autonomous agent that can be programmed
- Focus on teaching patterns rather than requesting specific implementations
- Build trust in the process while maintaining appropriate oversight
- Accept that internal implementations may evolve rapidly
- Understand that current models are at ~45% accuracy and need steering

### 22.2 Communication Style
- Avoid unnecessary pleasantries ("please" and "can you")
- Be direct and specific in instructions
- Use strong correction when needed (it's okay to be stern)
- Focus on clear, actionable feedback
- Cite specific requirements when corrections are needed
- Maintain professional but efficient communication
- Don't treat the AI as a conversation partner

### 22.3 Specification-First Approach
- Start with comprehensive specifications
- Have detailed discussions about requirements
- List requirements in numbered bullet points
- Store specifications in organized markdown files
- Allow the AI to help draft and refine specifications
- Focus on what needs to be done rather than how
- Trust the process while maintaining oversight

### 22.4 Steering and Intervention
When to intervene:
1. When the AI strays from specifications
2. When quality standards aren't met
3. When unwanted patterns emerge
4. When security concerns arise
5. When performance issues occur

How to intervene:
1. Stop the current process
2. Clear context if needed
3. Provide clear correction
4. Create rules to prevent recurrence
5. Restart with the loopback workflow

### 22.5 Teaching the Agent
- Create rules from successful patterns
- Document learnings and improvements
- Build up abstraction levels incrementally
- Use compiler errors as teaching tools
- Implement feedback loops for continuous improvement
- Have the agent write and update its own rules
- Focus on solving classes of problems
- Think of each interaction as a teaching opportunity

### 22.6 Multi-Agent Oversight
- Monitor multiple agent instances
- Maintain clear boundaries between domains
- Review integration points carefully
- Watch for resource constraints
- Manage screen space effectively
- Track agent performance and accuracy
- Implement automated validation
- Create rules for conflict resolution

### 22.7 Quality Control
- Review generated code thoroughly
- Verify test coverage and quality
- Check security implications
- Monitor performance metrics
- Validate cross-platform compatibility
- Ensure documentation completeness
- Verify specification compliance
- Track and analyze failure patterns

### 22.8 Building Trust
- Start with small, well-defined tasks
- Gradually increase complexity
- Document successful outcomes
- Share patterns with team members
- Build confidence through validation
- Maintain appropriate oversight
- Create clear boundaries and rules
- Establish trust verification processes

## 23. Advanced HiL Patterns

### 23.1 Specification Management
- Create clear, detailed specifications
- Organize specs by domain
- Maintain central documentation
- Allow AI input on specifications
- Review and refine regularly
- Track specification changes
- Validate implementation compliance
- Update based on learnings

### 23.2 Feedback Loop Management
- Monitor compiler errors
- Review test results
- Check static analysis output
- Verify security scans
- Track performance metrics
- Analyze quality indicators
- Update rules based on feedback
- Document successful patterns

### 23.3 Resource Optimization
- Manage screen space effectively
- Monitor system resources
- Track agent performance
- Optimize context usage
- Manage multiple instances
- Balance parallel operations
- Consider hardware limitations
- Plan for scaling needs

### 23.4 Team Integration
- Document interaction patterns
- Share successful approaches
- Create training materials
- Establish clear guidelines
- Monitor team effectiveness
- Build trust in the process
- Address concerns promptly
- Maintain consistent standards

### 23.5 Future Considerations
- Plan for increased automation
- Consider bootstrapping capabilities
- Monitor industry developments
- Evaluate new tools and approaches
- Prepare for scaling operations
- Document emerging patterns
- Build toward higher abstraction
- Maintain flexibility for change

## 24. Advanced Agent Interaction Patterns

### 24.1 Cognitive Load Management
- Implement strategies to optimize human cognitive load:
  - Create clear task boundaries
  - Use structured interaction patterns
  - Implement regular review checkpoints
  - Document decision points clearly
- Monitor cognitive load indicators:
  - Track decision fatigue patterns
  - Identify high-load activities
  - Implement load reduction strategies
  - Document load management techniques

### 24.2 Interaction Flow Optimization
- Design optimal interaction patterns:
  ```markdown
  interaction_flow:
    preparation:
      - Review context and requirements
      - Set clear objectives
      - Define success criteria
      - Establish checkpoints
    execution:
      - Follow structured workflow
      - Monitor progress actively
      - Document key decisions
      - Track deviations
    review:
      - Evaluate outcomes
      - Document learnings
      - Update patterns
      - Plan improvements
  ```
- Implement flow optimization:
  - Create clear interaction scripts
  - Define standard responses
  - Document common patterns
  - Optimize for efficiency

### 24.3 Decision Point Management
- Create structured decision frameworks:
  - Define clear decision criteria
  - Implement decision trees
  - Document decision rationale
  - Track decision outcomes
- Optimize decision processes:
  - Create decision templates
  - Implement fast paths
  - Document edge cases
  - Build decision history

### 24.4 Context Switching Optimization
- Implement effective context switching:
  - Create context snapshots
  - Define switch triggers
  - Document switch procedures
  - Track switch impact
- Optimize switching patterns:
  - Minimize switch frequency
  - Create switch checklists
  - Document context dependencies
  - Monitor switch overhead

### 24.5 Feedback Loop Enhancement
- Implement sophisticated feedback systems:
  - Create structured feedback channels
  - Define feedback categories
  - Track feedback patterns
  - Measure feedback impact
- Optimize feedback processes:
  - Implement real-time feedback
  - Create feedback templates
  - Document feedback history
  - Analyze feedback trends

### 24.6 Error Prevention and Recovery
- Implement proactive error prevention:
  - Create error pattern database
  - Define prevention strategies
  - Document common pitfalls
  - Track prevention success
- Optimize recovery procedures:
  - Create recovery playbooks
  - Define escalation paths
  - Document recovery steps
  - Measure recovery time

### 24.7 Performance Optimization
- Implement performance tracking:
  ```php
  class HiLPerformanceTracker {
    private $metrics = [];
    
    public function track_interaction($type, $data) {
      $this->metrics[] = [
        'type' => $type,
        'data' => $data,
        'timestamp' => microtime(true),
        'context' => $this->get_interaction_context()
      ];
    }
    
    public function analyze_performance() {
      return [
        'interaction_patterns' => $this->analyze_patterns(),
        'decision_efficiency' => $this->calculate_decision_metrics(),
        'error_prevention' => $this->measure_prevention_success(),
        'recovery_effectiveness' => $this->evaluate_recovery_metrics()
      ];
    }
  }
  ```

### 24.8 Continuous Improvement
- Implement improvement strategies:
  - Create improvement backlog
  - Define priority criteria
  - Track improvement impact
  - Document success patterns
- Optimize improvement process:
  - Regular pattern review
  - Update best practices
  - Document learnings
  - Share improvements

## 25. UcF Departmental Cursor Workflows

### 25.1 U1-Administration Workflows
- Cursor templates for trust documentation:
  - Standard headers with department identifiers
  - Automated formatting for financial documents
  - Template validation for compliance
- Financial planning assistance workflows:
  - Budget document generation
  - Financial report formatting
  - Audit trail documentation
- Strategic documentation templates:
  - Vision and mission statements
  - Strategic planning documents
  - Policy documentation

### 25.2 U2-Research Workflows
- AI agent role definition templates:
  - Agent capability specifications
  - Interaction protocol documentation
  - Performance metric tracking
- tYFeAiz-Cursor integration patterns:
  - Multi-agent session configuration
  - Agent handoff protocols
  - Session logging and analysis
- Research documentation frameworks:
  - Experiment documentation
  - Results analysis templates
  - Innovation tracking

### 25.3 U3-Operations Workflows
- Facility management templates:
  - Maintenance schedule documentation
  - Resource allocation tracking
  - Equipment inventory management
- Physical operations documentation:
  - Standard operating procedures
  - Safety protocol documentation
  - Emergency response procedures
- Infrastructure planning tools:
  - Capacity planning documentation
  - Resource utilization tracking
  - Growth projection analysis

### 25.4 U4-Production Workflows
- WordPress development templates:
  - Theme development workflows
  - Plugin customization patterns
  - Content management templates
- UcWebZ integration tools:
  - Cross-platform testing scripts
  - Integration validation tools
  - Performance monitoring templates
- Content production frameworks:
  - Content strategy documentation
  - Editorial workflow templates
  - Quality assurance checklists

### 25.5 U5-Data Workflows
- DMMS integration templates:
  - Memory file management
  - Synchronization protocols
  - Data validation procedures
- Service management tools:
  - Service level documentation
  - Performance metric tracking
  - Incident response templates
- Success tracking frameworks:
  - KPI documentation templates
  - Success metric analysis
  - Improvement tracking tools

### 25.6 U6-Marketing Workflows
- Social media management templates:
  - Campaign documentation
  - Content calendar management
  - Analytics tracking
- Communication frameworks:
  - Brand voice guidelines
  - Message templates
  - Style guide enforcement
- Design documentation tools:
  - Design system documentation
  - Asset management templates
  - Brand consistency checking

### 25.7 U7-Systems Workflows
- Development workflow templates:
  - Code review checklists
  - Architecture documentation
  - System integration guides
- Technical direction tools:
  - Technology stack documentation
  - Best practices enforcement
  - Standards compliance checking
- Design system integration:
  - Component documentation
  - Pattern library management
  - Design token validation

## 26. Platform-Specific Cursor Implementation

### 26.1 WordPress (cFish.io) Integration
- Theme development workflows:
  - Custom theme templates
  - Child theme patterns
  - Theme customization tools
- Plugin customization patterns:
  - Plugin development templates
  - Integration testing tools
  - Security validation scripts
- Content generation templates:
  - Custom post type definitions
  - Taxonomy management
  - Meta field documentation

### 26.2 ClickUp (cFish.App) Integration
- Task documentation automation:
  - Task template generation
  - Workflow documentation
  - Process mapping tools
- Workflow script generation:
  - Automation script templates
  - Integration testing tools
  - Error handling patterns
- Integration testing procedures:
  - API integration testing
  - Data sync validation
  - Performance monitoring

### 26.3 Notion (U.cFish.io) Integration
- Knowledge base organization:
  - Documentation structure templates
  - Cross-reference management
  - Version control patterns
- Documentation workflows:
  - Content creation templates
  - Review process automation
  - Update tracking tools
- Integration patterns:
  - API integration templates
  - Data synchronization tools
  - Content validation scripts

### 26.4 Vendasta (cFish.Vip) Integration
- Client solution templates:
  - Solution documentation
  - Implementation guides
  - Support documentation
- CRM integration patterns:
  - Data mapping templates
  - Integration testing tools
  - Sync validation scripts
- Marketing automation:
  - Campaign templates
  - Analytics tracking
  - Performance reporting

## 27. DMMS-Cursor Integration

### 27.1 Memory File Management
- Using Cursor to update memory.md files:
  ```markdown
  ## [Title] (MM-DD-2025)
  - [Bullet points with key information]
  - [More bullet points as needed]
  
  _Updated MM-DD-2025 | AI: Cursor (Claude 3.7 Sonnet)_
  ```
- Automated version tracking in file headers:
  - Version number management
  - Change tracking
  - Author attribution
- Cross-reference validation procedures:
  - Link checking
  - Reference validation
  - Consistency verification

### 27.2 Synchronization Operations
- Cursor-assisted sync verification:
  - Pre-sync validation
  - Post-sync checking
  - Error detection
- Error detection and resolution workflows:
  - Error pattern recognition
  - Resolution procedures
  - Prevention strategies
- Performance optimization patterns:
  - Sync operation timing
  - Resource usage monitoring
  - Optimization techniques

## 28. Relaunch-Focused HiL Strategies

### 28.1 Knowledge Monetization Acceleration
- Documentation template development:
  - Professional templates
  - Client-specific customization
  - Quality metrics
- Client-ready material generation:
  - Proposal templates
  - Case study formats
  - ROI calculators
- Knowledge product workflows:
  - Product definition templates
  - Delivery process documentation
  - Quality assurance procedures

### 28.2 Cross-Platform Integration
- Platform synchronization testing:
  - Integration test suites
  - Performance benchmarks
  - Error handling procedures
- Integration verification procedures:
  - Data consistency checks
  - User flow validation
  - Security verification
- Client demonstration script generation:
  - Demo templates
  - Feature showcases
  - ROI presentations

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## 29. Performance Management

### 29.1 Performance Monitoring
- Monitor Cursor performance metrics:
  - CPU usage through Task Manager
  - Number of Cursor-related processes
  - Memory consumption patterns
  - Response time for operations
- Establish baseline performance metrics:
  - 1-2% idle CPU usage
  - 5-8 subprocesses
  - Normal operation response times
  - Expected memory footprint

### 29.2 Token Usage Optimization
- Implement token monitoring tools:
  ```javascript
  const tokenCounter = require('./.cursor/performance-tools/token-counter');
  const tokenLogger = require('./.cursor/performance-tools/token-logger');
  
  // Track session token usage
  tokenLogger.startSession({
    sessionType: 'feature-development',
    maxTokens: 20000,
    alertThreshold: 18000
  });
  ```
- Monitor token usage patterns:
  - Track tokens per request
  - Monitor daily token consumption
  - Set up alerts for approaching limits
  - Optimize prompts for token efficiency

### 29.3 Process Management
- Monitor subprocess proliferation:
  - Track number of active processes
  - Identify critical vs. non-critical processes
  - Implement process cleanup procedures
  - Set up automated process monitoring
- Implement performance recovery procedures:
  1. Save all work in progress
  2. Document current session state
  3. Clean up unnecessary processes
  4. Restart Cursor if needed
  5. Restore session state

## 30. WordPress-Specific Workflows

### 30.1 Theme Development
- Implement WordPress theme development patterns:
  ```php
  // Theme development template
  function register_theme_components() {
    // Register theme features
    add_theme_support('post-thumbnails');
    add_theme_support('custom-logo');
    add_theme_support('title-tag');
    
    // Register navigation menus
    register_nav_menus([
      'primary' => __('Primary Menu', 'theme-textdomain'),
      'footer' => __('Footer Menu', 'theme-textdomain')
    ]);
  }
  add_action('after_setup_theme', 'register_theme_components');
  ```
- Use Cursor for theme customization:
  - Generate template files
  - Implement responsive styles
  - Create theme options
  - Handle theme hooks

### 30.2 Plugin Development
- Follow WordPress plugin development best practices:
  ```php
  // Plugin development template
  class MyPlugin {
    private static $instance = null;
    
    public static function get_instance() {
      if (null === self::$instance) {
        self::$instance = new self();
      }
      return self::$instance;
    }
    
    private function __construct() {
      add_action('plugins_loaded', [$this, 'init']);
    }
    
    public function init() {
      // Initialize plugin
      $this->load_dependencies();
      $this->setup_hooks();
    }
  }
  
  MyPlugin::get_instance();
  ```
- Implement plugin security measures:
  - Nonce verification
  - Capability checks
  - Data sanitization
  - Error handling

### 30.3 Custom Block Development
- Create custom Gutenberg blocks:
  ```javascript
  // Block registration template
  registerBlockType('namespace/block-name', {
    title: 'Block Title',
    icon: 'smiley',
    category: 'common',
    attributes: {
      content: {
        type: 'string',
        source: 'html',
        selector: 'p',
      },
    },
    edit: (props) => {
      // Editor interface
    },
    save: (props) => {
      // Saved content
    },
  });
  ```
- Implement block features:
  - Custom controls
  - Dynamic rendering
  - Block styles
  - Block variations

## 31. Token Optimization Strategies

### 31.1 Prompt Engineering
- Structure prompts for maximum efficiency:
  ```markdown
  TASK: [Specific action required]
  CONTEXT: [Minimal necessary background]
  CONSTRAINTS: [Key limitations/requirements]
  EXPECTED OUTPUT: [Clear description of desired result]
  ```
- Use consistent terminology
- Avoid redundant information
- Include only relevant context
- Structure multi-part requests efficiently

### 31.2 Context Management
- Implement context optimization:
  - Use selective file inclusion
  - Maintain context hierarchy
  - Implement context caching
  - Clear unnecessary context
- Monitor context size:
  ```javascript
  const contextManager = {
    trackContextSize(context) {
      const size = new TextEncoder().encode(JSON.stringify(context)).length;
      return {
        bytes: size,
        tokens: Math.ceil(size / 4),  // Approximate token count
        withinLimit: size < 20000 * 4  // 20k token limit
      };
    }
  };
  ```

### 31.3 Session Management
- Implement session optimization:
  - Regular context cleanup
  - Session state persistence
  - Efficient handoffs between agents
  - Resource usage monitoring
- Track session metrics:
  - Token consumption rate
  - Response time patterns
  - Error frequency
  - Context size evolution

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_

## 32. Development and Deployment Workflow

### 32.1 Session Management Protocol
- Create new chat/agent session for each:
  - Feature completion
  - Step completion
  - Memory file updates
  - Changelog updates
- End each session with:
  ```javascript
  // Console logging for session completion
  console.log('[Session] Initiating session completion protocol');
  
  // Update workbench files
  console.log('[Workbench] Updating workbench files');
  updateWorkbenchFiles();
  
  // Update memory files
  console.log('[Memory] Updating memory files');
  updateMemoryFiles();
  
  // Generate session summary
  const sessionSummary = {
    completed: [],
    challenges: [],
    successes: [],
    nextSteps: []
  };
  console.log('[Summary] Generated:', JSON.stringify(sessionSummary, null, 2));
  ```

### 32.2 Deployment Strategy
- Deploy application from initial development:
  ```javascript
  // Console logging for initial deployment
  console.log('[Deploy] Starting initial deployment');
  console.log('[Deploy] Environment:', process.env.NODE_ENV);
  console.log('[Deploy] Configuration:', config);
  ```
- Re-deploy after each:
  - Feature completion
  - Library addition
  - Major step completion
- Test production environment after each deployment:
  ```javascript
  // Console logging for production testing
  console.log('[Test] Starting production environment tests');
  console.log('[Test] Target URL:', process.env.PRODUCTION_URL);
  console.log('[Test] Test suite:', currentTests);
  ```

### 32.3 Mobile-First Development
- Prioritize mobile optimization:
  ```javascript
  // Console logging for mobile optimization
  console.log('[Mobile] Starting mobile-first implementation');
  console.log('[Mobile] Target breakpoints:', breakpoints);
  console.log('[Mobile] Base font size:', baseFontSize);
  ```
- Implement responsive design patterns:
  ```javascript
  // Console logging for responsive implementation
  const logResponsiveImplementation = (component) => {
    console.log('[Responsive] Implementing component:', component);
    console.log('[Responsive] Breakpoints:', component.breakpoints);
    console.log('[Responsive] Layout strategy:', component.layout);
  };
  ```
- Test across device sizes:
  ```javascript
  // Console logging for device testing
  const logDeviceTesting = (device) => {
    console.log('[Device] Testing on device:', device);
    console.log('[Device] Screen size:', device.screenSize);
    console.log('[Device] Pixel ratio:', device.pixelRatio);
  };
  ```

### 32.4 Library Management
- Verify library criteria:
  ```javascript
  // Console logging for library verification
  const verifyLibrary = (library) => {
    console.log('[Library] Verifying library:', library.name);
    console.log('[Library] Version:', library.version);
    console.log('[Library] Last update:', library.lastUpdate);
    console.log('[Library] Download count:', library.downloads);
    console.log('[Library] GitHub stars:', library.stars);
  };
  ```
- Track library updates:
  ```javascript
  // Console logging for library updates
  const trackLibraryUpdates = () => {
    console.log('[Libraries] Checking for updates');
    dependencies.forEach(dep => {
      console.log('[Library] Checking:', dep.name);
      console.log('[Library] Current version:', dep.version);
      console.log('[Library] Latest version:', dep.latestVersion);
    });
  };
  ```

### 32.5 Documentation Updates
- Update documentation after each session:
  ```javascript
  // Console logging for documentation updates
  const updateDocs = (changes) => {
    console.log('[Docs] Starting documentation update');
    console.log('[Docs] Changes:', changes);
    changes.forEach(change => {
      console.log('[Docs] Updating:', change.file);
      console.log('[Docs] Type:', change.type);
      console.log('[Docs] Content:', change.content);
    });
  };
  ```
- Generate session summaries:
  ```javascript
  // Console logging for summary generation
  const generateSummary = (session) => {
    console.log('[Summary] Generating session summary');
    console.log('[Summary] Duration:', session.duration);
    console.log('[Summary] Completed tasks:', session.completed);
    console.log('[Summary] Next steps:', session.nextSteps);
    
    return {
      timestamp: new Date().toISOString(),
      duration: session.duration,
      completed: session.completed,
      challenges: session.challenges,
      successes: session.successes,
      nextSteps: session.nextSteps
    };
  };
  ```
