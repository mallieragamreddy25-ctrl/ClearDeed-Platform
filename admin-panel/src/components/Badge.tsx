/**
 * @file Badge Component
 * Status badge display component
 */

import React from 'react';

type BadgeVariant = 'success' | 'error' | 'warning' | 'pending' | 'info' | 'neutral';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  icon?: React.ReactNode;
  className?: string;
}

const variantClasses: Record<BadgeVariant, string> = {
  success: 'bg-green-100 text-green-800',
  error: 'bg-red-100 text-red-800',
  warning: 'bg-yellow-100 text-yellow-800',
  pending: 'bg-blue-100 text-blue-800',
  info: 'bg-blue-100 text-blue-800',
  neutral: 'bg-gray-100 text-gray-800',
};

/**
 * Badge Component
 * @example
 * <Badge variant="success">✓ Verified</Badge>
 * <Badge variant="warning">Pending</Badge>
 * <Badge variant="error">Rejected</Badge>
 */
export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'info',
  icon,
  className = '',
}) => {
  return (
    <span
      className={`
        inline-flex items-center gap-1
        px-2.5 py-1 rounded-full
        text-sm font-medium
        ${variantClasses[variant]}
        ${className}
      `}
    >
      {icon && <span className="flex-shrink-0">{icon}</span>}
      {children}
    </span>
  );
};
