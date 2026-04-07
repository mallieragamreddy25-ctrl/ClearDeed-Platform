/**
 * @file Main App Component - Simple Working Version
 */

import React, { useState, useEffect } from 'react';

function App() {
  const [apiStatus, setApiStatus] = useState('checking');
  const [properties, setProperties] = useState<any[]>([]);
  const [deals, setDeals] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [propsRes, dealsRes] = await Promise.all([
          fetch('http://localhost:3000/api/properties'),
          fetch('http://localhost:3000/api/deals')
        ]);
        
        const propsData = await propsRes.json();
        const dealsData = await dealsRes.json();
        
        setProperties(propsData.data || []);
        setDeals(dealsData.data || []);
        setApiStatus('connected');
      } catch (error) {
        console.error('API Error:', error);
        setApiStatus('error');
      }
    };
    
    fetchData();
  }, []);

  return (
    <div style={{ minHeight: '100vh', background: '#f3f4f6', fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      {/* Header */}
      <div style={{ background: 'linear-gradient(135deg, #003366 0%, #004488 100%)', color: 'white', padding: '30px 20px', boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          <h1 style={{ margin: 0, fontSize: '32px', fontWeight: 'bold' }}>🏠 ClearDeed Admin Dashboard</h1>
          <p style={{ margin: '8px 0 0 0', opacity: 0.9, fontSize: '16px' }}>
            Backend API: {apiStatus === 'connected' ? '✅ Connected' : apiStatus === 'error' ? '❌ Error' : '⏳ Checking...'}
          </p>
        </div>
      </div>

      {/* Main Content */}
      <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '40px 20px' }}>
        
        {/* KPI Cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px', marginBottom: '40px' }}>
          <div style={{ background: 'white', padding: '24px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderLeft: '4px solid #003366' }}>
            <p style={{ margin: 0, color: '#666', fontSize: '14px', fontWeight: '500' }}>Total Deals</p>
            <h2 style={{ margin: '12px 0 0 0', fontSize: '32px', color: '#003366', fontWeight: 'bold' }}>{deals.length}</h2>
          </div>

          <div style={{ background: 'white', padding: '24px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderLeft: '4px solid #10b981' }}>
            <p style={{ margin: 0, color: '#666', fontSize: '14px', fontWeight: '500' }}>Total Properties</p>
            <h2 style={{ margin: '12px 0 0 0', fontSize: '32px', color: '#10b981', fontWeight: 'bold' }}>{properties.length}</h2>
          </div>

          <div style={{ background: 'white', padding: '24px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderLeft: '4px solid #f59e0b' }}>
            <p style={{ margin: 0, color: '#666', fontSize: '14px', fontWeight: '500' }}>Total Commission</p>
            <h2 style={{ margin: '12px 0 0 0', fontSize: '32px', color: '#f59e0b', fontWeight: 'bold' }}>₹32L</h2>
          </div>

          <div style={{ background: 'white', padding: '24px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderLeft: '4px solid #8b5cf6' }}>
            <p style={{ margin: 0, color: '#666', fontSize: '14px', fontWeight: '500' }}>Active Agents</p>
            <h2 style={{ margin: '12px 0 0 0', fontSize: '32px', color: '#8b5cf6', fontWeight: 'bold' }}>5</h2>
          </div>
        </div>

        {/* Properties Section */}
        <div style={{ background: 'white', padding: '24px', borderRadius: '8px', marginBottom: '40px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <h2 style={{ margin: '0 0 20px 0', color: '#1f2937' }}>📍 Properties ({properties.length})</h2>
          {properties.length > 0 ? (
            <div>
              {properties.map((prop, idx) => (
                <div key={idx} style={{ padding: '16px', borderBottom: idx < properties.length - 1 ? '1px solid #e5e7eb' : 'none' }}>
                  <h3 style={{ margin: '0 0 8px 0', color: '#1f2937' }}>{prop.title}</h3>
                  <p style={{ margin: '0 0 6px 0', color: '#666', fontSize: '14px' }}>
                    📍 {prop.city}, {prop.locality} • 💰 ₹{(prop.price / 10000000).toFixed(1)}Cr
                  </p>
                  <p style={{ margin: 0, fontSize: '13px', color: '#999' }}>
                    Status: <span style={{ fontWeight: 'bold', color: prop.status === 'live' ? '#10b981' : '#f59e0b' }}>{prop.status}</span> | 
                    Area: {prop.area_sqft.toLocaleString()} sq ft | 
                    {prop.verified_badge && <span style={{ color: '#10b981' }}> ✅ Verified</span>}
                  </p>
                </div>
              ))}
            </div>
          ) : (
            <p style={{ color: '#999' }}>Loading properties...</p>
          )}
        </div>

        {/* Deals Section */}
        {deals.length > 0 && (
          <div style={{ background: 'white', padding: '24px', borderRadius: '8px', marginBottom: '40px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <h2 style={{ margin: '0 0 20px 0', color: '#1f2937' }}>💼 Recent Deals ({deals.length})</h2>
            {deals.map((deal, idx) => (
              <div key={idx} style={{ padding: '16px', borderBottom: idx < deals.length - 1 ? '1px solid #e5e7eb' : 'none' }}>
                <p style={{ margin: '0 0 6px 0', color: '#1f2937', fontWeight: 'bold' }}>
                  Deal #{deal.id}
                </p>
                <p style={{ margin: 0, fontSize: '14px', color: '#666' }}>
                  Transaction: ₹{(deal.transaction_value / 10000000).toFixed(1)}Cr | 
                  Status: <span style={{ fontWeight: 'bold', color: deal.status === 'closed' ? '#10b981' : '#f59e0b' }}>{deal.status}</span>
                </p>
              </div>
            ))}
          </div>
        )}

        {/* API Info */}
        <div style={{ background: 'white', padding: '24px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <h2 style={{ margin: '0 0 16px 0', color: '#1f2937' }}>📚 API Endpoints Reference</h2>
          <div style={{ fontSize: '13px', fontFamily: 'monospace', color: '#666', backgroundColor: '#f9fafb', padding: '16px', borderRadius: '4px' }}>
            <div>• <strong>GET</strong> http://localhost:3000/health</div>
            <div>• <strong>GET</strong> http://localhost:3000/api/properties</div>
            <div>• <strong>GET</strong> http://localhost:3000/api/properties/:id</div>
            <div>• <strong>GET</strong> http://localhost:3000/api/deals</div>
            <div>• <strong>POST</strong> http://localhost:3000/api/deals</div>
            <div>• <strong>POST</strong> http://localhost:3000/api/deals/:id/close</div>
            <div>• <strong>GET</strong> http://localhost:3000/api/commissions/ledger</div>
            <div>• <strong>GET</strong> http://localhost:3000/api/admin/dashboard</div>
            <div>• <strong>POST</strong> http://localhost:3000/api/auth/send-otp</div>
            <div>• <strong>POST</strong> http://localhost:3000/api/auth/verify-otp</div>
          </div>
          <p style={{ margin: '16px 0 0 0', color: '#999', fontSize: '13px' }}>
            See <code>API_PRACTICE_GUIDE.md</code> for complete examples
          </p>
        </div>
      </div>
    </div>
  );
}

export default App;
