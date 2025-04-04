import React, { useMemo } from 'react';
import { ProcessAnomalyInfo } from '../../utils/types';
import styles from '../../styles/ProcessAnomalies.module.scss';

interface ProcessAnomaliesProps {
  anomalies: ProcessAnomalyInfo[];
  onAnomalyClick?: (anomaly: ProcessAnomalyInfo) => void;
  maxDisplayed?: number;
}

export const ProcessAnomalies: React.FC<ProcessAnomaliesProps> = ({
  anomalies,
  onAnomalyClick,
  maxDisplayed = 5,
}) => {
  const sortedAnomalies = useMemo(() => {
    return [...anomalies].sort((a, b) => {
      // Sort by severity first
      if (a.severity !== b.severity) {
        return a.severity === 'HIGH' ? -1 : 1;
      }
      // Then by timestamp (most recent first)
      return new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime();
    }).slice(0, maxDisplayed);
  }, [anomalies, maxDisplayed]);

  if (anomalies.length === 0) {
    return null;
  }

  return (
    <div className={styles.processAnomalies}>
      <h3>Process Anomalies</h3>
      <div className={styles.anomaliesList}>
        {sortedAnomalies.map((anomaly, index) => (
          <div
            key={`${anomaly.processId}-${index}`}
            className={styles.anomalyItem}
            onClick={() => onAnomalyClick?.(anomaly)}
            role="button"
            tabIndex={0}
          >
            <div className={styles.anomalyHeader}>
              <span className={styles.processName}>{anomaly.name}</span>
              <span className={`${styles.severityBadge} ${styles[anomaly.severity.toLowerCase()]}`}>
                {anomaly.severity}
              </span>
            </div>
            <div className={styles.anomalyReasons}>
              {anomaly.reasons.map((reason, i) => (
                <div key={i} className={styles.reasonItem}>
                  • {reason}
                </div>
              ))}
            </div>
            <div className={styles.anomalyTimestamp}>
              {new Date(anomaly.timestamp).toLocaleTimeString()}
            </div>
          </div>
        ))}
      </div>
      {anomalies.length > maxDisplayed && (
        <div className={styles.anomaliesMore}>
          +{anomalies.length - maxDisplayed} more anomalies
        </div>
      )}
    </div>
  );
}; 