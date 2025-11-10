#!/usr/bin/env node

/**
 * Zero-to-Dev CLI
 * Main entry point for CLI utilities
 */

const colors = require('./lib/colors');
const spinner = require('./lib/spinner');
const logger = require('./lib/logger');
const checks = require('./lib/checks');

module.exports = {
  colors,
  spinner,
  logger,
  checks,
};

