/**
 * @file Dashboard Screen
 * Main admin dashboard with KPIs and recent activities
 */

import React, { useState, useEffect } from 'react';
import { PageHeader, StatCard, Card, Table, Badge } from '@components/index';
import { Button } from '@components/Button';
import { useApi } from '@hooks/useApi';
import { dashboardApi } from '@services/api';
import { DashboardMetrics, Activity } from '@types/index';

/**
 * Dashboard Screen
 */
export const Dashboard: React.FC = () => {
  const { data: metrics, loading: metricsLoading } = useApi(dashboardApi.getMetrics);
  const { data: activities, loading: activitiesLoading } = useApi(() =>
    dashboardApi.getActivities(10)
  );

  const formatCurrency = (amount: number): string => {
    if (amount >= 10000000) {
      return `₹${(amount / 10000000).toFixed(1)}Cr`;
    }
    if (amount >= 100000) {
      return `₹${(amount / 100000).toFixed(1)}L`;
    }
    return `₹${amount.toLocaleString()}`;
  };

  const getActivityBadgeVariant = (status: string) => {
    switch (status) {
      case 'success':
        return 'success';
      case 'error':
        return 'error';
      default:
        return 'info';
    }
  };

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Dashboard"
        description="Overview of your real estate platform"
        breadcrumbs={[{ label: 'Home' }, { label: 'Dashboard' }]}
        actions={<Button variant="primary">+ New Deal</Button>}
        icon="📊"
      />

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <StatCard
          label="Total Properties"
          value={metrics?.totalProperties || 0}
          color="primary"
          icon="🏠"
          trend={{ direction: 'up', percentage: 12 }}
        />
        <StatCard
          label="Verified Properties"
          value={metrics?.verifiedProperties || 0}
          color="success"
          icon="✓"
          trend={{ direction: 'up', percentage: 8 }}
        />
        <StatCard
          label="Active Deals"
          value={metrics?.activeDealsCounts || 0}
          color="info"
          icon="🤝"
          trend={{ direction: 'up', percentage: 5 }}
        />
        <StatCard
          label="Commission Pending"
          value={formatCurrency(metrics?.commissionPending || 0)}
          color="warning"
          icon="⏳"
        />
        <StatCard
          label="Commission Paid"
          value={formatCurrency(metrics?.commissionPaid || 0)}
          color="success"
          icon="💰"
        />
        <StatCard
          label="Active Agents"
          value={metrics?.activeAgents || 0}
          color="primary"
          icon="👥"
          trend={{ direction: 'up', percentage: 3 }}
        />
      </div>

      {/* Recent Activities */}
      <Card>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Recent Activities</h3>
          <a href="/activities" className="text-primary-800 hover:text-primary-700 text-sm font-medium">
            View All →
          </a>
        </div>

        <Table
          columns={[
            {
              key: 'id',
              label: 'Activity ID',
              width: '100px',
              render: (value) => <span className="font-mono text-sm">{value}</span>,
            },
            {
              key: 'actionType',
              label: 'Action',
              render: (value) => <span className="font-medium">{value}</span>,
            },
            {
              key: 'entity',
              label: 'Entity Type',
              render: (value) => <span className="text-gray-600">{value}</span>,
            },
            {
              key: 'adminName',
              label: 'Admin',
              render: (value) => <span>{value}</span>,
            },
            {
              key: 'timestamp',
              label: 'Time',
              render: (value) => {
                const date = new Date(value);
                return <span className="text-sm text-gray-600">{date.toLocaleString()}</span>;
              },
            },
            {
              key: 'status',
              label: 'Status',
              render: (value) => (
                <Badge variant={getActivityBadgeVariant(value)}>
                  {value === 'success' ? '✓ Success' : '✗ Error'}
                </Badge>
              ),
            },
          ]}
          data={activities || []}
          loading={activitiesLoading}
          emptyState="No recent activities"
          keyExtractor={(row) => row.id}
        />
      </Card>

      {/* Quick Stats Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pending Verifications */}
        <Card>
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Pending Verifications</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-yellow-50 rounded-lg border border-yellow-200">
              <div>
                <p className="text-sm font-medium text-gray-900">Properties Awaiting Review</p>
                <p className="text-2xl font-bold text-warning">23</p>
              </div>
              <Button variant="secondary" size="sm">
                Review →
              </Button>
            </div>
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg border border-blue-200">
              <div>
                <p className="text-sm font-medium text-gray-900">Documents Missing</p>
                <p className="text-2xl font-bold text-info">8</p>
              </div>
              <Button variant="secondary" size="sm">
                Follow Up →
              </Button>
            </div>
          </div>
        </Card>

        {/* Overdue Tasks */}
        <Card>
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Action Required</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg border border-red-200">
              <div>
                <p className="text-sm font-medium text-gray-900">Overdue Agent Fees</p>
                <p className="text-2xl font-bold text-error">6</p>
              </div>
              <Button variant="danger" size="sm">
                Collect →
              </Button>
            </div>
            <div className="flex items-center justify-between p-3 bg-orange-50 rounded-lg border border-orange-200">
              <div>
                <p className="text-sm font-medium text-gray-900">Pending Commission Approvals</p>
                <p className="text-2xl font-bold text-warning">12</p>
              </div>
              <Button variant="secondary" size="sm">
                Approve →
              </Button>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};
