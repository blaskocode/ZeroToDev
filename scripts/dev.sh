#!/bin/bash

# Enhanced Development Environment Startup Script
# Provides colorized output, progress indicators, and health checks

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI_DIR="$SCRIPT_DIR/cli"

# Change to project root
cd "$PROJECT_ROOT"

# Colors for fallback (if Node.js fails)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Track start time
START_TIME=$(date +%s)

# Function to get elapsed time
elapsed_time() {
  local end_time=$(date +%s)
  local elapsed=$((end_time - START_TIME))
  echo "${elapsed}s"
}

# Enhanced startup using Node.js CLI utilities
if command -v node >/dev/null 2>&1; then
  node <<'EOF'
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

// Load CLI utilities (using process.cwd() since we're in project root)
const cliPath = path.join(process.cwd(), 'scripts/cli');
const logger = require(path.join(cliPath, 'lib/logger'));
const spinner = require(path.join(cliPath, 'lib/spinner'));
const checks = require(path.join(cliPath, 'lib/checks'));
const colors = require(path.join(cliPath, 'lib/colors'));

const startTime = Date.now();

// Service URLs
const SERVICES = {
  'API Health': 'http://localhost:4000/health',
  'Frontend': 'http://localhost:5173',
};

async function main() {
  try {
    // Display banner
    logger.banner('Zero to Dev');
    logger.info('Starting development environment...');
    logger.blank();

    // Step 1: Prerequisites check
    logger.section('Prerequisites Check');
    
    let preCheckSpinner = spinner.createSpinner('Checking Docker...').start();
    const dockerRunning = await checks.isDockerRunning();
    if (!dockerRunning) {
      preCheckSpinner.fail('Docker is not running');
      logger.error('Please start Docker Desktop and try again');
      logger.blank();
      process.exit(1);
    }
    preCheckSpinner.succeed('Docker is running');

    preCheckSpinner = spinner.createSpinner('Checking Docker Compose...').start();
    const composeAvailable = await checks.isDockerComposeAvailable();
    if (!composeAvailable) {
      preCheckSpinner.fail('Docker Compose not available');
      logger.error('Please install Docker Compose and try again');
      logger.blank();
      process.exit(1);
    }
    preCheckSpinner.succeed('Docker Compose is available');

    preCheckSpinner = spinner.createSpinner('Checking .env file...').start();
    const envExists = await checks.envFileExists();
    if (!envExists) {
      preCheckSpinner.warn('.env file not found');
      logger.warning('Creating .env from .env.example...');
      await execAsync('cp .env.example .env');
      logger.success('.env file created');
    } else {
      preCheckSpinner.succeed('.env file exists');
    }

    // Step 2: Port check
    logger.blank();
    logger.section('Port Availability Check');
    
    const ports = [
      { port: 5432, service: 'PostgreSQL' },
      { port: 6379, service: 'Redis' },
      { port: 4000, service: 'API' },
      { port: 5173, service: 'Frontend' },
    ];

    for (const { port, service } of ports) {
      const inUse = await checks.isPortInUse(port);
      if (inUse) {
        const process = await checks.getProcessOnPort(port);
        logger.warning(`Port ${port} (${service}) is in use by: ${process}`);
        logger.info(`If this is a previous instance, run: ${colors.command('make down')}`);
      } else {
        logger.serviceStatus(service, true, `Port ${port} available`);
      }
    }

    // Step 3: Start services
    logger.blank();
    logger.section('Starting Services');
    
    const startSpinner = spinner.createSpinner('Building and starting Docker containers...').start();
    
    try {
      await execAsync('docker compose up -d --build', { maxBuffer: 10 * 1024 * 1024 });
      startSpinner.succeed('All containers started');
    } catch (error) {
      startSpinner.fail('Failed to start containers');
      logger.error(error.message);
      logger.blank();
      logger.info(`View logs with: ${colors.command('make logs')}`);
      process.exit(1);
    }

    // Step 4: Wait for services
    logger.blank();
    logger.section('Health Checks');
    
    logger.info('Waiting for services to be ready (this may take 30-60 seconds)...');
    logger.blank();

    // Check PostgreSQL
    let dbSpinner = spinner.createSpinner('PostgreSQL').start();
    const dbHealthy = await waitForContainer('zero-to-dev-db', 30);
    if (dbHealthy) {
      dbSpinner.succeed('PostgreSQL is healthy');
    } else {
      dbSpinner.fail('PostgreSQL failed to start');
    }

    // Check Redis
    let redisSpinner = spinner.createSpinner('Redis').start();
    const redisHealthy = await waitForContainer('zero-to-dev-redis', 30);
    if (redisHealthy) {
      redisSpinner.succeed('Redis is healthy');
    } else {
      redisSpinner.fail('Redis failed to start');
    }

    // Check API
    let apiSpinner = spinner.createSpinner('API').start();
    const apiHealthy = await checks.waitForHealthy('http://localhost:4000/health', {
      maxAttempts: 30,
      interval: 2000,
    });
    if (apiHealthy) {
      apiSpinner.succeed('API is healthy');
    } else {
      apiSpinner.fail('API failed to start');
      logger.warning('Check API logs with: docker compose logs api');
    }

    // Check Frontend
    let frontendSpinner = spinner.createSpinner('Frontend').start();
    const frontendHealthy = await checks.waitForHealthy('http://localhost:5173', {
      maxAttempts: 30,
      interval: 2000,
    });
    if (frontendHealthy) {
      frontendSpinner.succeed('Frontend is healthy');
    } else {
      frontendSpinner.fail('Frontend failed to start');
      logger.warning('Check frontend logs with: docker compose logs frontend');
    }

    // Step 5: Display success message
    const allHealthy = dbHealthy && redisHealthy && apiHealthy && frontendHealthy;
    
    logger.blank();
    
    if (allHealthy) {
      const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
      
      logger.box(
        colors.success('✓ Development Environment Ready!\n\n') +
        colors.dim('All services are running and healthy\n') +
        colors.dim(`Total startup time: ${totalTime}s`),
        { borderColor: 'green', padding: 1 }
      );

      logger.blank();
      logger.section('Access Your Services');
      logger.showUrl('Frontend (React + Vite)', 'http://localhost:5173');
      logger.showUrl('API (Express)', 'http://localhost:4000');
      logger.showUrl('API Health Check', 'http://localhost:4000/health');
      logger.showUrl('Database (PostgreSQL)', 'localhost:5432');
      logger.showUrl('Cache (Redis)', 'localhost:6379');
      
      logger.blank();
      logger.section('Useful Commands');
      logger.list([
        { label: 'View logs', value: colors.command('make logs') },
        { label: 'Check status', value: colors.command('make status') },
        { label: 'Stop services', value: colors.command('make down') },
        { label: 'Clean everything', value: colors.command('make clean') },
      ]);
      
      logger.blank();
      logger.info('Happy coding! 🚀');
      logger.blank();
    } else {
      logger.box(
        colors.warning('⚠ Some services failed to start\n\n') +
        'Check the logs above for details',
        { borderColor: 'yellow', padding: 1 }
      );
      logger.blank();
      logger.info(`View detailed logs: ${colors.command('make logs')}`);
      logger.blank();
    }

  } catch (error) {
    logger.blank();
    logger.error(`Unexpected error: ${error.message}`);
    logger.blank();
    process.exit(1);
  }
}

// Helper function to wait for container health
async function waitForContainer(containerName, maxAttempts) {
  for (let i = 0; i < maxAttempts; i++) {
    const { running } = await checks.getContainerStatus(containerName);
    if (running) {
      // Additional check: verify container is actually healthy
      await new Promise(resolve => setTimeout(resolve, 1000));
      return true;
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  return false;
}

main();
EOF

else
  # Fallback if Node.js is not available
  echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║     Zero-to-Dev Environment           ║${NC}"
  echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BLUE}ℹ${NC} Starting development environment..."
  echo ""
  
  # Check Docker
  if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}✗${NC} Docker is not installed"
    exit 1
  fi
  
  if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}✗${NC} Docker is not running"
    echo -e "${YELLOW}⚠${NC} Please start Docker Desktop and try again"
    exit 1
  fi
  
  echo -e "${GREEN}✓${NC} Docker is running"
  
  # Check .env
  if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠${NC} .env file not found, creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✓${NC} .env file created"
  fi
  
  # Start services
  echo ""
  echo -e "${BLUE}→${NC} Starting Docker containers..."
  docker compose up -d --build
  
  echo ""
  echo -e "${GREEN}✓${NC} Services started"
  echo ""
  echo "Access your services:"
  echo "  • Frontend: http://localhost:5173"
  echo "  • API: http://localhost:4000"
  echo "  • Health: http://localhost:4000/health"
  echo ""
  echo "View logs: make logs"
  echo ""
fi

