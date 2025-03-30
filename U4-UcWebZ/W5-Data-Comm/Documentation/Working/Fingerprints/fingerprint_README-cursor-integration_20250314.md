# Content Fingerprint Report

## File Information
- **File Path**: C:\Users\Chris\cFish.io\Documentation\Technical\u5-data-management\README-cursor-integration.md
- **Word Count**: 505
- **Byte Size**: 3683 bytes
- **MD5 Hash**: 24B5C51EED6E79F5E1537225B77A998F
- **Generated**: 2025-03-14 16:11:40

## Content Structure
- **Headlines**: 15
- **Key Phrases**: 20
- **Code Blocks**: 3

## Headlines
- MD-JSON Sync System - Cursor Integration
- Overview
- Installation
- Manual Usage
- Troubleshooting
- Common Issues and Solutions
- 1. "MdJsonSync is not a constructor" Error
- 2. PowerShell Script Execution Issues
- First change to the project directory
- Then execute with the proper extension
- 3. Missing Dependencies
- Advanced Troubleshooting
- How It Works
- Configuration
- License


## Sample Key Phrases
- Cursor Integration
- Memory management with automatic garbage collection
- Improved lock management with stale lock detection
- JSON validation and automatic repair
- Low CPU mode for reduced resource usage
- This indicates an issue with how the MD-JSON sync module is imported
- **Solution**: The fixed version uses `const MDJSONSync = require('./tydisync.js');` to properly import the module
- If you still encounter this issue, try:
- Verify that tydisync.js exists in the same directory
- Check if the tydisync.js file properly exports a constructor
- _(plus 10 more phrases...)_


_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_
