#!/bin/bash
# tYDiSync~ Watch Mode Testing for Linux/macOS
# Shell script alternative to test-tydisync-watch-mode.bat

echo "===== tYDiSync~ Watch Mode Testing ====="
echo "Running automated tests for watch mode functionality..."
echo ""

# Define log paths with cross-platform compatibility
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/tydisync-watch-test.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log start of test
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running tYDiSync~ Watch Mode Test" > "$LOG_FILE"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH."
    echo "Please install Node.js from https://nodejs.org/"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Node.js not found" >> "$LOG_FILE"
    exit 1
fi

# Run the watch mode test script
echo "Running watch mode test script..."
node test-tydisync-watch-mode.js
EXIT_CODE=$?

# Check the result
if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "Watch Mode Test: PASSED"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Watch Mode Test: PASSED" >> "$LOG_FILE"
else
    echo ""
    echo "Watch Mode Test: FAILED"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Watch Mode Test: FAILED (Code: $EXIT_CODE)" >> "$LOG_FILE"
fi

echo ""
echo "Test results have been logged to $LOG_FILE"
echo "See detailed output in ../tydisync-test/watch_output.txt"

exit $EXIT_CODE 