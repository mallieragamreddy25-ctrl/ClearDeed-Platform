/**
 * @file Navbar Component
 * Top navigation bar for the admin panel
 */

import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';

interface NavItem {
  label: string;
  path: string;
  icon?: React.ReactNode;
}

interface NavbarProps {
  navItems?: NavItem[];
  onLogout?: () => void;
  userInitial?: string;
  userName?: string;
}

/**
 * Navbar Component
 */
export const Navbar: React.FC<NavbarProps> = ({
  navItems = [],
  onLogout,
  userInitial = 'A',
  userName = 'Admin User',
}) => {
  const [showUserMenu, setShowUserMenu] = useState(false);

  return (
    <nav className="bg-primary-800 text-white shadow-lg">
      <div className="max-w-full px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <div className="flex items-center gap-2">
            <div className="text-2xl font-bold">🏠</div>
            <div className="font-bold text-lg">ClearDeed Admin</div>
          </div>

          {/* Navigation Items */}
          <div className="hidden md:flex items-center gap-8">
            {navItems.map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) =>
                  `flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-primary-700 text-white'
                      : 'text-primary-100 hover:bg-primary-700'
                  }`
                }
              >
                {item.icon && <span className="w-4 h-4">{item.icon}</span>}
                {item.label}
              </NavLink>
            ))}
          </div>

          {/* User Menu */}
          <div className="relative">
            <button
              onClick={() => setShowUserMenu(!showUserMenu)}
              className="flex items-center gap-3 px-3 py-2 rounded-md hover:bg-primary-700 transition-colors"
            >
              <div className="w-8 h-8 rounded-full bg-primary-600 flex items-center justify-center text-sm font-bold">
                {userInitial}
              </div>
              <div className="hidden sm:block text-sm">{userName}</div>
              <svg
                className={`w-4 h-4 transition-transform ${showUserMenu ? 'rotate-180' : ''}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
              </svg>
            </button>

            {/* User Dropdown Menu */}
            {showUserMenu && (
              <div className="absolute right-0 mt-2 w-48 bg-white text-gray-900 rounded-lg shadow-lg z-10">
                <div className="px-4 py-3 border-b text-sm">
                  <p className="font-medium">{userName}</p>
                  <p className="text-gray-500 text-xs">Administrator</p>
                </div>
                <div className="py-2">
                  <button className="w-full text-left px-4 py-2 hover:bg-gray-100 transition-colors text-sm">
                    Profile Settings
                  </button>
                  <button className="w-full text-left px-4 py-2 hover:bg-gray-100 transition-colors text-sm">
                    Change Password
                  </button>
                  <button className="w-full text-left px-4 py-2 hover:bg-gray-100 transition-colors text-sm">
                    Activity Log
                  </button>
                </div>
                <div className="border-t py-2">
                  <button
                    onClick={onLogout}
                    className="w-full text-left px-4 py-2 hover:bg-red-50 text-red-600 hover:text-red-700 transition-colors text-sm font-medium"
                  >
                    Logout
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Mobile Navigation */}
        <div className="md:hidden pb-4 space-y-1">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                `flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors block ${
                  isActive
                    ? 'bg-primary-700 text-white'
                    : 'text-primary-100 hover:bg-primary-700'
                }`
              }
            >
              {item.icon && <span className="w-4 h-4">{item.icon}</span>}
              {item.label}
            </NavLink>
          ))}
        </div>
      </div>
    </nav>
  );
};
