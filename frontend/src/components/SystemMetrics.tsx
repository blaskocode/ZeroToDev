import React from 'react';
import type { SystemMetrics as SystemMetricsType } from '../types/health.types';

interface SystemMetricsProps {
  metrics: SystemMetricsType;
}

const SystemMetrics: React.FC<SystemMetricsProps> = ({ metrics }) => {
  const memoryPercentage = (metrics.memory.used / metrics.memory.total) * 100;
  
  return (
    <div className="bg-white dark:bg-gray-800 border-2 border-gray-300 dark:border-gray-600 rounded-lg p-6">
      <h3 className="text-xl font-semibold mb-4 flex items-center gap-2">
        <span className="text-blue-600">📊</span>
        System Metrics
      </h3>
      
      <div className="space-y-4">
        <div>
          <div className="flex justify-between text-sm mb-2">
            <span className="font-medium">Memory Usage</span>
            <span>{metrics.memory.used} / {metrics.memory.total} {metrics.memory.unit}</span>
          </div>
          <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3">
            <div 
              className={`h-3 rounded-full transition-all duration-300 ${
                memoryPercentage > 80 ? 'bg-red-600' : 
                memoryPercentage > 60 ? 'bg-yellow-600' : 
                'bg-green-600'
              }`}
              style={{ width: `${memoryPercentage}%` }}
            />
          </div>
          <div className="text-xs text-gray-600 dark:text-gray-400 mt-1">
            {memoryPercentage.toFixed(1)}% used
          </div>
        </div>
        
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <span className="font-medium block text-gray-600 dark:text-gray-400">Uptime</span>
            <span className="text-lg">{metrics.uptime}s</span>
          </div>
          <div>
            <span className="font-medium block text-gray-600 dark:text-gray-400">Platform</span>
            <span className="text-lg capitalize">{metrics.platform}</span>
          </div>
          <div className="col-span-2">
            <span className="font-medium block text-gray-600 dark:text-gray-400">Node Version</span>
            <span className="text-lg">{metrics.nodeVersion}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SystemMetrics;

