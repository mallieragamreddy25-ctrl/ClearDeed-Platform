/**
 * @file Commission Ledger Screen
 * Track and manage all commission transactions
 */

import React from 'react';
import {
  PageHeader,
  Card,
  Table,
  Filters,
  Badge,
  Button,
  StatCard,
} from '@components/index';
import { useApi, useFilters, usePagination } from '@hooks/useApi';
import { commissionApi } from '@services/api';
import { Commission } from '@types/index';
import { COMMISSION_TYPES } from '@utils/constants';

/**
 * Commission Ledger Screen
 */
export const CommissionLedger: React.FC = () => {
  const { page, pageSize } = usePagination();
  const { filters, updateFilters, clearFilters } = useFilters();

  const { data: commissionsData, loading } = useApi(() =>
    commissionApi.getCommissions(page, filters)
  );

  const handleFilterApply = (newFilters: Record<string, any>) => {
    updateFilters(newFilters);
  };

  const handleFilterClear = () => {
    clearFilters();
  };

  const getStatusBadge = (status: string) => {
    const variants: Record<string, any> = {
      pending: 'warning',
      approved: 'info',
      paid: 'success',
    };
    return variants[status] || 'neutral';
  };

  const filterConfigs = [
    {
      key: 'type',
      label: 'Type',
      type: 'select' as const,
      options: COMMISSION_TYPES,
    },
    {
      key: 'status',
      label: 'Status',
      type: 'select' as const,
      options: [
        { value: 'pending', label: 'Pending (₹2.4 Cr)' },
        { value: 'approved', label: 'Approved (₹1.8 Cr)' },
        { value: 'paid', label: 'Paid (₹5.8 Cr)' },
      ],
    },
    {
      key: 'dateFrom',
      label: 'From Date',
      type: 'date' as const,
    },
    {
      key: 'dateTo',
      label: 'To Date',
      type: 'date' as const,
    },
  ];

  // Calculate totals
  const totals = {
    pending: 24_000_000,
    approved: 18_000_000,
    paid: 58_000_000,
  };

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Commission Ledger"
        description="Track all payouts to agents, platform fees, and pending commissions"
        breadcrumbs={[{ label: 'Home' }, { label: 'Commission Ledger' }]}
        actions={<Button variant="primary">Export Report</Button>}
        icon="📊"
      />

      {/* Filters */}
      <Filters
        filters={filterConfigs}
        onApply={handleFilterApply}
        onClear={handleFilterClear}
        currentFilters={filters}
      />

      {/* Summary Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          label="Pending"
          value={`₹${(totals.pending / 10_000_000).toFixed(1)}Cr`}
          color="warning"
          icon="⏳"
        />
        <StatCard
          label="Approved"
          value={`₹${(totals.approved / 10_000_000).toFixed(1)}Cr`}
          color="info"
          icon="✓"
        />
        <StatCard
          label="Paid"
          value={`₹${(totals.paid / 10_000_000).toFixed(1)}Cr`}
          color="success"
          icon="💰"
        />
        <StatCard
          label="Total Volume"
          value={`₹${((totals.pending + totals.approved + totals.paid) / 10_000_000).toFixed(1)}Cr`}
          color="primary"
          icon="📈"
        />
      </div>

      {/* Commission Table */}
      <Card>
        <Table<ExtendedCommission>
          columns={[
            {
              key: 'id',
              label: 'Transaction ID',
              width: '120px',
              render: (value) => <span className="font-mono text-sm font-medium">{value}</span>,
            },
            {
              key: 'dealId',
              label: 'Deal ID',
              width: '80px',
              render: (value) => <span className="font-mono text-sm">#{value}</span>,
            },
            {
              key: 'recipientName',
              label: 'Recipient (Agent/Partner)',
              render: (value) => <span className="font-medium">{value}</span>,
            },
            {
              key: 'type',
              label: 'Type',
              render: (value) => (
                <span className="text-sm text-gray-600 capitalize">{value.replace('_', ' ')}</span>
              ),
            },
            {
              key: 'amount',
              label: 'Amount',
              render: (value) => <span className="font-medium">₹{value.toLocaleString()}</span>,
            },
            {
              key: 'status',
              label: 'Status',
              render: (value) => (
                <Badge variant={getStatusBadge(value)}>
                  {value.charAt(0).toUpperCase() + value.slice(1)}
                </Badge>
              ),
            },
            {
              key: 'paymentDate',
              label: 'Payment Date',
              render: (value) => (
                <span className="text-sm text-gray-600">{value || '-'}</span>
              ),
            },
            {
              key: 'reference',
              label: 'Reference',
              render: (value) => (
                <span className="text-sm text-gray-600 font-mono">{value || '-'}</span>
              ),
            },
          ]}
          data={
            commissionsData?.items.map((commission) => ({
              ...commission,
              reference: `TXN${Date.now()}`,
            })) || []
          }
          loading={loading}
          emptyState="No commission records found"
          keyExtractor={(row) => row.id}
        />
      </Card>

      {/* Export Options */}
      <Card>
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Export Options</h3>
        <div className="flex gap-3">
          <Button variant="secondary" size="sm">
            📥 Export to CSV
          </Button>
          <Button variant="secondary" size="sm">
            📄 Export to PDF
          </Button>
          <Button variant="secondary" size="sm">
            📧 Email Report
          </Button>
        </div>
      </Card>
    </div>
  );
};

// Extended type for display purposes
interface ExtendedCommission extends Commission {
  reference?: string;
}
