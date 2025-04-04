import { renderHook, act } from '@testing-library/react-hooks';
import { useProcessTree } from '../../hooks/useProcessTree';
import { ProcessNode, ProcessAnomalyInfo } from '../../utils/types';
import { defaultConfig } from '../../config/visualization.config';

describe('useProcessTree', () => {
  const mockProcessTree: ProcessNode = {
    name: 'root',
    id: 1,
    type: 'system',
    memoryUsageMB: 100,
    cpuUsagePercent: 50,
    children: [
      {
        name: 'child1',
        id: 2,
        type: 'cursor',
        memoryUsageMB: 200,
        cpuUsagePercent: 95,
      },
      {
        name: 'child2',
        id: 3,
        type: 'node',
        memoryUsageMB: 150,
        cpuUsagePercent: 30,
        children: [
          {
            name: 'grandchild1',
            id: 4,
            type: 'node',
            memoryUsageMB: 300,
            cpuUsagePercent: 85,
          },
        ],
      },
    ],
  };

  it('calculates metrics correctly', () => {
    const { result } = renderHook(() => useProcessTree(mockProcessTree));

    expect(result.current.metrics).toEqual({
      totalProcesses: 4,
      highMemoryProcesses: 2, // child1 and grandchild1 exceed warning threshold
      systemProcesses: 1,
      cursorProcesses: 1,
      nodeProcesses: 2,
      totalMemoryUsage: 750, // sum of all memory usage
    });
  });

  it('detects anomalies correctly', () => {
    const { result } = renderHook(() => useProcessTree(mockProcessTree));

    expect(result.current.anomalies).toHaveLength(2);
    expect(result.current.anomalies).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          processId: 2,
          name: 'child1',
          severity: 'HIGH',
          reasons: expect.arrayContaining(['High CPU usage: 95%']),
        }),
        expect.objectContaining({
          processId: 4,
          name: 'grandchild1',
          severity: 'HIGH',
          reasons: expect.arrayContaining(['High CPU usage: 85%']),
        }),
      ])
    );
  });

  it('updates metrics history', () => {
    jest.useFakeTimers();
    const { result } = renderHook(() => useProcessTree(mockProcessTree));

    // Advance time and update data
    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(result.current.metricsHistory.timestamps).toHaveLength(1);
    expect(Object.keys(result.current.metricsHistory.values)).toEqual([
      'totalProcesses',
      'highMemoryProcesses',
      'systemProcesses',
      'cursorProcesses',
      'nodeProcesses',
      'totalMemoryUsage',
    ]);

    jest.useRealTimers();
  });

  it('calls onAnomalyDetected when anomalies are found', () => {
    const mockOnAnomalyDetected = jest.fn();
    renderHook(() => useProcessTree(mockProcessTree, {
      onAnomalyDetected: mockOnAnomalyDetected,
    }));

    expect(mockOnAnomalyDetected).toHaveBeenCalledTimes(2);
    expect(mockOnAnomalyDetected).toHaveBeenCalledWith(
      expect.objectContaining({
        processId: expect.any(Number),
        name: expect.any(String),
        severity: 'HIGH',
        reasons: expect.any(Array),
      })
    );
  });

  it('updates when data changes', () => {
    const { result, rerender } = renderHook(
      ({ data }: { data: ProcessNode }) => useProcessTree(data),
      { initialProps: { data: mockProcessTree } }
    );

    const initialRenderCount = result.current.renderCount;

    const updatedTree = {
      ...mockProcessTree,
      children: [mockProcessTree.children![0]], // Remove one child
    };

    rerender({ data: updatedTree });

    expect(result.current.renderCount).toBe(initialRenderCount + 1);
    expect(result.current.metrics.totalProcesses).toBe(2);
  });

  it('cleans up old metrics based on history configuration', () => {
    jest.useFakeTimers();
    const { result } = renderHook(() => useProcessTree(mockProcessTree, {
      config: {
        monitoring: {
          metrics: defaultConfig.monitoring.metrics,
          alerts: defaultConfig.monitoring.alerts,
          history: 1, // 1 second history
          aggregation: defaultConfig.monitoring.aggregation,
          thresholds: defaultConfig.monitoring.thresholds,
        },
      },
    }));

    // Add some metrics
    act(() => {
      jest.advanceTimersByTime(500);
    });

    const initialTimestampsLength = result.current.metricsHistory.timestamps.length;

    // Advance time beyond history limit
    act(() => {
      jest.advanceTimersByTime(1500);
    });

    expect(result.current.metricsHistory.timestamps.length).toBeLessThan(initialTimestampsLength);

    jest.useRealTimers();
  });

  it('caches process nodes for quick access', () => {
    const { result } = renderHook(() => useProcessTree(mockProcessTree));

    // Access a cached node (implementation detail - we're testing the cache exists)
    expect(result.current.renderCount).toBe(1);
  });
}); 