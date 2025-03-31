#!/bin/bash
# tYDiSync~ Basic Functionality Testing for Linux/macOS
# Shell script alternative to test-tydisync-functionality.bat

echo "===== tYDiSync~ Functional Testing Script ====="
echo "Testing basic functionality after the file renaming project"
echo ""

# Define paths with cross-platform compatibility
TEST_DIR="../tydisync-test"
MD_DIR="$TEST_DIR/md"
JSON_DIR="$TEST_DIR/json"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/tydisync-test-results.log"

# Create test and log directories if they don't exist
mkdir -p "$TEST_DIR"
mkdir -p "$MD_DIR"
mkdir -p "$JSON_DIR"
mkdir -p "$LOG_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting tYDiSync~ functional tests" > "$LOG_FILE"

# Test 1: Basic Markdown to JSON Conversion
echo "=== Test 1: Basic Markdown to JSON Conversion ==="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 1: Basic Markdown to JSON Conversion" >> "$LOG_FILE"

# Create test Markdown file
echo "# Test Heading" > "$MD_DIR/test1.md"
echo "" >> "$MD_DIR/test1.md"
echo "This is a test paragraph." >> "$MD_DIR/test1.md"
echo "" >> "$MD_DIR/test1.md"
echo "- List item 1" >> "$MD_DIR/test1.md"
echo "- List item 2" >> "$MD_DIR/test1.md"

echo "Running tydisync.sh for basic conversion..."
# Check if we have a shell script version of tydisync.bat available
if [ -f "./tydisync.sh" ]; then
    bash ./tydisync.sh --convert "$MD_DIR/test1.md" --verbose
else
    # Fall back to Windows batch file if shell script not available
    echo "Warning: Using Windows batch file (tydisync.sh not found)"
    tydisync.bat --convert "$MD_DIR/test1.md" --verbose
fi
EXIT_CODE=$?

# Check both possible locations for the output file
if [ -f "$JSON_DIR/test1.json" ]; then
    echo "Test 1: PASSED - Successfully created JSON file in expected directory"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 1: PASSED - Successfully created JSON file in expected directory" >> "$LOG_FILE"
elif [ -f "$TEST_DIR/test1.json" ]; then
    echo "Test 1: PASSED - Successfully created JSON file in root test directory"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 1: PASSED - Successfully created JSON file in root test directory" >> "$LOG_FILE"
else
    echo "Test 1: FAILED - JSON file not created"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 1: FAILED - JSON file not created, exit code: $EXIT_CODE" >> "$LOG_FILE"
fi

echo ""
echo "=== Test 2: JSON to Markdown Conversion ==="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 2: JSON to Markdown Conversion" >> "$LOG_FILE"

# Create test JSON file
echo '{"heading":"Test JSON","content":"This is a test JSON file.","items":["Item A","Item B","Item C"]}' > "$JSON_DIR/test2.json"

echo "Running tydisync.sh for reverse conversion..."
# Check if we have a shell script version available
if [ -f "./tydisync.sh" ]; then
    bash ./tydisync.sh --convert "$JSON_DIR/test2.json" --verbose
else
    # Fall back to Windows batch file if shell script not available
    echo "Warning: Using Windows batch file (tydisync.sh not found)"
    tydisync.bat --convert "$JSON_DIR/test2.json" --verbose
fi
EXIT_CODE=$?

# Check both possible locations for the output file
if [ -f "$MD_DIR/test2.md" ]; then
    echo "Test 2: PASSED - Successfully created Markdown file in expected directory"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 2: PASSED - Successfully created Markdown file in expected directory" >> "$LOG_FILE"
elif [ -f "$TEST_DIR/test2.md" ]; then
    echo "Test 2: PASSED - Successfully created Markdown file in root test directory"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 2: PASSED - Successfully created Markdown file in root test directory" >> "$LOG_FILE"
else
    echo "Test 2: FAILED - Markdown file not created"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 2: FAILED - Markdown file not created, exit code: $EXIT_CODE" >> "$LOG_FILE"
fi

echo ""
echo "=== Test 3: Watch Mode Functionality ==="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 3: Watch Mode Functionality" >> "$LOG_FILE"

echo "SKIPPING Watch Mode Test - This test requires manual verification"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIPPED - Watch Mode Test requires manual verification" >> "$LOG_FILE"
echo "Test 3: SKIPPED - Watch Mode Test requires manual verification"

echo ""
echo "=== Test 4: Error Handling ==="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 4: Error Handling" >> "$LOG_FILE"

echo "Creating invalid JSON file..."
echo "{This is invalid JSON" > "$JSON_DIR/invalid.json"

echo "Running tydisync.sh with invalid JSON..."
# Check if we have a shell script version available
if [ -f "./tydisync.sh" ]; then
    bash ./tydisync.sh --convert "$JSON_DIR/invalid.json" > "$TEST_DIR/error_output.txt" 2>&1
else
    # Fall back to Windows batch file if shell script not available
    echo "Warning: Using Windows batch file (tydisync.sh not found)"
    tydisync.bat --convert "$JSON_DIR/invalid.json" > "$TEST_DIR/error_output.txt" 2>&1
fi
EXIT_CODE=$?

# Check if error was reported
if grep -q "ERROR" "$TEST_DIR/error_output.txt"; then
    echo "Test 4: PASSED - Error was properly reported"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 4: PASSED - Error was properly reported" >> "$LOG_FILE"
else
    echo "Test 4: FAILED - Error was not properly reported"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 4: FAILED - Error was not properly reported" >> "$LOG_FILE"
fi

echo ""
echo "=== Test 5: Backup System ==="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 5: Backup System" >> "$LOG_FILE"

# Prepare a test file for backup testing
cp "$MD_DIR/test1.md" "$MD_DIR/backup_test.md"

echo "Running tydisync.sh with backup option..."
# Check if we have a shell script version available
if [ -f "./tydisync.sh" ]; then
    bash ./tydisync.sh --convert "$MD_DIR/backup_test.md" --verbose
else
    # Fall back to Windows batch file if shell script not available
    echo "Warning: Using Windows batch file (tydisync.sh not found)"
    tydisync.bat --convert "$MD_DIR/backup_test.md" --verbose
fi
EXIT_CODE=$?

# Check if a backup was created in the backup directory
find ../backups -name "*backup_test*" > "$TEST_DIR/backup_files.txt" 2>&1
if grep -q "backup_test" "$TEST_DIR/backup_files.txt"; then
    echo "Test 5: PASSED - Backup file was created"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 5: PASSED - Backup file was created" >> "$LOG_FILE"
else
    echo "Test 5: FAILED - Backup file was not created"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test 5: FAILED - Backup file was not created" >> "$LOG_FILE"
fi

echo ""
echo "=== Test Results Summary ==="

# Count passed and skipped tests
PASS_COUNT=$(grep -c "PASSED" "$LOG_FILE")
SKIP_COUNT=$(grep -c "SKIPPED" "$LOG_FILE")

TOTAL_TESTS=4 # Excluding skipped test
echo "Passed $PASS_COUNT out of $TOTAL_TESTS tests, with $SKIP_COUNT skipped."

if [ "$PASS_COUNT" -eq "$TOTAL_TESTS" ]; then
    echo "All tests PASSED!"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] All tests PASSED!" >> "$LOG_FILE"
    exit 0
else
    echo "Some tests FAILED. Please review the log file for details: $LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Some tests FAILED. Please review the log file for details." >> "$LOG_FILE"
    exit 1
fi 