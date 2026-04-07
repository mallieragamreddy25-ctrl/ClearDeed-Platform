/**
 * @file Sidebar Component
 * Side navigation panel for the admin dashboard
 */

import React from 'react';
import { NavLink } from 'react-router-dom';

interface SidebarItem {
  label: string;
  path: string;
  icon: React.ReactNode;
  badge?: number;
}

interface SidebarProps {
  items: SidebarItem[];
  collapsed?: boolean;
  onCollapse?: (collapsed: boolean) => void;
}

/**
 * Sidebar Component
 */
export const Sidebar: React.FC<SidebarProps> = ({
  items,
  collapsed = false,
  onCollapse,
}) => {
  return (
    <div
      className={`bg-accent-100 border-r border-accent-200 transition-all duration-300 ${
        collapsed ? 'w-20' : 'w-64'
      } min-h-screen overflow-y-auto`}
    >
      {/* Toggle Button */}
      <div className="p-4 flex justify-end">
        <button
          onClick={() => onCollapse?.(!collapsed)}
          className="p-2 hover:bg-accent-200 rounded-lg transition-colors"
          title={collapsed ? 'Expand' : 'Collapse'}
        >
          <svg
            className={`w-5 h-5 text-accent-600 transition-transform ${
              collapsed ? 'rotate-180' : ''
            }`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </button>
      </div>

      {/* Navigation Items */}
      <nav className="space-y-1 px-2">
        {items.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors relative group ${
                isActive
                  ? 'bg-primary-800 text-white'
                  : 'text-accent-600 hover:bg-accent-200'
              }`
            }
            title={collapsed ? item.label : undefined}
          >
            <span className="flex-shrink-0 w-6 h-6">{item.icon}</span>
            {!collapsed && (
              <>
                <span className="flex-1 text-sm font-medium truncate">{item.label}</span>
                {item.badge && item.badge > 0 && (
                  <span className="flex-shrink-0 ml-2 inline-flex items-center justify-center px-2 py-0.5 rounded-full text-xs font-bold bg-error text-white">
                    {item.badge > 99 ? '99+' : item.badge}
                  </span>
                )}
              </>
            )}

            {/* Tooltip for collapsed state */}
            {collapsed && (
              <div className="absolute left-full ml-2 px-2 py-1 bg-gray-900 text-white text-xs rounded whitespace-nowrap hidden group-hover:block z-10">
                {item.label}
              </div>
            )}
          </NavLink>
        ))}
      </nav>
    </div>
  );
};
