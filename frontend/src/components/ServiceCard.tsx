import React from 'react';
import type { ServiceHealth } from '../types/health.types';

interface ServiceCardProps {
  name: string;
  service: ServiceHealth;
  icon: string;
}

const ServiceCard: React.FC<ServiceCardProps> = ({ name, service, icon }) => {
  const isHealthy = service.status === 'ok' && service.healthy !== false;
  
  const statusColor = isHealthy
    ? 'bg-green-100 text-green-800 border-green-300'
    : 'bg-red-100 text-red-800 border-red-300';
  
  const iconColor = isHealthy ? 'text-green-600' : 'text-red-600';

  return (
    <div className={`border-2 rounded-lg p-6 transition-all duration-300 hover:shadow-lg ${statusColor}`}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <span className={`text-3xl ${iconColor}`}>{icon}</span>
          <h3 className="text-xl font-semibold">{name}</h3>
        </div>
        <div className={`px-3 py-1 rounded-full text-sm font-medium ${
          isHealthy ? 'bg-green-200 text-green-900' : 'bg-red-200 text-red-900'
        }`}>
          {isHealthy ? 'Healthy' : 'Error'}
        </div>
      </div>
      
      <div className="space-y-2 text-sm">
        <div className="flex justify-between">
          <span className="font-medium">Status:</span>
          <span className="capitalize">{service.status}</span>
        </div>
        
        {service.uptime !== undefined && (
          <div className="flex justify-between">
            <span className="font-medium">Uptime:</span>
            <span>{Math.round(service.uptime)}s</span>
          </div>
        )}
      </div>
    </div>
  );
};

export default ServiceCard;

