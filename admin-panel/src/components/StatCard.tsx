/**
 * @file StatCard Component
 * Card for displaying statistics/KPIs
 */

import React from 'react';
import { Card } from './Card';

interface StatCardProps {
  label: string;
  value: string | number;
  icon?: React.ReactNode;
  trend?: {
    direction: 'up' | 'down';
    percentage: number;
  };
  color?: 'primary' | 'success' | 'warning' | 'error';
  onClick?: () => void;
}

const colorClasses = {
  primary: 'text-primary-800',
  success: 'text-success',
  warning: 'text-warning',
  error: 'text-error',
};

/**
 * StatCard Component
 * @example
 * <StatCard
 *   label="Active Deals"
 *   value={42}
 *   color="primary"
 *   trend={{ direction: 'up', percentage: 12 }}
 * />
 */
export const StatCard: React.FC<StatCardProps> = ({
  label,
  value,
  icon,
  trend,
  color = 'primary',
  onClick,
}) => {
  return (
    <Card
      hover={!!onClick}
      padding="lg"
      className={onClick ? 'cursor-pointer' : ''}
      onClick={onClick}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm text-gray-600 font-medium mb-2">{label}</p>
          <div className="flex items-baseline gap-2">
            <p className={`text-3xl font-bold ${colorClasses[color]}`}>{value}</p>
            {trend && (
              <div className={`flex items-center gap-1 text-sm font-medium ${
                trend.direction === 'up' ? 'text-success' : 'text-error'
              }`}>
                <svg
                  className={`w-4 h-4 ${trend.direction === 'down' ? 'rotate-180' : ''}`}
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V9.414l-4.293 4.293a1 1 0 01-1.414-1.414L13.586 8H12z"
                    clipRule="evenodd"
                  />
                </svg>
                {trend.percentage}%
              </div>
            )}
          </div>
        </div>
        {icon && (
          <div className={`flex-shrink-0 w-12 h-12 rounded-lg bg-gray-100 flex items-center justify-center ${colorClasses[color]}`}>
            {icon}
          </div>
        )}
      </div>
    </Card>
  );
};
