// Jest test setup file
const path = require('path');
const fs = require('fs').promises;

// Global test timeout
jest.setTimeout(10000);

// Create test directories if they don't exist
beforeAll(async () => {
  const testDirs = [
    '.cursor/test-metrics',
    '.cursor/test-logs',
    '.cursor/test-config'
  ];

  for (const dir of testDirs) {
    await fs.mkdir(dir, { recursive: true }).catch(() => {});
  }
});

// Clean up test files after each test
afterEach(async () => {
  const testFiles = [
    '.cursor/test-metrics/test-*.json',
    '.cursor/test-logs/test-*.log',
    '.cursor/test-config/test-*.json'
  ];

  for (const pattern of testFiles) {
    const files = await require('glob').glob(pattern);
    for (const file of files) {
      await fs.unlink(file).catch(() => {});
    }
  }
});

// Mock WebSocket for tests
class MockWebSocket {
  constructor() {
    this.OPEN = 1;
    this.CLOSED = 3;
    this.readyState = this.OPEN;
    this.sent = [];
  }

  send(data) {
    this.sent.push(data);
  }

  close() {
    this.readyState = this.CLOSED;
  }

  emit(event, data) {
    if (this[`on${event}`]) {
      this[`on${event}`](data);
    }
  }
}

global.WebSocket = MockWebSocket;

// Mock process monitoring for tests
jest.mock('pidtree', () => ({
  __esModule: true,
  default: jest.fn().mockResolvedValue([1, 2, 3])
}));

// Add test utilities
global.createTestMetrics = () => ({
  cpu: Math.random() * 100,
  memory: Math.random() * 100,
  processes: [
    { pid: 1, name: 'test1', cpu: 10, memory: 100 },
    { pid: 2, name: 'test2', cpu: 20, memory: 200 },
    { pid: 3, name: 'test3', cpu: 30, memory: 300 }
  ]
});

// Add test assertions
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () => `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true
      };
    } else {
      return {
        message: () => `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false
      };
    }
  }
}); 