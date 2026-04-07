/**
 * @file PageHeader Component
 * Header component for pages with title, breadcrumb, and actions
 */

import React from 'react';

interface Breadcrumb {
  label: string;
  path?: string;
}

interface PageHeaderProps {
  title: string;
  description?: string;
  breadcrumbs?: Breadcrumb[];
  actions?: React.ReactNode;
  icon?: React.ReactNode;
}

/**
 * PageHeader Component
 * @example
 * <PageHeader
 *   title="Property Verification"
 *   description="Manage and verify property listings"
 *   breadcrumbs={[{ label: 'Home' }, { label: 'Verification' }]}
 *   actions={<Button>+ Add Property</Button>}
 * />
 */
export const PageHeader: React.FC<PageHeaderProps> = ({
  title,
  description,
  breadcrumbs,
  actions,
  icon,
}) => {
  return (
    <div className="mb-8">
      {/* Breadcrumbs */}
      {breadcrumbs && breadcrumbs.length > 0 && (
        <div className="flex items-center gap-2 text-sm text-accent-600 mb-4">
          {breadcrumbs.map((crumb, index) => (
            <React.Fragment key={index}>
              {crumb.path ? (
                <a href={crumb.path} className="hover:text-primary-800 transition-colors">
                  {crumb.label}
                </a>
              ) : (
                <span>{crumb.label}</span>
              )}
              {index < breadcrumbs.length - 1 && (
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              )}
            </React.Fragment>
          ))}
        </div>
      )}

      {/* Title and Actions */}
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-start gap-4 flex-1">
          {icon && <div className="text-3xl">{icon}</div>}
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{title}</h1>
            {description && <p className="text-gray-600 mt-1">{description}</p>}
          </div>
        </div>
        {actions && <div className="flex-shrink-0">{actions}</div>}
      </div>
    </div>
  );
};
