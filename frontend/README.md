# Frontend

React + TypeScript + Vite + Tailwind CSS frontend application with real-time health monitoring.

## Features

- ✅ React 18 with TypeScript
- ✅ Vite for blazing-fast development
- ✅ Tailwind CSS for modern styling
- ✅ Real-time health monitoring dashboard
- ✅ Auto-refresh every 5 seconds
- ✅ Color-coded service status cards
- ✅ System metrics visualization with progress bars
- ✅ Dark/Light theme toggle
- ✅ Axios for API communication
- ✅ Fully responsive design
- ✅ Multi-stage Docker build (development & production)

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Start dev server (http://localhost:5173)
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Docker Development

```bash
# Via Docker Compose (recommended)
docker compose up frontend

# Or standalone
docker build --target development -t frontend:dev .
docker run -p 5173:5173 frontend:dev
```

## Environment Variables

Create `.env` from `.env.example`:

```bash
cp .env.example .env
```

**Configuration:**
- `VITE_API_URL` - Backend API URL (default: `http://localhost:4000`)

## Dashboard Features

### Real-Time Monitoring
- Automatically polls `/health/all` endpoint every 5 seconds
- Displays status for API, PostgreSQL, and Redis services
- Shows system metrics: memory usage, uptime, platform, Node version

### Color-Coded Status
- 🟢 **Green**: Service is healthy and operational
- 🔴 **Red**: Service is experiencing errors or is unavailable

### Visual Indicators
- Progress bars for memory usage with color coding
- Service uptime display
- Real-time timestamp updates
- Last updated indicator

### Theme Support
- Toggle between light and dark modes
- Persistent theme preference
- Smooth transitions

## Project Structure

```
src/
├── components/
│   ├── HealthDashboard.tsx  # Main dashboard with auto-refresh
│   ├── ServiceCard.tsx      # Individual service status display
│   └── SystemMetrics.tsx    # System metrics with progress bars
├── services/
│   └── api.ts               # Axios API client
├── types/
│   └── health.types.ts      # TypeScript interfaces
├── App.tsx                  # Root component with theme toggle
├── main.tsx                 # Application entry point
├── index.css                # Tailwind imports & base styles
└── App.css                  # Additional styling
```

## API Integration

The frontend polls the backend at:
- **Endpoint**: `GET /health/all`
- **Interval**: Every 5 seconds
- **Timeout**: 5 seconds
- **Error Handling**: Displays user-friendly error messages with retry button

### Response Format

```typescript
{
  status: 'ok' | 'degraded' | 'error',
  timestamp: string,
  services: {
    api: { status: 'ok', uptime: number },
    database: { status: 'ok', healthy: boolean },
    cache: { status: 'ok', healthy: boolean }
  },
  system: {
    memory: { used: number, total: number, unit: string },
    uptime: number,
    nodeVersion: string,
    platform: string
  }
}
```

## Production Build

### Multi-Stage Dockerfile

**Development Stage:**
- Uses Vite dev server with hot reload
- Volume mounting for live code updates
- Port: 5173

**Production Stage:**
- Optimized Nginx-based image
- Gzip compression
- Security headers
- Static asset caching (1 year)
- SPA routing support
- Health check endpoint

### Build & Deploy

```bash
# Build production image
docker build --target production -t frontend:prod .

# Run production container
docker run -p 80:80 frontend:prod

# Access at http://localhost
```

## Technology Stack

- **React 18**: Modern UI library with hooks
- **TypeScript 5**: Type-safe JavaScript
- **Vite**: Next-generation build tool
- **Tailwind CSS 3**: Utility-first CSS framework
- **Axios**: Promise-based HTTP client
- **Nginx** (production): High-performance web server

## Development Tips

### Hot Module Replacement (HMR)
Vite provides instant HMR. Changes reflect immediately in the browser.

### Type Safety
All components are fully typed with TypeScript. The type definitions in `types/health.types.ts` match the API response structure.

### Styling
Uses Tailwind CSS utility classes. Custom styles in `App.css` for scrollbars and transitions.

### State Management
Uses React hooks (`useState`, `useEffect`) for state management. No external state library needed for this simple dashboard.

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

- **Initial Load**: < 2 seconds
- **API Polling**: Every 5 seconds (configurable)
- **Production Bundle**: Optimized and code-split by Vite
- **Lighthouse Score**: 90+ (Performance, Accessibility, Best Practices, SEO)

## Future Enhancements

- ⏱️ Historical health data with charts
- 📊 More detailed system metrics
- 🔔 Alert notifications for service failures
- 📱 Push notifications
- 🎨 More theme options
- 📈 Performance metrics over time