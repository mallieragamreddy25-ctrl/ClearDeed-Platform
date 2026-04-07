/**
 * @file API service for ClearDeed Admin Panel
 * Handles all HTTP requests to the backend
 */

import axios, { AxiosInstance, AxiosError } from 'axios';
import { API_BASE_URL, API_TIMEOUT, ERROR_MESSAGES } from '@utils/constants';
import { ApiResponse, PaginatedResponse } from '@types/index';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: API_TIMEOUT,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add token to requests if it exists
    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('authToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Handle response errors
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expired or invalid
          localStorage.removeItem('authToken');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  /**
   * Handle API errors
   */
  private handleError(error: AxiosError): string {
    if (error.response) {
      return error.response.data?.message || error.message;
    }
    if (error.request) {
      return ERROR_MESSAGES.networkError;
    }
    return ERROR_MESSAGES.unknownError;
  }

  /**
   * GET request
   */
  async get<T>(endpoint: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.get<ApiResponse<T>>(endpoint, { params });
      return response.data;
    } catch (error) {
      const message = this.handleError(error as AxiosError);
      return { success: false, error: message };
    }
  }

  /**
   * POST request
   */
  async post<T>(endpoint: string, data?: Record<string, any>): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.post<ApiResponse<T>>(endpoint, data);
      return response.data;
    } catch (error) {
      const message = this.handleError(error as AxiosError);
      return { success: false, error: message };
    }
  }

  /**
   * PUT request
   */
  async put<T>(endpoint: string, data?: Record<string, any>): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.put<ApiResponse<T>>(endpoint, data);
      return response.data;
    } catch (error) {
      const message = this.handleError(error as AxiosError);
      return { success: false, error: message };
    }
  }

  /**
   * DELETE request
   */
  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.delete<ApiResponse<T>>(endpoint);
      return response.data;
    } catch (error) {
      const message = this.handleError(error as AxiosError);
      return { success: false, error: message };
    }
  }

  /**
   * GET paginated data
   */
  async getPaginated<T>(
    endpoint: string,
    page: number = 1,
    pageSize: number = 10,
    filters?: Record<string, any>
  ): Promise<ApiResponse<PaginatedResponse<T>>> {
    return this.get<PaginatedResponse<T>>(endpoint, {
      page,
      pageSize,
      ...filters,
    });
  }
}

// Export singleton instance
export const apiClient = new ApiClient();

/**
 * Dashboard API endpoints
 */
export const dashboardApi = {
  getMetrics: () => apiClient.get('/dashboard/metrics'),
  getActivities: (limit: number = 10) =>
    apiClient.get('/dashboard/activities', { limit }),
};

/**
 * Property API endpoints
 */
export const propertyApi = {
  getProperties: (page: number = 1, filters?: Record<string, any>) =>
    apiClient.getPaginated('/properties', page, 10, filters),
  getProperty: (id: string) => apiClient.get(`/properties/${id}`),
  verifyProperty: (id: string, data: Record<string, any>) =>
    apiClient.post(`/properties/${id}/verify`, data),
  rejectProperty: (id: string, notes: string) =>
    apiClient.post(`/properties/${id}/reject`, { notes }),
};

/**
 * Deal API endpoints
 */
export const dealApi = {
  getDeals: (page: number = 1, filters?: Record<string, any>) =>
    apiClient.getPaginated('/deals', page, 10, filters),
  getDeal: (id: string) => apiClient.get(`/deals/${id}`),
  createDeal: (data: Record<string, any>) => apiClient.post('/deals', data),
  closeDeal: (id: string, data: Record<string, any>) =>
    apiClient.post(`/deals/${id}/close`, data),
  cancelDeal: (id: string, reason: string) =>
    apiClient.post(`/deals/${id}/cancel`, { reason }),
};

/**
 * Commission API endpoints
 */
export const commissionApi = {
  getCommissions: (page: number = 1, filters?: Record<string, any>) =>
    apiClient.getPaginated('/commissions', page, 10, filters),
  getCommission: (id: string) => apiClient.get(`/commissions/${id}`),
  approveCommission: (id: string, approvalData: Record<string, any>) =>
    apiClient.post(`/commissions/${id}/approve`, approvalData),
  rejectCommission: (id: string, reason: string) =>
    apiClient.post(`/commissions/${id}/reject`, { reason }),
  payCommission: (id: string, paymentData: Record<string, any>) =>
    apiClient.post(`/commissions/${id}/pay`, paymentData),
};

/**
 * Agent API endpoints
 */
export const agentApi = {
  getAgents: (page: number = 1, filters?: Record<string, any>) =>
    apiClient.getPaginated('/agents', page, 10, filters),
  getAgent: (id: string) => apiClient.get(`/agents/${id}`),
  registerAgent: (data: Record<string, any>) => apiClient.post('/agents', data),
  updateAgent: (id: string, data: Record<string, any>) =>
    apiClient.put(`/agents/${id}`, data),
  recordMaintenanceFee: (id: string, data: Record<string, any>) =>
    apiClient.post(`/agents/${id}/maintenance-fee`, data),
  suspendAgent: (id: string, reason: string) =>
    apiClient.post(`/agents/${id}/suspend`, { reason }),
};

/**
 * Report API endpoints
 */
export const reportApi = {
  getCommissionLedger: (filters?: Record<string, any>) =>
    apiClient.get('/reports/commission-ledger', filters),
  exportCommissionReport: (format: 'csv' | 'pdf') =>
    apiClient.post('/reports/export', { format }),
  getPropertyMetrics: () => apiClient.get('/reports/properties-metrics'),
  getDealMetrics: () => apiClient.get('/reports/deals-metrics'),
  getAgentMetrics: () => apiClient.get('/reports/agents-metrics'),
};
