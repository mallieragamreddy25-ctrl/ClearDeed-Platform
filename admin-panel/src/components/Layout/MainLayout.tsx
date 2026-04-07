/**
 * @file MainLayout Component
 * Main layout wrapper combining navbar, sidebar, and content area
 */

import React, { useState } from 'react';
import { Navbar } from './Navbar';
import { Sidebar } from './Sidebar';

interface LayoutNavItem {
  label: string;
  path: string;
  icon?: React.ReactNode;
}

interface SidebarItem {
  label: string;
  path: string;
  icon: React.ReactNode;
  badge?: number;
}

interface MainLayoutProps {
  children: React.ReactNode;
  navItems?: LayoutNavItem[];
  sidebarItems?: SidebarItem[];
  onLogout?: () => void;
  userName?: string;
  userInitial?: string;
}

/**
 * MainLayout Component
 * @example
 * <MainLayout navItems={...} sidebarItems={...}>
 *   <Dashboard />
 * </MainLayout>
 */
export const MainLayout: React.FC<MainLayoutProps> = ({
  children,
  navItems = [],
  sidebarItems = [],
  onLogout,
  userName,
  userInitial,
}) => {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  return (
    <div className="flex flex-col h-screen bg-accent-100">
      {/* Navbar */}
      <Navbar
        navItems={navItems}
        onLogout={onLogout}
        userName={userName}
        userInitial={userInitial}
      />

      {/* Main Content */}
      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        {sidebarItems.length > 0 && (
          <Sidebar
            items={sidebarItems}
            collapsed={sidebarCollapsed}
            onCollapse={setSidebarCollapsed}
          />
        )}

        {/* Content Area */}
        <main className="flex-1 overflow-auto">
          <div className="h-full">{children}</div>
        </main>
      </div>
    </div>
  );
};
