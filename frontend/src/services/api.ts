import axios from 'axios';
import type { HealthStatus, ComprehensiveHealth, RootInfo } from '../types/health.types';

// Runtime configuration: Use window.__API_URL__ if available (injected at runtime),
// otherwise fall back to VITE_API_URL (build-time) or relative URL (production)
const getApiUrl = (): string => {
  // Runtime configuration (injected by nginx/config script)
  if (typeof window !== 'undefined' && (window as any).__API_URL__) {
    return (window as any).__API_URL__;
  }
  
  // Build-time configuration (for local development)
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  
  // Production fallback: use relative URL since frontend and API are on same ALB
  // This works because the ALB routes /health* to the API
  if (import.meta.env.PROD) {
    return ''; // Relative URL - same origin
  }
  
  // Development fallback
  return 'http://localhost:4000';
};

const API_URL = getApiUrl();

const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.message);
    return Promise.reject(error);
  }
);

/**
 * Get root API information
 */
export const getRootInfo = async (): Promise<RootInfo> => {
  const response = await apiClient.get<RootInfo>('/');
  return response.data;
};

/**
 * Get basic health status
 */
export const getHealth = async (): Promise<HealthStatus> => {
  const response = await apiClient.get<HealthStatus>('/health');
  return response.data;
};

/**
 * Get database health status
 */
export const getDatabaseHealth = async (): Promise<HealthStatus> => {
  const response = await apiClient.get<HealthStatus>('/health/db');
  return response.data;
};

/**
 * Get cache health status
 */
export const getCacheHealth = async (): Promise<HealthStatus> => {
  const response = await apiClient.get<HealthStatus>('/health/cache');
  return response.data;
};

/**
 * Get comprehensive health status (all services)
 */
export const getComprehensiveHealth = async (): Promise<ComprehensiveHealth> => {
  const response = await apiClient.get<ComprehensiveHealth>('/health/all');
  return response.data;
};

export default {
  getRootInfo,
  getHealth,
  getDatabaseHealth,
  getCacheHealth,
  getComprehensiveHealth,
};

