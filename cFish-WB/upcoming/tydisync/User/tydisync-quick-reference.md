# MD-JSON Sync Quick Reference Guide

## Basic Commands

| Command | Description |
|---------|-------------|
| `node tydisync.js` | Run a one-time synchronization |
| `node tydisync.js --watch` | Start continuous monitoring |
| `node tydisync.js --watch --verbose` | Monitor with detailed logging |
| `node tydisync.js --force` | Force synchronization regardless of conflicts |
| `node tydisync.js --prefer-md` | Use Markdown as source of truth |
| `node tydisync.js --prefer-json` | Use JSON as source of truth |
| `node tydisync.js --config=custom-config.json` | Use custom configuration |

## Windows Batch Files

| File | Purpose |
|------|---------|
| `start-tydisync.bat` | Start with console output |
| `start-tydisync-background.bat` | Run invisibly in background |
| `add-to-startup.bat` | Add to Windows startup |

## File Exclusion

To exclude a file from synchronization, create a `.nosync` marker file:
```
touch filename.md.nosync
```

## Configuration (config.json)

```json
{
  "watchDirs": [
    { "md": "./docs", "json": "./docs/json" },
    { "md": "./shortlinks", "json": "./shortlinks/json" }
  ],
  "backupDir": "./backups",
  "maxBackups": 5,
  "enableBackups": true,
  "conflictResolutionMethod": "timestamp",
  "criticalFiles": ["memory.md"]
}
```

## Conflict Resolution Methods

| Method | Description |
|--------|-------------|
| `timestamp` | Newer file wins |
| `prefer-markdown` | Markdown file always wins |
| `prefer-json` | JSON file always wins |

## Log File

Default log location: `./logs/tydisync.log`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Synchronization loop | Check for circular references or timestamp issues |
| Missing JSON files | Ensure JSON directories exist and are writable |
| Data loss in critical files | Check `.nosync` markers and critical files list |
| Process not starting | Verify Node.js installation and file permissions |

## Agent Responsibilities

| Agent | Role |
|-------|------|
| Alpha | File monitoring |
| Beta | Content transformation |
| Gamma | Conflict resolution |
| Delta | Safety (backups, locks) |
| Epsilon | Process management |

## Testing

| Script | Purpose |
|--------|---------|
| `test-md-to-json.js` | Test Markdown to JSON conversion |
| `test-json-to-md.js` | Test JSON to Markdown conversion |