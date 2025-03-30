#!/bin/bash
#
# prepare-unix-testing.sh
#
# Script to prepare and execute Unix testing for tYDiSync~
# This script:
# 1. Makes all shell scripts executable
# 2. Sets up the testing environment
# 3. Runs all tests in the correct order
#

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs/unix-testing"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/unix-testing-$TIMESTAMP.log"

# Header
echo -e "${YELLOW}==================================================================${NC}"
echo -e "${YELLOW}                 tYDiSync~ Unix Testing Suite                     ${NC}"
echo -e "${YELLOW}==================================================================${NC}"
echo

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Initialize log file
echo "tYDiSync~ Unix Testing - $TIMESTAMP" > "$LOG_FILE"
echo "=====================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# Function to log messages
log() {
    echo -e "$1"
    echo "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> "$LOG_FILE"
}

# Step 1: Make all shell scripts executable
log "${BLUE}Step 1: Making shell scripts executable...${NC}"

# Find all shell scripts in the scripts directory and make them executable
SHELL_SCRIPTS=($(find "$SCRIPT_DIR" -name "*.sh"))
for script in "${SHELL_SCRIPTS[@]}"; do
    chmod +x "$script"
    log "  Made executable: $(basename "$script")"
done

log "  ${GREEN}✓ All shell scripts are now executable${NC}"
log ""

# Step 2: Verify system requirements
log "${BLUE}Step 2: Verifying system requirements...${NC}"

# Check for Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    log "  ${GREEN}✓ Node.js is installed: $NODE_VERSION${NC}"
else
    log "  ${RED}✗ Node.js is not installed${NC}"
    log "  ${RED}Unix testing cannot proceed without Node.js${NC}"
    exit 1
fi

# Check for essential Unix commands
COMMANDS=("bash" "find" "grep" "sed" "awk")
MISSING_COMMANDS=()

for cmd in "${COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -eq 0 ]; then
    log "  ${GREEN}✓ All required Unix commands are available${NC}"
else
    log "  ${RED}✗ Missing required commands: ${MISSING_COMMANDS[*]}${NC}"
    log "  ${RED}Unix testing may not proceed correctly${NC}"
fi

# Check if we're actually on a Unix system
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* || "$OSTYPE" == "freebsd"* ]]; then
    log "  ${GREEN}✓ Running on Unix-compatible system: $OSTYPE${NC}"
else
    log "  ${YELLOW}⚠ Not running on a Unix-compatible system: $OSTYPE${NC}"
    log "  ${YELLOW}This script is intended for Unix testing${NC}"
fi

log ""

# Step 3: Run tests in sequence
log "${BLUE}Step 3: Running tests...${NC}"
log ""

# Function to run a test and report status
run_test() {
    local test_script="$1"
    local test_name="$2"
    
    log "${YELLOW}Running $test_name test...${NC}"
    
    # Execute test
    if "$test_script"; then
        log "  ${GREEN}✓ $test_name test completed successfully${NC}"
        return 0
    else
        log "  ${RED}✗ $test_name test failed${NC}"
        return 1
    fi
}

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0

# Run basic functionality test
TOTAL_TESTS=$((TOTAL_TESTS+1))
if run_test "$SCRIPT_DIR/test-tydisync-functionality.sh" "Basic functionality"; then
    PASSED_TESTS=$((PASSED_TESTS+1))
fi
log ""

# Run watch mode test
TOTAL_TESTS=$((TOTAL_TESTS+1))
if run_test "$SCRIPT_DIR/test-tydisync-watch-mode.sh" "Watch mode"; then
    PASSED_TESTS=$((PASSED_TESTS+1))
fi
log ""

# Run edge cases test
TOTAL_TESTS=$((TOTAL_TESTS+1))
if run_test "$SCRIPT_DIR/test-tydisync-edge-cases.sh" "Edge cases"; then
    PASSED_TESTS=$((PASSED_TESTS+1))
fi
log ""

# Run Unicode test
TOTAL_TESTS=$((TOTAL_TESTS+1))
if run_test "$SCRIPT_DIR/test-tydisync-unicode.sh" "Unicode handling"; then
    PASSED_TESTS=$((PASSED_TESTS+1))
fi
log ""

# Run path edge cases test
TOTAL_TESTS=$((TOTAL_TESTS+1))
if run_test "$SCRIPT_DIR/test-tydisync-path-edge-cases.sh" "Path edge cases"; then
    PASSED_TESTS=$((PASSED_TESTS+1))
fi
log ""

# Calculate success rate
SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))

# Final summary
log "${BLUE}Testing Summary:${NC}"
log "  Total tests:   $TOTAL_TESTS"
log "  Passed tests:  $PASSED_TESTS"
log "  Failed tests:  $((TOTAL_TESTS - PASSED_TESTS))"
log "  Success rate:  $SUCCESS_RATE%"
log ""

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    log "${GREEN}All tests passed successfully!${NC}"
else
    log "${RED}Some tests failed. Check individual test logs for details.${NC}"
fi

log ""
log "Detailed logs available at: $LOG_FILE"

# Create summary file with platform-specific information
SUMMARY_FILE="$LOG_DIR/unix-testing-summary-$TIMESTAMP.md"

cat > "$SUMMARY_FILE" << EOF
# tYDiSync~ Unix Testing Summary

**Test Date:** $(date)

## System Information
- **OS:** $(uname -s)
- **OS Version:** $(uname -r)
- **Architecture:** $(uname -m)
- **Node Version:** $NODE_VERSION
- **File System:** $(df -T . | tail -n 1 | awk '{print $2}')

## Test Results
- **Total Tests:** $TOTAL_TESTS
- **Passed Tests:** $PASSED_TESTS
- **Failed Tests:** $((TOTAL_TESTS - PASSED_TESTS))
- **Success Rate:** $SUCCESS_RATE%

## Individual Test Results
1. **Basic Functionality:** $([ $(grep -c "Basic functionality test completed successfully" "$LOG_FILE") -gt 0 ] && echo "✅ Passed" || echo "❌ Failed")
2. **Watch Mode:** $([ $(grep -c "Watch mode test completed successfully" "$LOG_FILE") -gt 0 ] && echo "✅ Passed" || echo "❌ Failed")
3. **Edge Cases:** $([ $(grep -c "Edge cases test completed successfully" "$LOG_FILE") -gt 0 ] && echo "✅ Passed" || echo "❌ Failed")
4. **Unicode Handling:** $([ $(grep -c "Unicode handling test completed successfully" "$LOG_FILE") -gt 0 ] && echo "✅ Passed" || echo "❌ Failed")
5. **Path Edge Cases:** $([ $(grep -c "Path edge cases test completed successfully" "$LOG_FILE") -gt 0 ] && echo "✅ Passed" || echo "❌ Failed")

## Log Locations
- Main log: \`$LOG_FILE\`
- Individual test logs are available in the \`../logs/\` directory.

_Generated: $(date)_
EOF

log "Summary report created at: $SUMMARY_FILE"
log ""
log "Unix testing completed."

# Exit with success if all tests passed, failure otherwise
if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    exit 0
else
    exit 1
fi 