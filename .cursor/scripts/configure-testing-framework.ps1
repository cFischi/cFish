# Testing Framework Configuration Script
# Configures and validates testing framework according to established standards

# Console logging setup
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Testing framework configuration
$testConfig = @{
    "unitTests" = @{
        "framework" = "jest"
        "coverage" = @{
            "statements" = 95
            "branches" = 90
            "functions" = 95
            "lines" = 95
        }
        "quality" = @{
            "mutation" = 85
            "complexity" = 10
        }
    }
    "integrationTests" = @{
        "framework" = "supertest"
        "coverage" = @{
            "apis" = 100
            "workflows" = 90
            "edgeCases" = 85
        }
        "performance" = @{
            "response" = 200
            "throughput" = 1000
        }
    }
    "e2eTests" = @{
        "framework" = "cypress"
        "coverage" = @{
            "criticalPaths" = 100
            "userFlows" = 90
        }
        "performance" = @{
            "pageLoad" = 2000
            "interaction" = 100
        }
    }
}

# Configuration functions
function Initialize-JestConfig {
    Write-Log "Configuring Jest..." "INFO"
    
    $jestConfig = @{
        "preset" = "ts-jest"
        "testEnvironment" = "node"
        "coverageThreshold" = @{
            "global" = @{
                "statements" = $testConfig.unitTests.coverage.statements
                "branches" = $testConfig.unitTests.coverage.branches
                "functions" = $testConfig.unitTests.coverage.functions
                "lines" = $testConfig.unitTests.coverage.lines
            }
        }
        "collectCoverageFrom" = @(
            "src/**/*.{js,jsx,ts,tsx}"
            "!src/**/*.d.ts"
            "!src/**/index.{js,ts}"
            "!src/types/**/*"
        )
    }

    $jestConfig | ConvertTo-Json -Depth 10 | Out-File "jest.config.json"
    Write-Log "Jest configuration complete" "SUCCESS"
}

function Initialize-SupertestConfig {
    Write-Log "Configuring Supertest..." "INFO"
    
    $supertestConfig = @{
        "baseUrl" = "http://localhost:3000"
        "timeout" = 5000
        "retries" = 3
        "coverage" = @{
            "apis" = $testConfig.integrationTests.coverage.apis
            "workflows" = $testConfig.integrationTests.coverage.workflows
            "edgeCases" = $testConfig.integrationTests.coverage.edgeCases
        }
        "performance" = @{
            "responseTime" = $testConfig.integrationTests.performance.response
            "throughput" = $testConfig.integrationTests.performance.throughput
        }
    }

    $supertestConfig | ConvertTo-Json -Depth 10 | Out-File "supertest.config.json"
    Write-Log "Supertest configuration complete" "SUCCESS"
}

function Initialize-CypressConfig {
    Write-Log "Configuring Cypress..." "INFO"
    
    $cypressConfig = @{
        "baseUrl" = "http://localhost:3000"
        "viewportWidth" = 1280
        "viewportHeight" = 720
        "video" = $true
        "screenshotOnRunFailure" = $true
        "coverage" = @{
            "criticalPaths" = $testConfig.e2eTests.coverage.criticalPaths
            "userFlows" = $testConfig.e2eTests.coverage.userFlows
        }
        "performance" = @{
            "pageLoadTimeout" = $testConfig.e2eTests.performance.pageLoad
            "defaultCommandTimeout" = $testConfig.e2eTests.performance.interaction
        }
    }

    $cypressConfig | ConvertTo-Json -Depth 10 | Out-File "cypress.json"
    Write-Log "Cypress configuration complete" "SUCCESS"
}

function Initialize-TestScripts {
    Write-Log "Setting up test scripts..." "INFO"
    
    # Create or update package.json
    if (-not (Test-Path "package.json")) {
        Write-Log "Creating new package.json..." "INFO"
        $packageJson = @{
            "name" = "cfish-io"
            "version" = "1.0.0"
            "description" = "cFish.io platform"
            "main" = "index.js"
            "scripts" = @{}
            "dependencies" = @{}
            "devDependencies" = @{}
        }
    } else {
        Write-Log "Updating existing package.json..." "INFO"
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        if (-not $packageJson.scripts) {
            $packageJson | Add-Member -NotePropertyName "scripts" -NotePropertyValue @{}
        }
    }

    # Update test scripts
    $packageJson.scripts = @{
        "test" = "jest"
        "test:watch" = "jest --watch"
        "test:coverage" = "jest --coverage"
        "test:integration" = "jest --config=jest.integration.config.js"
        "test:e2e" = "cypress run"
        "test:all" = "npm run test && npm run test:integration && npm run test:e2e"
    }

    # Add required dev dependencies
    $packageJson.devDependencies = @{
        "jest" = "^29.7.0"
        "ts-jest" = "^29.1.1"
        "@types/jest" = "^29.5.11"
        "supertest" = "^6.3.3"
        "cypress" = "^13.6.2"
    }

    $packageJson | ConvertTo-Json -Depth 10 | Out-File "package.json"
    Write-Log "Test scripts setup complete" "SUCCESS"
}

# Validation functions
function Test-JestSetup {
    Write-Log "Validating Jest setup..." "INFO"
    
    if (Test-Path "jest.config.json") {
        $config = Get-Content "jest.config.json" | ConvertFrom-Json
        if ($config.coverageThreshold.global.statements -eq $testConfig.unitTests.coverage.statements) {
            Write-Log "Jest configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Jest configuration validation failed" "ERROR"
    return $false
}

function Test-SupertestSetup {
    Write-Log "Validating Supertest setup..." "INFO"
    
    if (Test-Path "supertest.config.json") {
        $config = Get-Content "supertest.config.json" | ConvertFrom-Json
        if ($config.coverage.apis -eq $testConfig.integrationTests.coverage.apis) {
            Write-Log "Supertest configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Supertest configuration validation failed" "ERROR"
    return $false
}

function Test-CypressSetup {
    Write-Log "Validating Cypress setup..." "INFO"
    
    if (Test-Path "cypress.json") {
        $config = Get-Content "cypress.json" | ConvertFrom-Json
        if ($config.coverage.criticalPaths -eq $testConfig.e2eTests.coverage.criticalPaths) {
            Write-Log "Cypress configuration validated" "SUCCESS"
            return $true
        }
    }
    Write-Log "Cypress configuration validation failed" "ERROR"
    return $false
}

# Main execution
Write-Log "Starting testing framework configuration" "INFO"

try {
    # Create necessary directories
    if (-not (Test-Path ".cursor/logs")) {
        New-Item -ItemType Directory -Path ".cursor/logs"
    }
    if (-not (Test-Path "src")) {
        New-Item -ItemType Directory -Path "src"
    }

    # Initialize configurations
    Initialize-JestConfig
    Initialize-SupertestConfig
    Initialize-CypressConfig
    Initialize-TestScripts

    # Validate setup
    $jest_valid = Test-JestSetup
    $supertest_valid = Test-SupertestSetup
    $cypress_valid = Test-CypressSetup
    
    $all_valid = $jest_valid -and $supertest_valid -and $cypress_valid
    
    if ($all_valid) {
        Write-Log "Testing framework configuration complete" "SUCCESS"
    } else {
        throw "Configuration validation failed"
    }

    # Export configuration results
    $results = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "jest_configured" = $jest_valid
        "supertest_configured" = $supertest_valid
        "cypress_configured" = $cypress_valid
        "test_scripts_updated" = $true
        "configuration" = $testConfig
    }

    $results | ConvertTo-Json -Depth 10 | Out-File ".cursor/logs/testing-framework-setup.json"
    Write-Log "Configuration results exported to .cursor/logs/testing-framework-setup.json" "INFO"

} catch {
    Write-Log "Error during configuration: $_" "ERROR"
    exit 1
} 