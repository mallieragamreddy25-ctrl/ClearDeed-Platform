import assert from 'node:assert/strict';
import { DealsService } from '../src/modules/deals/deals.service';

class InMemoryUserRepository {
  constructor(private readonly items: any[]) {}

  async findOne(options: { where: { id?: number } }) {
    return this.items.find((item) => item.id === options.where.id) ?? null;
  }
}

class InMemoryPropertyRepository {
  constructor(private readonly items: any[]) {}

  async findOne(options: { where: { id?: number } }) {
    return this.items.find((item) => item.id === options.where.id) ?? null;
  }

  async update(criteria: { id: number }, update: Record<string, unknown>) {
    const property = this.items.find((item) => item.id === criteria.id);
    if (property) {
      Object.assign(property, update);
    }
    return property;
  }
}

class InMemoryProjectRepository {
  constructor(private readonly items: any[]) {}

  async findOne(options: { where: { id?: number } }) {
    return this.items.find((item) => item.id === options.where.id) ?? null;
  }
}

class InMemoryReferralPartnerRepository {
  constructor(private readonly items: any[]) {}

  async findOne(options: { where: { id?: number } }) {
    return this.items.find((item) => item.id === options.where.id) ?? null;
  }
}

class InMemoryDealReferralRepository {
  private nextId = 1;

  constructor(
    private readonly items: any[],
    private readonly referralPartners: any[],
  ) {}

  create(payload: Record<string, unknown>) {
    return { ...payload };
  }

  async save(payload: any | any[]) {
    const entries = Array.isArray(payload) ? payload : [payload];
    const saved = entries.map((entry) => {
      const record = {
        id: entry.id ?? this.nextId++,
        ...entry,
        created_at: entry.created_at ?? new Date(),
      };
      this.items.push(record);
      return record;
    });

    return Array.isArray(payload) ? saved : saved[0];
  }
}

class InMemoryCommissionRepository {
  private nextId = 1;

  constructor(private readonly items: any[]) {}

  create(payload: Record<string, unknown>) {
    return { ...payload };
  }

  async save(payload: any | any[]) {
    const entries = Array.isArray(payload) ? payload : [payload];
    const saved = entries.map((entry) => {
      const record = {
        id: entry.id ?? this.nextId++,
        ...entry,
        created_at: entry.created_at ?? new Date(),
        updated_at: entry.updated_at ?? new Date(),
      };
      this.items.push(record);
      return record;
    });

    return Array.isArray(payload) ? saved : saved[0];
  }

  async find(options: { where?: { deal_id?: number }; relations?: string[] } = {}) {
    const filtered = this.items.filter((item) =>
      options.where?.deal_id ? item.deal_id === options.where.deal_id : true,
    );
    return filtered.map((item) => ({ ...item }));
  }
}

class InMemoryDealRepository {
  private nextId = 1;

  constructor(
    private readonly deals: any[],
    private readonly users: any[],
    private readonly properties: any[],
    private readonly projects: any[],
    private readonly referralMappings: any[],
    private readonly referralPartners: any[],
  ) {}

  create(payload: Record<string, unknown>) {
    return { ...payload };
  }

  async save(payload: any) {
    if (!payload.id) {
      payload.id = this.nextId++;
      payload.created_at = payload.created_at ?? new Date();
      payload.updated_at = payload.updated_at ?? new Date();
      this.deals.push({ ...payload });
    } else {
      const index = this.deals.findIndex((deal) => deal.id === payload.id);
      if (index >= 0) {
        this.deals[index] = {
          ...this.deals[index],
          ...payload,
          updated_at: new Date(),
        };
      } else {
        this.deals.push({ ...payload, updated_at: new Date() });
      }
    }

    return this.findOne({ where: { id: payload.id } });
  }

  async findOne(options: { where: Record<string, unknown>; relations?: string[] }) {
    const [key, value] = Object.entries(options.where)[0] ?? [];
    const raw = this.deals.find((deal) => deal[key] === value) ?? null;

    if (!raw) {
      return null;
    }

    const buyer_user = this.users.find((user) => user.id === raw.buyer_user_id);
    const seller_user = this.users.find((user) => user.id === raw.seller_user_id);
    const property = this.properties.find((item) => item.id === raw.property_id);
    const project = this.projects.find((item) => item.id === raw.project_id);
    const referral_mappings = this.referralMappings
      .filter((mapping) => mapping.deal_id === raw.id)
      .map((mapping) => ({
        ...mapping,
        referral_partner: this.referralPartners.find(
          (partner) => partner.id === mapping.referral_partner_id,
        ),
      }));

    return {
      ...raw,
      buyer_user,
      seller_user,
      property,
      project,
      referral_mappings,
    };
  }
}

async function main() {
  const users = [
    { id: 10, full_name: 'Buyer One', mobile_number: '9000000010' },
    { id: 20, full_name: 'Seller One', mobile_number: '9000000020' },
  ];
  const properties = [
    { id: 5, status: 'verified', title: 'Verified Plot' },
  ];
  const projects: any[] = [];
  const referralPartners = [
    {
      id: 101,
      full_name: 'Buyer Partner',
      status: 'approved',
      is_active: true,
      commission_enabled: true,
    },
    {
      id: 202,
      full_name: 'Seller Partner',
      status: 'approved',
      is_active: true,
      commission_enabled: true,
    },
  ];
  const deals: any[] = [];
  const referralMappings: any[] = [];
  const commissions: any[] = [];

  const service = new DealsService(
    new InMemoryDealRepository(
      deals,
      users,
      properties,
      projects,
      referralMappings,
      referralPartners,
    ) as any,
    new InMemoryCommissionRepository(commissions) as any,
    new InMemoryDealReferralRepository(referralMappings, referralPartners) as any,
    new InMemoryUserRepository(users) as any,
    new InMemoryPropertyRepository(properties) as any,
    new InMemoryProjectRepository(projects) as any,
    new InMemoryReferralPartnerRepository(referralPartners) as any,
  );

  const createdDeal = await service.createDeal(
    {
      buyer_user_id: 10,
      seller_user_id: 20,
      property_id: 5,
      transaction_value: 1_000_000,
      buyer_referral_partner_id: 101,
      seller_referral_partner_id: 202,
      buyer_commission_percentage: 2,
      seller_commission_percentage: 2,
    } as any,
    1,
  );

  assert.equal(createdDeal.referral_mappings.length, 2, 'expected two referral mappings');
  assert.deepEqual(
    createdDeal.referral_mappings.map((mapping: any) => mapping.side).sort(),
    ['buyer', 'seller'],
    'expected buyer and seller mappings',
  );

  const closedDeal = await service.closeDeal(createdDeal.id, {} as any);

  assert.equal(closedDeal.status, 'closed', 'deal should be closed');
  assert.equal(commissions.length, 5, 'expected buyer, seller, platform, and two referral commissions');

  const referralCommissionEntries = commissions.filter(
    (entry) => entry.commission_type === 'referral_fee',
  );
  assert.equal(referralCommissionEntries.length, 2, 'expected two referral fee entries');
  assert.deepEqual(
    referralCommissionEntries.map((entry) => entry.referral_partner_id).sort(),
    [101, 202],
    'expected buyer and seller referral partners to receive commission entries',
  );

  const summary = {
    createdDealId: createdDeal.id,
    mappingSides: createdDeal.referral_mappings.map((mapping: any) => mapping.side),
    commissionTypes: commissions.map((entry) => entry.commission_type),
    referralPartnerIds: referralCommissionEntries.map((entry) => entry.referral_partner_id),
  };

  console.log('Smoke test passed:', JSON.stringify(summary, null, 2));
}

main().catch((error) => {
  console.error('Smoke test failed:', error);
  process.exitCode = 1;
});
