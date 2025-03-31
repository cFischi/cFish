/**
 * run-cross-platform-tests.js
 * 
 * A script to automatically detect the platform and run the appropriate
 * tYDiSync~ testing script (Unix or Windows).
 * 
 * Usage: node run-cross-platform-tests.js
 */

const os = require('os');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Determine the current platform
const isWindows = os.platform() === 'win32';
const platform = isWindows ? 'Windows' : 'Unix';

// Configure the paths
const scriptDir = path.dirname(__filename);
const windowsScript = path.join(scriptDir, 'prepare-windows-testing.bat');
const unixScript = path.join(scriptDir, 'prepare-unix-testing.sh');

// ANSI color codes
const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m'
};

// Print header
console.log(`${colors.cyan}==================================================================${colors.reset}`);
console.log(`${colors.cyan}          tYDiSync~ Cross-Platform Testing Launcher               ${colors.reset}`);
console.log(`${colors.cyan}==================================================================${colors.reset}`);
console.log();

console.log(`${colors.yellow}Detected platform: ${colors.green}${platform}${colors.reset}`);
console.log(`${colors.yellow}OS details: ${colors.green}${os.type()} ${os.release()}${colors.reset}`);
console.log(`${colors.yellow}Node.js version: ${colors.green}${process.version}${colors.reset}`);
console.log();

// Verify the test script exists
let testScript, shell, shellArgs;

if (isWindows) {
  testScript = windowsScript;
  shell = 'cmd.exe';
  shellArgs = ['/c', testScript];
  
  if (!fs.existsSync(testScript)) {
    console.error(`${colors.red}Error: Windows testing script not found: ${testScript}${colors.reset}`);
    process.exit(1);
  }
} else {
  testScript = unixScript;
  shell = 'bash';
  shellArgs = [testScript];
  
  if (!fs.existsSync(testScript)) {
    console.error(`${colors.red}Error: Unix testing script not found: ${testScript}${colors.reset}`);
    process.exit(1);
  }
  
  // Make Unix script executable
  try {
    fs.chmodSync(testScript, '755');
    console.log(`${colors.green}Made Unix script executable: ${testScript}${colors.reset}`);
  } catch (err) {
    console.warn(`${colors.yellow}Warning: Could not make Unix script executable: ${err.message}${colors.reset}`);
    console.warn(`${colors.yellow}You may need to run "chmod +x ${testScript}" manually.${colors.reset}`);
  }
}

console.log(`${colors.blue}Launching platform-specific testing script...${colors.reset}`);
console.log(`${colors.yellow}Script: ${colors.reset}${testScript}`);
console.log();

// Run the platform-specific testing script
const testProcess = spawn(shell, shellArgs, {
  stdio: 'inherit',
  cwd: scriptDir
});

testProcess.on('error', (err) => {
  console.error(`${colors.red}Failed to start test process: ${err.message}${colors.reset}`);
  process.exit(1);
});

testProcess.on('close', (code) => {
  console.log();
  
  if (code === 0) {
    console.log(`${colors.green}All tests completed successfully!${colors.reset}`);
    process.exit(0);
  } else {
    console.error(`${colors.red}Some tests failed with exit code: ${code}${colors.reset}`);
    console.error(`${colors.red}Check the log files for detailed information.${colors.reset}`);
    process.exit(code);
  }
}); 