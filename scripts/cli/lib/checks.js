/**
 * Health Checks
 * Utilities for checking service health and availability
 */

const axios = require('axios');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

/**
 * Check if a port is in use
 * @param {number} port - Port number to check
 * @returns {Promise<boolean>}
 */
async function isPortInUse(port) {
  try {
    const { stdout } = await execAsync(`lsof -i :${port} -sTCP:LISTEN -t`);
    return stdout.trim().length > 0;
  } catch (error) {
    return false;
  }
}

/**
 * Get process using a port
 * @param {number} port - Port number to check
 * @returns {Promise<string|null>}
 */
async function getProcessOnPort(port) {
  try {
    const { stdout } = await execAsync(`lsof -i :${port} -sTCP:LISTEN -t`);
    const pid = stdout.trim();
    if (!pid) return null;
    
    const { stdout: processInfo } = await execAsync(`ps -p ${pid} -o comm=`);
    return processInfo.trim();
  } catch (error) {
    return null;
  }
}

/**
 * Check if Docker daemon is running
 * @returns {Promise<boolean>}
 */
async function isDockerRunning() {
  try {
    await execAsync('docker info');
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Check if Docker Compose is available
 * @returns {Promise<boolean>}
 */
async function isDockerComposeAvailable() {
  try {
    await execAsync('docker compose version');
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Get Docker container status
 * @param {string} containerName - Name of the container
 * @returns {Promise<{running: boolean, status: string}>}
 */
async function getContainerStatus(containerName) {
  try {
    const { stdout } = await execAsync(
      `docker ps -a --filter "name=${containerName}" --format "{{.Status}}"`
    );
    const status = stdout.trim();
    const running = status.toLowerCase().includes('up');
    return { running, status: status || 'Not found' };
  } catch (error) {
    return { running: false, status: 'Error checking status' };
  }
}

/**
 * Check HTTP endpoint health
 * @param {string} url - URL to check
 * @param {number} timeout - Request timeout in ms
 * @returns {Promise<{healthy: boolean, status?: number, message?: string}>}
 */
async function checkHttpHealth(url, timeout = 5000) {
  try {
    const response = await axios.get(url, { timeout });
    return {
      healthy: response.status === 200,
      status: response.status,
      message: 'OK',
    };
  } catch (error) {
    return {
      healthy: false,
      status: error.response?.status,
      message: error.message,
    };
  }
}

/**
 * Poll endpoint until healthy or timeout
 * @param {string} url - URL to check
 * @param {Object} options - Options
 * @param {number} options.maxAttempts - Maximum number of attempts
 * @param {number} options.interval - Interval between attempts in ms
 * @param {number} options.timeout - Request timeout in ms
 * @returns {Promise<boolean>}
 */
async function waitForHealthy(url, options = {}) {
  const {
    maxAttempts = 30,
    interval = 2000,
    timeout = 5000,
  } = options;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const result = await checkHttpHealth(url, timeout);
    if (result.healthy) {
      return true;
    }
    
    if (attempt < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, interval));
    }
  }
  
  return false;
}

/**
 * Check all services health
 * @param {Object} services - Map of service names to URLs
 * @returns {Promise<Object>} - Map of service names to health status
 */
async function checkAllServices(services) {
  const results = {};
  
  for (const [name, url] of Object.entries(services)) {
    results[name] = await checkHttpHealth(url);
  }
  
  return results;
}

/**
 * Get Docker Compose service logs
 * @param {string} service - Service name
 * @param {number} lines - Number of lines to get
 * @returns {Promise<string>}
 */
async function getServiceLogs(service, lines = 50) {
  try {
    const { stdout } = await execAsync(
      `docker compose logs --tail=${lines} ${service}`
    );
    return stdout;
  } catch (error) {
    return `Error getting logs: ${error.message}`;
  }
}

/**
 * Check if .env file exists
 * @returns {Promise<boolean>}
 */
async function envFileExists() {
  try {
    const { stdout } = await execAsync('test -f .env && echo "exists"');
    return stdout.trim() === 'exists';
  } catch (error) {
    return false;
  }
}

module.exports = {
  isPortInUse,
  getProcessOnPort,
  isDockerRunning,
  isDockerComposeAvailable,
  getContainerStatus,
  checkHttpHealth,
  waitForHealthy,
  checkAllServices,
  getServiceLogs,
  envFileExists,
};

