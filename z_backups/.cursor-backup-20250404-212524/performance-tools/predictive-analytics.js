const fs = require('fs');
const path = require('path');

class PredictiveAnalytics {
    constructor(historicalDataPath) {
        this.historicalDataPath = historicalDataPath;
        this.trendWindow = 30; // Days to analyze for trends
    }

    loadHistoricalMetrics() {
        try {
            const data = fs.readFileSync(path.join(this.historicalDataPath, 'historical-metrics.json'));
            return JSON.parse(data);
        } catch (error) {
            console.error('Error loading historical metrics:', error);
            return [];
        }
    }

    analyzeTrends(historicalData) {
        const recentData = historicalData.slice(-this.trendWindow);
        
        return {
            token: this.analyzeTokenTrends(recentData),
            performance: this.analyzePerformanceTrends(recentData),
            optimization: this.analyzeOptimizationTrends(recentData)
        };
    }

    analyzeTokenTrends(data) {
        const tokenUsage = data.map(d => d.tokenMetrics);
        return {
            average: this.calculateAverage(tokenUsage),
            trend: this.calculateTrend(tokenUsage),
            forecast: this.forecastMetric(tokenUsage)
        };
    }

    analyzePerformanceTrends(data) {
        const performance = data.map(d => d.performanceMetrics);
        return {
            average: this.calculateAverage(performance),
            trend: this.calculateTrend(performance),
            forecast: this.forecastMetric(performance)
        };
    }

    analyzeOptimizationTrends(data) {
        const optimization = data.map(d => d.optimizationMetrics);
        return {
            average: this.calculateAverage(optimization),
            trend: this.calculateTrend(optimization),
            forecast: this.forecastMetric(optimization)
        };
    }

    calculateAverage(metrics) {
        return metrics.reduce((sum, val) => sum + val, 0) / metrics.length;
    }

    calculateTrend(metrics) {
        const n = metrics.length;
        if (n < 2) return 0;

        const xMean = (n - 1) / 2;
        const yMean = this.calculateAverage(metrics);

        let numerator = 0;
        let denominator = 0;

        for (let i = 0; i < n; i++) {
            const x = i - xMean;
            const y = metrics[i] - yMean;
            numerator += x * y;
            denominator += x * x;
        }

        return denominator !== 0 ? numerator / denominator : 0;
    }

    forecastMetric(metrics) {
        const trend = this.calculateTrend(metrics);
        const lastValue = metrics[metrics.length - 1];
        
        return {
            nextDay: lastValue + trend,
            nextWeek: lastValue + (trend * 7),
            nextMonth: lastValue + (trend * 30)
        };
    }

    calculateTokenProjection(trends) {
        const { token } = trends;
        
        return {
            projected: token.forecast,
            recommendations: this.generateTokenRecommendations(token)
        };
    }

    predictPerformanceNeeds(trends) {
        const { performance } = trends;
        
        return {
            projected: performance.forecast,
            recommendations: this.generatePerformanceRecommendations(performance)
        };
    }

    generateOptimizationPlan(trends) {
        const { optimization } = trends;
        
        return {
            projectedEfficiency: optimization.forecast,
            recommendations: this.generateOptimizationRecommendations(optimization)
        };
    }

    generateTokenRecommendations(tokenTrends) {
        const recommendations = [];
        
        if (tokenTrends.trend > 0) {
            recommendations.push({
                priority: 'HIGH',
                action: 'Implement token optimization strategies',
                impact: 'Reduce token usage growth rate'
            });
        }
        
        if (tokenTrends.average > tokenTrends.forecast.nextDay) {
            recommendations.push({
                priority: 'MEDIUM',
                action: 'Review token usage patterns',
                impact: 'Maintain current optimization levels'
            });
        }
        
        return recommendations;
    }

    generatePerformanceRecommendations(perfTrends) {
        const recommendations = [];
        
        if (perfTrends.trend < 0) {
            recommendations.push({
                priority: 'HIGH',
                action: 'Investigate performance degradation',
                impact: 'Prevent further performance decline'
            });
        }
        
        if (perfTrends.average < perfTrends.forecast.nextWeek) {
            recommendations.push({
                priority: 'MEDIUM',
                action: 'Implement performance optimizations',
                impact: 'Improve system performance'
            });
        }
        
        return recommendations;
    }

    generateOptimizationRecommendations(optTrends) {
        const recommendations = [];
        
        if (optTrends.trend < 0) {
            recommendations.push({
                priority: 'HIGH',
                action: 'Review optimization strategies',
                impact: 'Reverse negative optimization trend'
            });
        }
        
        if (optTrends.average > optTrends.forecast.nextMonth) {
            recommendations.push({
                priority: 'LOW',
                action: 'Document successful optimization patterns',
                impact: 'Maintain optimization knowledge'
            });
        }
        
        return recommendations;
    }

    async predictResourceNeeds() {
        try {
            const historicalData = this.loadHistoricalMetrics();
            const trends = this.analyzeTrends(historicalData);
            
            return {
                timestamp: new Date().toISOString(),
                tokenPrediction: this.calculateTokenProjection(trends),
                performanceForecast: this.predictPerformanceNeeds(trends),
                optimizationSuggestions: this.generateOptimizationPlan(trends),
                confidence: this.calculatePredictionConfidence(trends)
            };
        } catch (error) {
            console.error('Error in predictive analysis:', error);
            throw error;
        }
    }

    calculatePredictionConfidence(trends) {
        const variability = {
            token: this.calculateVariability(trends.token),
            performance: this.calculateVariability(trends.performance),
            optimization: this.calculateVariability(trends.optimization)
        };
        
        return {
            overall: Math.round((variability.token + variability.performance + variability.optimization) / 3),
            components: variability
        };
    }

    calculateVariability(metricTrends) {
        const trendStrength = Math.abs(metricTrends.trend);
        const variability = Math.abs(metricTrends.forecast.nextDay - metricTrends.average) / metricTrends.average;
        
        return Math.round((1 - variability) * 100);
    }
}

module.exports = PredictiveAnalytics; 