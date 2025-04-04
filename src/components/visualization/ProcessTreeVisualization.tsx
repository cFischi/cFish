import React, { useEffect, useRef, useState } from 'react';
import * as d3 from 'd3';
import { ProcessNode, ProcessAnomalyInfo, D3ProcessNode } from '../../utils/types';
import { useProcessTree } from '../../hooks/useProcessTree';
import { ProcessAnomalies } from './ProcessAnomalies';
import { defaultConfig } from '../../config/visualization.config';
import '../../styles/ProcessTreeVisualization.scss';

interface ProcessTreeVisualizationProps {
  data: ProcessNode;
  width?: number;
  height?: number;
  nodeRadius?: number;
  nodePadding?: number;
  refreshInterval?: number;
  onTerminateProcess?: (processId: number, name: string) => Promise<boolean>;
  onViewDetails?: (process: ProcessNode) => void;
  showMetrics?: boolean;
  protectedProcesses?: string[];
  onAnomalyDetected?: (anomaly: ProcessAnomalyInfo) => void;
}

export const ProcessTreeVisualization: React.FC<ProcessTreeVisualizationProps> = ({
  data,
  width = 800,
  height = 600,
  nodeRadius = 30,
  nodePadding = 20,
  refreshInterval = 5000,
  onTerminateProcess,
  onViewDetails,
  showMetrics = true,
  protectedProcesses = [],
  onAnomalyDetected,
}) => {
  const svgRef = useRef<SVGSVGElement>(null);
  const [error, setError] = useState<string | null>(null);
  
  const {
    metrics,
    anomalies,
    lastUpdate,
    renderCount,
    metricsHistory
  } = useProcessTree(data, {
    config: {
      rendering: {
        mode: 'virtual',
        updateInterval: refreshInterval,
        batchSize: 100,
        maxDepth: 10,
        compression: true,
        compressionThreshold: 1000,
      },
    },
    onAnomalyDetected,
  });

  // Render the visualization
  useEffect(() => {
    if (!svgRef.current || !data) {
      setError("SVG reference or data is missing");
      return;
    }

    try {
      // Clear existing visualization
      const svg = d3.select(svgRef.current);
      if (!svg || typeof svg.selectAll !== 'function') {
        setError("D3 select failed to initialize properly");
        return;
      }
      
      svg.selectAll('*').remove();

      // Create hierarchical layout
      const hierarchyData = d3.hierarchy(data) as d3.HierarchyNode<ProcessNode>;
      if (!hierarchyData) {
        setError("Failed to create hierarchy data");
        return;
      }

      const treeLayout = d3.tree<ProcessNode>()
        .size([height - nodePadding * 2, width - nodePadding * 2]);

      const root = treeLayout(hierarchyData);
      if (!root) {
        setError("Failed to create tree layout");
        return;
      }

      // Create SVG container with zoom support
      svg.attr('width', width)
         .attr('height', height);

      const g = svg.append('g')
                  .attr('transform', `translate(${nodePadding},${nodePadding})`)
                  .attr('class', 'tree-container');

      // Add zoom behavior with proper typing
      const zoom = d3.zoom<SVGSVGElement, unknown>()
                     .scaleExtent([0.1, 4])
                     .on('zoom', (event: d3.D3ZoomEvent<SVGSVGElement, unknown>) => {
                       if (g && typeof g.attr === 'function') {
                         g.attr('transform', event.transform.toString());
                       }
                     });

      if (typeof svg.call === 'function') {
        svg.call(zoom);
      }

      // Create a properly typed linkHorizontal generator
      const linkGenerator = d3.linkHorizontal<d3.HierarchyLink<ProcessNode>, d3.HierarchyNode<ProcessNode>>()
                              .x((d) => (d as unknown as D3ProcessNode).y)
                              .y((d) => (d as unknown as D3ProcessNode).x);

      // Draw links with error handling
      const links = g.selectAll('path.link')
                    .data(root.links())
                    .enter();
      
      if (links && typeof links.append === 'function') {
        links.append('path')
            .attr('class', 'link')
            .attr('d', (d) => linkGenerator(d as any) || '');
      }

      // Create node groups with error handling
      const nodes = g.selectAll('g.node')
                    .data(root.descendants())
                    .enter();
      
      if (nodes && typeof nodes.append === 'function') {
        const nodeGroups = nodes.append('g')
                               .attr('class', (d: any) => `node ${d.data.status || 'default'}`)
                               .attr('transform', (d: any) => `translate(${d.y},${d.x})`);

        // Add node circles with error handling
        if (nodeGroups && typeof nodeGroups.append === 'function') {
          nodeGroups.append('circle')
                   .attr('r', nodeRadius)
                   .attr('class', (d: any) => {
                     const classes = ['node-circle'];
                     if (d.data.status) classes.push(d.data.status);
                     if (d.data.type === 'system') classes.push('system');
                     if (d.data.type === 'cursor') classes.push('cursor');
                     if (d.data.type === 'node') classes.push('node');
                     if (d.data.memoryUsageMB && d.data.memoryUsageMB > defaultConfig.monitoring.thresholds.memory.warning) {
                       classes.push('high-memory');
                     }
                     if (protectedProcesses.includes(d.data.name || '')) {
                       classes.push('protected');
                     }
                     return classes.join(' ');
                   });

          // Add node labels
          nodeGroups.append('text')
                   .attr('dy', '0.3em')
                   .attr('text-anchor', 'middle')
                   .text((d: any) => d.data.name)
                   .attr('class', 'node-label');

          // Add resource indicators if showMetrics is true
          if (showMetrics) {
            // Memory usage indicator
            nodeGroups.filter((d: any) => Boolean(d.data.memoryUsageMB))
                     .append('text')
                     .attr('dy', `${nodeRadius + 15}px`)
                     .attr('text-anchor', 'middle')
                     .text((d: any) => `${Math.round(d.data.memoryUsageMB || 0)} MB`)
                     .attr('class', 'node-metric memory');
            
            // CPU usage indicator
            nodeGroups.filter((d: any) => Boolean(d.data.cpuUsagePercent))
                     .append('text')
                     .attr('dy', `${nodeRadius + 30}px`)
                     .attr('text-anchor', 'middle')
                     .text((d: any) => `${Math.round(d.data.cpuUsagePercent || 0)}% CPU`)
                     .attr('class', 'node-metric cpu');
          }

          // Add tooltips
          nodeGroups.append('title')
                   .text((d: any) => `
                     Name: ${d.data.name}
                     ID: ${d.data.id}
                     Status: ${d.data.status || 'running'}
                     Type: ${d.data.type || 'user'}
                     Memory: ${d.data.memoryUsageMB ? d.data.memoryUsageMB + ' MB' : 'N/A'}
                     CPU: ${d.data.cpuUsagePercent ? d.data.cpuUsagePercent + '%' : 'N/A'}
                     ${d.data.priorityLevel ? `Priority: ${d.data.priorityLevel}` : ''}
                     ${d.data.description ? `Description: ${d.data.description}` : ''}
                     ${protectedProcesses.includes(d.data.name || '') ? 'PROTECTED PROCESS' : ''}
                   `);

          // Add click handlers
          nodeGroups.on('click', (event: MouseEvent, d: any) => {
            event.stopPropagation();
            if (onViewDetails) {
              onViewDetails(d.data);
            }
          });
        }
      }

      // Reset error state if render is successful
      setError(null);
    } catch (err) {
      // Handle any errors that occur during rendering
      setError(`Error rendering process tree: ${err instanceof Error ? err.message : String(err)}`);
      console.error('Error rendering process tree:', err);
    }
  }, [data, width, height, nodeRadius, nodePadding, showMetrics, protectedProcesses, onViewDetails]);

  return (
    <div className="process-tree-visualization">
      {error && (
        <div className="error-message">
          <p>Error: {error}</p>
          <button onClick={() => setError(null)}>Dismiss</button>
        </div>
      )}
      
      <svg ref={svgRef} />
      
      {showMetrics && (
        <div className="metrics-summary">
          <div>Total Processes: {metrics.totalProcesses}</div>
          <div>High Memory Processes: {metrics.highMemoryProcesses}</div>
          <div>System Processes: {metrics.systemProcesses}</div>
          <div>Cursor Processes: {metrics.cursorProcesses}</div>
          <div>Node Processes: {metrics.nodeProcesses}</div>
          <div>Total Memory Usage: {Math.round(metrics.totalMemoryUsage)} MB</div>
          <div>Last Update: {new Date(lastUpdate).toLocaleTimeString()}</div>
          <div>Render Count: {renderCount}</div>
        </div>
      )}

      <ProcessAnomalies
        anomalies={anomalies}
        onAnomalyClick={process => {
          if (onViewDetails && process.processId) {
            const node = data.children?.find(n => n.id === process.processId);
            if (node) {
              onViewDetails(node);
            }
          }
        }}
      />
    </div>
  );
}; 