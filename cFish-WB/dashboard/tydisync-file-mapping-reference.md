# tYDiSync~ File Renaming Reference

This document serves as a reference for the file renaming that occurred during the tYDiSync~ rebranding project. It maps the old `md-json-sync` filenames to their new `tydisync` equivalents to help with transitioning and maintaining backward compatibility.

## File Mapping Reference

| Old Filename | New Filename | Status |
|--------------|--------------|--------|
| md-json-sync-status-report.md | tydisync-status-report.md | ✅ Renamed |
| md-json-sync-debug.log | tydisync-debug.log | ✅ Renamed |
| md-json-sync-low-cpu-reference.md | tydisync-low-cpu-reference.md | ✅ Renamed |
| md-json-sync-implementation-verification.md | tydisync-implementation-verification.md | ✅ Renamed |
| md-json-sync-system-summary.md | tydisync-system-summary.md | ✅ Renamed |
| md-json-sync-testing-findings.md | tydisync-testing-findings.md | ✅ Renamed |
| md-json-sync-next-steps.md | tydisync-next-steps.md | ✅ Renamed |
| README-md-json-sync.md | README-tydisync.md | ✅ Renamed |
| md-json-sync-quick-reference.md | tydisync-quick-reference.md | ✅ Renamed |
| start-md-json-sync-silent.vbs | start-tydisync-silent.vbs | ✅ Renamed |
| docs/md-json-sync-testing-findings.md | docs/tydisync-testing-findings.md | ✅ Renamed |
| docs/md-json-sync-status-report.md | docs/tydisync-status-report.md | ✅ Renamed |
| docs/md-json-sync-implementation-verification.md | docs/tydisync-implementation-verification.md | ✅ Renamed |
| docs/md-json-sync-low-cpu-reference.md | docs/tydisync-low-cpu-reference.md | ✅ Renamed |
| docs/md-json-sync-next-steps.md | docs/tydisync-next-steps.md | ✅ Renamed |
| docs/md-json-sync-improvements.md | docs/tydisync-improvements.md | ✅ Renamed |
| docs/md-json-sync-quick-reference.md | docs/tydisync-quick-reference.md | ✅ Renamed |
| docs/md-json-sync-system-summary.md | docs/tydisync-system-summary.md | ✅ Renamed |
| md-json-sync.js.backup | tydisync.js.backup | ✅ Renamed |
| md-json-sync-enhanced.js | tydisync-enhanced.js | ✅ Renamed |
| md-json-sync-improvements.md | tydisync-improvements.md | ✅ Renamed |
| sync-system/core/md-json-sync.js | sync-system/core/tydisync.js | ✅ Renamed |
| sync-system/core/optimized-md-json-sync.js | sync-system/core/optimized-tydisync.js | ✅ Renamed |
| sync-system/core/dummy-md-json-sync.js | sync-system/core/dummy-tydisync.js | ✅ Renamed |
| md-json-sync-engine.js | tydisync-engine.js | ✅ Renamed |
| md-json-sync-enhanced-README.md.lock | tydisync-enhanced-README.md.lock | ✅ Renamed |
| md-json-sync-implementation-verification.md.lock | tydisync-implementation-verification.md.lock | ✅ Renamed |
| md-json-sync-README.md.lock | tydisync-README.md.lock | ✅ Renamed |

## Implementation Files with References That Need Updating

The following files may still contain references to old filenames that need to be updated:

1. Import statements: `const sync = require('./md-json-sync.js')` → `const sync = require('./tydisync.js')`
2. File paths in configuration files
3. Log file references
4. Documentation references

## How to Use This Reference

When encountering an error related to missing files:

1. Check this reference to see if the file has been renamed
2. Update any code references to use the new filename
3. If working with an old guide or documentation, mentally substitute old filenames with their new equivalents

## Backward Compatibility

For backward compatibility, consider:

1. Creating symbolic links from old names to new files
2. Adding clear error messages when old filenames are referenced
3. Updating all documentation to use new naming

_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 