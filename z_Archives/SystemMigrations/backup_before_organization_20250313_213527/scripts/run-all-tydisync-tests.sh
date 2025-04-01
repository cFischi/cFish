#!/bin/bash
# tYDiSync~ Complete Test Suite for Linux/macOS
# Shell script alternative to run-all-tydisync-tests.bat

echo "===== tYDiSync~ Complete Test Suite ====="
echo "Running all tYDiSync~ tests..."
echo ""

# Define log paths with cross-platform compatibility
LOG_DIR="../logs"
SUMMARY_LOG="$LOG_DIR/tydisync-all-tests-summary.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log start of test
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Complete tYDiSync~ Test Suite" > "$SUMMARY_LOG"

# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# 1. Basic Functionality Tests
echo "===== 1. Basic Functionality Tests ====="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Basic Functionality Tests" >> "$SUMMARY_LOG"

# Check for the shell script version first, fall back to bat if not available
if [ -f "./test-tydisync-functionality.sh" ]; then
    bash ./test-tydisync-functionality.sh
    EXIT_CODE=$?
else
    echo "Warning: Using Windows batch file for functionality tests (test-tydisync-functionality.sh not found)"
    test-tydisync-functionality.bat
    EXIT_CODE=$?
fi

# Count based on basic test results
if [ $EXIT_CODE -eq 0 ]; then
    PASSED_TESTS=$((PASSED_TESTS + 4))
    TOTAL_TESTS=$((TOTAL_TESTS + 4))
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Basic Functionality Tests: PASSED" >> "$SUMMARY_LOG"
else
    # For Linux we'll need a more complex parsing of the log file
    # This is a simplified version
    PASSED_COUNT=$(grep -c "PASSED" "$LOG_DIR/tydisync-test-results.log" || echo "0")
    FAILED_COUNT=$(grep -c "FAILED" "$LOG_DIR/tydisync-test-results.log" || echo "0")
    SKIPPED_COUNT=$(grep -c "SKIPPED" "$LOG_DIR/tydisync-test-results.log" || echo "0")
    
    PASSED_TESTS=$((PASSED_TESTS + PASSED_COUNT))
    FAILED_TESTS=$((FAILED_TESTS + FAILED_COUNT))
    SKIPPED_TESTS=$((SKIPPED_TESTS + SKIPPED_COUNT))
    TOTAL_TESTS=$((TOTAL_TESTS + 5))
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Basic Functionality Tests: FAILED" >> "$SUMMARY_LOG"
fi

# 2. Watch Mode Tests
echo ""
echo "===== 2. Watch Mode Tests ====="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Watch Mode Tests" >> "$SUMMARY_LOG"

bash ./test-tydisync-watch-mode.sh
EXIT_CODE=$?

# Count based on watch mode test results
if [ $EXIT_CODE -eq 0 ]; then
    PASSED_TESTS=$((PASSED_TESTS + 2))
    TOTAL_TESTS=$((TOTAL_TESTS + 2))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Watch Mode Tests: PASSED" >> "$SUMMARY_LOG"
else
    FAILED_TESTS=$((FAILED_TESTS + 2))
    TOTAL_TESTS=$((TOTAL_TESTS + 2))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Watch Mode Tests: FAILED" >> "$SUMMARY_LOG"
fi

# 3. Edge Case Tests
echo ""
echo "===== 3. Edge Case Tests ====="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Edge Case Tests" >> "$SUMMARY_LOG"

bash ./test-tydisync-edge-cases.sh
EXIT_CODE=$?

# Count based on edge case test results
if [ $EXIT_CODE -eq 0 ]; then
    PASSED_TESTS=$((PASSED_TESTS + 5))
    TOTAL_TESTS=$((TOTAL_TESTS + 5))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Edge Case Tests: PASSED" >> "$SUMMARY_LOG"
else
    # For Linux we'll need a different approach to parsing
    PASSED_EDGE=$(grep -c "PASSED" "$LOG_DIR/tydisync-edge-test.log" || echo "0")
    FAILED_EDGE=$(grep -c "FAILED" "$LOG_DIR/tydisync-edge-test.log" || echo "0")
    
    # Count is approximate since we're parsing logs
    if [ -n "$PASSED_EDGE" ]; then
        PASSED_TESTS=$((PASSED_TESTS + PASSED_EDGE))
    fi
    
    if [ -n "$FAILED_EDGE" ]; then
        FAILED_TESTS=$((FAILED_TESTS + FAILED_EDGE))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 5))
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Edge Case Tests: FAILED" >> "$SUMMARY_LOG"
fi

# Test Summary
echo ""
echo "===== Test Summary ====="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test Summary" >> "$SUMMARY_LOG"
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Skipped: $SKIPPED_TESTS"

echo "Total Tests: $TOTAL_TESTS" >> "$SUMMARY_LOG"
echo "Passed: $PASSED_TESTS" >> "$SUMMARY_LOG"
echo "Failed: $FAILED_TESTS" >> "$SUMMARY_LOG"
echo "Skipped: $SKIPPED_TESTS" >> "$SUMMARY_LOG"

PASS_PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo "Pass Rate: $PASS_PERCENTAGE%"
echo "Pass Rate: $PASS_PERCENTAGE%" >> "$SUMMARY_LOG"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo "ALL TESTS PASSED!"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALL TESTS PASSED!" >> "$SUMMARY_LOG"
    
    # Create success indicator file
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "../tydisync-test/tests-passed.txt"
    exit 0
else
    echo ""
    echo "SOME TESTS FAILED. Please review the logs for details."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SOME TESTS FAILED." >> "$SUMMARY_LOG"
    
    # Create failure indicator file
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "../tydisync-test/tests-failed.txt"
    exit 1
fi 