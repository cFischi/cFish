import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ProcessTreeVisualization } from '../../../components/visualization/ProcessTreeVisualization';
import { ProcessNode } from '../../../utils/types';

// Mock the useProcessTree hook to avoid complex setup
jest.mock('../../../hooks/useProcessTree', () => ({
  useProcessTree: jest.fn(() => ({
    metrics: {
      totalProcesses: 10,
      highMemoryProcesses: 2,
      systemProcesses: 5,
      cursorProcesses: 3,
      nodeProcesses: 2,
      totalMemoryUsage: 1024
    },
    anomalies: [],
    lastUpdate: Date.now(),
    renderCount: 1,
    metricsHistory: []
  }))
}));

describe('ProcessTreeVisualization', () => {
  const mockData: ProcessNode = {
    name: 'Root',
    id: 1,
    status: 'active',
    children: [
      {
        name: 'Child 1',
        id: 2,
        status: 'completed',
      },
      {
        name: 'Child 2',
        id: 3,
        status: 'pending',
        children: [
          {
            name: 'Grandchild 1',
            id: 4,
            status: 'error',
          },
        ],
      },
    ],
  };

  const mockOnViewDetails = jest.fn();
  const mockOnAnomalyDetected = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders without crashing', () => {
    const { container } = render(<ProcessTreeVisualization data={mockData} />);
    expect(container.querySelector('svg')).toBeInTheDocument();
    expect(container.querySelector('.metrics-summary')).toBeInTheDocument();
  });

  it('renders with custom dimensions', () => {
    const { container } = render(
      <ProcessTreeVisualization
        data={mockData}
        width={1000}
        height={800}
      />
    );
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
  });

  it('shows metrics when showMetrics is true', () => {
    const { container } = render(
      <ProcessTreeVisualization data={mockData} showMetrics={true} />
    );
    expect(container.querySelector('.metrics-summary')).toBeInTheDocument();
    expect(screen.getByText(/Total Processes:/)).toBeInTheDocument();
    expect(screen.getByText(/High Memory Processes:/)).toBeInTheDocument();
  });

  it('hides metrics when showMetrics is false', () => {
    const { container } = render(
      <ProcessTreeVisualization data={mockData} showMetrics={false} />
    );
    expect(container.querySelector('.metrics-summary')).not.toBeInTheDocument();
  });

  it('calls onViewDetails when an anomaly is clicked', () => {
    // Override the useProcessTree mock just for this test
    require('../../../hooks/useProcessTree').useProcessTree.mockReturnValueOnce({
      metrics: {
        totalProcesses: 10,
        highMemoryProcesses: 2,
        systemProcesses: 5,
        cursorProcesses: 3,
        nodeProcesses: 2,
        totalMemoryUsage: 1024
      },
      anomalies: [{
        processId: 2,
        name: 'Child 1',
        reasons: ['High memory usage'],
        timestamp: new Date().toISOString(),
        severity: 'HIGH'
      }],
      lastUpdate: Date.now(),
      renderCount: 1,
      metricsHistory: []
    });

    render(
      <ProcessTreeVisualization 
        data={mockData} 
        onViewDetails={mockOnViewDetails}
      />
    );
    
    // Now the anomaly should be visible
    const anomalyElement = screen.getByText('Child 1');
    fireEvent.click(anomalyElement);
    
    // Child 1 has id 2, so we should find the node with that id
    expect(mockOnViewDetails).toHaveBeenCalledWith(expect.objectContaining({
      name: 'Child 1',
      id: 2
    }));
  });

  it('passes onAnomalyDetected to the useProcessTree hook', () => {
    const useProcessTreeMock = require('../../../hooks/useProcessTree').useProcessTree;
    
    render(
      <ProcessTreeVisualization 
        data={mockData} 
        onAnomalyDetected={mockOnAnomalyDetected}
      />
    );
    
    // Check that the hook was called with the right parameters
    expect(useProcessTreeMock).toHaveBeenCalledWith(
      mockData,
      expect.objectContaining({
        onAnomalyDetected: mockOnAnomalyDetected
      })
    );
  });

  it('displays an error message when an error occurs during rendering', async () => {
    // Simulate an error by providing invalid data
    const invalidData = null as unknown as ProcessNode;
    
    const { findByText } = render(
      <ProcessTreeVisualization data={invalidData} />
    );
    
    // Error message should be displayed
    const errorMessage = await findByText(/Error:/);
    expect(errorMessage).toBeInTheDocument();
  });

  it('clears error when dismiss button is clicked', async () => {
    // Simulate an error by providing invalid data
    const invalidData = null as unknown as ProcessNode;
    
    const { findByText, queryByText } = render(
      <ProcessTreeVisualization data={invalidData} />
    );
    
    // Error message should be displayed
    const errorMessage = await findByText(/Error:/);
    expect(errorMessage).toBeInTheDocument();
    
    // Click the dismiss button
    const dismissButton = screen.getByText('Dismiss');
    fireEvent.click(dismissButton);
    
    // Error message should be gone
    expect(queryByText(/Error:/)).not.toBeInTheDocument();
  });
}); 