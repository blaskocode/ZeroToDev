export interface HealthStatus {
  status: 'ok' | 'error' | 'degraded';
  timestamp: string;
  message?: string;
}

export interface ServiceHealth {
  status: 'ok' | 'error';
  healthy?: boolean;
  uptime?: number;
}

export interface SystemMetrics {
  memory: {
    used: number;
    total: number;
    unit: string;
  };
  uptime: number;
  nodeVersion: string;
  platform: string;
}

export interface ComprehensiveHealth {
  status: 'ok' | 'degraded' | 'error';
  timestamp: string;
  services: {
    api: ServiceHealth;
    database: ServiceHealth;
    cache: ServiceHealth;
  };
  system: SystemMetrics;
}

export interface RootInfo {
  service: string;
  version: string;
  status: string;
  timestamp: string;
  endpoints: {
    health: string;
    healthDb: string;
    healthCache: string;
    healthAll: string;
  };
}

