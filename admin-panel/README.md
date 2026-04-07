# ClearDeed Admin Panel

A comprehensive React 18+ admin dashboard for managing real estate operations including property verification, deal management, agent/commission tracking, and financial reporting.

## 📋 Features

### Phase 1 (MVP) - Complete ✓

1. **Dashboard**
   - KPI cards (Total Properties, Verified, Active Deals, Commissions)
   - Recent activities timeline
   - Quick action widgets with status indicators
   - Real-time metrics and trends

2. **Property Verification**
   - Pending properties management interface
   - Multi-field filtering (Category, City, Status)
   - Document upload and verification tracking
   - Batch approval/rejection workflow
   - Verification checklist with audit trail

3. **Deal Management**
   - Active deals overview with status tracking
   - Commission breakdown by deal
   - Deal closure and commission locking
   - Deal status filtering and search

4. **Agent Management**
   - Agent directory with activity status
   - Maintenance fee tracking and collection
   - Commission earnings display
   - Fee payment recording with reference tracking
   - Agent performance metrics

5. **Commission Ledger**
   - Complete transaction history
   - Filter by type, status, date range
   - Real-time totals (Pending, Approved, Paid)
   - Export capabilities (CSV, PDF)
   - Financial reconciliation reports

6. **Multi-Step Deal Creation**
   - Step 1: Select Buyer & Seller
   - Step 2: Select Property
   - Step 3: Assign Agents & Commission
   - Step 4: Review & Confirm
   - Form validation and error handling

## 🏗️ Project Structure

```
admin-panel/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── Modal.tsx
│   │   ├── Table.tsx
│   │   ├── Filters.tsx
│   │   ├── StatCard.tsx
│   │   ├── PageHeader.tsx
│   │   ├── Layout/
│   │   │   ├── Navbar.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── MainLayout.tsx
│   │   └── index.ts
│   ├── screens/             # Page components
│   │   ├── Dashboard.tsx
│   │   ├── PropertyVerification.tsx
│   │   ├── DealManagement.tsx
│   │   ├── AgentManagement.tsx
│   │   ├── CommissionLedger.tsx
│   │   ├── CreateDeal.tsx
│   │   └── index.ts
│   ├── services/            # API integration
│   │   └── api.ts
│   ├── hooks/               # Custom React hooks
│   │   └── useApi.ts
│   ├── types/               # TypeScript type definitions
│   │   └── index.ts
│   ├── utils/               # Utility functions and constants
│   │   └── constants.ts
│   ├── App.tsx              # Main app component with routing
│   ├── index.tsx            # Entry point
│   └── index.css            # Global styles
├── public/
├── index.html               # HTML template
├── package.json             # Dependencies and scripts
├── tsconfig.json            # TypeScript configuration
├── vite.config.ts           # Vite configuration
├── tailwind.config.js       # Tailwind CSS configuration
├── postcss.config.js        # PostCSS configuration
└── README.md                # This file
```

## 🎨 Design System

### Color Palette
- **Primary**: #003366 (Dark Blue) - Main actions and highlights
- **Accent**: #555555 (Grey) - Secondary text and borders
- **Background**: #F5F5F5 (Light Grey) - Page backgrounds
- **Success**: #4CAF50 - Positive actions and approved states
- **Error**: #F44336 - Destructive actions and error states
- **Warning**: #FFC107 - Caution and pending states

### Typography
- **Font Family**: System fonts (Segoe UI, Roboto, SF Pro Display)
- **Sizes**: sm (12px), base (14px), lg (16px), xl (20px), 2xl (24px), 3xl (32px)

### Components
All components support:
- Multiple size variants (sm, md, lg)
- Variant styles (primary, secondary, success, danger, warning, ghost)
- Responsive design with Tailwind CSS
- Accessibility features (ARIA labels, keyboard navigation)
- Loading states with spinners
- Disabled states

## 🚀 Getting Started

### Prerequisites
- Node.js 16+ 
- npm or yarn package manager

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linting
npm run lint

# Type checking
npm run type-check
```

### Environment Setup

Create a `.env.local` file in the root directory:

```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_API_TIMEOUT=30000
```

## 📡 API Integration

The admin panel connects to a backend API with the following endpoints:

### Dashboard
- `GET /api/dashboard/metrics` - Get KPI metrics
- `GET /api/dashboard/activities` - Get recent activities

### Properties
- `GET /api/properties` - List properties with pagination
- `GET /api/properties/:id` - Get property details
- `POST /api/properties/:id/verify` - Verify property
- `POST /api/properties/:id/reject` - Reject property

### Deals
- `GET /api/deals` - List deals
- `GET /api/deals/:id` - Get deal details
- `POST /api/deals` - Create new deal
- `POST /api/deals/:id/close` - Close deal and lock commissions
- `POST /api/deals/:id/cancel` - Cancel deal

### Agents
- `GET /api/agents` - List agents
- `GET /api/agents/:id` - Get agent details
- `POST /api/agents` - Register new agent
- `POST /api/agents/:id/maintenance-fee` - Record fee payment

### Commissions
- `GET /api/commissions` - List commissions
- `POST /api/commissions/:id/approve` - Approve commission
- `POST /api/commissions/:id/pay` - Mark commission as paid

### Reports
- `GET /api/reports/commission-ledger` - Get commission ledger
- `POST /api/reports/export` - Export report (CSV/PDF)

## 🔧 Configuration

### Tailwind CSS
Customizable through `tailwind.config.js`:
- Color palette
- Spacing scale
- Font families
- Custom utilities

### TypeScript
Strict type checking enabled in `tsconfig.json` for better code quality.

## 🎯 Development Patterns

### Creating New Components

```tsx
interface MyComponentProps {
  title: string;
  onClick?: () => void;
}

export const MyComponent: React.FC<MyComponentProps> = ({
  title,
  onClick,
}) => {
  return (
    <div className="bg-white p-4 rounded-lg border border-gray-200">
      <h3 className="text-lg font-semibold">{title}</h3>
      {onClick && <button onClick={onClick}>Action</button>}
    </div>
  );
};
```

### Using API Hooks

```tsx
const { data, loading, error, refetch } = useApi(
  () => propertyApi.getProperties(page, filters),
  { refetchInterval: 30000 }
);
```

### Managing Pagination

```tsx
const { page, pageSize, nextPage, prevPage, setSize } = usePagination(1, 10);
```

### Managing Filters

```tsx
const { filters, setFilter, updateFilters, clearFilters } = useFilters();
```

## 📦 Customization

### Adding New Screens

1. Create component in `src/screens/YourScreen.tsx`
2. Use standard layout with `PageHeader` and components
3. Export from `src/screens/index.ts`
4. Add route to `App.tsx`

### Styling Components

Use Tailwind CSS utility classes for styling:

```tsx
<div className="bg-white p-4 rounded-lg shadow-md border border-gray-200">
  <h3 className="text-lg font-semibold text-gray-900">Title</h3>
</div>
```

### Adding New API Endpoints

Update `src/services/api.ts`:

```tsx
export const newApi = {
  getEndpoint: () => apiClient.get('/endpoint'),
  postEndpoint: (data) => apiClient.post('/endpoint', data),
};
```

## 🧪 Testing

Currently no test framework is set up. To add tests:

```bash
npm install --save-dev vitest @testing-library/react
```

Then create `.test.tsx` files alongside components.

## 🔒 Security Considerations

1. **Authentication**: Token stored in localStorage, sent with all requests
2. **CSRF Protection**: Ensure backend implements CSRF tokens
3. **Input Validation**: Form validation on both client and server
4. **XSS Prevention**: React's built-in XSS protection
5. **Session Timeout**: 30-minute default (configurable in constants)

## 🚨 Error Handling

All API errors are handled gracefully:
- Network errors show user-friendly messages
- Invalid authentication redirects to login
- Form validation errors display inline
- Loading states prevent duplicate submissions

## 📱 Responsive Design

The dashboard is fully responsive:
- Desktop: Full layout with sidebar and navbar
- Tablet: Adjustable sidebar with responsive tables
- Mobile: Collapsible sidebar, optimized touch targets

## 🎓 Next Steps & Enhancement Ideas

### Phase 2 Features
- Advanced analytics and charting
- Batch operations for bulk actions
- Custom alert configuration
- Bulk property verification
- Commission dispute handling

### Phase 3 Features  
- ML-powered verification suggestions
- Fraud detection alerts
- Multi-language support
- Dark mode theme
- Mobile app integration
- WebSocket real-time updates

## 🤝 Contributing

When adding new features:
1. Follow existing code patterns and naming conventions
2. Use TypeScript for type safety
3. Document complex logic with JSDoc comments
4. Ensure responsive design across devices
5. Maintain consistent styling with Tailwind utilities

## 📝 License

Proprietary - ClearDeed Real Estate Platform

## 📞 Support

For issues or questions:
- Check existing documentation in README and comments
- Review wireframes in `ADMIN_WIREFRAMES.html`
- Consult API specification in `../docs/API_SPECIFICATION.yaml`

---

**Last Updated**: March 2026
**Version**: 1.0.0 (Phase 1 MVP)
