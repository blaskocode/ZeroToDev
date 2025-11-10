/**
 * Progress Indicators
 * Manages loading spinners and progress displays
 */

const ora = require('ora');
const colors = require('./colors');

class Spinner {
  constructor(text) {
    this.startTime = Date.now();
    this.spinner = ora({
      text,
      color: 'cyan',
      spinner: 'dots',
    });
  }

  start(text) {
    if (text) this.spinner.text = text;
    this.startTime = Date.now();
    this.spinner.start();
    return this;
  }

  update(text) {
    this.spinner.text = text;
    return this;
  }

  succeed(text) {
    const elapsed = this.getElapsed();
    this.spinner.succeed(`${text} ${colors.time(elapsed)}`);
    return this;
  }

  fail(text) {
    const elapsed = this.getElapsed();
    this.spinner.fail(`${text} ${colors.time(elapsed)}`);
    return this;
  }

  warn(text) {
    const elapsed = this.getElapsed();
    this.spinner.warn(`${text} ${colors.time(elapsed)}`);
    return this;
  }

  info(text) {
    const elapsed = this.getElapsed();
    this.spinner.info(`${text} ${colors.time(elapsed)}`);
    return this;
  }

  stop() {
    this.spinner.stop();
    return this;
  }

  getElapsed() {
    const elapsed = Date.now() - this.startTime;
    if (elapsed < 1000) return `${elapsed}ms`;
    return `${(elapsed / 1000).toFixed(1)}s`;
  }
}

/**
 * Create a new spinner
 * @param {string} text - Initial text to display
 * @returns {Spinner}
 */
function createSpinner(text) {
  return new Spinner(text);
}

/**
 * Run a task with a spinner
 * @param {string} text - Text to display
 * @param {Function} task - Async function to execute
 * @returns {Promise<any>}
 */
async function withSpinner(text, task) {
  const spinner = createSpinner(text).start();
  try {
    const result = await task(spinner);
    spinner.succeed(text);
    return result;
  } catch (error) {
    spinner.fail(`${text} - ${error.message}`);
    throw error;
  }
}

module.exports = {
  createSpinner,
  withSpinner,
  Spinner,
};

