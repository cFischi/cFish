# cFish.io File Naming Conventions

## Metadata
- **Last Updated**: 03-13-2025
- **Purpose**: Standardize file naming across cFish.io projects
- **Target Audience**: All cFish.io team members and contributors

---

## General Principles

1. **Consistency**: Use the same naming pattern across all similar files
2. **Clarity**: Names should clearly indicate the file's purpose
3. **Searchability**: Names should be easy to find with search tools
4. **Specificity**: Names should be specific enough to avoid confusion

## Standard File Naming Format

### Primary Format
```
[CompanyPrefix]-[DeptNumber].[FunctionNumber]-[TaskIdentifier]-[Date].[extension]
```

Example: `ucf-u5.3-data-migration-20250313.js`

### Components Explained

1. **Company Prefix**: 
   - `ucf` - UcFish trust? + holdingz companY 
   - `tyf` - tYFeAiz
   - `fh` - FiscHouse
   - `ucw` - UcWebZ
   - `uz` - the UZ
   - `fe` - FischEYe
   - `ty` - tYberius Designz

2. **Department Number**:
   - `u1` - Overheads (OVR)
   - `u2` - Research & Development (R+D)
   - `u3` - Physical Operations (OPz)
   - `u4` - Production (PRO)
   - `u5` - Data Management (DMT)
   - `u6` - Social Media/Communications (SMC)
   - `u7` - Specialized Operations (SPEC)

3. **Function Number**:
   - Department-specific function identifier (1-9)
   - Example: `u5.3` - Data Management, Function 3 (Database Integration)

4. **Task Identifier**:
   - Brief, hyphen-separated description of file purpose
   - Use lowercase letters and hyphens (kebab-case)

5. **Date** (optional):
   - Format: YYYYMMDD
   - Used for version-sensitive documents

## Specific File Types

### Source Code Files
- JavaScript: `ucw-u4.2-product-api-client.js`
- PHP: `ucf-u5.1-database-connection.php`
- CSS: `fe-u7.3-main-stylesheet.css`

### Documentation
- Guides: `uz-u5.7-user-access-guide.md`
- Procedures: `fh-u3.2-inventory-procedure.md` 
- Standards: `ucf-u1.5-coding-standards.md`

### WordPress Files
- Themes: `ty-u7.1-main-theme-functions.php`
- Plugins: `ucw-u4.6-cfish-sync-admin.php`

### Configuration Files
- JSON: `tyf-u2.4-ai-agent-config.json`
- YAML: `fe-u6.2-deployment-config.yaml`

## Special Naming Cases

### Temporary Files
- Prefix with `tmp-`
- Example: `tmp-ucf-u5.3-test-data.json`

### Backup Files
- Suffix with `-bak-[date]`
- Example: `ucw-u4.2-api-client-bak-20250312.js`

### Shared Files
- Prefix with `shared-`
- Example: `shared-ucf-constants.js`

## Implementation Guidelines

1. Apply these conventions to all new files
2. When updating existing files, rename them to follow conventions
3. Update references when renaming files
4. Document any exceptions to these conventions

---

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 