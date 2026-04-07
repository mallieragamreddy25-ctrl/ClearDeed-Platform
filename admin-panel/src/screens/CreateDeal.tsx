/**
 * @file Create Deal Screen
 * Multi-step form for creating new deals
 */

import React, { useState } from 'react';
import { PageHeader, Card, Button, Modal } from '@components/index';
import { useApiMutation } from '@hooks/useApi';
import { dealApi } from '@services/api';

type CreateDealStep = 'parties' | 'property' | 'referrals' | 'review';

interface CreateDealFormData {
  buyerId: string;
  buyerName: string;
  sellerId: string;
  sellerName: string;
  propertyId: string;
  buyerAgentId: string;
  sellerAgentId: string;
  buyerCommissionPercentage: number;
  sellerCommissionPercentage: number;
}

/**
 * Create Deal Screen
 */
export const CreateDeal: React.FC = () => {
  const [currentStep, setCurrentStep] = useState<CreateDealStep>('parties');
  const [formData, setFormData] = useState<CreateDealFormData>({
    buyerId: '',
    buyerName: '',
    sellerId: '',
    sellerName: '',
    propertyId: '',
    buyerAgentId: '',
    sellerAgentId: '',
    buyerCommissionPercentage: 2,
    sellerCommissionPercentage: 2,
  });

  const { execute: createDeal, loading: createLoading } = useApiMutation(
    dealApi.createDeal
  );

  const steps: CreateDealStep[] = ['parties', 'property', 'referrals', 'review'];
  const currentStepIndex = steps.indexOf(currentStep);

  const handleStepChange = (step: CreateDealStep) => {
    setCurrentStep(step);
  };

  const handleInputChange = (field: keyof CreateDealFormData, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleNextStep = () => {
    if (currentStepIndex < steps.length - 1) {
      setCurrentStep(steps[currentStepIndex + 1]);
    }
  };

  const handlePrevStep = () => {
    if (currentStepIndex > 0) {
      setCurrentStep(steps[currentStepIndex - 1]);
    }
  };

  const handleSubmit = async () => {
    const result = await createDeal(formData);
    if (result.success) {
      // Show success modal and redirect
      alert('Deal created successfully!');
      // window.location.href = '/deals';
    }
  };

  return (
    <div className="p-6 space-y-6">
      {/* Page Header */}
      <PageHeader
        title="Create New Deal"
        description="Follow the steps to create a new deal with buyer and seller"
        breadcrumbs={[{ label: 'Home' }, { label: 'Deals' }, { label: 'Create' }]}
        icon="🤝"
      />

      {/* Step Indicator */}
      <Card padding="lg">
        <div className="flex items-center justify-between mb-6">
          {steps.map((step, index) => (
            <React.Fragment key={step}>
              <button
                onClick={() => handleStepChange(step)}
                className={`
                  flex items-center justify-center w-12 h-12 rounded-full border-2 transition-colors
                  ${
                    index <= currentStepIndex
                      ? 'bg-primary-800 border-primary-800 text-white'
                      : 'bg-white border-gray-300 text-gray-600'
                  }
                `}
                disabled={index > currentStepIndex}
              >
                {index <= currentStepIndex - 1 ? '✓' : index + 1}
              </button>
              {index < steps.length - 1 && (
                <div
                  className={`flex-1 h-1 mx-2 ${
                    index < currentStepIndex ? 'bg-primary-800' : 'bg-gray-300'
                  }`}
                />
              )}
            </React.Fragment>
          ))}
        </div>

        <div className="flex justify-between items-center">
          <div className="text-sm font-medium text-gray-600">
            Step {currentStepIndex + 1} of {steps.length}
          </div>
          <div className="text-sm font-semibold text-primary-800 capitalize">
            {currentStep === 'parties' && 'Select Buyer & Seller'}
            {currentStep === 'property' && 'Select Property'}
            {currentStep === 'referrals' && 'Assign Referrals & Commission'}
            {currentStep === 'review' && 'Review & Confirm'}
          </div>
        </div>
      </Card>

      {/* Step Content */}
      <Card>
        {currentStep === 'parties' && (
          <StepParties formData={formData} onInputChange={handleInputChange} />
        )}
        {currentStep === 'property' && (
          <StepProperty formData={formData} onInputChange={handleInputChange} />
        )}
        {currentStep === 'referrals' && (
          <StepReferrals formData={formData} onInputChange={handleInputChange} />
        )}
        {currentStep === 'review' && (
          <StepReview formData={formData} />
        )}

        {/* Navigation Buttons */}
        <div className="flex gap-3 justify-end border-t pt-6 mt-6">
          <Button
            variant="secondary"
            onClick={handlePrevStep}
            disabled={currentStepIndex === 0}
          >
            ← Previous
          </Button>
          {currentStep !== 'review' ? (
            <Button variant="primary" onClick={handleNextStep}>
              Next →
            </Button>
          ) : (
            <Button
              variant="success"
              onClick={handleSubmit}
              isLoading={createLoading}
            >
              ✓ Create Deal
            </Button>
          )}
        </div>
      </Card>
    </div>
  );
};

/**
 * Step 1: Select Buyer & Seller
 */
const StepParties: React.FC<{
  formData: CreateDealFormData;
  onInputChange: (field: keyof CreateDealFormData, value: any) => void;
}> = ({ formData, onInputChange }) => {
  const mockBuyers = [
    { id: '234', name: 'Priya Sharma', mobile: '+91 98765 43210', city: 'Bangalore' },
    { id: '235', name: 'Amit Patel', mobile: '+91 98765 43211', city: 'Delhi' },
    { id: '236', name: 'Rajesh Singh', mobile: '+91 98765 43212', city: 'Mumbai' },
  ];

  const mockSellers = [
    { id: '123', name: 'Rajesh Kumar', mobile: '+91 98765 43200', city: 'Bangalore' },
    { id: '124', name: 'Neha Verma', mobile: '+91 98765 43201', city: 'Delhi' },
    { id: '125', name: 'Priya Gupta', mobile: '+91 98765 43202', city: 'Mumbai' },
  ];

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* Buyer Selection */}
      <div>
        <h4 className="text-lg font-semibold text-gray-900 mb-4">Select Buyer</h4>
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-900 mb-2">Search Buyer</label>
          <input
            type="text"
            placeholder="Enter mobile, name, or user ID..."
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
          />
        </div>
        <div className="space-y-2 bg-gray-50 rounded-lg p-3 max-h-96 overflow-y-auto border border-gray-200">
          {mockBuyers.map((buyer) => (
            <div
              key={buyer.id}
              onClick={() => {
                onInputChange('buyerId', buyer.id);
                onInputChange('buyerName', buyer.name);
              }}
              className={`
                p-3 border rounded-lg cursor-pointer transition-colors
                ${formData.buyerId === buyer.id
                  ? 'bg-primary-800 text-white border-primary-800'
                  : 'bg-white border-gray-200 hover:bg-gray-100'
                }
              `}
            >
              <div className="font-medium">{buyer.name}</div>
              <div className="text-sm opacity-75">{buyer.mobile}</div>
              <div className="text-xs opacity-75">{buyer.city}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Seller Selection */}
      <div>
        <h4 className="text-lg font-semibold text-gray-900 mb-4">Select Seller</h4>
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-900 mb-2">Search Seller</label>
          <input
            type="text"
            placeholder="Enter mobile, name, or user ID..."
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
          />
        </div>
        <div className="space-y-2 bg-gray-50 rounded-lg p-3 max-h-96 overflow-y-auto border border-gray-200">
          {mockSellers.map((seller) => (
            <div
              key={seller.id}
              onClick={() => {
                onInputChange('sellerId', seller.id);
                onInputChange('sellerName', seller.name);
              }}
              className={`
                p-3 border rounded-lg cursor-pointer transition-colors
                ${formData.sellerId === seller.id
                  ? 'bg-primary-800 text-white border-primary-800'
                  : 'bg-white border-gray-200 hover:bg-gray-100'
                }
              `}
            >
              <div className="font-medium">{seller.name}</div>
              <div className="text-sm opacity-75">{seller.mobile}</div>
              <div className="text-xs opacity-75">{seller.city}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

/**
 * Step 2: Select Property
 */
const StepProperty: React.FC<{
  formData: CreateDealFormData;
  onInputChange: (field: keyof CreateDealFormData, value: any) => void;
}> = ({ formData, onInputChange }) => {
  const mockProperties = [
    { id: '542', title: 'Plot in Indiranagar', location: 'Bangalore', price: 45_000_000 },
    { id: '541', title: '3 BHK House Whitefield', location: 'Bangalore', price: 120_000_000 },
    { id: '540', title: 'Agricultural Land', location: 'Nashik', price: 35_000_000 },
  ];

  return (
    <div>
      <h4 className="text-lg font-semibold text-gray-900 mb-4">Select Property</h4>
      <div className="mb-4">
        <label className="block text-sm font-medium text-gray-900 mb-2">Search Property</label>
        <input
          type="text"
          placeholder="Search by ID, title, or location..."
          className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
        />
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {mockProperties.map((property) => (
          <div
            key={property.id}
            onClick={() => onInputChange('propertyId', property.id)}
            className={`
              p-4 border-2 rounded-lg cursor-pointer transition-colors
              ${formData.propertyId === property.id
                ? 'bg-primary-50 border-primary-800'
                : 'bg-white border-gray-200 hover:bg-gray-50'
              }
            `}
          >
            <div className="font-semibold text-gray-900">#{property.id} - {property.title}</div>
            <div className="text-sm text-gray-600 mt-1">{property.location}</div>
            <div className="text-lg font-bold text-primary-800 mt-2">
              ₹{(property.price / 100000).toFixed(1)}L
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

/**
 * Step 3: Assign Referrals & Commission
 */
const StepReferrals: React.FC<{
  formData: CreateDealFormData;
  onInputChange: (field: keyof CreateDealFormData, value: any) => void;
}> = ({ formData, onInputChange }) => {
  const mockAgents = [
    { id: 'AG001', name: 'Akshay Reddy' },
    { id: 'AG002', name: 'Ravi Singh' },
    { id: 'AG003', name: 'Deepak Kumar' },
  ];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Buyer Agent */}
        <div>
          <h4 className="text-lg font-semibold text-gray-900 mb-4">Buyer Agent</h4>
          <select
            value={formData.buyerAgentId}
            onChange={(e) => onInputChange('buyerAgentId', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
          >
            <option value="">Select Buyer Agent</option>
            {mockAgents.map((agent) => (
              <option key={agent.id} value={agent.id}>
                {agent.name} ({agent.id})
              </option>
            ))}
          </select>
        </div>

        {/* Seller Agent */}
        <div>
          <h4 className="text-lg font-semibold text-gray-900 mb-4">Seller Agent</h4>
          <select
            value={formData.sellerAgentId}
            onChange={(e) => onInputChange('sellerAgentId', e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
          >
            <option value="">Select Seller Agent</option>
            {mockAgents.map((agent) => (
              <option key={agent.id} value={agent.id}>
                {agent.name} ({agent.id})
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Commission Configuration */}
      <div className="border-t pt-6">
        <h4 className="text-lg font-semibold text-gray-900 mb-4">Commission Configuration</h4>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-900 mb-2">
              Buyer Side Commission (%)
            </label>
            <input
              type="number"
              value={formData.buyerCommissionPercentage}
              onChange={(e) =>
                onInputChange('buyerCommissionPercentage', parseFloat(e.target.value))
              }
              min="0"
              max="10"
              step="0.5"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-900 mb-2">
              Seller Side Commission (%)
            </label>
            <input
              type="number"
              value={formData.sellerCommissionPercentage}
              onChange={(e) =>
                onInputChange('sellerCommissionPercentage', parseFloat(e.target.value))
              }
              min="0"
              max="10"
              step="0.5"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-800"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

/**
 * Step 4: Review & Confirm
 */
const StepReview: React.FC<{ formData: CreateDealFormData }> = ({ formData }) => {
  return (
    <div className="space-y-6">
      <div className="bg-gray-50 p-4 rounded-lg space-y-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-gray-600">Buyer</p>
            <p className="font-bold text-lg">{formData.buyerName}</p>
          </div>
          <div>
            <p className="text-gray-600">Seller</p>
            <p className="font-bold text-lg">{formData.sellerName}</p>
          </div>
          <div>
            <p className="text-gray-600">Property</p>
            <p className="font-bold">#{formData.propertyId}</p>
          </div>
          <div>
            <p className="text-gray-600">Buyer Agent</p>
            <p className="font-bold">#{formData.buyerAgentId}</p>
          </div>
          <div>
            <p className="text-gray-600">Seller Agent</p>
            <p className="font-bold">#{formData.sellerAgentId}</p>
          </div>
          <div>
            <p className="text-gray-600">Commission Split</p>
            <p className="font-bold">
              {formData.buyerCommissionPercentage}% / {formData.sellerCommissionPercentage}%
            </p>
          </div>
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900">
          ✓ All required information has been entered. Review the details above and click "Create Deal" to finalize.
        </p>
      </div>
    </div>
  );
};
