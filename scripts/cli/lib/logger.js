/**
 * Structured Logger
 * Provides consistent logging with levels and pretty formatting
 */

const chalk = require('chalk');
const boxen = require('boxen');
const figlet = require('figlet');
const colors = require('./colors');

/**
 * Get current timestamp
 * @returns {string}
 */
function timestamp() {
  const now = new Date();
  return now.toLocaleTimeString('en-US', { hour12: false });
}

/**
 * Log info message
 * @param {string} message
 */
function info(message) {
  console.log(`${colors.dim(timestamp())} ${colors.info('ℹ')} ${message}`);
}

/**
 * Log success message
 * @param {string} message
 */
function success(message) {
  console.log(`${colors.dim(timestamp())} ${colors.success('✓')} ${message}`);
}

/**
 * Log warning message
 * @param {string} message
 */
function warning(message) {
  console.log(`${colors.dim(timestamp())} ${colors.warning('⚠')} ${message}`);
}

/**
 * Log error message
 * @param {string} message
 */
function error(message) {
  console.log(`${colors.dim(timestamp())} ${colors.error('✗')} ${message}`);
}

/**
 * Log debug message (dimmed)
 * @param {string} message
 */
function debug(message) {
  console.log(`${colors.dim(timestamp())} ${colors.dim('→')} ${colors.dim(message)}`);
}

/**
 * Display a banner with ASCII art
 * @param {string} text - Text to display
 */
function banner(text) {
  console.log('\n');
  console.log(colors.highlight(
    figlet.textSync(text, {
      font: 'Standard',
      horizontalLayout: 'default',
    })
  ));
  console.log('\n');
}

/**
 * Display a boxed message
 * @param {string} message - Message to display
 * @param {Object} options - Boxen options
 */
function box(message, options = {}) {
  const defaultOptions = {
    padding: 1,
    margin: 1,
    borderStyle: 'round',
    borderColor: 'cyan',
  };
  console.log(boxen(message, { ...defaultOptions, ...options }));
}

/**
 * Display section header
 * @param {string} title
 */
function section(title) {
  console.log('\n' + colors.highlight(`━━━ ${title} ━━━`) + '\n');
}

/**
 * Display a list of items
 * @param {Array<{label: string, value: string, status?: string}>} items
 */
function list(items) {
  items.forEach(item => {
    const status = item.status || '';
    const label = colors.dim(`${item.label}:`);
    console.log(`  ${status} ${label} ${item.value}`);
  });
}

/**
 * Display a blank line
 */
function blank() {
  console.log('');
}

/**
 * Display service status
 * @param {string} name - Service name
 * @param {boolean} healthy - Whether service is healthy
 * @param {string} [message] - Optional message
 */
function serviceStatus(name, healthy, message = '') {
  const icon = healthy ? colors.ready : colors.failed;
  const status = healthy ? colors.success('HEALTHY') : colors.error('UNHEALTHY');
  const msg = message ? colors.dim(` - ${message}`) : '';
  console.log(`  ${icon} ${colors.service(name.padEnd(12))} ${status}${msg}`);
}

/**
 * Display URL with label
 * @param {string} label - Label for the URL
 * @param {string} url - URL to display
 */
function showUrl(label, url) {
  console.log(`  ${colors.ready} ${colors.dim(`${label}:`)} ${colors.url(url)}`);
}

module.exports = {
  info,
  success,
  warning,
  error,
  debug,
  banner,
  box,
  section,
  list,
  blank,
  serviceStatus,
  showUrl,
  timestamp,
};

