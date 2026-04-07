/**
 * @file Reporting & Analytics Screen
 * Commission reports, verification metrics, deal velocity, revenue analytics, and custom reports
 */

import React, { useState, useEffect } from 'react';
import { PageHeader, Card, Button, Table, Modal, StatCard, Filters } from '@components/index';
import {
  CommissionReport,
  VerificationMetrics,
  DealVelocityMetrics,
  RevenueMetrics,
} from '@types/index';

/**
 * Reporting Component
 * Comprehensive reporting and analytics dashboard
 */
export const Reporting: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'commission' | 'verification' | 'revenue' | 'velocity'>('commission');
  const [showModal, setShowModal] = useState(false);
  const [exportFormat, setExportFormat] = useState<'pdf' | 'csv' | 'excel'>('pdf');
  const [dateRange, setDateRange] = useState({ from: '', to: '' });
  const [commissionReports, setCommissionReports] = useState<CommissionReport[]>([]);
  const [verificationMetrics, setVerificationMetrics] = useState<VerificationMetrics | null>(null);
  const [dealVelocity, setDealVelocity] = useState<DealVelocityMetrics | null>(null);
  const [revenueMetrics, setRevenueMetrics] = useState<RevenueMetrics | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadReports();
  }, []);

  const loadReports = async () => {
    setLoading(true);
    try {
      // Simulated API calls
      const mockCommissionReports: CommissionReport[] = [
        {
          id: 'cr-001',
          agentId: 'agent-001',
          agentName: 'John Doe',
          period: '2026-03',
          totalDeals: 12,
          totalAmount: 180000,
          paid: 120000,
          pending: 60000,
          breakdown: [
            { type: 'buyer_side', count: 6, amount: 90000, percentage: 50 },
            { type: 'seller_side', count: 6, amount: 90000, percentage: 50 },
            { type: 'referral', count: 0, amount: 0, percentage: 0 },
          ],
          generatedAt: '2026-03-28T10:00:00Z',
        },
        {
          id: 'cr-002',
          agentId: 'agent-002',
          agentName: 'Jane Smith',
          period: '2026-03',
          totalDeals: 8,
          totalAmount: 140000,
          paid: 140000,
          pending: 0,
          breakdown: [
            { type: 'buyer_side', count: 4, amount: 70000, percentage: 50 },
            { type: 'seller_side', count: 4, amount: 70000, percentage: 50 },
            { type: 'referral', count: 0, amount: 0, percentage: 0 },
          ],
          generatedAt: '2026-03-28T10:00:00Z',
        },
      ];

      const mockVerificationMetrics: VerificationMetrics = {
        totalProperties: 250,
        verifiedCount: 180,
        rejectedCount: 25,
        pendingCount: 45,
        averageVerificationTime: 4.5,
        verificationRate: 72,
        byCity: [
          { city: 'Bangalore', total: 100, verified: 78, rate: 78 },
          { city: 'Pune', total: 80, verified: 62, rate: 77.5 },
          { city: 'Mumbai', total: 70, verified: 40, rate: 57 },
        ],
        byCategory: [
          { category: 'Land', total: 80, verified: 72, rate: 90 },
          { category: 'House', total: 120, verified: 85, rate: 70.8 },
          { category: 'Commercial', total: 50, verified: 23, rate: 46 },
        ],
      };

      const mockDealVelocity: DealVelocityMetrics = {
        period: '2026-03',
        totalDeals: 45,
        closedDeals: 38,
        averageDealValue: 450000,
        averageDealTime: 12,
        trend: 'up',
        dailyData: [
          { date: '2026-03-20', created: 2, closed: 1, value: 850000 },
          { date: '2026-03-21', created: 3, closed: 2, value: 1200000 },
          { date: '2026-03-22', created: 2, closed: 3, value: 950000 },
        ],
      };

      const mockRevenueMetrics: RevenueMetrics = {
        period: '2026-03',
        totalRevenue: 450000,
        commissionRevenue: 300000,
        feeRevenue: 150000,
        bySource: [
          { source: 'Commission - Buyer', amount: 150000, percentage: 33.3 },
          { source: 'Commission - Seller', amount: 150000, percentage: 33.3 },
          { source: 'Platform Fees', amount: 150000, percentage: 33.4 },
        ],
        trend: 8.5,
      };

      setCommissionReports(mockCommissionReports);
      setVerificationMetrics(mockVerificationMetrics);
      setDealVelocity(mockDealVelocity);
      setRevenueMetrics(mockRevenueMetrics);
    } catch (error) {
      console.error('Failed to load reports:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleExportReport = async (format: 'pdf' | 'csv' | 'excel') => {
    try {
      // Simulated export
      console.log(`Exporting ${activeTab} report as ${format}`);
      setShowModal(false);
      // In a real application, this would trigger a download
    } catch (error) {
      console.error('Failed to export report:', error);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Reports & Analytics"
        description="Commission reports, verification metrics, deal velocity, and revenue analytics"
      />

      {/* Quick Actions */}
      <div className="flex gap-3">
        <Button
          onClick={() => setShowModal(true)}
          variant="primary"
          size="md"
        >
          📥 Export Report
        </Button>
        <Button variant="secondary" size="md">
          📧 Schedule Report
        </Button>
        <Button variant="secondary" size="md">
          ⚙️ Custom Report
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('commission')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'commission'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Commission Reports
        </button>
        <button
          onClick={() => setActiveTab('verification')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'verification'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Verification Metrics
        </button>
        <button
          onClick={() => setActiveTab('revenue')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'revenue'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Revenue Analytics
        </button>
        <button
          onClick={() => setActiveTab('velocity')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'velocity'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Deal Velocity
        </button>
      </div>

      {/* Commission Reports Tab */}
      {activeTab === 'commission' && (
        <div className="space-y-4">
          <Filters onFilterChange={() => {}} />

          <Table
            columns={[
              { key: 'agent', label: 'Agent', width: '20%' },
              { key: 'period', label: 'Period', width: '12%' },
              { key: 'deals', label: 'Deals', width: '12%' },
              { key: 'total', label: 'Total Amount', width: '20%' },
              { key: 'paid', label: 'Paid', width: '15%' },
              { key: 'pending', label: 'Pending', width: '15%' },
              { key: 'action', label: 'Action', width: '6%' },
            ]}
            data={commissionReports.map((report) => ({
              agent: report.agentName,
              period: report.period,
              deals: report.totalDeals,
              total: `₹${(report.totalAmount / 100000).toFixed(1)}L`,
              paid: `₹${(report.paid / 100000).toFixed(1)}L`,
              pending: `₹${(report.pending / 100000).toFixed(1)}L`,
              action: '👁️',
            }))}
            onRowClick={() => {}}
          />
        </div>
      )}

      {/* Verification Metrics Tab */}
      {activeTab === 'verification' && verificationMetrics && (
        <div className="space-y-6">
          {/* Key Metrics */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard
              title="Total Properties"
              value={String(verificationMetrics.totalProperties)}
              change={12}
              icon="📊"
            />
            <StatCard
              title="Verified"
              value={String(verificationMetrics.verifiedCount)}
              change={8}
              icon="✅"
            />
            <StatCard
              title="Pending"
              value={String(verificationMetrics.pendingCount)}
              change={-5}
              icon="⏳"
            />
            <StatCard
              title="Verification Rate"
              value={`${verificationMetrics.verificationRate}%`}
              change={3}
              icon="📈"
            />
          </div>

          {/* Metrics by City */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Verification Rate by City</h3>
            <Table
              columns={[
                { key: 'city', label: 'City', width: '25%' },
                { key: 'total', label: 'Total', width: '20%' },
                { key: 'verified', label: 'Verified', width: '20%' },
                { key: 'rate', label: 'Verification Rate', width: '35%' },
              ]}
              data={verificationMetrics.byCity.map((metric) => ({
                city: metric.city,
                total: metric.total,
                verified: metric.verified,
                rate: (
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-green-600 h-2 rounded-full"
                      style={{ width: `${metric.rate}%` }}
                    />
                  </div>
                ),
              }))}
              onRowClick={() => {}}
            />
          </Card>

          {/* Metrics by Category */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Verification Rate by Property Category</h3>
            <Table
              columns={[
                { key: 'category', label: 'Category', width: '25%' },
                { key: 'total', label: 'Total', width: '20%' },
                { key: 'verified', label: 'Verified', width: '20%' },
                { key: 'rate', label: 'Rate', width: '35%' },
              ]}
              data={verificationMetrics.byCategory.map((metric) => ({
                category: metric.category,
                total: metric.total,
                verified: metric.verified,
                rate: (
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full"
                      style={{ width: `${metric.rate}%` }}
                    />
                  </div>
                ),
              }))}
              onRowClick={() => {}}
            />
          </Card>
        </div>
      )}

      {/* Revenue Analytics Tab */}
      {activeTab === 'revenue' && revenueMetrics && (
        <div className="space-y-6">
          {/* Key Metrics */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <StatCard
              title="Total Revenue"
              value={`₹${(revenueMetrics.totalRevenue / 100000).toFixed(1)}L`}
              change={revenueMetrics.trend}
              icon="💰"
            />
            <StatCard
              title="Commission Revenue"
              value={`₹${(revenueMetrics.commissionRevenue / 100000).toFixed(1)}L`}
              change={10}
              icon="🤝"
            />
            <StatCard
              title="Fee Revenue"
              value={`₹${(revenueMetrics.feeRevenue / 100000).toFixed(1)}L`}
              change={5}
              icon="💎"
            />
          </div>

          {/* Revenue by Source */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Revenue by Source</h3>
            <div className="space-y-3">
              {revenueMetrics.bySource.map((source, idx) => (
                <div key={idx}>
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm font-medium text-gray-900">{source.source}</span>
                    <span className="text-sm font-semibold text-gray-900">₹{(source.amount / 100000).toFixed(1)}L ({source.percentage.toFixed(1)}%)</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-3">
                    <div
                      className="bg-blue-600 h-3 rounded-full"
                      style={{ width: `${source.percentage}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>
      )}

      {/* Deal Velocity Tab */}
      {activeTab === 'velocity' && dealVelocity && (
        <div className="space-y-6">
          {/* Key Metrics */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard
              title="Total Deals"
              value={String(dealVelocity.totalDeals)}
              change={15}
              icon="📋"
            />
            <StatCard
              title="Closed Deals"
              value={String(dealVelocity.closedDeals)}
              change={10}
              icon="✅"
            />
            <StatCard
              title="Avg Deal Value"
              value={`₹${(dealVelocity.averageDealValue / 100000).toFixed(1)}L`}
              change={5}
              icon="💵"
            />
            <StatCard
              title="Avg Time (Days)"
              value={String(dealVelocity.averageDealTime)}
              change={dealVelocity.trend === 'up' ? 5 : -5}
              icon="⏱️"
            />
          </div>

          {/* Daily Metrics */}
          <Card className="p-6">
            <h3 className="text-lg font-semibold mb-4">Daily Deal Metrics</h3>
            <Table
              columns={[
                { key: 'date', label: 'Date', width: '20%' },
                { key: 'created', label: 'Created', width: '20%' },
                { key: 'closed', label: 'Closed', width: '20%' },
                { key: 'value', label: 'Total Value', width: '40%' },
              ]}
              data={dealVelocity.dailyData.map((data) => ({
                date: new Date(data.date).toLocaleDateString(),
                created: data.created,
                closed: data.closed,
                value: `₹${(data.value / 100000).toFixed(1)}L`,
              }))}
              onRowClick={() => {}}
            />
          </Card>
        </div>
      )}

      {/* Export Modal */}
      {showModal && (
        <Modal
          isOpen={showModal}
          onClose={() => setShowModal(false)}
          title="Export Report"
        >
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Export Format</label>
              <div className="flex gap-3">
                {(['pdf', 'csv', 'excel'] as const).map((format) => (
                  <label key={format} className="flex items-center gap-2">
                    <input
                      type="radio"
                      name="format"
                      value={format}
                      checked={exportFormat === format}
                      onChange={(e) => setExportFormat(e.target.value as any)}
                      className="w-4 h-4"
                    />
                    <span className="text-sm text-gray-700">{format.toUpperCase()}</span>
                  </label>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
              <div className="flex gap-2">
                <input
                  type="date"
                  value={dateRange.from}
                  onChange={(e) => setDateRange({ ...dateRange, from: e.target.value })}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
                />
                <input
                  type="date"
                  value={dateRange.to}
                  onChange={(e) => setDateRange({ ...dateRange, to: e.target.value })}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
            </div>

            <div className="flex gap-2 justify-end pt-4">
              <Button onClick={() => setShowModal(false)} variant="secondary">
                Cancel
              </Button>
              <Button onClick={() => handleExportReport(exportFormat)} variant="primary">
                Export
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};

export default Reporting;
