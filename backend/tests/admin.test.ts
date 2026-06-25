import request from 'supertest';
import app from '../src/app';
import { pool } from '../src/config/db';
import { randomPhone } from './testUtils';

const ADMIN_PHONE = '+998901234567';
const ADMIN_PASSWORD = 'admin123';

describe('Admin', () => {
  afterAll(async () => {
    await pool.end();
  });

  it('GET /api/admin/metrics without token returns 401', async () => {
    const res = await request(app).get('/api/admin/metrics');
    expect(res.status).toBe(401);
  });

  it('GET /api/admin/metrics with buyer token returns 403', async () => {
    const phone = randomPhone();
    const registerRes = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Buyer', phone, password: 'secret123' });

    const res = await request(app)
      .get('/api/admin/metrics')
      .set('Authorization', `Bearer ${registerRes.body.accessToken}`);

    expect(res.status).toBe(403);
  });

  it('GET /api/admin/metrics with admin token returns 200', async () => {
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({ phone: ADMIN_PHONE, password: ADMIN_PASSWORD });
    expect(loginRes.status).toBe(200);

    const res = await request(app)
      .get('/api/admin/metrics')
      .set('Authorization', `Bearer ${loginRes.body.accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('totalUsers');
    expect(res.body).toHaveProperty('activeListings');
    expect(res.body).toHaveProperty('totalRevenue');
    expect(res.body).toHaveProperty('todayRevenue');
  });
});
