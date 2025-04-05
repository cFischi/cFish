# D3.js Mocking Infrastructure Implementation Plan

**Document ID:** UCF-U2.4-D3-MOCKING-PLAN-20250522  
**Version:** 1.0  
**Department:** U2-Research / tYFeAiz  
**Status:** [RELAUNCH-CRITICAL]  
**Target Completion:** May 24, 2025

## 1. Overview

This implementation plan focuses on creating the D3.js mocking infrastructure needed to properly test the ProcessTreeVisualization component and other D3.js-based visualizations in the .cursor system. This is identified as a critical path item for the UcF launch.

## 2. Current Issues

1. D3.js selection chain breaks in test environment
2. JSDOM lacks full SVG support for D3 operations
3. D3 event handling doesn't work properly in tests
4. Layout calculations fail due to missing DOM dimensions
5. Tests involving D3 are unreliable and often fail

## 3. Implementation Phases

### Phase 1: Core D3 Mocking System (Day 1)

| # | Task | Description | Est. Hours | Dependencies |
|---|------|-------------|------------|--------------|
| 1.1 | Create mock directory structure | Set up `/src/test-utils/d3` folder structure | 0.5 | None |
| 1.2 | Implement basic selection mocking | Create mock D3 selection class with chainable methods | 2 | 1.1 |
| 1.3 | Implement attr/style API | Add attribute and style manipulation methods | 1 | 1.2 |
| 1.4 | Implement DOM manipulation API | Add append, insert, remove methods | 1.5 | 1.3 |
| 1.5 | Implement data binding API | Add data, enter, exit, join methods | 2 | 1.4 |
| 1.6 | Create setup/teardown utilities | Implement mockD3Setup/mockD3Teardown functions | 1 | 1.2-1.5 |
| 1.7 | Test basic mocking | Write tests for the mocking system itself | 1.5 | 1.6 |
| **Phase 1 Total** ||| **9.5** ||

### Phase 2: Advanced D3 Features (Day 1-2)

| # | Task | Description | Est. Hours | Dependencies |
|---|------|-------------|------------|--------------|
| 2.1 | Implement event handling mocks | Add event binding and simulation | 2 | 1.6 |
| 2.2 | Implement transition mocks | Create deterministic transition mocks | 2 | 1.6 |
| 2.3 | Add hierarchy mocking | Mock tree and hierarchy functions | 1.5 | 1.6 |
| 2.4 | Add zoom behavior mocking | Create mock zoom behavior | 2 | 2.1 |
| 2.5 | Implement scale mocking | Add scale functions with predictable output | 1 | 1.6 |
| 2.6 | Add layout calculation mocks | Create force, tree layout mocks | 2 | 2.3 |
| 2.7 | Test advanced features | Write tests for advanced feature mocks | 2 | 2.1-2.6 |
| **Phase 2 Total** ||| **12.5** ||

### Phase 3: Test Environment Integration (Day 2)

| # | Task | Description | Est. Hours | Dependencies |
|---|------|-------------|------------|--------------|
| 3.1 | Create Jest setup file | Add D3 mocking to Jest setup | 1 | 1.6, 2.7 |
| 3.2 | Implement DOM emulation | Create DOM dimensions emulation for layouts | 2 | 1.6 |
| 3.3 | Create SVG namespace handling | Add SVG namespace support for JSDOM | 1.5 | 3.2 |
| 3.4 | Build test wrapper component | Implement D3TestWrapper component | 2 | 3.1-3.3 |
| 3.5 | Create testing utilities | Add helper functions for D3 testing | 1.5 | 3.4 |
| 3.6 | Write documentation | Document the complete mocking system | 1.5 | 3.1-3.5 |
| 3.7 | Test full integration | Verify integration with Jest | 1 | 3.1-3.6 |
| **Phase 3 Total** ||| **10.5** ||

## 4. File Structure

```
src/
├── test-utils/
│   ├── d3/
│   │   ├── index.ts                 # Main export file
│   │   ├── mocks/
│   │   │   ├── selection.ts         # Selection mocking
│   │   │   ├── transition.ts        # Transition mocking
│   │   │   ├── event.ts             # Event handling mocks
│   │   │   ├── hierarchy.ts         # Hierarchy mocking
│   │   │   ├── zoom.ts              # Zoom behavior mocks
│   │   │   ├── scale.ts             # Scale function mocks
│   │   │   └── layout.ts            # Layout algorithm mocks
│   │   ├── setup.ts                 # Setup/teardown utilities
│   │   ├── wrapper.tsx              # Testing wrapper component
│   │   └── utils.ts                 # Helper utilities
│   └── __tests__/                   # Tests for the mocking system
│       ├── selection.test.ts
│       ├── transition.test.ts
│       └── ...
├── setupTests.ts                    # Jest setup file
└── mocks/
    └── d3Mock.js                    # Module mock for Jest
```

## 5. Implementation Details

### 5.1 Core D3 Selection Mock

```typescript
// src/test-utils/d3/mocks/selection.ts
export class MockSelection {
  private _elements: Element[] = [];
  private _data: any[] = [];
  
  constructor(elements: Element | Element[] = []) {
    this._elements = Array.isArray(elements) ? elements : [elements];
  }
  
  // Chainable methods
  attr(name: string, value?: any): this {
    // Implementation that tracks attributes
    return this;
  }
  
  style(name: string, value?: any): this {
    // Implementation that tracks styles
    return this;
  }
  
  append(type: string): MockSelection {
    // Create mock elements and track them
    const newElements = this._elements.map(() => {
      // Create element of correct type
      return document.createElement(type);
    });
    
    return new MockSelection(newElements);
  }
  
  data(data: any[]): MockSelection {
    // Clone selection and attach data
    const clone = new MockSelection(this._elements);
    clone._data = data;
    return clone;
  }
  
  enter(): MockSelection {
    // Create enter selection
    return new MockSelection();
  }
  
  exit(): MockSelection {
    // Create exit selection
    return new MockSelection();
  }
  
  // Add more methods as needed
}
```

### 5.2 Setup/Teardown Utilities

```typescript
// src/test-utils/d3/setup.ts
import * as d3 from 'd3';
import { MockSelection } from './mocks/selection';

declare global {
  interface Window {
    __d3Original?: {
      select: typeof d3.select;
      selectAll: typeof d3.selectAll;
      // Add other methods as needed
    };
  }
}

export function mockD3Setup(): void {
  // Store original methods
  window.__d3Original = {
    select: d3.select,
    selectAll: d3.selectAll,
    // Store other methods
  };
  
  // Replace with mocks
  const mockSelect = jest.fn().mockImplementation(
    (selector) => new MockSelection(
      typeof selector === 'string' 
        ? document.querySelectorAll(selector)
        : [selector]
    )
  );
  
  d3.select = mockSelect as any;
  d3.selectAll = mockSelect as any;
  
  // Replace other methods
}

export function mockD3Teardown(): void {
  // Restore original methods
  if (window.__d3Original) {
    d3.select = window.__d3Original.select;
    d3.selectAll = window.__d3Original.selectAll;
    // Restore other methods
    
    delete window.__d3Original;
  }
}
```

### 5.3 Test Wrapper Component

```typescript
// src/test-utils/d3/wrapper.tsx
import React, { useEffect, useRef } from 'react';

interface D3TestWrapperProps {
  width?: number;
  height?: number;
  children: React.ReactNode;
  className?: string;
  id?: string;
}

export const D3TestWrapper: React.FC<D3TestWrapperProps> = ({
  width = 800,
  height = 600,
  children,
  className = 'd3-test-container',
  id = 'test-container'
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    if (!containerRef.current) return;
    
    // Mock getBoundingClientRect
    containerRef.current.getBoundingClientRect = jest.fn().mockReturnValue({
      width,
      height,
      top: 0,
      left: 0,
      right: width,
      bottom: height,
      x: 0,
      y: 0,
      toJSON: () => {}
    });
    
    // Add SVG namespace handling if needed
    const svgElement = containerRef.current.querySelector('svg');
    if (svgElement) {
      // Mock SVG methods/properties
    }
  }, [width, height]);
  
  return (
    <div 
      ref={containerRef} 
      className={className}
      id={id}
      data-testid="d3-test-container"
      style={{ width: `${width}px`, height: `${height}px` }}
    >
      {children}
    </div>
  );
};
```

### 5.4 Jest Integration

```typescript
// src/setupTests.ts
import '@testing-library/jest-dom';
import { mockD3Setup, mockD3Teardown } from './test-utils/d3';

// Automatically setup D3 mocks for all tests
beforeEach(() => {
  mockD3Setup();
});

afterEach(() => {
  mockD3Teardown();
});

// Mock window properties needed by D3
Object.defineProperty(window, 'getComputedStyle', {
  value: () => ({
    getPropertyValue: (prop: string) => {
      return '';
    }
  })
});
```

## 6. Testing Strategy

1. **Unit Test Mocking System**:
   - Test each mock component in isolation
   - Verify chainable methods work correctly
   - Ensure mock objects behave like real D3

2. **Integration Test with Components**:
   - Test D3TestWrapper with simple D3 components
   - Verify DOM interactions work as expected
   - Test event handling

3. **Apply to ProcessTreeVisualization**:
   - Create tests for ProcessTreeVisualization using mocks
   - Validate visualization renders correctly
   - Test interaction behavior

## 7. Resource Requirements

- **Developer Time**: 32.5 hours (estimated total)
- **Technical Knowledge**:
  - D3.js
  - Jest
  - React Testing Library
  - TypeScript
  - SVG manipulation

## 8. Risk Assessment and Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|------------|------------|
| D3.js API changes | Medium | Low | Focus on core APIs first; version-pin D3.js |
| Jest environment limitations | High | Medium | Create workarounds for JSDOM limitations |
| Incomplete mocking | High | Medium | Prioritize features used in ProcessTreeVisualization |
| Performance issues | Medium | Low | Optimize mock objects for performance |
| Complex event handling | High | High | Implement simplified event system first, then enhance |

## 9. Success Criteria

1. **Test Reliability**: ProcessTreeVisualization tests pass consistently
2. **Coverage**: Achieve >85% test coverage for visualization components
3. **Maintainability**: Documentation and examples for all mock components
4. **Performance**: Tests run in <5 seconds for ProcessTreeVisualization
5. **Integration**: Works with existing Jest configuration

## 10. Dependencies

- Jest testing framework
- D3.js library
- React Testing Library
- JSDOM environment

## 11. Deliverables

1. D3.js mocking library in `src/test-utils/d3`
2. Jest integration in `src/setupTests.ts`
3. D3TestWrapper component for DOM emulation
4. Documentation and usage examples
5. Tests for the mocking system itself
6. Updated ProcessTreeVisualization tests using the new mocking system

## 12. Post-Implementation Tasks

1. **Knowledge Transfer**:
   - Update team documentation with mocking approach
   - Create examples for common D3.js testing scenarios
   - Document troubleshooting for common issues

2. **Maintenance Plan**:
   - Review D3.js updates for API changes
   - Update mocks as needed for new visualizations
   - Track test performance and optimize as needed

## 13. Implementation Schedule

| Day | Focus | Key Milestones |
|-----|-------|----------------|
| Day 1 (May 23) | Core Mocking, Advanced Features | Complete Phases 1 & 2 |
| Day 2 (May 24) | Test Environment Integration | Complete Phase 3, ProcessTreeVisualization tests pass |

_Updated 05-22-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 