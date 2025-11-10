/**
 * Color Themes
 * Provides consistent color coding across CLI tools
 */

const chalk = require('chalk');

module.exports = {
  // Status colors
  success: chalk.green,
  error: chalk.red,
  warning: chalk.yellow,
  info: chalk.blue,
  
  // Emphasis
  highlight: chalk.cyan.bold,
  dim: chalk.gray,
  bold: chalk.bold,
  
  // Service-specific colors
  postgres: chalk.hex('#336791'), // PostgreSQL blue
  redis: chalk.hex('#DC382D'),    // Redis red
  node: chalk.hex('#339933'),     // Node.js green
  react: chalk.hex('#61DAFB'),    // React cyan
  docker: chalk.hex('#2496ED'),   // Docker blue
  
  // Status indicators
  ready: chalk.green('✓'),
  failed: chalk.red('✗'),
  waiting: chalk.yellow('⋯'),
  running: chalk.blue('→'),
  
  // Helpers
  service: (name) => chalk.cyan.bold(name),
  url: (url) => chalk.blue.underline(url),
  command: (cmd) => chalk.yellow(cmd),
  file: (path) => chalk.cyan(path),
  time: (duration) => chalk.gray(`[${duration}]`),
};

