import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { ProcessAnomalies } from '../../../components/visualization/ProcessAnomalies';
import { ProcessAnomalyInfo } from '../../../utils/types';

describe('ProcessAnomalies', () => {
  const mockAnomalies: ProcessAnomalyInfo[] = [
    {
      processId: 1,
      name: 'High CPU Process',
      reasons: ['High CPU usage: 95%'],
      timestamp: '2025-04-15T10:00:00.000Z',
      severity: 'HIGH',
    },
    {
      processId: 2,
      name: 'Memory Intensive Process',
      reasons: ['High memory usage: 2048MB'],
      timestamp: '2025-04-15T10:01:00.000Z',
      severity: 'MEDIUM',
    },
    {
      processId: 3,
      name: 'Multiple Issues Process',
      reasons: [
        'High CPU usage: 98%',
        'High memory usage: 4096MB',
      ],
      timestamp: '2025-04-15T10:02:00.000Z',
      severity: 'HIGH',
    },
  ];

  it('renders nothing when no anomalies are present', () => {
    const { container } = render(<ProcessAnomalies anomalies={[]} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders anomalies sorted by severity and timestamp', () => {
    render(<ProcessAnomalies anomalies={mockAnomalies} />);
    
    const anomalyItems = screen.getAllByRole('button');
    expect(anomalyItems).toHaveLength(3);
    
    // Check sorting (HIGH severity first, then by timestamp)
    const processNames = anomalyItems.map(item => 
      item.querySelector('.process-name')?.textContent
    );
    expect(processNames).toEqual([
      'Multiple Issues Process',
      'High CPU Process',
      'Memory Intensive Process',
    ]);
  });

  it('limits displayed anomalies based on maxDisplayed prop', () => {
    render(<ProcessAnomalies anomalies={mockAnomalies} maxDisplayed={2} />);
    
    const anomalyItems = screen.getAllByRole('button');
    expect(anomalyItems).toHaveLength(2);
    
    const moreText = screen.getByText('+1 more anomalies');
    expect(moreText).toBeInTheDocument();
  });

  it('calls onAnomalyClick when an anomaly is clicked', () => {
    const mockOnClick = jest.fn();
    render(<ProcessAnomalies anomalies={mockAnomalies} onAnomalyClick={mockOnClick} />);
    
    const firstAnomaly = screen.getAllByRole('button')[0];
    fireEvent.click(firstAnomaly);
    
    expect(mockOnClick).toHaveBeenCalledWith(mockAnomalies[2]); // The first displayed anomaly
  });

  it('displays severity badges with correct classes', () => {
    render(<ProcessAnomalies anomalies={mockAnomalies} />);
    
    const highSeverityBadges = screen.getAllByText('HIGH');
    expect(highSeverityBadges).toHaveLength(2);
    expect(highSeverityBadges[0].className).toContain('high');
    
    const mediumSeverityBadge = screen.getByText('MEDIUM');
    expect(mediumSeverityBadge.className).toContain('medium');
  });

  it('displays all reasons for each anomaly', () => {
    render(<ProcessAnomalies anomalies={mockAnomalies} />);
    
    const multipleIssuesProcess = mockAnomalies[2];
    multipleIssuesProcess.reasons.forEach(reason => {
      expect(screen.getByText(`• ${reason}`)).toBeInTheDocument();
    });
  });

  it('displays formatted timestamps', () => {
    render(<ProcessAnomalies anomalies={mockAnomalies} />);
    
    const timestamps = screen.getAllByText(/\d{1,2}:\d{2}:\d{2}/);
    expect(timestamps).toHaveLength(3);
  });
}); 