/**
 * @file Table Component
 * Reusable table component
 */

import React from 'react';

interface Column<T> {
  key: keyof T | string;
  label: string;
  render?: (value: any, row: T) => React.ReactNode;
  width?: string;
  align?: 'left' | 'center' | 'right';
}

interface TableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyExtractor?: (row: T, index: number) => string | number;
  loading?: boolean;
  emptyState?: React.ReactNode;
  hoverable?: boolean;
  striped?: boolean;
  compact?: boolean;
  onRowClick?: (row: T) => void;
  className?: string;
}

const LoadingRow: React.FC<{ colSpan: number }> = ({ colSpan }) => (
  <tr>
    <td colSpan={colSpan} className="px-4 py-8 text-center">
      <div className="flex items-center justify-center gap-2">
        <svg className="animate-spin h-5 w-5 text-primary-800" fill="none" viewBox="0 0 24 24">
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          />
        </svg>
        Loading...
      </div>
    </td>
  </tr>
);

const EmptyState: React.FC<{ colSpan: number; message?: string }> = ({
  colSpan,
  message = 'No data available',
}) => (
  <tr>
    <td colSpan={colSpan} className="px-4 py-12 text-center text-gray-500">
      {message}
    </td>
  </tr>
);

/**
 * Table Component
 * @example
 * <Table<PropertyType>
 *   columns={[
 *     { key: 'id', label: 'Property ID', width: '100px' },
 *     { key: 'title', label: 'Title' },
 *     {
 *       key: 'status',
 *       label: 'Status',
 *       render: (value) => <Badge variant="success">{value}</Badge>
 *     }
 *   ]}
 *   data={properties}
 *   hoverable
 * />
 */
export const Table = React.forwardRef<
  HTMLTableElement,
  TableProps<any>
>(
  (
    {
      columns,
      data,
      keyExtractor = (_, index) => index,
      loading = false,
      emptyState,
      hoverable = true,
      striped = true,
      compact = false,
      onRowClick,
      className = '',
    },
    ref
  ) => {
    const alignmentClass = {
      left: 'text-left',
      center: 'text-center',
      right: 'text-right',
    };

    return (
      <div className="overflow-x-auto">
        <table
          ref={ref}
          className={`
            w-full border-collapse bg-white
            ${className}
          `}
        >
          <thead>
            <tr className="bg-gray-50 border-b-2 border-gray-200">
              {columns.map((column) => (
                <th
                  key={String(column.key)}
                  style={{ width: column.width }}
                  className={`
                    px-4 ${compact ? 'py-2' : 'py-3'} text-left font-semibold text-gray-700
                    ${alignmentClass[column.align || 'left']}
                  `}
                >
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading && <LoadingRow colSpan={columns.length} />}
            {!loading && data.length === 0 && (
              <EmptyState colSpan={columns.length} message={emptyState as any} />
            )}
            {!loading &&
              data.map((row, rowIndex) => (
                <tr
                  key={keyExtractor(row, rowIndex)}
                  onClick={() => onRowClick?.(row)}
                  className={`
                    border-b border-gray-200
                    ${striped && rowIndex % 2 === 1 ? 'bg-gray-50' : 'bg-white'}
                    ${hoverable && onRowClick ? 'hover:bg-gray-50 cursor-pointer' : ''}
                  `}
                >
                  {columns.map((column) => {
                    const value = (row as any)[column.key as string];
                    const rendered = column.render ? column.render(value, row) : value;

                    return (
                      <td
                        key={String(column.key)}
                        className={`
                          px-4 ${compact ? 'py-2' : 'py-3'} text-gray-900
                          ${alignmentClass[column.align || 'left']}
                        `}
                      >
                        {rendered}
                      </td>
                    );
                  })}
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    );
  }
);

Table.displayName = 'Table';
