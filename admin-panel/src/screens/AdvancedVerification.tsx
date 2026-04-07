/**
 * @file Advanced Verification Screen
 * Handles bulk verification, verification rules, checklists, and AI suggestions
 */

import React, { useState, useEffect } from 'react';
import { PageHeader, Card, Button, Table, Modal, Filters, Badge } from '@components/index';
import { VerificationRule, VerificationChecklist, BulkVerificationOperation } from '@types/index';

/**
 * AdvancedVerification Component
 * Manage verification workflows with checklists, rules, and bulk operations
 */
export const AdvancedVerification: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'rules' | 'checklists' | 'bulk'>('rules');
  const [rules, setRules] = useState<VerificationRule[]>([]);
  const [checklists, setChecklists] = useState<VerificationChecklist[]>([]);
  const [bulkOps, setBulkOps] = useState<BulkVerificationOperation[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState<'rule' | 'bulk'>('rule');
  const [selectedRule, setSelectedRule] = useState<VerificationRule | null>(null);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({});

  // Form state
  const [formData, setFormData] = useState({
    ruleName: '',
    description: '',
    category: 'legal',
    checks: [] as string[],
    propertyIds: [] as string[],
    operationType: 'verify',
    newCheck: '',
  });

  useEffect(() => {
    loadRules();
    loadChecklists();
    loadBulkOperations();
  }, []);

  const loadRules = async () => {
    setLoading(true);
    try {
      // Simulated API call
      const mockRules: VerificationRule[] = [
        {
          id: '1',
          name: 'Legal Ownership Verification',
          description: 'Verify legal ownership and title clarity',
          category: 'legal',
          checks: ['Ownership verified', 'Title clear', 'No disputes', 'Possession clear'],
          enabled: true,
          createdAt: '2026-03-20T10:00:00Z',
          updatedAt: '2026-03-28T15:30:00Z',
        },
        {
          id: '2',
          name: 'Document Authenticity Check',
          description: 'Verify authenticity of all submitted documents',
          category: 'document',
          checks: [
            'All documents provided',
            'Documents authentic',
            'Ownership in name of seller',
            'No alterations',
          ],
          enabled: true,
          createdAt: '2026-03-15T09:00:00Z',
          updatedAt: '2026-03-25T14:00:00Z',
        },
      ];
      setRules(mockRules);
    } catch (error) {
      console.error('Failed to load verification rules:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadChecklists = async () => {
    try {
      const mockChecklists: VerificationChecklist[] = [
        {
          id: 'cl-001',
          propertyId: 'prop-001',
          ruleId: '1',
          checkItems: [
            { id: '1', name: 'Ownership verified', completed: true, verifier: 'John Doe', timestamp: '2026-03-28T10:30:00Z' },
            { id: '2', name: 'Title clear', completed: true, verifier: 'John Doe', timestamp: '2026-03-28T11:00:00Z' },
            { id: '3', name: 'No disputes', completed: false },
          ],
          status: 'in_progress',
          completedPercentage: 66,
          verifierId: 'verifier-001',
          createdAt: '2026-03-27T09:00:00Z',
          updatedAt: '2026-03-28T11:30:00Z',
        },
      ];
      setChecklists(mockChecklists);
    } catch (error) {
      console.error('Failed to load checklists:', error);
    }
  };

  const loadBulkOperations = async () => {
    try {
      const mockOps: BulkVerificationOperation[] = [
        {
          id: 'bulk-001',
          type: 'verify',
          propertyIds: ['prop-001', 'prop-002', 'prop-003'],
          status: 'completed',
          totalItems: 3,
          processedItems: 3,
          startedAt: '2026-03-28T08:00:00Z',
          completedAt: '2026-03-28T08:45:00Z',
        },
      ];
      setBulkOps(mockOps);
    } catch (error) {
      console.error('Failed to load bulk operations:', error);
    }
  };

  const handleCreateRule = async () => {
    try {
      const newRule: VerificationRule = {
        id: String(rules.length + 1),
        name: formData.ruleName,
        description: formData.description,
        category: formData.category as any,
        checks: formData.checks,
        enabled: true,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      setRules([...rules, newRule]);
      resetForm();
      setShowModal(false);
    } catch (error) {
      console.error('Failed to create rule:', error);
    }
  };

  const handleBulkOperation = async () => {
    try {
      const newOp: BulkVerificationOperation = {
        id: `bulk-${Date.now()}`,
        type: formData.operationType as any,
        propertyIds: formData.propertyIds,
        status: 'pending',
        totalItems: formData.propertyIds.length,
        processedItems: 0,
        startedAt: new Date().toISOString(),
      };
      setBulkOps([...bulkOps, newOp]);
      resetForm();
      setShowModal(false);
    } catch (error) {
      console.error('Failed to create bulk operation:', error);
    }
  };

  const handleAddCheck = () => {
    if (formData.newCheck.trim()) {
      setFormData({
        ...formData,
        checks: [...formData.checks, formData.newCheck],
        newCheck: '',
      });
    }
  };

  const handleRemoveCheck = (index: number) => {
    setFormData({
      ...formData,
      checks: formData.checks.filter((_, i) => i !== index),
    });
  };

  const resetForm = () => {
    setFormData({
      ruleName: '',
      description: '',
      category: 'legal',
      checks: [],
      propertyIds: [],
      operationType: 'verify',
      newCheck: '',
    });
    setSelectedRule(null);
  };

  const handleOpenModal = (type: 'rule' | 'bulk') => {
    resetForm();
    setModalType(type);
    setShowModal(true);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Advanced Property Verification"
        description="Manage verification rules, checklists, bulk operations, and AI suggestions"
      />

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('rules')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'rules'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Verification Rules
        </button>
        <button
          onClick={() => setActiveTab('checklists')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'checklists'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Verification Checklists
        </button>
        <button
          onClick={() => setActiveTab('bulk')}
          className={`px-4 py-2 font-medium text-sm ${
            activeTab === 'bulk'
              ? 'border-b-2 border-blue-600 text-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          Bulk Operations
        </button>
      </div>

      {/* Rules Tab */}
      {activeTab === 'rules' && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-semibold">Verification Rules</h3>
            <Button onClick={() => handleOpenModal('rule')} variant="primary" size="md">
              + Create Rule
            </Button>
          </div>

          <div className="grid gap-4">
            {rules.map((rule) => (
              <Card key={rule.id} className="p-4">
                <div className="flex justify-between items-start">
                  <div>
                    <h4 className="font-semibold text-gray-900">{rule.name}</h4>
                    <p className="text-sm text-gray-600 mt-1">{rule.description}</p>
                    <div className="mt-3 flex gap-2 flex-wrap">
                      {rule.checks.map((check, idx) => (
                        <Badge key={idx} text={check} variant="info" />
                      ))}
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Badge
                      text={rule.category.toUpperCase()}
                      variant={rule.enabled ? 'success' : 'warning'}
                    />
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Checklists Tab */}
      {activeTab === 'checklists' && (
        <div className="space-y-4">
          <div>
            <h3 className="text-lg font-semibold mb-4">Active Verification Checklists</h3>
            <Filters onFilterChange={() => {}} />
          </div>

          <div className="grid gap-4">
            {checklists.map((checklist) => (
              <Card key={checklist.id} className="p-4">
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <h4 className="font-semibold">Property: {checklist.propertyId}</h4>
                    <Badge
                      text={checklist.status.toUpperCase()}
                      variant={
                        checklist.status === 'completed'
                          ? 'success'
                          : checklist.status === 'failed'
                            ? 'danger'
                            : 'warning'
                      }
                    />
                  </div>

                  {/* Progress Bar */}
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full transition-all"
                      style={{ width: `${checklist.completedPercentage}%` }}
                    />
                  </div>
                  <p className="text-sm text-gray-600">{checklist.completedPercentage}% Complete</p>

                  {/* Checklist Items */}
                  <div className="space-y-2 mt-4">
                    {checklist.checkItems.map((item) => (
                      <div key={item.id} className="flex items-center gap-3 p-2 bg-gray-50 rounded">
                        <input type="checkbox" checked={item.completed} readOnly className="w-4 h-4" />
                        <span className={item.completed ? 'line-through text-gray-500' : 'text-gray-900'}>
                          {item.name}
                        </span>
                        {item.verifier && (
                          <span className="text-xs text-gray-500 ml-auto">By: {item.verifier}</span>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Bulk Operations Tab */}
      {activeTab === 'bulk' && (
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-semibold">Bulk Operations</h3>
            <Button onClick={() => handleOpenModal('bulk')} variant="primary" size="md">
              + Start Bulk Operation
            </Button>
          </div>

          <Table
            columns={[
              { key: 'id', label: 'Operation ID', width: '20%' },
              { key: 'type', label: 'Type', width: '15%' },
              { key: 'status', label: 'Status', width: '15%' },
              { key: 'progress', label: 'Progress', width: '30%' },
              { key: 'dates', label: 'Timeline', width: '20%' },
            ]}
            data={bulkOps.map((op) => ({
              id: op.id,
              type: op.type.toUpperCase(),
              status: (
                <Badge
                  text={op.status.toUpperCase()}
                  variant={
                    op.status === 'completed'
                      ? 'success'
                      : op.status === 'failed'
                        ? 'danger'
                        : 'warning'
                  }
                />
              ),
              progress: (
                <div className="space-y-1">
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-green-600 h-2 rounded-full"
                      style={{ width: `${(op.processedItems / op.totalItems) * 100}%` }}
                    />
                  </div>
                  <p className="text-xs text-gray-600">
                    {op.processedItems} of {op.totalItems}
                  </p>
                </div>
              ),
              dates: (
                <div className="text-xs text-gray-600">
                  <p>Started: {new Date(op.startedAt).toLocaleDateString()}</p>
                  {op.completedAt && <p>Completed: {new Date(op.completedAt).toLocaleDateString()}</p>}
                </div>
              ),
            }))}
            onRowClick={() => {}}
          />
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <Modal
          isOpen={showModal}
          onClose={() => setShowModal(false)}
          title={modalType === 'rule' ? 'Create Verification Rule' : 'Start Bulk Operation'}
        >
          <div className="space-y-4">
            {modalType === 'rule' ? (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Rule Name</label>
                  <input
                    type="text"
                    value={formData.ruleName}
                    onChange={(e) => setFormData({ ...formData, ruleName: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter rule name"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter description"
                    rows={3}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="legal">Legal</option>
                    <option value="financial">Financial</option>
                    <option value="document">Document</option>
                    <option value="property">Property</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Verification Checks</label>
                  <div className="space-y-2">
                    {formData.checks.map((check, idx) => (
                      <div key={idx} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                        <span>{check}</span>
                        <button
                          onClick={() => handleRemoveCheck(idx)}
                          className="text-red-600 hover:text-red-800 text-sm"
                        >
                          Remove
                        </button>
                      </div>
                    ))}
                  </div>

                  <div className="flex gap-2 mt-2">
                    <input
                      type="text"
                      value={formData.newCheck}
                      onChange={(e) => setFormData({ ...formData, newCheck: e.target.value })}
                      onKeyPress={(e) => e.key === 'Enter' && handleAddCheck()}
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Add a check item"
                    />
                    <Button onClick={handleAddCheck} variant="secondary" size="sm">
                      Add
                    </Button>
                  </div>
                </div>

                <div className="flex gap-2 justify-end pt-4">
                  <Button onClick={() => setShowModal(false)} variant="secondary">
                    Cancel
                  </Button>
                  <Button onClick={handleCreateRule} variant="primary">
                    Create Rule
                  </Button>
                </div>
              </>
            ) : (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Operation Type</label>
                  <select
                    value={formData.operationType}
                    onChange={(e) => setFormData({ ...formData, operationType: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="verify">Verify Properties</option>
                    <option value="reject">Reject Properties</option>
                    <option value="reassign">Reassign to Verifier</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Property IDs (comma-separated)
                  </label>
                  <textarea
                    value={formData.propertyIds.join(', ')}
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        propertyIds: e.target.value.split(',').map((id) => id.trim()),
                      })
                    }
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="prop-001, prop-002, prop-003"
                    rows={4}
                  />
                </div>

                <div className="flex gap-2 justify-end pt-4">
                  <Button onClick={() => setShowModal(false)} variant="secondary">
                    Cancel
                  </Button>
                  <Button onClick={handleBulkOperation} variant="primary">
                    Start Operation
                  </Button>
                </div>
              </>
            )}
          </div>
        </Modal>
      )}
    </div>
  );
};

export default AdvancedVerification;
