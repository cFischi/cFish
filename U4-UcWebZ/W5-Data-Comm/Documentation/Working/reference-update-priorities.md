# Reference Update Priorities

## Overview
This document provides a prioritized list of references that need to be updated as part of the documentation reorganization process. It organizes references by priority level to ensure the most critical references are updated first.

## Priority Levels

| Priority | Description | Timeline | Risk |
|----------|-------------|----------|------|
| High | Critical references in core system files | Immediate (Day 2) | Broken links could disrupt system functionality |
| Medium | Important references in operational tools | Day 2 (after High priority) | May cause minor disruptions if not updated |
| Low | Historical or archived references | Day 2-3 (after Medium priority) | Minimal impact if not updated immediately |

## High Priority References

### 1. README Reference in memory.md
- **Source File**: memory.md
- **Line Number**: 33
- **Current Reference**: docs/digital-organization-system-README.md
- **New Reference**: U5-Data/Documentation/ucf-u5.1-digital-organization-system-README-20250315.md
- **Context**: "Updated README to reflect current date (March 15, 2025) and fixed documentation references"
- **Update Command**: `.\\U5-Data\\Documentation\\Tools\\update-document-references-simple.bat -UpdateReferences -PriorityLevel High`
- **Verification**: Confirm updated reference in memory.md line 33

## Medium Priority References

### 1. README Reference in SOP Monitoring Reference
- **Source File**: U7-Systems/Tools/ucf-u7.3-sop-monitoring-reference-20250314.md
- **Line Number**: 8
- **Current Reference**: docs/digital-organization-system-README.md
- **New Reference**: U5-Data/Documentation/ucf-u5.1-digital-organization-system-README-20250315.md
- **Context**: "Key System File: Digital Organization System README"
- **Update Command**: `.\\U5-Data\\Documentation\\Tools\\update-document-references-simple.bat -UpdateReferences -PriorityLevel Medium`
- **Verification**: Confirm updated reference in SOP Monitoring Reference line 8

### 2. README Reference in Critical Files Exception Implementation
- **Source File**: Documentation/Implementation/ucf-u5.1-critical-files-exception-implementation-20250420.md
- **Line Number**: 40
- **Current Reference**: docs/digital-organization-system-README.md
- **New Reference**: U5-Data/Documentation/ucf-u5.1-digital-organization-system-README-20250315.md
- **Context**: "Add ExemptedFilePatterns to docs/digital-organization-system-README.md"
- **Update Command**: `.\\U5-Data\\Documentation\\Tools\\update-document-references-simple.bat -UpdateReferences -PriorityLevel Medium`
- **Verification**: Confirm updated reference in Critical Files Exception Implementation line 40

## Low Priority References

### 1. README Reference in Archived Critical Files Exception Implementation
- **Source File**: _Archives/Documentation/PreReorganization_20250314_155924/Documentation/Implementation/ucf-u5.1-critical-files-exception-implementation-20250420.md
- **Line Number**: 40
- **Current Reference**: docs/digital-organization-system-README.md
- **New Reference**: U5-Data/Documentation/ucf-u5.1-digital-organization-system-README-20250315.md
- **Context**: "Add ExemptedFilePatterns to docs/digital-organization-system-README.md"
- **Update Command**: `.\\U5-Data\\Documentation\\Tools\\update-document-references-simple.bat -UpdateReferences -PriorityLevel Low`
- **Verification**: Confirm updated reference in Archived Critical Files Exception Implementation line 40

## Symbolic Link Creation

To maintain backward compatibility during the transition period, symbolic links will be created for all moved files:

```powershell
# High Priority Symbolic Links
New-Item -ItemType SymbolicLink -Path "docs/digital-organization-system-README.md" -Target "U5-Data/Documentation/ucf-u5.1-digital-organization-system-README-20250315.md"

# Medium Priority Symbolic Links  
New-Item -ItemType SymbolicLink -Path "U5-Data/Documentation/ucf-u5.1-implementation-summary-20250315.md" -Target "U5-Data/Documentation/ucf-u5.1-implementation-summary-20250315.md"

# Low Priority Symbolic Links
New-Item -ItemType SymbolicLink -Path "U4-Production/Documentation/WordPress/ucf-u4.2-wp-setup-guide-20250315.md" -Target "U4-Production/Documentation/WordPress/ucf-u4.2-wp-setup-guide-20250315.md"
```

## Reference Removal Timeline

Symbolic links should remain in place for at least 30 days after the documentation reorganization is complete. After this period, they can be phased out with appropriate communication to all system users.

## Verification Process

After updating each priority level, the following verification steps should be performed:

1. Run document reference analysis tool to confirm references have been updated
2. Manually verify critical references to ensure proper formatting
3. Test any scripts or tools that depend on the updated references
4. Document all changes in the update log

_Updated 03-15-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 