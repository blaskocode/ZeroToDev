import axios from 'axios';
import type { HealthStatus, ComprehensiveHealth, RootInfo } from '../types/health.types';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000';

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

