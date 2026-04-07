/**
 * @file Deal Management Screen
 * Manage active deals and commission tracking
 */

import React, { useState } from 'react';
import {
  PageHeader,
  Card,
  Table,
  Filters,
  Badge,
  Button,
  Modal,
} from '@components/index';
import { useApi, useFilters, usePagination } from '@hooks/useApi';
import { dealApi } from '@services/api';
import { Deal } from '@types/index';
import { CITIES } from '@utils/constants';

/**
 * Deal Management Screen
 */
export const DealManagement: React.FC = () => {
  const { page, pageSize } = usePagination();
  const { filters, updateFilters, clearFilters } = useFilters();
  const [selectedDeal, setSelectedDeal] = useState<Deal | null>(null);
  const [showDetailModal, setShowDetailModal] = useState(false);

  const { data: dealsData, loading } = useApi(() =>
    dealApi.getDeals(page, filters)
  );

  const handleFilterApply = (newFilters: Record<string, any>) => {
    updateFilters(newFilters);
  };

  const handleFilterClear = () => {
    clearFilters();
  };

  const openDealDetail = (deal: Deal) => {
    setSelectedDeal(deal);
    setShowDetailModal(true);
  };

  const getStatusBadge = (status: string) => {
    const variants: Record<string, any> = {
      created: 'neutral',
      active: 'success',
      verification_pending: 'warning',
      closed: 'neutral',
      cancelled: 'error',
    };
    return variants[status] || 'info';
  };

  const filterConfigs = [
    {
      key: 'status',
      label: 'Status',
      type: 'select' as const,
      options: [
        { value: 'created', label: 'Created (8)' },
        { value: 'active', label: 'Active (28)' },
        { value: 'verification_pending', label: 'Verification Pending (6)' },
      ],
    },
    {
      key: 'city',
      label: 'City',
      type: 'select' as const,
      options: CITIES,
    },
  ];

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Deal Management"
        description={`${dealsData?.total || 0} active deals`}
        breadcrumbs={[{ label: 'Home' }, { label: 'Deals' }]}
        actions={<Button variant="primary">+ Create Deal</Button>}
        icon="🤝"
      />

      {/* Filters */}
      <Filters
        filters={filterConfigs}
        onApply={handleFilterApply}
        onClear={handleFilterClear}
        currentFilters={filters}
      />

      {/* Deals Table */}
      <Card>
        <Table<Deal>
          columns={[
            {
              key: 'id',
              label: 'Deal ID',
              width: '80px',
              render: (value) => <span className="font-mono font-medium">#{value}</span>,
            },
            {
              key: 'buyerName',
              label: 'Buyer',
              render: (value) => <span className="font-medium">{value}</span>,
            },
            {
              key: 'sellerName',
              label: 'Seller',
              render: (value) => <span className="font-medium">{value}</span>,
            },
            {
              key: 'propertyId',
              label: 'Property',
              render: (value) => <span className="text-gray-600">#{value}</span>,
            },
            {
              key: 'value',
              label: 'Value',
              render: (value) => <span className="font-medium">₹{(value / 100000).toFixed(1)}L</span>,
            },
            {
              key: 'buyerAgentName',
              label: 'Buyer Agent',
              render: (value) => <span className="text-sm text-gray-600">{value}</span>,
            },
            {
              key: 'sellerAgentName',
              label: 'Seller Agent',
              render: (value) => <span className="text-sm text-gray-600">{value}</span>,
            },
            {
              key: 'status',
              label: 'Status',
              render: (value) => (
                <Badge variant={getStatusBadge(value)}>
                  {value.replace('_', ' ')}
                </Badge>
              ),
            },
            {
              key: 'id',
              label: 'Action',
              render: (value, row) => (
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => openDealDetail(row)}
                >
                  Manage
                </Button>
              ),
            },
          ]}
          data={dealsData?.items || []}
          loading={loading}
          emptyState="No deals found"
          keyExtractor={(row) => row.id}
        />
      </Card>

      {/* Deal Detail Modal */}
      <Modal
        isOpen={showDetailModal}
        onClose={() => setShowDetailModal(false)}
        title={selectedDeal ? `Deal #${selectedDeal.id} - Commission Management` : undefined}
        maxWidth="lg"
      >
        {selectedDeal && <DealDetailView deal={selectedDeal} />}
      </Modal>
    </div>
  );
};

/**
 * Deal Detail View Component
 */
const DealDetailView: React.FC<{ deal: Deal }> = ({ deal }) => {
  return (
    <div className="space-y-6">
      {/* Deal Information */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-4">Deal Information</h4>
        <div className="bg-gray-50 p-4 rounded-lg grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-gray-600">Buyer</p>
            <p className="font-medium">{deal.buyerName}</p>
          </div>
          <div>
            <p className="text-gray-600">Seller</p>
            <p className="font-medium">{deal.sellerName}</p>
          </div>
          <div>
            <p className="text-gray-600">Property</p>
            <p className="font-medium">#{deal.propertyId}</p>
          </div>
          <div>
            <p className="text-gray-600">Transaction Value</p>
            <p className="font-medium">₹{(deal.value / 100000).toFixed(1)}L</p>
          </div>
          <div>
            <p className="text-gray-600">Creation Date</p>
            <p className="font-medium">{new Date(deal.createdAt).toLocaleDateString()}</p>
          </div>
          <div>
            <p className="text-gray-600">Status</p>
            <p className="font-medium capitalize">{deal.status.replace('_', ' ')}</p>
          </div>
        </div>
      </div>

      {/* Commission Breakdown */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-4">Commission Breakdown</h4>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 border-b">
                <th className="px-4 py-3 text-left font-semibold text-gray-900">Type</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-900">Amount</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-900">To</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-900">Status</th>
              </tr>
            </thead>
            <tbody>
              {deal.commissions.map((commission, index) => (
                <tr key={index} className="border-b hover:bg-gray-50">
                  <td className="px-4 py-3 capitalize">{commission.type.replace('_', ' ')}</td>
                  <td className="px-4 py-3 font-medium">₹{commission.amount.toLocaleString()}</td>
                  <td className="px-4 py-3">
                    <div>
                      <p className="font-medium">{commission.recipientName || 'ClearDeed'}</p>
                      <p className="text-xs text-gray-600">
                        {commission.recipientType === 'agent' ? 'Agent' : 'Platform'}
                      </p>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <Badge variant={commission.status === 'paid' ? 'success' : 'pending'}>
                      {commission.status.replace('_', ' ')}
                    </Badge>
                  </td>
                </tr>
              ))}
              <tr className="bg-gray-50 font-bold">
                <td className="px-4 py-3">TOTAL</td>
                <td className="px-4 py-3">
                  ₹{deal.commissions.reduce((sum, c) => sum + c.amount, 0).toLocaleString()}
                </td>
                <td className="px-4 py-3">-</td>
                <td className="px-4 py-3">-</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-3 justify-end border-t pt-6">
        <Button variant="danger">✗ Cancel Deal</Button>
        <Button variant="success">✓ Close Deal (Lock Commission)</Button>
      </div>
    </div>
  );
};
