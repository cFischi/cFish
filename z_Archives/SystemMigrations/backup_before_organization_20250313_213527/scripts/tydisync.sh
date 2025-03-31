#!/bin/bash
# tYDiSync~ - Two-Way Markdown-JSON Synchronization for Linux/macOS
# Shell script alternative to tydisync.bat

echo "========================================="
echo "cFish.io MD-JSON Two-Way Sync"
echo "========================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH."
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Initialize variables for command line arguments
WATCH_MODE=""
VERBOSE_MODE=""
PREFER_MODE=""
RECURSIVE_MODE=""
DEPTH_PARAM=""
NON_RECURSIVE_WATCH=""
NO_BACKUPS=""
HELP_MODE=""
CONVERT_MODE=""
CONVERT_FILE=""

# Display debug information
echo "DEBUG: Arguments: $@"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --convert)
            CONVERT_MODE="--convert"
            shift
            CONVERT_FILE="$1"
            ;;
        --verbose|-v)
            VERBOSE_MODE="--verbose"
            ;;
        --watch|-w)
            WATCH_MODE="--watch"
            ;;
        --prefer-md)
            PREFER_MODE="--prefer-md"
            ;;
        --prefer-json)
            PREFER_MODE="--prefer-json"
            ;;
        --recursive)
            RECURSIVE_MODE="--recursive"
            ;;
        --non-recursive-watch)
            NON_RECURSIVE_WATCH="--non-recursive-watch"
            ;;
        --no-backups)
            NO_BACKUPS="--no-backups"
            ;;
        --help|-h|--\?)
            HELP_MODE="1"
            ;;
        --depth=*)
            DEPTH_PARAM="$1"
            ;;
        *)
            echo "Unknown option: $1"
            HELP_MODE="1"
            ;;
    esac
    shift
done

# Display debug information
echo "DEBUG: After parsing:"
echo "DEBUG: WATCH_MODE=$WATCH_MODE"
echo "DEBUG: VERBOSE_MODE=$VERBOSE_MODE"
echo "DEBUG: PREFER_MODE=$PREFER_MODE"
echo "DEBUG: RECURSIVE_MODE=$RECURSIVE_MODE"
echo "DEBUG: DEPTH_PARAM=$DEPTH_PARAM"
echo "DEBUG: NON_RECURSIVE_WATCH=$NON_RECURSIVE_WATCH"
echo "DEBUG: NO_BACKUPS=$NO_BACKUPS"
echo "DEBUG: HELP_MODE=$HELP_MODE"
echo "DEBUG: CONVERT_MODE=$CONVERT_MODE"
echo "DEBUG: CONVERT_FILE=$CONVERT_FILE"

# Display help if requested or if no valid command is specified
if [ -n "$HELP_MODE" ] || { [ -z "$WATCH_MODE" ] && [ -z "$CONVERT_MODE" ]; }; then
    echo "Usage: tydisync.sh [options]"
    echo ""
    echo "Options:"
    echo "  --watch, -w              Run in watch mode (continuous monitoring)"
    echo "  --verbose, -v            Display detailed information"
    echo "  --prefer-md              Prefer Markdown files in conflicts"
    echo "  --prefer-json            Prefer JSON files in conflicts"
    echo "  --recursive              Enable recursive directory scanning (default)"
    echo "  --depth=N                Set maximum directory depth for recursive scanning"
    echo "  --non-recursive-watch    Disable recursive watching for compatibility"
    echo "  --no-backups             Disable automatic backups before modifying files"
    echo "  --convert [file]         Convert a specific file (md to json or json to md)"
    echo "  --help, -h, /?           Display this help message"
    echo ""
    echo "Examples:"
    echo "  tydisync.sh --watch --verbose"
    echo "  tydisync.sh --prefer-md --depth=3"
    echo "  tydisync.sh --non-recursive-watch --watch"
    echo "  tydisync.sh --convert path/to/file.md"
    exit 0
fi

# Set correct path to the JavaScript file using cross-platform path
JS_PATH="../sync-system/core/tydisync.js"

# Check if the script exists
if [ ! -f "$JS_PATH" ]; then
    echo "ERROR: Could not find $JS_PATH"
    echo "Make sure you're running this script from the scripts directory"
    exit 1
fi

# Debug output
echo "DEBUG: JS_PATH = $JS_PATH"
echo "DEBUG: CONVERT_MODE = $CONVERT_MODE"
echo "DEBUG: CONVERT_FILE = $CONVERT_FILE"
echo "DEBUG: VERBOSE_MODE = $VERBOSE_MODE"

# Build command with options
if [ -n "$CONVERT_MODE" ]; then
    if [ -z "$CONVERT_FILE" ]; then
        echo "ERROR: No file specified for conversion"
        echo "Usage: tydisync.sh --convert [file]"
        exit 1
    fi
    
    CMD="node $JS_PATH $CONVERT_MODE \"$CONVERT_FILE\" $VERBOSE_MODE $PREFER_MODE $NO_BACKUPS"
    echo "Converting file: $CONVERT_FILE"
    echo "DEBUG: Command = $CMD"
else
    CMD="node $JS_PATH $WATCH_MODE $VERBOSE_MODE $PREFER_MODE $RECURSIVE_MODE $DEPTH_PARAM $NON_RECURSIVE_WATCH $NO_BACKUPS"
    
    # Display command information
    if [ -n "$WATCH_MODE" ]; then
        echo "Running two-way Markdown-JSON synchronization..."
        echo "Watch mode enabled - Press Ctrl+C to stop"
    else
        echo "Running one-time Markdown-JSON synchronization..."
    fi
    echo "DEBUG: Command = $CMD"
fi

# Run the command
echo "DEBUG: Executing command: $CMD"
eval "$CMD"

# Check for errors
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Synchronization failed with error code $EXIT_CODE"
    exit $EXIT_CODE
fi

exit 0 