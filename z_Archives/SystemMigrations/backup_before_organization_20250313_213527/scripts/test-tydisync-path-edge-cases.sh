#!/bin/bash
#
# test-tydisync-path-edge-cases.sh
#
# Shell script wrapper for the path edge case testing script for tYDiSync~
# This allows the test to be run from a Unix/Linux/macOS environment
#

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/path-edge-case-output.log"

# Create logs directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/$LOG_DIR"

# Ensure node is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed or not in PATH${NC}"
    echo "Please install Node.js and try again"
    exit 1
fi

# Print header
echo -e "${YELLOW}==================================================================${NC}"
echo -e "${YELLOW}              tYDiSync~ Path Edge Case Test                       ${NC}"
echo -e "${YELLOW}==================================================================${NC}"
echo

# Check if the test script exists
TEST_SCRIPT="$SCRIPT_DIR/test-tydisync-path-edge-cases.js"
if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${RED}Error: Test script not found: $TEST_SCRIPT${NC}"
    exit 1
fi

# Function to ensure script is executable
make_executable() {
    if [ ! -x "$1" ]; then
        echo "Making script executable: $1"
        chmod +x "$1"
    fi
}

# Ensure tydisync.sh is executable
TYDISYNC_SCRIPT="$SCRIPT_DIR/tydisync.sh"
make_executable "$TYDISYNC_SCRIPT"

# Print system information
echo "System information:"
echo "  OS: $(uname -s)"
echo "  Node: $(node -v)"
echo "  Date: $(date)"
echo "  Max path length: $(getconf PATH_MAX /)"
echo

# Report on file system capabilities
echo "File system capabilities:"
if [ "$(uname -s)" = "Darwin" ]; then
    echo "  File system: $(mount | grep " / " | cut -d' ' -f5)"
else
    echo "  File system: $(df -T / | tail -n 1 | awk '{print $2}')"
fi
echo "  Case sensitive: $(touch /tmp/testfile && touch /tmp/TestFile && echo 'Yes' || echo 'No'; rm -f /tmp/testfile /tmp/TestFile)"
echo

# Run the test
echo -e "${YELLOW}Starting path edge case tests...${NC}"
echo "Test output will be logged to: $SCRIPT_DIR/$LOG_FILE"
echo

# Execute the test script and capture output
node "$TEST_SCRIPT" 2>&1 | tee "$SCRIPT_DIR/$LOG_FILE"

# Check if the test was successful
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "\n${GREEN}Path edge case tests completed successfully!${NC}"
    echo "See detailed results in the logs directory."
    exit 0
else
    echo -e "\n${RED}Path edge case tests failed!${NC}"
    echo "Check the log file for error details: $SCRIPT_DIR/$LOG_FILE"
    exit 1
fi 