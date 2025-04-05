# Safe Installation Guide

## Overview
This guide outlines the safe installation process for the resource management system, using a staged approach to prevent Cursor crashes and resource exhaustion.

## Prerequisites
- Node.js >= 18.0.0
- npm >= 8.0.0
- At least 4GB of available RAM
- Clean npm cache recommended

## Installation Stages

### 1. Core Installation
```bash
# Install core dependencies only
npm run install:core
```
Core dependencies include:
- express@4.18.2: Web server framework
- ws@8.13.0: WebSocket implementation

### 2. Monitoring Tools
```bash
# Wait 30 seconds after core installation, then:
npm run install:monitoring
```
Monitoring dependencies include:
- systeminformation@5.21.24: System metrics collection
- node-os-utils@1.3.7: OS-level utilities

### 3. UI Components
```bash
# Wait 30 seconds after monitoring installation, then:
npm run install:ui
```
UI dependencies include:
- cli-progress@3.12.0: Progress bar utilities
- moment@2.30.1: Time formatting

### 4. ML Components (Optional)
```bash
# Only install if required and system has sufficient resources (8GB+ RAM)
npm run install:ml
```
ML dependencies include:
- @tensorflow/tfjs-node@4.17.0: TensorFlow.js Node.js bindings

## Safety Measures

### Resource Monitoring
- Monitor system resources during installation
- Maintain at least 2GB free RAM
- Keep CPU usage below 80%
- Allow cool-down periods between stages

### Installation Recovery
If installation fails:
1. Clear npm cache: `npm cache clean --force`
2. Remove node_modules: `rm -rf node_modules`
3. Remove package-lock.json: `rm package-lock.json`
4. Start from Stage 1 again

### Testing After Installation
- Run core tests: `npm run test:core`
- Run monitoring tests: `npm run test:monitoring`
- Run full test suite: `npm run test:all`

## Troubleshooting

### Common Issues
1. **Cursor Crashes**
   - Clear Cursor cache
   - Restart Cursor
   - Use staged installation with longer cool-down periods

2. **Resource Exhaustion**
   - Free up system resources
   - Close unnecessary applications
   - Increase cool-down periods between stages

3. **Installation Failures**
   - Check system requirements
   - Verify network connectivity
   - Follow recovery procedures

### When to Seek Help
- Repeated installation failures
- Persistent Cursor crashes
- Unresolved dependency issues
- System resource problems

## Maintenance

### Regular Updates
- Update core dependencies first
- Test after each component update
- Maintain staging approach for updates
- Document any issues encountered

### Health Checks
- Monitor resource usage
- Check for memory leaks
- Verify process isolation
- Test system stability

_Updated 05-07-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 