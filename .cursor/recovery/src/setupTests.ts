import '@testing-library/jest-dom';
import { LRUCache } from 'lru-cache';

// Mock TextEncoder and TextDecoder
if (typeof TextEncoder === 'undefined') {
  global.TextEncoder = require('util').TextEncoder;
}
if (typeof TextDecoder === 'undefined') {
  global.TextDecoder = require('util').TextDecoder;
}

// Define CSS.escape for jsdom
if (!global.CSS) {
  global.CSS = {} as typeof CSS;
}
if (!global.CSS.escape) {
  global.CSS.escape = function(value: string): string {
    return value.replace(/[!"#$%&'()*+,-./:;<=>?@[\]^`{|}~]/g, '\\$&');
  };
}

// DOM properties needed for animation and transitions
if (typeof window !== 'undefined') {
  Object.defineProperties(window, {
    getComputedStyle: {
      value: () => ({
        getPropertyValue: () => '',
      }),
    },
    webkitRequestAnimationFrame: {
      value: (callback: FrameRequestCallback) => setTimeout(callback, 0),
    },
  });

  // Add webkitAnimation support for DOM mocking
  if (window.HTMLElement) {
    Object.defineProperties(HTMLElement.prototype, {
      offsetLeft: { value: 0 },
      offsetTop: { value: 0 },
      offsetHeight: { value: 0 },
      offsetWidth: { value: 0 },
      getBoundingClientRect: {
        value: () => ({
          width: 0,
          height: 0,
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        }),
      },
      // Add webkitAnimation properties
      webkitAnimationName: { value: '' },
      webkitAnimationDuration: { value: '' },
      webkitAnimationTimingFunction: { value: '' },
      webkitAnimationDelay: { value: '' },
      webkitAnimationIterationCount: { value: '' },
      webkitAnimationDirection: { value: '' },
      webkitAnimationFillMode: { value: '' },
      webkitAnimationPlayState: { value: '' },
    });
  }
}

// Define LRUCache interface for TypeScript
interface LRUCacheOptions<K, V> {
  max?: number;
  ttl?: number;
  allowStale?: boolean;
  updateAgeOnGet?: boolean;
  updateAgeOnHas?: boolean;
  maxSize?: number;
  sizeCalculation?: (value: V, key: K) => number;
  fetchMethod?: (key: K, oldValue: V | undefined, options: any) => Promise<V> | V;
  dispose?: (value: V, key: K) => void;
  noDisposeOnSet?: boolean;
  ttlResolution?: number;
  ttlAutopurge?: boolean;
  maxEntrySize?: number;
}

// Type augmentation for older versions of LRUCache
interface LRUCacheLegacy<K extends object | number | string | boolean | symbol, V> {
  max: number;
  maxSize: number | undefined;
  size: number;
  calculatedSize: number;
  get(key: K): V | undefined;
  set(key: K, value: V): this;
  has(key: K): boolean;
  delete(key: K): boolean;
  clear(): void;
  keys(): IterableIterator<K>;
  values(): IterableIterator<V>;
  entries(): IterableIterator<[K, V]>;
  forEach(callbackFn: (value: V, key: K, map: Map<K, V>) => void, thisArg?: any): void;
  purgeStale?: () => void;
  prune?: () => void;
  getRemainingTTL?: (key: K) => number;
}

// Configure LRUCache for tests with proper error handling
(global as any).setupLRUCache = (options: LRUCacheOptions<any, any> = {}) => {
  try {
    const cache = new LRUCache({
      max: 100,
      ttl: 1000 * 60,
      allowStale: true,
      updateAgeOnGet: true,
      updateAgeOnHas: false,
      ...options
    }) as unknown as LRUCacheLegacy<any, any>;
    
    // Add graceful fallbacks for purgeStale/prune methods
    if (!cache.purgeStale && typeof cache.prune === 'function') {
      (cache as any).purgeStale = cache.prune;
    } else if (!cache.purgeStale) {
      (cache as any).purgeStale = () => {
        // Manual implementation for older versions
        const now = Date.now();
        for (const key of cache.keys()) {
          try {
            const remaining = cache.getRemainingTTL ? cache.getRemainingTTL(key) : -1;
            if (remaining <= 0) {
              cache.delete(key);
            }
          } catch (err) {
            console.error(`Error purging stale entry for key ${key}:`, err);
          }
        }
      };
    }
    
    return cache;
  } catch (error) {
    console.error('Error setting up LRUCache:', error);
    // Return a simplified fallback implementation if LRUCache initialization fails
    return new Map();
  }
};

// Mock ResizeObserver for D3 tests
global.ResizeObserver = class ResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
}; 