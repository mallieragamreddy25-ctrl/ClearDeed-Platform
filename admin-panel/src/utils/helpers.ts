/**
 * @file Utility helper functions
 */

/**
 * Format currency value
 * @example
 * formatCurrency(1500000) => "₹15L"
 */
export function formatCurrency(amount: number): string {
  if (amount >= 10_000_000) {
    return `₹${(amount / 10_000_000).toFixed(1)}Cr`;
  }
  if (amount >= 100_000) {
    return `₹${(amount / 100_000).toFixed(1)}L`;
  }
  if (amount >= 1_000) {
    return `₹${(amount / 1000).toFixed(1)}K`;
  }
  return `₹${amount}`;
}

/**
 * Format date to readable string
 * @example
 * formatDate(new Date()) => "Mar 29, 2026"
 */
export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  };
  return d.toLocaleDateString('en-IN', options);
}

/**
 * Format datetime to readable string
 * @example
 * formatDateTime(new Date()) => "Mar 29, 2026 at 10:30 AM"
 */
export function formatDateTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  };
  return d.toLocaleDateString('en-IN', options);
}

/**
 * Format relative time
 * @example
 * formatRelativeTime(new Date(Date.now() - 3600000)) => "1 hour ago"
 */
export function formatRelativeTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const seconds = Math.floor((now.getTime() - d.getTime()) / 1000);

  if (seconds < 60) return 'just now';
  if (seconds < 3600) return `${Math.floor(seconds / 60)} minutes ago`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)} hours ago`;
  if (seconds < 604800) return `${Math.floor(seconds / 86400)} days ago`;

  return formatDate(d);
}

/**
 * Format percentage with validation
 * @example
 * formatPercentage(0.125) => "12.5%"
 */
export function formatPercentage(value: number, decimals: number = 1): string {
  return `${(value * 100).toFixed(decimals)}%`;
}

/**
 * Truncate text with ellipsis
 * @example
 * truncateText("Lorem ipsum dolor sit amet", 15) => "Lorem ipsum..."
 */
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return `${text.substring(0, maxLength)}...`;
}

/**
 * Capitalize first letter of string
 * @example
 * capitalize("hello") => "Hello"
 */
export function capitalize(text: string): string {
  return text.charAt(0).toUpperCase() + text.slice(1);
}

/**
 * Convert snake_case to Title Case
 * @example
 * toTitleCase("pending_verification") => "Pending Verification"
 */
export function toTitleCase(text: string): string {
  return text
    .split('_')
    .map((word) => capitalize(word))
    .join(' ');
}

/**
 * Check if value is empty
 * @example
 * isEmpty("") => true
 * isEmpty(null) => true
 * isEmpty([]) => true
 */
export function isEmpty(value: any): boolean {
  if (value === null || value === undefined) return true;
  if (typeof value === 'string') return value.trim().length === 0;
  if (Array.isArray(value)) return value.length === 0;
  if (typeof value === 'object') return Object.keys(value).length === 0;
  return false;
}

/**
 * Validate email format
 * @example
 * isValidEmail("user@example.com") => true
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate phone number (Indian format)
 * @example
 * isValidPhone("+919876543210") => true
 * isValidPhone("9876543210") => true
 */
export function isValidPhone(phone: string): boolean {
  const phoneRegex = /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/;
  return phoneRegex.test(phone.replace(/\D/g, ''));
}

/**
 * Debounce function for expensive operations
 * @example
 * const debouncedSearch = debounce((value) => api.search(value), 300)
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;
  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * Throttle function for frequent events
 * @example
 * const throttledScroll = throttle(() => handleScroll(), 300)
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;
  return function executedFunction(...args: Parameters<T>) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => {
        inThrottle = false;
      }, limit);
    }
  };
}

/**
 * Generate unique ID
 * @example
 * generateId() => "abc123xyz"
 */
export function generateId(length: number = 8): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Deep merge objects
 * @example
 * deepMerge({ a: 1 }, { b: 2 }) => { a: 1, b: 2 }
 */
export function deepMerge<T extends Record<string, any>>(
  target: T,
  source: Partial<T>
): T {
  const output = { ...target };
  
  Object.keys(source).forEach((key) => {
    const sourceValue = source[key as keyof T];
    const targetValue = target[key as keyof T];

    if (
      sourceValue &&
      typeof sourceValue === 'object' &&
      !Array.isArray(sourceValue) &&
      targetValue &&
      typeof targetValue === 'object' &&
      !Array.isArray(targetValue)
    ) {
      output[key as keyof T] = deepMerge(targetValue, sourceValue);
    } else {
      output[key as keyof T] = sourceValue;
    }
  });

  return output;
}

/**
 * Query string parser
 * @example
 * parseQueryString("?page=1&status=active") => { page: "1", status: "active" }
 */
export function parseQueryString(queryString: string): Record<string, string> {
  const params = new URLSearchParams(queryString);
  const result: Record<string, string> = {};
  
  params.forEach((value, key) => {
    result[key] = value;
  });
  
  return result;
}

/**
 * Build query string
 * @example
 * buildQueryString({ page: 1, status: 'active' }) => "page=1&status=active"
 */
export function buildQueryString(params: Record<string, any>): string {
  return Object.entries(params)
    .filter(([, value]) => value !== null && value !== undefined)
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
    .join('&');
}

/**
 * Copy text to clipboard
 * @example
 * copyToClipboard("text to copy")
 */
export async function copyToClipboard(text: string): Promise<void> {
  try {
    await navigator.clipboard.writeText(text);
  } catch (error) {
    console.error('Failed to copy to clipboard:', error);
  }
}

/**
 * Download file
 * @example
 * downloadFile("data:text/csv;base64,...", "report.csv")
 */
export function downloadFile(dataUrl: string, filename: string): void {
  const link = document.createElement('a');
  link.href = dataUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
