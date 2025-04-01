#!/bin/bash
# tYDiSync~ Edge Case Testing for Linux/macOS
# Shell script alternative to test-tydisync-edge-cases.bat

echo "===== tYDiSync~ Edge Case Testing ====="
echo "Running tests for edge conditions..."
echo ""

# Define log paths with cross-platform compatibility
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/tydisync-edge-test-summary.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log start of test
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running tYDiSync~ Edge Case Tests" > "$LOG_FILE"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH."
    echo "Please install Node.js from https://nodejs.org/"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Node.js not found" >> "$LOG_FILE"
    exit 1
fi

# Run the edge case test script
echo "Running edge case tests..."
node test-tydisync-edge-cases.js
EXIT_CODE=$?

# Check the result
if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "Edge Case Tests: PASSED"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Edge Case Tests: PASSED" >> "$LOG_FILE"
else
    echo ""
    echo "Edge Case Tests: FAILED"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Edge Case Tests: FAILED (Code: $EXIT_CODE)" >> "$LOG_FILE"
fi

echo ""
echo "Test results have been logged to $LOG_FILE"
echo "Detailed logs available in ../logs/tydisync-edge-test.log"

exit $EXIT_CODE 