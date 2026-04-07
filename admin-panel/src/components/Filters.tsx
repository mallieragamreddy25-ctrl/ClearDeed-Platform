/**
 * @file Filters Component
 * Reusable filter controls component
 */

import React from 'react';
import { Button } from './Button';

interface FilterOption {
  label: string;
  value: string;
}

interface FilterConfig {
  key: string;
  label: string;
  type: 'select' | 'text' | 'date';
  placeholder?: string;
  options?: FilterOption[];
}

interface FiltersProps {
  filters: FilterConfig[];
  onApply: (values: Record<string, any>) => void;
  onClear: () => void;
  currentFilters?: Record<string, any>;
  className?: string;
}

/**
 * Filters Component
 * @example
 * <Filters
 *   filters={[
 *     { key: 'category', label: 'Category', type: 'select', options: [...] },
 *     { key: 'city', label: 'City', type: 'select', options: [...] }
 *   ]}
 *   onApply={(values) => handleFilter(values)}
 *   onClear={() => handleClearFilters()}
 * />
 */
export const Filters: React.FC<FiltersProps> = ({
  filters,
  onApply,
  onClear,
  currentFilters = {},
  className = '',
}) => {
  const [values, setValues] = React.useState<Record<string, any>>(currentFilters);

  const handleChange = (key: string, value: any) => {
    setValues((prev) => ({ ...prev, [key]: value }));
  };

  const handleApply = () => {
    onApply(values);
  };

  const handleClear = () => {
    setValues({});
    onClear();
  };

  return (
    <div className={`bg-white p-4 rounded-lg border border-gray-200 ${className}`}>
      <div className="flex flex-wrap gap-3 mb-4">
        {filters.map((filter) => (
          <div key={filter.key} className="flex-1 min-w-[150px]">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {filter.label}
            </label>

            {filter.type === 'select' && (
              <select
                value={values[filter.key] || ''}
                onChange={(e) => handleChange(filter.key, e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              >
                <option value="">{filter.placeholder || 'All'}</option>
                {filter.options?.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            )}

            {filter.type === 'text' && (
              <input
                type="text"
                value={values[filter.key] || ''}
                onChange={(e) => handleChange(filter.key, e.target.value)}
                placeholder={filter.placeholder}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              />
            )}

            {filter.type === 'date' && (
              <input
                type="date"
                value={values[filter.key] || ''}
                onChange={(e) => handleChange(filter.key, e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              />
            )}
          </div>
        ))}
      </div>

      <div className="flex gap-2 justify-end">
        <Button variant="secondary" size="sm" onClick={handleClear}>
          Clear Filters
        </Button>
        <Button variant="primary" size="sm" onClick={handleApply}>
          Apply Filters
        </Button>
      </div>
    </div>
  );
};
