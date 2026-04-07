/**
 * @file Agent Management Screen
 * Manage agents, referral partners, and maintenance fees
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
import { agentApi } from '@services/api';
import { Agent } from '@types/index';
import { AGENT_TYPES, CITIES } from '@utils/constants';

/**
 * Agent Management Screen
 */
export const AgentManagement: React.FC = () => {
  const { page, pageSize } = usePagination();
  const { filters, updateFilters, clearFilters } = useFilters();
  const [selectedAgent, setSelectedAgent] = useState<Agent | null>(null);
  const [showDetailModal, setShowDetailModal] = useState(false);

  const { data: agentsData, loading } = useApi(() =>
    agentApi.getAgents(page, filters)
  );

  const handleFilterApply = (newFilters: Record<string, any>) => {
    updateFilters(newFilters);
  };

  const handleFilterClear = () => {
    clearFilters();
  };

  const openAgentDetail = (agent: Agent) => {
    setSelectedAgent(agent);
    setShowDetailModal(true);
  };

  const getStatusBadge = (status: string) => {
    const variants: Record<string, any> = {
      active: 'success',
      inactive: 'neutral',
      suspended: 'error',
    };
    return variants[status] || 'info';
  };

  const getFeeBadge = (status: string) => {
    const variants: Record<string, any> = {
      paid: 'success',
      pending: 'warning',
      overdue: 'error',
    };
    return variants[status] || 'info';
  };

  const filterConfigs = [
    {
      key: 'agentType',
      label: 'Type',
      type: 'select' as const,
      options: AGENT_TYPES,
    },
    {
      key: 'status',
      label: 'Status',
      type: 'select' as const,
      options: [
        { value: 'active', label: 'Active (32)' },
        { value: 'inactive', label: 'Inactive (5)' },
        { value: 'suspended', label: 'Suspended (1)' },
      ],
    },
    {
      key: 'feeStatus',
      label: 'Fee Status',
      type: 'select' as const,
      options: [
        { value: 'paid', label: 'Paid' },
        { value: 'pending', label: 'Pending' },
        { value: 'overdue', label: 'Overdue' },
      ],
    },
  ];

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Agent Management"
        description="Manage agents, referral partners, and track earnings"
        breadcrumbs={[{ label: 'Home' }, { label: 'Agents' }]}
        actions={<Button variant="primary">+ Register Agent</Button>}
        icon="👥"
      />

      {/* Filters */}
      <Filters
        filters={filterConfigs}
        onApply={handleFilterApply}
        onClear={handleFilterClear}
        currentFilters={filters}
      />

      {/* Agents Table */}
      <Card>
        <Table<Agent>
          columns={[
            {
              key: 'id',
              label: 'Agent ID',
              width: '100px',
              render: (value) => <span className="font-mono text-sm font-medium">{value}</span>,
            },
            {
              key: 'name',
              label: 'Name & Mobile',
              render: (value, row) => (
                <div>
                  <p className="font-medium text-gray-900">{value}</p>
                  <p className="text-sm text-gray-600">{row.mobile}</p>
                </div>
              ),
            },
            {
              key: 'agentType',
              label: 'Type',
              render: (value) => (
                <span className="text-sm capitalize text-gray-600">{value.replace('_', ' ')}</span>
              ),
            },
            {
              key: 'agencyName',
              label: 'Agency / Location',
              render: (value, row) => (
                <span className="text-sm text-gray-600">
                  {value}, {row.city}
                </span>
              ),
            },
            {
              key: 'status',
              label: 'Status',
              render: (value) => (
                <Badge variant={getStatusBadge(value)}>
                  {value === 'active' && '● '}
                  {value.charAt(0).toUpperCase() + value.slice(1)}
                </Badge>
              ),
            },
            {
              key: 'feeStatus',
              label: 'Maintenance Fee',
              render: (value) => (
                <Badge variant={getFeeBadge(value)}>
                  {value === 'paid' ? '✓ Paid (2025)' : value === 'overdue' ? 'Fee Due' : 'Pending'}
                </Badge>
              ),
            },
            {
              key: 'earnedCommission',
              label: 'Earned Commission',
              render: (value) => <span className="font-medium">₹{(value / 100000).toFixed(1)}L</span>,
            },
            {
              key: 'id',
              label: 'Actions',
              render: (value, row) => (
                <Button
                  variant={row.feeStatus === 'overdue' ? 'danger' : 'secondary'}
                  size="sm"
                  onClick={() => openAgentDetail(row)}
                >
                  {row.feeStatus === 'overdue' ? 'Pay Fee' : 'View'}
                </Button>
              ),
            },
          ]}
          data={agentsData?.items || []}
          loading={loading}
          emptyState="No agents found"
          keyExtractor={(row) => row.id}
        />
      </Card>

      {/* Agent Detail Modal */}
      <Modal
        isOpen={showDetailModal}
        onClose={() => setShowDetailModal(false)}
        title={selectedAgent ? `Agent #${selectedAgent.id} - ${selectedAgent.name}` : undefined}
        maxWidth="lg"
      >
        {selectedAgent && <AgentDetailView agent={selectedAgent} />}
      </Modal>
    </div>
  );
};

/**
 * Agent Detail View Component
 */
const AgentDetailView: React.FC<{ agent: Agent }> = ({ agent }) => {
  const [paymentData, setPaymentData] = React.useState({
    paymentMethod: 'bank_transfer',
    referenceId: '',
    paymentDate: new Date().toISOString().split('T')[0],
  });

  const handlePaymentDataChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setPaymentData((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Agent Information */}
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-4">Agent Information</h4>
          <div className="bg-gray-50 p-4 rounded-lg space-y-3 text-sm">
            <div>
              <p className="text-gray-600">Name</p>
              <p className="font-medium">{agent.name}</p>
            </div>
            <div>
              <p className="text-gray-600">Mobile</p>
              <p className="font-medium">{agent.mobile}</p>
            </div>
            <div>
              <p className="text-gray-600">License #</p>
              <p className="font-medium">{agent.licenseNumber}</p>
            </div>
            <div>
              <p className="text-gray-600">Agency</p>
              <p className="font-medium">{agent.agencyName}</p>
            </div>
            <div>
              <p className="text-gray-600">City</p>
              <p className="font-medium">{agent.city}</p>
            </div>
            <div>
              <p className="text-gray-600">Commission Enabled</p>
              <p className="font-medium">{agent.commissionEnabled ? '✓ Yes' : '✗ No'}</p>
            </div>
          </div>
        </div>

        {/* Maintenance Fee Status */}
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-4">Maintenance Fee Status</h4>
          <div className="bg-gray-50 p-4 rounded-lg space-y-3 text-sm">
            <div>
              <p className="text-gray-600">Annual Fee</p>
              <p className="font-medium">₹{agent.maintenanceFee}</p>
            </div>
            <div>
              <p className="text-gray-600">Current Status</p>
              <p className="mt-1">
                <Badge variant={getFeeBadgeVariant(agent.feeStatus)}>
                  {agent.feeStatus.toUpperCase()}
                </Badge>
              </p>
            </div>
            <div>
              <p className="text-gray-600">Last Paid</p>
              <p className="font-medium">{agent.lastFeePaid || 'Never'}</p>
            </div>
            <div>
              <p className="text-gray-600">Due Date</p>
              <p className="font-medium">{agent.feeDueDate || 'N/A'}</p>
            </div>
            <div className="border-t pt-3">
              <p className="text-gray-600">Commissions Status</p>
              <p className="font-medium text-error">
                {agent.feeStatus === 'overdue' ? 'Locked until fee paid' : 'Active'}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Record Payment Form */}
      {agent.feeStatus !== 'paid' && (
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-4">Record Maintenance Fee Payment</h4>
          <div className="bg-gray-50 p-4 rounded-lg space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-900 mb-1">Payment Amount</label>
              <input
                type="number"
                value={agent.maintenanceFee}
                disabled
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm bg-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-900 mb-1">Payment Method</label>
              <select
                name="paymentMethod"
                value={paymentData.paymentMethod}
                onChange={handlePaymentDataChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              >
                <option value="bank_transfer">Bank Transfer</option>
                <option value="cheque">Cheque</option>
                <option value="cash">Cash</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-900 mb-1">
                Payment Reference / Transaction ID
              </label>
              <input
                type="text"
                name="referenceId"
                value={paymentData.referenceId}
                onChange={handlePaymentDataChange}
                placeholder="e.g., TXN20250315001"
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-900 mb-1">Payment Date</label>
              <input
                type="date"
                name="paymentDate"
                value={paymentData.paymentDate}
                onChange={handlePaymentDataChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              />
            </div>
          </div>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex gap-3 justify-end border-t pt-6">
        <Button variant="secondary">Cancel</Button>
        {agent.feeStatus !== 'paid' && (
          <Button variant="success">✓ Record Payment & Activate Commissions</Button>
        )}
      </div>
    </div>
  );
};

const getFeeBadgeVariant = (status: string): any => {
  const variants: Record<string, any> = {
    paid: 'success',
    pending: 'warning',
    overdue: 'error',
  };
  return variants[status] || 'info';
};
