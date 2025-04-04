const fs = require('fs').promises;
const path = require('path');

class Logger {
  constructor(component) {
    this.component = component;
    this.logDir = path.join(__dirname, '../logs');
    this.logFile = path.join(this.logDir, `${component}.log`);
    this.setupLogger();
  }

  async setupLogger() {
    try {
      await fs.mkdir(this.logDir, { recursive: true });
    } catch (error) {
      console.error('Error creating log directory:', error);
    }
  }

  formatMessage(level, message) {
    const timestamp = new Date().toISOString();
    return `[${timestamp}] [${level}] [${this.component}] ${message}`;
  }

  async writeLog(level, message) {
    const formattedMessage = this.formatMessage(level, message);
    try {
      await fs.appendFile(this.logFile, formattedMessage + '\n');
      // Also output to console for immediate feedback
      console[level.toLowerCase()](formattedMessage);
    } catch (error) {
      console.error('Error writing to log file:', error);
    }
  }

  info(message) {
    this.writeLog('INFO', message);
  }

  warn(message) {
    this.writeLog('WARN', message);
  }

  error(message) {
    this.writeLog('ERROR', message);
  }

  debug(message) {
    if (process.env.DEBUG) {
      this.writeLog('DEBUG', message);
    }
  }
}

function createLogger(component) {
  return new Logger(component);
}

module.exports = { createLogger }; 