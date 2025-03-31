/**
 * JSON Validator and Recovery Tool
 * 
 * This utility validates JSON files, identifies parsing errors, and attempts recovery
 * when possible. It's designed to be used as part of the MD-JSON synchronization system.
 * 
 * Usage:
 *   node json-validator.js <file-path> [--fix] [--verbose]
 *   
 * Options:
 *   --fix      Attempt to automatically fix issues when possible
 *   --verbose  Show detailed diagnostics during validation
 */

const fs = require('fs');
const path = require('path');

// Configuration
const BACKUP_DIR = 'backups';

/**
 * Validates a JSON file and returns validation result
 * @param {string} filePath - Path to JSON file
 * @param {boolean} verbose - Whether to output verbose diagnostics
 * @returns {Object} Validation result object
 */
function validateJSON(filePath, verbose = false) {
  const result = {
    valid: false,
    error: null,
    errorPosition: null,
    errorLine: null,
    errorColumn: null,
    content: null,
    filePath
  };

  try {
    if (!fs.existsSync(filePath)) {
      result.error = 'File does not exist';
      return result;
    }

    // Read file content
    const content = fs.readFileSync(filePath, 'utf8');
    result.content = content;

    if (verbose) {
      console.log(`Validating ${filePath} (${content.length} bytes)`);
    }

    // Attempt to parse JSON
    JSON.parse(content);
    
    // If we get here, JSON is valid
    result.valid = true;
    
    if (verbose) {
      console.log(`✅ JSON file is valid: ${filePath}`);
    }
    
    return result;
  } catch (err) {
    // Handle JSON parsing error
    result.error = err.message;
    
    // Extract position information when available
    if (err instanceof SyntaxError && err.message.includes('position')) {
      // Try to extract position from error message
      const posMatch = err.message.match(/position (\d+)/);
      if (posMatch && posMatch[1]) {
        result.errorPosition = parseInt(posMatch[1], 10);
        
        // Calculate line and column numbers
        const contentBeforeError = result.content.substring(0, result.errorPosition);
        const lines = contentBeforeError.split('\n');
        result.errorLine = lines.length;
        result.errorColumn = lines[lines.length - 1].length + 1;
      }
    }
    
    if (verbose) {
      console.error(`❌ JSON validation failed: ${err.message}`);
      if (result.errorLine) {
        console.error(`   Error at line ${result.errorLine}, column ${result.errorColumn}`);
        
        // Show the problematic line with a pointer
        const allLines = result.content.split('\n');
        if (result.errorLine <= allLines.length) {
          const problemLine = allLines[result.errorLine - 1];
          console.error(`   ${problemLine}`);
          console.error(`   ${' '.repeat(result.errorColumn - 1)}^`);
        }
      }
    }
    
    return result;
  }
}

/**
 * Attempts to fix common JSON issues
 * @param {Object} validationResult - Validation result from validateJSON
 * @returns {Object} Fix result object
 */
function attemptFix(validationResult) {
  const result = {
    fixed: false,
    fixedContent: null,
    backupPath: null,
    error: null
  };
  
  if (validationResult.valid) {
    result.fixed = true;
    result.fixedContent = validationResult.content;
    return result;
  }
  
  const content = validationResult.content;
  
  // Create backup before attempting fixes
  try {
    if (!fs.existsSync(BACKUP_DIR)) {
      fs.mkdirSync(BACKUP_DIR, { recursive: true });
    }
    
    const backupFileName = `${path.basename(validationResult.filePath)}.${Date.now()}.backup`;
    const backupPath = path.join(BACKUP_DIR, backupFileName);
    fs.writeFileSync(backupPath, content);
    result.backupPath = backupPath;
    
    console.log(`✓ Created backup: ${backupPath}`);
  } catch (err) {
    result.error = `Failed to create backup: ${err.message}`;
    return result;
  }
  
  // Common JSON fixes based on error types
  let fixedContent = content;
  
  // 1. Fix: Unexpected end of JSON input (missing closing brackets)
  if (validationResult.error?.includes('Unexpected end of input')) {
    // Count opening and closing braces/brackets to find mismatches
    const openBraces = (fixedContent.match(/\{/g) || []).length;
    const closeBraces = (fixedContent.match(/\}/g) || []).length;
    const openBrackets = (fixedContent.match(/\[/g) || []).length;
    const closeBrackets = (fixedContent.match(/\]/g) || []).length;
    
    // Add missing closing braces
    if (openBraces > closeBraces) {
      fixedContent += '}'.repeat(openBraces - closeBraces);
      console.log(`Added ${openBraces - closeBraces} missing closing braces }`);
    }
    
    // Add missing closing brackets
    if (openBrackets > closeBrackets) {
      fixedContent += ']'.repeat(openBrackets - closeBrackets);
      console.log(`Added ${openBrackets - closeBrackets} missing closing brackets ]`);
    }
  }
  
  // 2. Fix: Missing commas between properties
  if (validationResult.error?.includes('Unexpected string') || 
      validationResult.error?.includes('Expected property name')) {
    // Find positions where a comma might be missing (look for "}\s*{" pattern)
    fixedContent = fixedContent.replace(/"\s*}\s*"/g, '"},\n"');
    fixedContent = fixedContent.replace(/]\s*\[/g, '],\n[');
  }
  
  // 3. Fix: Trailing commas
  if (validationResult.error?.includes('Trailing comma')) {
    fixedContent = fixedContent.replace(/,\s*}/g, '}');
    fixedContent = fixedContent.replace(/,\s*]/g, ']');
  }
  
  // Validate fixed content
  try {
    JSON.parse(fixedContent);
    result.fixed = true;
    result.fixedContent = fixedContent;
    return result;
  } catch (err) {
    // If still not valid, try a more aggressive approach:
    // Attempt to recover by finding the largest parseable subset
    try {
      // Find the last position where we have valid JSON by trying to parse 
      // increasingly longer substrings
      let validLength = 0;
      for (let i = 1; i <= content.length; i++) {
        try {
          const substring = content.substring(0, i) + '}';
          JSON.parse(substring);
          validLength = i;
        } catch (e) {
          // Keep trying
        }
      }
      
      if (validLength > 0) {
        // We found a valid subset - add closing brace
        fixedContent = content.substring(0, validLength) + '}';
        try {
          JSON.parse(fixedContent);
          result.fixed = true;
          result.fixedContent = fixedContent;
          console.log(`Recovered ${validLength} bytes of valid JSON and added closing brace`);
          return result;
        } catch (e) {
          // Last resort failed
        }
      }
    } catch (recoveryErr) {
      // Recovery failed
    }
    
    result.error = `Could not fix JSON: ${err.message}`;
    return result;
  }
}

/**
 * Main function to validate and optionally fix a JSON file
 */
function processJSONFile(filePath, shouldFix = false, verbose = false) {
  console.log(`Processing JSON file: ${filePath}`);
  
  // Validate the JSON file
  const validationResult = validateJSON(filePath, verbose);
  
  if (validationResult.valid) {
    console.log(`✅ JSON file is valid: ${filePath}`);
    return true;
  }
  
  console.error(`❌ JSON validation failed: ${validationResult.error}`);
  
  if (validationResult.errorLine) {
    console.error(`   Error at line ${validationResult.errorLine}, column ${validationResult.errorColumn}`);
  }
  
  // Attempt to fix if requested
  if (shouldFix) {
    console.log('Attempting to fix JSON issues...');
    const fixResult = attemptFix(validationResult);
    
    if (fixResult.fixed) {
      // Save the fixed content
      fs.writeFileSync(filePath, fixResult.fixedContent);
      console.log(`✅ Successfully fixed and saved: ${filePath}`);
      return true;
    } else {
      console.error(`❌ Failed to fix JSON: ${fixResult.error || 'Unknown error'}`);
      if (fixResult.backupPath) {
        console.log(`   Backup created at: ${fixResult.backupPath}`);
      }
      return false;
    }
  }
  
  return false;
}

// Handle command line arguments
function processCommandLineArgs() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('Usage: node json-validator.js <file-path> [--fix] [--verbose]');
    console.log('Options:');
    console.log('  --fix      Attempt to automatically fix issues when possible');
    console.log('  --verbose  Show detailed diagnostics during validation');
    process.exit(1);
  }
  
  const filePath = args[0];
  const shouldFix = args.includes('--fix');
  const verbose = args.includes('--verbose');
  
  return processJSONFile(filePath, shouldFix, verbose);
}

// Execute if run directly
if (require.main === module) {
  const success = processCommandLineArgs();
  process.exit(success ? 0 : 1);
}

// Export functions for use in other modules
module.exports = {
  validateJSON,
  attemptFix,
  processJSONFile
}; 