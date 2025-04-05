# SOP: D3.js Component Testing in React/TypeScript Environment

**Document ID:** UCF-U2.4-D3-TESTING-20250522  
**Version:** 1.0  
**Department:** U2-Research / tYFeAiz  
**Created:** May 22, 2025  

## 1. Purpose

This Standard Operating Procedure (SOP) establishes the methodology for effective testing of D3.js-based visualization components in a React/TypeScript environment. It addresses common testability challenges and provides standardized approaches to ensure consistent quality across all visualization implementations.

## 2. Scope

This SOP applies to all D3.js visualization components developed for the cFish.io ecosystem, particularly:

- Process visualization components
- Resource monitoring dashboards
- Interactive data visualizations
- Cross-platform visualization systems

## 3. Prerequisites

- Node.js environment
- Jest testing framework
- React Testing Library
- D3.js library (version 7.x+)
- TypeScript compiler

## 4. Common D3.js Testing Challenges

### 4.1 DOM Manipulation Conflicts

D3.js directly manipulates the DOM, which conflicts with React's virtual DOM and Jest's JSDOM environment.

**Symptoms:**
- TypeError: `d3.select(...).attr(...).attr is not a function`
- Missing DOM elements in test environment
- Unexpected null references

### 4.2 Selection Chain Issues

D3.js uses method chaining for selections, which can break in test environments.

**Symptoms:**
- TypeError in selection chains
- Undefined method errors
- Selection objects lacking expected methods

### 4.3 SVG Rendering Problems

JSDOM lacks full SVG support needed for D3.js visualizations.

**Symptoms:**
- Missing SVG elements
- Incorrect rendering behaviors
- Layout calculation failures

### 4.4 Event Simulation Difficulties

D3.js event handling often breaks in test environments.

**Symptoms:**
- Events not firing properly in tests
- Zoom/pan behaviors not functioning
- Drag operations failing

## 5. Solution Framework

### 5.1 Specialized Test Environment Setup

```javascript
// jest.config.js
module.exports = {
  // Base configuration
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.ts'],
  
  // D3.js specific settings
  testPathIgnorePatterns: ['/node_modules/'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  
  // Mock configurations
  moduleNameMapper: {
    '\\.scss$': '<rootDir>/src/mocks/styleMock.js',
    'd3': '<rootDir>/src/mocks/d3Mock.js'  // Conditional D3 mocking
  }
};
```

### 5.2 D3.js Component Testing Pattern

Follow this pattern for all D3.js component tests:

```typescript
// processVisualization.test.tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ProcessVisualization } from './ProcessVisualization';
import { mockD3Setup, mockD3Teardown } from '../test-utils/d3TestUtils';

describe('ProcessVisualization', () => {
  // Setup/Teardown with D3 specific handling
  beforeEach(() => {
    mockD3Setup();
  });
  
  afterEach(() => {
    mockD3Teardown();
  });

  // Isolate DOM manipulation tests
  test('renders SVG container correctly', () => {
    const { container } = render(<ProcessVisualization data={mockData} />);
    expect(container.querySelector('svg')).toBeInTheDocument();
  });

  // Mock D3 methods when testing React logic
  test('handles node selection correctly', () => {
    render(<ProcessVisualization data={mockData} onSelect={mockSelectHandler} />);
    
    // Use React Testing Library for React-level interactions
    fireEvent.click(screen.getByTestId('node-1'));
    
    expect(mockSelectHandler).toHaveBeenCalledWith(expect.objectContaining({
      id: 'node-1'
    }));
  });
});
```

### 5.3 D3.js Mocking Strategy

Create specialized D3.js mocks that simplify testing while preserving core behavior:

```typescript
// d3TestUtils.ts
import * as d3 from 'd3';

export const mockD3Setup = () => {
  // Store original D3 methods for restoration
  window.__d3Original = {
    select: d3.select,
    selectAll: d3.selectAll
  };
  
  // Create chainable mock selection object
  const mockSelection = {
    attr: () => mockSelection,
    style: () => mockSelection,
    append: () => mockSelection,
    on: () => mockSelection,
    call: () => mockSelection,
    data: () => mockSelection,
    enter: () => mockSelection,
    exit: () => mockSelection,
    remove: () => mockSelection,
    text: () => mockSelection
  };
  
  // Replace D3 selection methods with mocks
  d3.select = jest.fn().mockImplementation(() => mockSelection);
  d3.selectAll = jest.fn().mockImplementation(() => mockSelection);
};

export const mockD3Teardown = () => {
  // Restore original D3 methods
  if (window.__d3Original) {
    d3.select = window.__d3Original.select;
    d3.selectAll = window.__d3Original.selectAll;
    delete window.__d3Original;
  }
};
```

### 5.4 Test Component Wrapper

Create a specialized wrapper component for visual testing:

```typescript
// D3TestWrapper.tsx
import React, { useEffect, useRef } from 'react';

interface D3TestWrapperProps {
  width?: number;
  height?: number;
  children: React.ReactNode;
  className?: string;
}

export const D3TestWrapper: React.FC<D3TestWrapperProps> = ({
  width = 800,
  height = 600,
  children,
  className = 'd3-test-wrapper'
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    // Simulate browser environment aspects needed by D3
    if (containerRef.current) {
      // Mock getBoundingClientRect for layout calculations
      containerRef.current.getBoundingClientRect = () => ({
        width,
        height,
        x: 0,
        y: 0,
        top: 0,
        left: 0,
        right: width,
        bottom: height,
        toJSON: () => {}
      });
    }
  }, [width, height]);
  
  return (
    <div 
      ref={containerRef} 
      className={className}
      data-testid="d3-container"
      style={{ width: `${width}px`, height: `${height}px` }}
    >
      {children}
    </div>
  );
};
```

## 6. Implementation Process

### 6.1 Refactoring D3.js Components for Testability

1. Separate D3.js logic from React logic:

```typescript
// Bad approach (hard to test)
useEffect(() => {
  const svg = d3.select(svgRef.current)
    .attr('width', width)
    .attr('height', height);
    
  svg.selectAll('circle')
    .data(data)
    .enter()
    .append('circle')
    // more D3 code...
}, [data, width, height]);

// Good approach (testable)
useEffect(() => {
  if (!svgRef.current) return;
  
  // Separate initialization
  const svg = initializeSvg(svgRef.current, width, height);
  
  // Separate data binding
  updateVisualization(svg, data);
}, [data, width, height]);

// Separate testable functions
export const initializeSvg = (element: SVGSVGElement, width: number, height: number) => {
  return d3.select(element)
    .attr('width', width)
    .attr('height', height);
};

export const updateVisualization = (svg: d3.Selection<SVGSVGElement, unknown, null, undefined>, data: any[]) => {
  // D3 visualization logic...
};
```

2. Add test data attributes:

```typescript
// Add test hooks to D3 elements
nodes.append('circle')
  .attr('r', nodeRadius)
  .attr('class', 'node-circle')
  .attr('data-testid', d => `node-${d.id}`);  // Add test ID
```

### 6.2 Testing Implementation Steps

1. Create baseline tests for React functionality
2. Add isolated tests for D3.js manipulation
3. Create integration tests with mocked D3 behavior
4. Add browser-specific tests for critical visualizations

### 6.3 Advanced D3.js Testing

For complex D3.js visualizations, follow this approach:

1. Test event handlers separately from D3 bindings
2. Mock transition behaviors to make tests deterministic
3. Test calculations and data transformations separately
4. Use snapshot testing for SVG output validation

## 7. D3.js Test Troubleshooting Guide

| Issue | Cause | Solution |
|-------|-------|----------|
| `TypeError: d3.select(...).attr(...).attr is not a function` | Selection chain breaking due to null return | Use the D3 mock selection pattern; check element exists |
| `Cannot read property 'getBoundingClientRect' of null` | Missing DOM dimensions needed by D3 layout | Use D3TestWrapper with preset dimensions |
| `Error: Not implemented: window.computedStyle` | JSDOM missing style computation | Mock getComputedStyle or use simple style assertions |
| D3 events not triggering | Event binding issues in test environment | Test event handlers directly; mock D3 event objects |
| SVG elements not found in tests | SVG namespace issues in JSDOM | Add test IDs to elements; use specialized SVG test assertions |
| Performance issues with large datasets | Test environment overhead | Use smaller datasets for tests; focus on edge cases |

## 8. Quality Metrics

Ensure all D3.js components meet these testing metrics:

- **Test Coverage:** Minimum 85% coverage for D3 component code
- **Test Types:** Unit (60%), Integration (30%), Visual (10%)
- **Critical Paths:** 100% coverage of user interactions
- **Performance:** Tests complete in under 5 seconds per component
- **Stability:** No flaky tests (reliability > 99%)

## 9. References

- [D3.js Documentation](https://d3js.org/)
- [Jest Testing Framework](https://jestjs.io/)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- Internal Documentation: `UCF-U2.2-TESTING-FRAMEWORK-20250420.md`

## 10. Revision History

| Version | Date | Description | Author |
|---------|------|-------------|--------|
| 1.0 | 2025-05-22 | Initial SOP creation | AI: Cursor (Claude 3.7 Sonnet) |

## 11. Approval

This SOP complies with the testing standards established by the U2-Research department and the quality metrics defined for the cFish.io platform launch.

_Document generated as per UcF departmental guidelines for SOP creation and management._

_Updated 05-22-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 