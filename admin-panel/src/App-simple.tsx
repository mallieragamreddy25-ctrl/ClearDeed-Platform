/**
 * @file Simplified App Component - Testing Version
 */

import React, { useState, useEffect } from 'react';

function App() {
  const [apiStatus, setApiStatus] = useState('checking');
  const [properties, setProperties] = useState([]);

  useEffect(() => {
    // Check API
    fetch('http://localhost:3000/api/properties')
      .then(r => r.json())
      .then(data => {
        setApiStatus('connected');
        setProperties(data.data || []);
      })
      .catch(() => setApiStatus('error'));
  }, []);

  return (
    <div style={{ minHeight: '100vh', background: '#f3f4f6' }}>
      {/* Header */}
      <div style={{ background: '#003366', color: 'white', padding: '20px' }}>
        <h1 style={{ margin: 0 }}>🏠 ClearDeed Admin Dashboard</h1>
        <p style={{ margin: '5px 0 0 0', opacity: 0.9 }}>
          API Status: {apiStatus === 'connected' ? '✅ Connected' : apiStatus === 'error' ? '❌ Error' : '⏳ Checking...'}
        </p>
      </div>

      {/* Main Content */}
      <div style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto' }}>
        
        {/* KPI Cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px', marginBottom: '40px' }}>
          <Card title="Total Deals" value="1" />
          <Card title="Pending Verification" value="1" />
          <Card title="Total Commission" value="₹32L" />
          <Card title="Active Agents" value="5" />
        </div>

        {/* Properties List */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '8px', marginBottom: '40px' }}>
          <h2>Properties</h2>
          {properties.length > 0 ? (
            <div>
              {properties.map((prop, idx) => (
                <div key={idx} style={{ padding: '15px', borderBottom: '1px solid #e5e7eb' }}>
                  <h3 style={{ margin: '0 0 5px 0' }}>{prop.title}</h3>
                  <p style={{ margin: '0 0 5px 0', color: '#666' }}>
                    {prop.city}, {prop.locality} • ₹{(prop.price / 10000000).toFixed(1)}Cr
                  </p>
                  <p style={{ margin: 0, fontSize: '14px', color: '#999' }}>
                    Status: <strong>{prop.status}</strong> | Area: {prop.area_sqft.toLocaleString()} sq ft
                  </p>
                </div>
              ))}
            </div>
          ) : (
            <p>Loading properties...</p>
          )}
        </div>

        {/* API Endpoints */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '8px' }}>
          <h2>📚 Available API Endpoints</h2>
          <div style={{ fontSize: '14px', fontFamily: 'monospace', color: '#666' }}>
            <p>• GET  http://localhost:3000/health</p>
            <p>• GET  http://localhost:3000/api/properties</p>
            <p>• GET  http://localhost:3000/api/deals</p>
            <p>• GET  http://localhost:3000/api/admin/dashboard</p>
            <p>• POST http://localhost:3000/api/auth/send-otp</p>
          </div>
        </div>
      </div>
    </div>
  );
}

function Card({ title, value }) {
  return (
    <div style={{
      background: 'white',
      padding: '20px',
      borderRadius: '8px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      border: '1px solid #e5e7eb'
    }}>
      <p style={{ margin: 0, color: '#666', fontSize: '14px' }}>{title}</p>
      <h3 style={{ margin: '10px 0 0 0', fontSize: '28px', color: '#003366' }}>{value}</h3>
    </div>
  );
}

export default App;
