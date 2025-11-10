#!/bin/bash

# Enhanced Shutdown Script
# Gracefully stops all services with progress feedback

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
NC='\033[0m' # No Color

# Enhanced shutdown using Node.js CLI utilities
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
const colors = require(path.join(cliPath, 'lib/colors'));

async function main() {
  try {
    logger.blank();
    logger.section('Stopping Development Environment');
    
    // Stop containers
    const stopSpinner = spinner.createSpinner('Stopping containers...').start();
    
    try {
      await execAsync('docker compose down');
      stopSpinner.succeed('All containers stopped');
    } catch (error) {
      stopSpinner.fail('Failed to stop containers');
      logger.error(error.message);
      process.exit(1);
    }

    logger.blank();
    logger.success('Development environment stopped successfully');
    logger.blank();
    logger.info(`To start again: ${colors.command('make dev')}`);
    logger.info(`To clean volumes: ${colors.command('make clean')}`);
    logger.blank();

  } catch (error) {
    logger.blank();
    logger.error(`Unexpected error: ${error.message}`);
    logger.blank();
    process.exit(1);
  }
}

main();
EOF

else
  # Fallback if Node.js is not available
  echo ""
  echo -e "${BLUE}→${NC} Stopping development environment..."
  echo ""
  
  docker compose down
  
  echo ""
  echo -e "${GREEN}✓${NC} Services stopped"
  echo ""
  echo "To start again: make dev"
  echo "To clean volumes: make clean"
  echo ""
fi

