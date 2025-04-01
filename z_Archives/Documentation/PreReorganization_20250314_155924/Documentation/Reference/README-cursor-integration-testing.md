# Testing the Cursor Integration After Restart

This document provides step-by-step instructions for testing the MD-JSON sync system integration with Cursor IDE after restarting your computer.

## Expected Behavior

When Cursor IDE is launched, the MD-JSON sync system should:
1. Start automatically (via the scheduled task)
2. Create a `.cursor-running` flag file in the project directory
3. Begin monitoring changes to Markdown and JSON files
4. Perform bidirectional synchronization between these file formats

## Testing Procedure

### Step 1: Verify Automatic Startup
1. Restart your computer
2. Launch Cursor IDE
3. Open your project (`C:\Users\Chris\cFish.io`)
4. Wait approximately 10-15 seconds for the sync system to initialize
5. Check if the `.cursor-running` flag file exists in your project directory:
   ```powershell
   if (Test-Path .cursor-running) { "Integration is active!" } else { "Integration is NOT active" }
   ```

### Step 2: Test Markdown to JSON Synchronization
1. Open or create a test Markdown file (e.g., `test-sync.md`)
2. Add some content or modify existing content
3. Save the file
4. Check if the corresponding JSON file (e.g., `json/test-sync.json`) is created or updated

### Step 3: Test JSON to Markdown Synchronization
1. Open or create a test JSON file (e.g., `json/test-json-to-md.json`)
2. Add or modify content in valid JSON format
3. Save the file
4. Check if the corresponding Markdown file (e.g., `test-json-to-md.md`) is created or updated

### Step 4: Verify Clean Shutdown
1. Close Cursor IDE
2. Check if the `.cursor-running` flag file is automatically removed
3. Verify that the Node.js process for the sync system has terminated

## Troubleshooting

If the integration doesn't activate automatically:

1. Check the Task Scheduler:
   - Open Task Scheduler (search for it in the Start menu)
   - Look for the "MD-JSON-Sync-Cursor-Integration" task
   - Check the "Last Run Result" and "History" for any errors

2. Run the script manually to verify it works:
   ```
   node cursor-md-json-enhanced.js
   ```

3. Re-run the setup script with administrative privileges:
   ```
   powershell -ExecutionPolicy Bypass -File setup-cursor-integration.ps1
   ```

4. Check all relevant logs:
   - Windows Event Viewer (Administrative Events)
   - `logs/md-json-sync.log` (if it exists)

## Confirming Success

The integration is successfully working when:
1. The `.cursor-running` flag file appears automatically when Cursor is launched
2. Changes to Markdown files are reflected in corresponding JSON files
3. Changes to JSON files are reflected in corresponding Markdown files
4. The system cleans up properly when Cursor is closed

_Created 03-12-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 