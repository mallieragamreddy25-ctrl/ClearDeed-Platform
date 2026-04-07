/**
 * @file Property Verification Screen
 * Manage and verify pending properties
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
import { propertyApi } from '@services/api';
import { Property, PropertyFilters } from '@types/index';
import { PROPERTY_CATEGORIES, CITIES } from '@utils/constants';

/**
 * Property Verification Screen
 */
export const PropertyVerification: React.FC = () => {
  const { page, pageSize } = usePagination();
  const { filters, setFilter, updateFilters, clearFilters } = useFilters();
  const [selectedProperty, setSelectedProperty] = useState<Property | null>(null);
  const [showDetailModal, setShowDetailModal] = useState(false);

  const { data: propertiesData, loading } = useApi(() =>
    propertyApi.getProperties(page, filters)
  );

  const handleFilterApply = (newFilters: Record<string, any>) => {
    updateFilters(newFilters);
  };

  const handleFilterClear = () => {
    clearFilters();
  };

  const openPropertyDetail = (property: Property) => {
    setSelectedProperty(property);
    setShowDetailModal(true);
  };

  const getStatusBadge = (status: string) => {
    const variants: Record<string, any> = {
      pending: 'pending',
      under_review: 'pending',
      verified: 'success',
      rejected: 'error',
    };
    return variants[status] || 'info';
  };

  const filterConfigs = [
    {
      key: 'category',
      label: 'Category',
      type: 'select' as const,
      options: PROPERTY_CATEGORIES,
    },
    {
      key: 'city',
      label: 'City',
      type: 'select' as const,
      options: CITIES,
    },
    {
      key: 'status',
      label: 'Status',
      type: 'select' as const,
      options: [
        { value: 'pending', label: 'Under Review (15)' },
        { value: 'under_review', label: 'Documents Complete (8)' },
      ],
    },
  ];

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Property Verification"
        description={`${propertiesData?.total || 0} properties awaiting review`}
        breadcrumbs={[{ label: 'Home' }, { label: 'Verification' }]}
        icon="✓"
      />

      {/* Filters */}
      <Filters
        filters={filterConfigs}
        onApply={handleFilterApply}
        onClear={handleFilterClear}
        currentFilters={filters}
      />

      {/* Properties Table */}
      <Card>
        <Table<Property>
          columns={[
            {
              key: 'id',
              label: 'Property ID',
              width: '100px',
              render: (value) => <span className="font-mono font-medium">#{value}</span>,
            },
            {
              key: 'title',
              label: 'Title & Location',
              render: (value, row) => (
                <div>
                  <p className="font-medium text-gray-900">{value}</p>
                  <p className="text-sm text-gray-600">{row.location}</p>
                </div>
              ),
            },
            {
              key: 'category',
              label: 'Category',
              render: (value) => (
                <span className="capitalize text-sm text-gray-600">{value.replace('_', ' ')}</span>
              ),
            },
            {
              key: 'price',
              label: 'Price',
              render: (value) => (
                <span className="font-medium">₹{(value / 100000).toFixed(1)}L</span>
              ),
            },
            {
              key: 'documents',
              label: 'Documents',
              render: (docs) => (
                <Badge variant={docs?.length >= 4 ? 'success' : 'warning'}>
                  {docs?.length || 0}/4
                </Badge>
              ),
            },
            {
              key: 'status',
              label: 'Status',
              render: (value) => (
                <Badge variant={getStatusBadge(value)}>
                  {value === 'under_review' ? 'Under Review' : value.replace('_', ' ')}
                </Badge>
              ),
            },
            {
              key: 'id',
              label: 'Action',
              render: (value, row) => (
                <Button variant="secondary" size="sm" onClick={() => openPropertyDetail(row)}>
                  Review
                </Button>
              ),
            },
          ]}
          data={propertiesData?.items || []}
          loading={loading}
          emptyState="No properties to verify"
          keyExtractor={(row) => row.id}
        />
      </Card>

      {/* Property Detail Modal */}
      <Modal
        isOpen={showDetailModal}
        onClose={() => setShowDetailModal(false)}
        title={selectedProperty ? `Verify Property #${selectedProperty.id}` : undefined}
        maxWidth="lg"
      >
        {selectedProperty && <PropertyVerificationDetail property={selectedProperty} />}
      </Modal>
    </div>
  );
};

/**
 * Property Verification Detail Component
 */
const PropertyVerificationDetail: React.FC<{ property: Property }> = ({ property }) => {
  const [verificationData, setVerificationData] = useState({
    legalOwnershipVerified: true,
    documentsAuthentic: true,
    noDisputes: true,
    priceReasonable: true,
    allDocumentsProvided: true,
    notes: '',
  });

  const handleCheckChange = (key: string, value: boolean) => {
    setVerificationData((prev) => ({ ...prev, [key]: value }));
  };

  const handleNotesChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setVerificationData((prev) => ({ ...prev, notes: e.target.value }));
  };

  return (
    <div className="space-y-6">
      {/* Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Property Information */}
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-4">Property Information</h4>
          <div className="space-y-3 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Title:</span>
              <span className="font-medium">{property.title}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Category:</span>
              <span className="font-medium capitalize">{property.category.replace('_', ' ')}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Location:</span>
              <span className="font-medium">{property.location}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Price:</span>
              <span className="font-medium">₹{(property.price / 100000).toFixed(1)}L</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Area:</span>
              <span className="font-medium">{property.area} sq.ft</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Seller:</span>
              <span className="font-medium">{property.sellerName}</span>
            </div>
          </div>

          {/* Documents Uploaded */}
          <h4 className="text-sm font-semibold text-gray-900 mt-6 mb-3">Documents Uploaded</h4>
          <ul className="space-y-2">
            {property.documents.map((doc) => (
              <li key={doc.id} className="flex items-start gap-2 text-sm">
                <span className="text-success">✓</span>
                <div>
                  <p className="font-medium">{doc.type}</p>
                  <p className="text-gray-600 text-xs">Verified</p>
                </div>
              </li>
            ))}
          </ul>
        </div>

        {/* Verification Checklist */}
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-4">Verification Checklist</h4>
          <div className="space-y-3">
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={verificationData.legalOwnershipVerified}
                onChange={(e) => handleCheckChange('legalOwnershipVerified', e.target.checked)}
                className="w-4 h-4 mt-0.5 rounded border-gray-300 text-primary-800"
              />
              <span className="text-sm text-gray-700">Legal ownership verified</span>
            </label>
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={verificationData.documentsAuthentic}
                onChange={(e) => handleCheckChange('documentsAuthentic', e.target.checked)}
                className="w-4 h-4 mt-0.5 rounded border-gray-300 text-primary-800"
              />
              <span className="text-sm text-gray-700">Property documents authentic</span>
            </label>
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={verificationData.noDisputes}
                onChange={(e) => handleCheckChange('noDisputes', e.target.checked)}
                className="w-4 h-4 mt-0.5 rounded border-gray-300 text-primary-800"
              />
              <span className="text-sm text-gray-700">No title disputes found</span>
            </label>
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={verificationData.priceReasonable}
                onChange={(e) => handleCheckChange('priceReasonable', e.target.checked)}
                className="w-4 h-4 mt-0.5 rounded border-gray-300 text-primary-800"
              />
              <span className="text-sm text-gray-700">Price reasonable for location</span>
            </label>
            <label className="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={verificationData.allDocumentsProvided}
                onChange={(e) => handleCheckChange('allDocumentsProvided', e.target.checked)}
                className="w-4 h-4 mt-0.5 rounded border-gray-300 text-primary-800"
              />
              <span className="text-sm text-gray-700">All mandatory docs provided</span>
            </label>

            {/* Verification Notes */}
            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-900 mb-2">
                Verification Notes
              </label>
              <textarea
                value={verificationData.notes}
                onChange={handleNotesChange}
                placeholder="Add any notes..."
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-3 justify-end border-t pt-6">
        <Button variant="secondary">Save & Continue</Button>
        <Button variant="danger">✗ Reject</Button>
        <Button variant="success">✓ Approve</Button>
      </div>
    </div>
  );
};
