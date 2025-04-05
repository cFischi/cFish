# README: .cursor System for cFish.io

## Overview

This `.cursor` directory serves as the central configuration hub and contextual memory for the AI assistant (Cursor/Gemini) operating within the `cFish.io` workspace. Its primary purpose is to ensure the AI understands the project's specific context, adheres to UcF/Dreamflo principles and standards, maintains consistency across development sessions, and facilitates advanced workflows like multi-agent collaboration.

Think of it as the AI's "workspace brain," customized for the unique needs of cFish.io.

## Key Components

*   **`memory.md`**: The primary short-to-medium-term memory file. It's a detailed, timestamped log capturing key interactions, decisions made, code implemented, challenges encountered, system states, and immediate next steps during development sessions. *Crucial for maintaining context within and across sessions.*
*   **`UcF_logZ.md` (formerly `changelog.md`)**: The master changelog for the cFish.io project, documenting significant changes, features, and fixes, often updated in coordination with `memory.md`.
*   **`rules/`**: A subdirectory containing numerous `.mdc` (Markdown Configuration) files. These files define the specific rules, coding standards, architectural guidelines, departmental context (U1-U7), workflow procedures, relaunch priorities, and philosophical alignments (Dreamflo) that the AI must follow. This is the core of the system's customization.
    *   **`rules/prompt-templates/`**: Stores standardized prompts for specific tasks or agent roles (e.g., tYFeAiz Live Boardz).
*   **`patterns/`**: Intended location for storing reusable code patterns or standardized solutions (may require development).
*   **`.cursorrules` / `.cursorrules-client`**: Configuration files that specify which rules in the `rules/` directory should be applied globally or based on specific file patterns or conditions. Manages rule priority and application scope.
*   **`scratchpad.md`**: A temporary file for quick notes, code snippets, or task tracking during an active session. More ephemeral than `memory.md`.
*   **Supporting Files/Dirs (Examples)**: `implementation-log.md`, `testing-plan.md`, `agent-configs/`, `config/`, `scripts/` – These indicate a broader ecosystem of tools and documentation managed alongside the core `.cursor` configuration, supporting complex implementation and tracking.

## How it Works

When interacting with the AI assistant within this workspace, Cursor automatically loads the relevant rules specified in `.cursorrules` and potentially references the content within `memory.md` and other specified files to inform its responses and actions. This allows the AI to:

1.  **Maintain Context:** Remember previous decisions, code changes, and project goals.
2.  **Follow Standards:** Adhere to specific coding styles, documentation formats (like memory/changelog updates), and architectural patterns defined in the rules.
3.  **Align with UcF/Dreamflo:** Operate within the defined departmental structure and philosophical framework.
4.  **Execute Specialized Tasks:** Use prompt templates and role definitions for consistent execution of complex workflows (like multi-agent collaboration).

## Strengths & Potential (Leverage These)

1.  **Contextual Consistency:** Enables the AI to retain deep, project-specific knowledge across sessions, leading to more relevant and aligned assistance. *Keep rules and memory updated.*
2.  **Customization & Control:** Provides fine-grained control over AI behavior through the extensive rules system. *Refine and expand rules as the project evolves.*
3.  **Knowledge Codification:** Acts as living documentation for AI interaction protocols and project standards. *Treat `.cursor` as a critical documented system.*
4.  **Workflow Automation Foundation:** Provides the contextual basis for integrating AI with scripts (like Git shortcuts) to automate tasks. *Explore cautiously once system stability is confirmed.*
5.  **Multi-Agent Framework:** The defined rules and templates provide a solid foundation for the tYFeAiz Live Boardz concept. *Continue building agent templates and interaction protocols.*

## Weaknesses & Challenges (Mitigate These)

1.  **CRITICAL: System Stability Sensitivity:** **Currently the biggest challenge.** Complex automated tasks (especially heavy file I/O or script execution) triggered via Cursor/terminal tools have repeatedly caused severe instability (Cursor/Windows crashes) on the primary development machine. **AVOID complex automation triggered via Cursor for now. Prioritize manual steps or external scripts until the root cause is resolved.**
2.  **Complexity Management:** The large number of rules and extensive memory files require diligent management to ensure relevance, consistency, and prevent conflicts. *Implement regular reviews and pruning/archiving.*
3.  **Configuration Errors:** Errors in `.cursorrules`, rule files (`.mdc`), or related configurations (like `keybindings.json`) can silently break AI functionality. *Implement validation or testing where possible.*
4.  **Manual Upkeep:** Maintaining the accuracy and detail of `memory.md` and `UcF_logZ.md` requires consistent effort during interactions. *Integrate updates into your core workflow.*
5.  **Potential for "Over-Instruction":** Too many rigid or conflicting rules might hinder AI performance. *Focus on clear principles, allowing flexibility.*
6.  **Synchronization:** Ensuring the `.cursor` directory is perfectly synchronized across multiple machines requires a robust workflow (like the implemented Git shortcuts) and careful conflict resolution.

## Management & Best Practices

*   **Update Memory Consistently:** Regularly update `memory.md` during sessions with key decisions, actions, and next steps.
*   **Maintain Changelog:** Update `UcF_logZ.md` with significant versioned changes.
*   **Rule Management:**
    *   Keep rules focused and modular.
    *   Use the `meta-rule.mdc` principles for creating/updating rules.
    *   Regularly review rules for relevance and potential conflicts.
    *   Use `.cursorrules` to manage priorities effectively.
*   **Pruning/Archiving:** Periodically review `memory.md` and `UcF_logZ.md`. Consider archiving older sections to keep the active files manageable, while preserving history elsewhere.
*   **Stability First:** Prioritize system stability. Avoid complex automation directly triggered by Cursor until underlying issues are resolved. Test script interactions thoroughly outside of Cursor first.
*   **Backup:** Regularly back up the entire `.cursor` directory as part of your project backup strategy.

## Relationship to UcF Framework

The `.cursor` system is deeply integrated with the UcF framework:

*   **Departmental Rules:** Specific rules exist for each of the 7 UcF departments (U1-U7), tailoring AI behavior to departmental responsibilities.
*   **Dreamflo Alignment:** Rules often reference Dreamflo principles, guiding the AI towards philosophically aligned solutions.
*   **Workflow Integration:** Memory/changelog formats and update requirements align with defined UcF documentation standards.
*   **Relaunch Priorities:** Specific rules (`relaunch/`) guide the AI on tasks critical to the April 2025 relaunch.

By maintaining this directory, you ensure the AI assistant acts as a knowledgeable, consistent, and aligned partner in the cFish.io development process. 