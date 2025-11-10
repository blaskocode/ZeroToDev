/**
 * HealthDashboard Component
 * 
 * Main dashboard that displays real-time health status of all services.
 * Polls the API every 5 seconds for updates and displays service cards
 * and system metrics.
 * 
 * @component
 */

import React, { useState, useEffect } from 'react';
import { getComprehensiveHealth } from '../services/api';
import type { ComprehensiveHealth } from '../types/health.types';
import ServiceCard from './ServiceCard';
import SystemMetrics from './SystemMetrics';

/**
 * HealthDashboard displays comprehensive health information for all services.
 * Includes automatic polling every 5 seconds and error handling.
 * 
 * @returns {JSX.Element} The health dashboard component
 */
const HealthDashboard: React.FC = () => {
  const [health, setHealth] = useState<ComprehensiveHealth | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date());

  /**
   * Fetch health status from the API.
   * Updates state with health data or error message.
   * 
   * @async
   * @function fetchHealth
   */
  const fetchHealth = async () => {
    try {
      const data = await getComprehensiveHealth();
      setHealth(data);
      setError(null);
      setLastUpdated(new Date());
    } catch (err) {
      setError('Failed to fetch health status. Is the API running?');
      console.error('Health check error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchHealth();

    // Set up polling every 5 seconds
    const interval = setInterval(fetchHealth, 5000);

    // Cleanup on unmount
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
          <p className="text-lg text-gray-600 dark:text-gray-400">Loading health status...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center p-4">
        <div className="bg-red-100 border-2 border-red-300 rounded-lg p-8 max-w-md">
          <div className="text-red-600 text-5xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-red-900 mb-2">Connection Error</h2>
          <p className="text-red-800 mb-4">{error}</p>
          <button
            onClick={fetchHealth}
            className="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  if (!health) {
    return null;
  }

  const overallStatus = health.status;
  const isHealthy = overallStatus === 'ok';

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8 px-4">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <header className="mb-8">
          <div className="flex items-center justify-between flex-wrap gap-4">
            <div>
              <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">
                Zero-to-Dev Health Monitor
              </h1>
              <p className="text-gray-600 dark:text-gray-400">
                Real-time service health monitoring dashboard
              </p>
            </div>
            <div className={`px-6 py-3 rounded-full text-lg font-semibold ${
              isHealthy 
                ? 'bg-green-100 text-green-800 border-2 border-green-300' 
                : 'bg-yellow-100 text-yellow-800 border-2 border-yellow-300'
            }`}>
              {isHealthy ? '✓ All Systems Operational' : '⚠ System Degraded'}
            </div>
          </div>
          
          <div className="mt-4 text-sm text-gray-500 dark:text-gray-400">
            Last updated: {lastUpdated.toLocaleTimeString()} • Auto-refreshes every 5 seconds
          </div>
        </header>

        {/* Services Grid */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <ServiceCard 
            name="API Service" 
            service={health.services.api} 
            icon="🚀"
          />
          <ServiceCard 
            name="PostgreSQL Database" 
            service={health.services.database} 
            icon="🗄️"
          />
          <ServiceCard 
            name="Redis Cache" 
            service={health.services.cache} 
            icon="⚡"
          />
        </div>

        {/* System Metrics */}
        <SystemMetrics metrics={health.system} />

        {/* Footer Info */}
        <div className="mt-8 text-center text-sm text-gray-500 dark:text-gray-400">
          <p>API Status: {health.status} • Timestamp: {new Date(health.timestamp).toLocaleString()}</p>
        </div>
      </div>
    </div>
  );
};

export default HealthDashboard;

