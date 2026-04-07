/**
 * @file Custom React hooks for ClearDeed Admin Panel
 */

import { useState, useEffect, useCallback } from 'react';
import { ApiResponse } from '@types/index';

interface UseApiOptions {
  skip?: boolean;
  refetchInterval?: number;
}

interface UseApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

/**
 * Custom hook for handling API requests
 * @example
 * const { data, loading, error, refetch } = useApi(
 *   () => apiClient.get('/endpoint'),
 *   { refetchInterval: 30000 }
 * )
 */
export function useApi<T>(
  apiCall: () => Promise<ApiResponse<T>>,
  options: UseApiOptions = {}
) {
  const [state, setState] = useState<UseApiState<T>>({
    data: null,
    loading: false,
    error: null,
  });

  const fetchData = useCallback(async () => {
    setState((prev) => ({ ...prev, loading: true, error: null }));
    try {
      const response = await apiCall();
      if (response.success && response.data) {
        setState({ data: response.data, loading: false, error: null });
      } else {
        setState({
          data: null,
          loading: false,
          error: response.error || 'Unknown error occurred',
        });
      }
    } catch (err) {
      setState({
        data: null,
        loading: false,
        error: err instanceof Error ? err.message : 'Unknown error occurred',
      });
    }
  }, [apiCall]);

  useEffect(() => {
    if (options.skip) return;
    fetchData();
  }, [fetchData, options.skip]);

  // Auto-refetch at interval
  useEffect(() => {
    if (!options.refetchInterval) return;
    const interval = setInterval(fetchData, options.refetchInterval);
    return () => clearInterval(interval);
  }, [fetchData, options.refetchInterval]);

  return {
    ...state,
    refetch: fetchData,
  };
}

/**
 * Custom hook for handling form submission
 * @example
 * const { loading, error, execute } = useApiMutation(
 *   (data) => apiClient.post('/endpoint', data)
 * )
 */
export function useApiMutation<T, P = any>(
  apiCall: (params: P) => Promise<ApiResponse<T>>
) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const execute = useCallback(
    async (params: P) => {
      setLoading(true);
      setError(null);
      try {
        const response = await apiCall(params);
        if (response.success) {
          return { success: true, data: response.data };
        } else {
          setError(response.error || 'Unknown error occurred');
          return { success: false, error: response.error };
        }
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error occurred';
        setError(errorMsg);
        return { success: false, error: errorMsg };
      } finally {
        setLoading(false);
      }
    },
    [apiCall]
  );

  const clearError = useCallback(() => setError(null), []);

  return { loading, error, execute, clearError };
}

/**
 * Custom hook for managing pagination state
 * @example
 * const { page, pageSize, goToPage, nextPage, prevPage } = usePagination()
 */
export function usePagination(initialPage: number = 1, initialPageSize: number = 10) {
  const [page, setPage] = useState(initialPage);
  const [pageSize, setPageSize] = useState(initialPageSize);

  const goToPage = useCallback((newPage: number) => {
    setPage(Math.max(1, newPage));
  }, []);

  const nextPage = useCallback(() => {
    setPage((prev) => prev + 1);
  }, []);

  const prevPage = useCallback(() => {
    setPage((prev) => Math.max(1, prev - 1));
  }, []);

  const setSize = useCallback((size: number) => {
    setPageSize(size);
    setPage(1);
  }, []);

  return { page, pageSize, goToPage, nextPage, prevPage, setSize };
}

/**
 * Custom hook for managing filter state
 * @example
 * const { filters, setFilter, removeFilter, clearFilters } = useFilters()
 */
export function useFilters(initialFilters: Record<string, any> = {}) {
  const [filters, setFilters] = useState(initialFilters);

  const setFilter = useCallback((key: string, value: any) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
  }, []);

  const removeFilter = useCallback((key: string) => {
    setFilters((prev) => {
      const newFilters = { ...prev };
      delete newFilters[key];
      return newFilters;
    });
  }, []);

  const clearFilters = useCallback(() => {
    setFilters({});
  }, []);

  const updateFilters = useCallback((newFilters: Record<string, any>) => {
    setFilters((prev) => ({ ...prev, ...newFilters }));
  }, []);

  return { filters, setFilter, removeFilter, clearFilters, updateFilters };
}

/**
 * Custom hook for managing local storage
 * @example
 * const [value, setValue] = useLocalStorage('key', 'defaultValue')
 */
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = useCallback(
    (value: T | ((val: T) => T)) => {
      try {
        const valueToStore = value instanceof Function ? value(storedValue) : value;
        setStoredValue(valueToStore);
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      } catch (error) {
        console.error(`Error setting localStorage key "${key}":`, error);
      }
    },
    [key, storedValue]
  );

  return [storedValue, setValue] as const;
}
