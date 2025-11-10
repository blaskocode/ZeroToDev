# CLI Utilities

Enhanced command-line interface with colorized output and progress indicators.

## Overview

This package provides a suite of CLI utilities that enhance the developer experience with:
- **Colorized output** - Consistent color themes across all scripts
- **Progress spinners** - Visual feedback for long-running operations
- **Pretty boxes** - Attention-grabbing messages with boxen
- **ASCII art** - Beautiful banners with figlet
- **Health checks** - Automated service health verification
- **Structured logging** - Timestamped, leveled log messages

## Installation

Dependencies are automatically installed when you run the enhanced scripts. To manually install:

```bash
cd scripts/cli
npm install
```

## Structure

```
cli/
├── package.json          # Dependencies (chalk, ora, boxen, figlet)
├── index.js              # Main exports
└── lib/
    ├── colors.js         # Color themes and helpers
    ├── spinner.js        # Progress indicators
    ├── logger.js         # Structured logging
    └── checks.js         # Health check utilities
```

## Usage in Scripts

### Colors

```javascript
const colors = require('./lib/colors');

console.log(colors.success('Operation successful!'));
console.log(colors.error('Something went wrong'));
console.log(colors.warning('Be careful'));
console.log(colors.info('FYI: useful information'));
console.log(colors.highlight('IMPORTANT MESSAGE'));

// Status indicators
console.log(colors.ready + ' Service is ready');
console.log(colors.failed + ' Service failed');

// Helpers
console.log('Visit ' + colors.url('http://localhost:3000'));
console.log('Run ' + colors.command('make dev'));
console.log('Edit ' + colors.file('src/index.ts'));
```

### Spinners

```javascript
const spinner = require('./lib/spinner');

// Simple usage
const mySpinner = spinner.createSpinner('Loading...').start();
// ... do work ...
mySpinner.succeed('Done!');

// With error handling
const s = spinner.createSpinner('Processing...').start();
try {
  // ... do work ...
  s.succeed('Processed successfully');
} catch (error) {
  s.fail('Processing failed');
}

// With async function
await spinner.withSpinner('Running task', async (s) => {
  // ... async work ...
  // Spinner automatically succeeds on completion
});
```

### Logger

```javascript
const logger = require('./lib/logger');

// Log messages with timestamps and icons
logger.info('Starting operation');
logger.success('Operation completed');
logger.warning('This might be a problem');
logger.error('Something went wrong');
logger.debug('Detailed debugging info');

// Display banner
logger.banner('My App');

// Display boxed message
logger.box('Important Message', { borderColor: 'green' });

// Section headers
logger.section('Database Setup');

// Service status
logger.serviceStatus('PostgreSQL', true, 'Port 5432');
logger.serviceStatus('API', false, 'Connection failed');

// URLs
logger.showUrl('Frontend', 'http://localhost:3000');

// Lists
logger.list([
  { label: 'Command', value: 'make dev' },
  { label: 'Status', value: 'Running', status: '✓' },
]);
```

### Health Checks

```javascript
const checks = require('./lib/checks');

// Check if port is in use
const inUse = await checks.isPortInUse(4000);

// Get process using a port
const process = await checks.getProcessOnPort(4000);

// Check Docker status
const dockerRunning = await checks.isDockerRunning();
const composeAvailable = await checks.isDockerComposeAvailable();

// Check container status
const { running, status } = await checks.getContainerStatus('my-container');

// Check HTTP endpoint
const result = await checks.checkHttpHealth('http://localhost:4000/health');
console.log(result.healthy); // true/false

// Wait for endpoint to become healthy
const healthy = await checks.waitForHealthy('http://localhost:4000/health', {
  maxAttempts: 30,
  interval: 2000,
  timeout: 5000,
});

// Check multiple services
const results = await checks.checkAllServices({
  'API': 'http://localhost:4000/health',
  'Frontend': 'http://localhost:3000',
});
```

## Scripts Using These Utilities

- **scripts/dev.sh** - Enhanced startup with progress and health checks
- **scripts/down.sh** - Graceful shutdown with feedback
- **scripts/status.sh** - Comprehensive status dashboard

## Color Themes

### Status Colors
- `success` - Green
- `error` - Red  
- `warning` - Yellow
- `info` - Blue

### Service Colors
- `postgres` - PostgreSQL blue (#336791)
- `redis` - Redis red (#DC382D)
- `node` - Node.js green (#339933)
- `react` - React cyan (#61DAFB)
- `docker` - Docker blue (#2496ED)

### Status Indicators
- `ready` - Green checkmark (✓)
- `failed` - Red cross (✗)
- `waiting` - Yellow ellipsis (⋯)
- `running` - Blue arrow (→)

## Requirements

- Node.js >= 20.0.0
- npm >= 10.0.0

## Dependencies

- **chalk** (^4.1.2) - Terminal string styling
- **ora** (^5.4.1) - Elegant terminal spinners
- **boxen** (^5.1.2) - Create boxes in the terminal
- **figlet** (^1.7.0) - ASCII art from text
- **axios** (^1.6.2) - HTTP client for health checks

## Development

To test CLI utilities:

```bash
cd scripts/cli
node -e "const logger = require('./lib/logger'); logger.banner('Test');"
```

## License

MIT

