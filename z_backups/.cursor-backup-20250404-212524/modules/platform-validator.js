const os = require('os');
const path = require('path');

class PlatformValidator {
  constructor() {
    this.platform = os.platform();
    this.isWindows = this.platform === 'win32';
    this.isMac = this.platform === 'darwin';
    this.isLinux = this.platform === 'linux';
  }

  validatePaths(paths) {
    console.log('[Platform] Validating paths for platform:', this.platform);
    
    const results = paths.map(p => ({
      original: p,
      normalized: this._normalizePath(p),
      isValid: this._isValidPath(p),
      issues: this._findPathIssues(p)
    }));

    return {
      platform: this.platform,
      results,
      summary: this._generatePathSummary(results)
    };
  }

  validateResources(resources) {
    console.log('[Platform] Validating resources for platform:', this.platform);
    
    const validations = {
      memory: this._validateMemoryConfig(resources.memory),
      filesystem: this._validateFilesystem(resources.filesystem),
      permissions: this._validatePermissions(resources.permissions),
      network: this._validateNetwork(resources.network)
    };

    return {
      platform: this.platform,
      validations,
      summary: this._generateResourceSummary(validations)
    };
  }

  validateCompatibility(config) {
    console.log('[Platform] Validating platform compatibility');
    
    const compatibility = {
      paths: this.validatePaths(config.paths || []),
      resources: this.validateResources(config.resources || {}),
      features: this._validateFeatures(config.features || {}),
      dependencies: this._validateDependencies(config.dependencies || [])
    };

    return {
      platform: this.platform,
      compatibility,
      summary: this._generateCompatibilitySummary(compatibility),
      recommendations: this._generateRecommendations(compatibility)
    };
  }

  _normalizePath(p) {
    try {
      return path.normalize(p).replace(/\\/g, '/');
    } catch (error) {
      console.error('[Platform] Path normalization error:', error);
      return p;
    }
  }

  _isValidPath(p) {
    try {
      const normalized = this._normalizePath(p);
      return !normalized.includes('..') && 
             !path.isAbsolute(normalized) &&
             normalized.length <= 260; // Windows MAX_PATH
    } catch (error) {
      console.error('[Platform] Path validation error:', error);
      return false;
    }
  }

  _findPathIssues(p) {
    const issues = [];
    
    if (p.includes('\\')) {
      issues.push('Contains backslashes');
    }
    
    if (p.length > 260 && this.isWindows) {
      issues.push('Exceeds Windows MAX_PATH');
    }
    
    if (p.includes('..')) {
      issues.push('Contains parent directory references');
    }
    
    if (path.isAbsolute(p)) {
      issues.push('Is absolute path');
    }

    return issues;
  }

  _validateMemoryConfig(config) {
    if (!config) return { valid: true, issues: [] };

    const issues = [];
    const limits = {
      win32: { max: 2048 },
      darwin: { max: 4096 },
      linux: { max: 8192 }
    };

    if (config.maxHeap > limits[this.platform].max) {
      issues.push(`Max heap exceeds platform limit: ${limits[this.platform].max}MB`);
    }

    return {
      valid: issues.length === 0,
      issues,
      recommendations: this._getMemoryRecommendations(config)
    };
  }

  _validateFilesystem(config) {
    if (!config) return { valid: true, issues: [] };

    const issues = [];
    
    if (config.watchFiles && this.isWindows) {
      issues.push('File watching may have limitations on Windows');
    }

    if (config.symlinks && this.isWindows) {
      issues.push('Symlink support requires special permissions on Windows');
    }

    return {
      valid: issues.length === 0,
      issues,
      recommendations: this._getFilesystemRecommendations(config)
    };
  }

  _validatePermissions(config) {
    if (!config) return { valid: true, issues: [] };

    const issues = [];
    
    if (config.requiresAdmin && !this._isAdmin()) {
      issues.push('Administrative privileges required');
    }

    return {
      valid: issues.length === 0,
      issues,
      recommendations: this._getPermissionRecommendations(config)
    };
  }

  _validateNetwork(config) {
    if (!config) return { valid: true, issues: [] };

    const issues = [];
    
    if (config.ports) {
      const reservedPorts = this._getReservedPorts();
      config.ports.forEach(port => {
        if (reservedPorts.includes(port)) {
          issues.push(`Port ${port} is reserved on ${this.platform}`);
        }
      });
    }

    return {
      valid: issues.length === 0,
      issues,
      recommendations: this._getNetworkRecommendations(config)
    };
  }

  _validateFeatures(features) {
    const validations = {};
    
    Object.entries(features).forEach(([feature, config]) => {
      validations[feature] = this._validateFeature(feature, config);
    });

    return validations;
  }

  _validateFeature(feature, config) {
    const platformSupport = {
      win32: config.windows || false,
      darwin: config.mac || false,
      linux: config.linux || false
    };

    return {
      supported: platformSupport[this.platform],
      alternatives: config.alternatives || [],
      workarounds: config.workarounds || []
    };
  }

  _validateDependencies(dependencies) {
    return dependencies.map(dep => ({
      name: dep.name,
      version: dep.version,
      compatible: this._isDependencyCompatible(dep),
      issues: this._getDependencyIssues(dep)
    }));
  }

  _isDependencyCompatible(dep) {
    // Implement actual dependency compatibility check
    return true;
  }

  _getDependencyIssues(dep) {
    return [];
  }

  _generatePathSummary(results) {
    return {
      total: results.length,
      valid: results.filter(r => r.isValid).length,
      invalid: results.filter(r => !r.isValid).length,
      issueTypes: this._aggregateIssueTypes(results)
    };
  }

  _generateResourceSummary(validations) {
    return {
      valid: Object.values(validations).every(v => v.valid),
      issueCount: Object.values(validations)
        .reduce((count, v) => count + (v.issues?.length || 0), 0)
    };
  }

  _generateCompatibilitySummary(compatibility) {
    return {
      platform: this.platform,
      overallCompatibility: this._calculateOverallCompatibility(compatibility),
      criticalIssues: this._findCriticalIssues(compatibility),
      recommendations: this._generateRecommendations(compatibility)
    };
  }

  _calculateOverallCompatibility(compatibility) {
    // Implement scoring logic based on various factors
    return {
      score: 0.95,
      confidence: 0.9,
      factors: ['paths', 'resources', 'features', 'dependencies']
    };
  }

  _findCriticalIssues(compatibility) {
    const critical = [];
    
    // Check paths
    if (compatibility.paths.results.some(r => !r.isValid)) {
      critical.push('Invalid paths detected');
    }
    
    // Check resources
    Object.entries(compatibility.resources.validations).forEach(([resource, validation]) => {
      if (!validation.valid) {
        critical.push(`Invalid ${resource} configuration`);
      }
    });

    return critical;
  }

  _generateRecommendations(compatibility) {
    const recommendations = [];
    
    // Path recommendations
    if (compatibility.paths.results.some(r => !r.isValid)) {
      recommendations.push({
        category: 'paths',
        priority: 'high',
        message: 'Fix invalid paths',
        actions: ['Normalize path separators', 'Use relative paths']
      });
    }
    
    // Resource recommendations
    Object.entries(compatibility.resources.validations).forEach(([resource, validation]) => {
      if (!validation.valid) {
        recommendations.push({
          category: 'resources',
          priority: 'high',
          message: `Fix ${resource} configuration`,
          actions: validation.recommendations || []
        });
      }
    });

    return recommendations;
  }

  _aggregateIssueTypes(results) {
    const issueTypes = {};
    
    results.forEach(result => {
      result.issues.forEach(issue => {
        issueTypes[issue] = (issueTypes[issue] || 0) + 1;
      });
    });

    return issueTypes;
  }

  _isAdmin() {
    // Implement actual admin check
    return false;
  }

  _getReservedPorts() {
    return [0, 1, 7, 9, 11, 13, 15, 17, 19, 20, 21, 22, 23, 25, 37, 42, 43, 53, 77, 79, 87, 95, 101, 102, 103, 104, 109, 110, 111, 113, 115, 117, 119, 123, 135, 139, 143, 179, 389, 465, 512, 513, 514, 515, 526, 530, 531, 532, 540, 556, 563, 587, 601, 636, 993, 995, 2049, 4045, 6000];
  }
}

module.exports = { PlatformValidator }; 