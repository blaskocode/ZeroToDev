#!/bin/bash

# Status Dashboard Script
# Displays comprehensive service status information

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI_DIR="$SCRIPT_DIR/cli"

# Change to project root
cd "$PROJECT_ROOT"

# Colors for fallback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Enhanced status display using Node.js CLI utilities
if command -v node >/dev/null 2>&1; then
  node <<'EOF'
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

// Load CLI utilities (using process.cwd() since we're in project root)
const cliPath = path.join(process.cwd(), 'scripts/cli');
const logger = require(path.join(cliPath, 'lib/logger'));
const checks = require(path.join(cliPath, 'lib/checks'));
const colors = require(path.join(cliPath, 'lib/colors'));

async function main() {
  try {
    logger.blank();
    logger.banner('Status');
    
    // Container Status
    logger.section('Container Status');
    
    const containers = [
      { name: 'zero-to-dev-db', display: 'PostgreSQL' },
      { name: 'zero-to-dev-redis', display: 'Redis' },
      { name: 'zero-to-dev-api', display: 'API' },
      { name: 'zero-to-dev-frontend', display: 'Frontend' },
    ];

    for (const container of containers) {
      const { running, status } = await checks.getContainerStatus(container.name);
      logger.serviceStatus(container.display, running, status);
    }

    // Health Check Status
    logger.blank();
    logger.section('Health Check Status');

    const endpoints = [
      { name: 'API Health', url: 'http://localhost:4000/health' },
      { name: 'API Database', url: 'http://localhost:4000/health/db' },
      { name: 'API Cache', url: 'http://localhost:4000/health/cache' },
      { name: 'Frontend', url: 'http://localhost:5173' },
    ];

    for (const endpoint of endpoints) {
      const result = await checks.checkHttpHealth(endpoint.url, 3000);
      logger.serviceStatus(
        endpoint.name,
        result.healthy,
        result.status ? `HTTP ${result.status}` : result.message
      );
    }

    // Port Status
    logger.blank();
    logger.section('Port Status');

    const ports = [
      { port: 5432, service: 'PostgreSQL' },
      { port: 6379, service: 'Redis' },
      { port: 4000, service: 'API' },
      { port: 5173, service: 'Frontend' },
    ];

    for (const { port, service } of ports) {
      const inUse = await checks.isPortInUse(port);
      const process = inUse ? await checks.getProcessOnPort(port) : null;
      const status = inUse ? `In use by ${process || 'unknown'}` : 'Available';
      logger.serviceStatus(service, inUse, `Port ${port} - ${status}`);
    }

    // Docker System Info
    logger.blank();
    logger.section('Docker System Info');

    try {
      const { stdout: psOutput } = await execAsync(
        'docker compose ps --format json 2>/dev/null || docker compose ps'
      );
      
      // Try to get resource usage
      try {
        const { stdout: statsOutput } = await execAsync(
          'docker stats --no-stream --format "table {{.Name}}\\t{{.CPUPerc}}\\t{{.MemUsage}}" 2>/dev/null | grep zero-to-dev || echo "Stats not available"'
        );
        
        if (statsOutput && !statsOutput.includes('Stats not available')) {
          logger.blank();
          logger.info('Resource Usage:');
          console.log(colors.dim(statsOutput.trim()));
        }
      } catch (e) {
        // Stats not available, skip
      }

      // Volume info
      const { stdout: volumeOutput } = await execAsync(
        'docker volume ls --filter name=zerotoDev --format "{{.Name}}: {{.Size}}" 2>/dev/null || echo "Volume info not available"'
      );
      
      if (volumeOutput && !volumeOutput.includes('not available')) {
        logger.blank();
        logger.info('Volumes:');
        console.log(colors.dim(volumeOutput.trim()));
      }

    } catch (error) {
      logger.warning('Unable to fetch detailed Docker info');
    }

    // Service URLs
    logger.blank();
    logger.section('Service URLs');
    logger.showUrl('Frontend', 'http://localhost:5173');
    logger.showUrl('API', 'http://localhost:4000');
    logger.showUrl('API Health', 'http://localhost:4000/health');
    logger.showUrl('Database', 'postgresql://dev:devpass@localhost:5432/appdb');
    logger.showUrl('Redis', 'redis://localhost:6379');

    // Useful Commands
    logger.blank();
    logger.section('Useful Commands');
    logger.list([
      { label: 'View logs (all)', value: colors.command('make logs') },
      { label: 'View logs (API)', value: colors.command('docker compose logs -f api') },
      { label: 'View logs (Frontend)', value: colors.command('docker compose logs -f frontend') },
      { label: 'Restart services', value: colors.command('docker compose restart') },
      { label: 'Stop services', value: colors.command('make down') },
      { label: 'Clean everything', value: colors.command('make clean') },
    ]);

    logger.blank();

  } catch (error) {
    logger.blank();
    logger.error(`Error: ${error.message}`);
    logger.blank();
    process.exit(1);
  }
}

main();
EOF

else
  # Fallback if Node.js is not available
  echo ""
  echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║        Service Status Dashboard       ║${NC}"
  echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
  echo ""
  
  echo -e "${BLUE}Container Status:${NC}"
  docker compose ps
  
  echo ""
  echo -e "${BLUE}Service URLs:${NC}"
  echo "  • Frontend: http://localhost:5173"
  echo "  • API: http://localhost:4000"
  echo "  • Health: http://localhost:4000/health"
  echo ""
  
  echo "View logs: make logs"
  echo ""
fi

