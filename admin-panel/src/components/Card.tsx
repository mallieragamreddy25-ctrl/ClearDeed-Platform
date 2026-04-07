/**
 * @file Card Component
 * Reusable card container component
 */

import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
  padding?: 'sm' | 'md' | 'lg';
  border?: boolean;
}

const paddingClasses = {
  sm: 'p-3',
  md: 'p-4',
  lg: 'p-6',
};

/**
 * Card Component
 * @example
 * <Card padding="md" hover>
 *   <h3>Card Title</h3>
 *   <p>Card content</p>
 * </Card>
 */
export const Card: React.FC<CardProps> = ({
  children,
  className = '',
  hover = false,
  padding = 'md',
  border = true,
}) => {
  return (
    <div
      className={`
        bg-white rounded-lg
        ${border ? 'border border-gray-200' : ''}
        ${hover ? 'hover:shadow-md transition-shadow duration-200' : 'shadow-sm'}
        ${paddingClasses[padding]}
        ${className}
      `}
    >
      {children}
    </div>
  );
};
