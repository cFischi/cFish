# Content Fingerprint Report

## File Information
- **File Path**: C:\Users\Chris\cFish.io\Documentation\Technical\path-handling-limitations.md
- **Word Count**: 955
- **Byte Size**: 7147 bytes
- **MD5 Hash**: D9027114F0026B527618CD6555FF7200
- **Generated**: 2025-03-14 16:11:38

## Content Structure
- **Headlines**: 19
- **Key Phrases**: 44
- **Code Blocks**: 2

## Headlines
- Path Handling Limitations in tYDiSync~
- Overview
- Testing Implementation
- Path Edge Case Test Categories
- Platform-Specific Path Limitations
- Windows
- Linux/Unix
- macOS
- Common Path Handling Issues
- Testing Results
- Implementation Approach
- Platform-Specific Testing Considerations
- Windows-Specific Testing
- Unix-Specific Testing
- Usage Instructions
- Windows
- Linux/macOS
- Troubleshooting
- Recommended Path Handling Practices


## Sample Key Phrases
- **Path Length**: Standard MAX_PATH limit of 260 characters (including null terminator)
- **Extended Path**: Up to ~32,767 characters with extended-length path prefix (`\\?\`)
- **Reserved Characters**: `< > : " / \ | ? *`
- **Reserved Names**: CON, PRN, AUX, NUL, COM1-9, LPT1-9
- **Case Sensitivity**: Case-insensitive but case-preserving
- **UNC Paths**: Network paths starting with `\\server\share`
- **Drive Letters**: Uses drive letters like `C:` for volume mounting
- **Path Length**: Typically 4,096 bytes (PATH_MAX) but varies by filesystem
- **Filename Length**: Often 255 bytes (NAME_MAX)
- **Reserved Characters**: Only `/` and NULL byte
- _(plus 34 more phrases...)_


_Updated 03-14-2025 | AI: Cursor (Claude 3.7 Sonnet)_
