import '@testing-library/jest-dom';

// Setup global LRU cache for tests
import { LRUCache } from 'lru-cache';

// Define the type for the global cache
declare global {
  var TextEncoder: typeof TextEncoder;
  var TextDecoder: typeof TextDecoder;
  interface Window {
    processCache: LRUCache<string, any>;
  }
}

// Ensure LRUCache is properly instantiated with the correct options
// to avoid issues during tests
window.processCache = new LRUCache({
  max: 100, // Maximum number of items to store in the cache
  ttl: 1000 * 60 * 5, // 5 minutes time-to-live
  allowStale: false, // Don't allow stale items to be returned
  updateAgeOnGet: true, // Reset TTL when an item is accessed
  updateAgeOnHas: false, // Don't reset TTL when checking if an item exists
});

// Mock CSS animation properties for JSDOM
Object.defineProperty(window, 'CSS', {value: {escape: jest.fn(str => str)}});

// Mock getComputedStyle
Object.defineProperty(window, 'getComputedStyle', {
  value: () => ({
    getPropertyValue: () => '',
    webkitAnimation: '',
    animation: '',
  }),
});

// Add missing Webkit properties
document.documentElement.style.webkitAnimation = '';
document.documentElement.style.animation = '';

// Mock ResizeObserver which isn't available in JSDOM
class ResizeObserverMock {
  observe() {}
  unobserve() {}
  disconnect() {}
}

global.ResizeObserver = ResizeObserverMock as unknown as typeof ResizeObserver;

// Mock requestAnimationFrame
global.requestAnimationFrame = (callback) => setTimeout(callback, 0);
global.cancelAnimationFrame = (id) => clearTimeout(id);

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Setup D3 mocks
jest.mock('d3', () => {
  const originalD3 = jest.requireActual('d3');
  
  return {
    ...originalD3,
    select: jest.fn().mockImplementation((selector) => {
      const mockSelection = {
        selectAll: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        data: jest.fn().mockReturnThis(),
        enter: jest.fn().mockReturnThis(),
        exit: jest.fn().mockReturnThis(),
        merge: jest.fn().mockReturnThis(),
        append: jest.fn().mockReturnThis(),
        attr: jest.fn().mockReturnThis(),
        style: jest.fn().mockReturnThis(),
        text: jest.fn().mockReturnThis(),
        html: jest.fn().mockReturnThis(),
        call: jest.fn().mockReturnThis(),
        on: jest.fn().mockReturnThis(),
        remove: jest.fn().mockReturnThis(),
        datum: jest.fn().mockReturnThis(),
        filter: jest.fn().mockReturnThis(),
        node: jest.fn().mockReturnValue(null),
        nodes: jest.fn().mockReturnValue([]),
      };
      return mockSelection;
    }),
    zoom: () => ({
      scaleExtent: () => ({
        on: () => ({}),
      }),
    }),
    linkHorizontal: () => ({
      x: () => ({
        y: () => (d: any) => '',
      }),
    }),
    tree: () => ({
      size: () => (data: any) => data,
    }),
    hierarchy: (data: any) => ({
      descendants: () => [],
      links: () => [],
      ...data,
    }),
  };
});

// Set up DOM environment
const mockElement = {
  getBoundingClientRect: () => ({
    width: 120,
    height: 120,
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
  }),
  parentElement: {
    getBoundingClientRect: () => ({
      width: 500,
      height: 500,
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
    }),
  },
};

Object.defineProperty(document, 'createElement', {
  writable: true,
  value: jest.fn().mockImplementation((tag) => ({
    ...mockElement,
    tagName: tag.toUpperCase(),
    classList: {
      add: jest.fn(),
      remove: jest.fn(),
      contains: jest.fn(),
    },
    getAttribute: jest.fn(),
    setAttribute: jest.fn(),
    appendChild: jest.fn(),
    removeChild: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    style: {},
  })),
});

// Mock SVG elements
interface SVGElementWithBBox extends SVGElement {
  getBBox(): DOMRect;
}

const mockGetBBox = jest.fn().mockReturnValue({
  x: 0,
  y: 0,
  width: 100,
  height: 100,
});

// Apply mock to SVGElement prototype
Object.defineProperty(SVGElement.prototype, 'getBBox', {
  configurable: true,
  value: mockGetBBox,
});

// Set up test environment
beforeAll(() => {
  // Add any global setup
  jest.spyOn(console, 'error').mockImplementation(() => {});
});

afterAll(() => {
  // Clean up any global state
  (console.error as jest.Mock).mockRestore();
});

beforeEach(() => {
  jest.clearAllMocks();
});

afterEach(() => {
  jest.clearAllTimers();
}); 