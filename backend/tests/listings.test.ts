import request from 'supertest';
import app from '../src/app';
import { pool, execute } from '../src/config/db';
import { randomPhone, getAnyCategoryId } from './testUtils';

async function registerAndLogin(name: string) {
  const phone = randomPhone();
  const res = await request(app).post('/api/auth/register').send({ name, phone, password: 'secret123' });
  return { phone, token: res.body.accessToken as string, userId: res.body.user.id as number };
}

describe('Listings', () => {
  afterAll(async () => {
    await pool.end();
  });

  it('GET /api/listings returns 200 with array', async () => {
    const res = await request(app).get('/api/listings');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('GET /api/listings?q=traktor returns filtered results', async () => {
    const seller = await registerAndLogin('Traktor Seller');
    const categoryId = await getAnyCategoryId();

    // Insert directly as 'active' so it's visible in the public feed without
    // going through the payment flow.
    await execute(
      `INSERT INTO listings
        (user_id, category_id, title, description, price, currency, location, contact_phone,
         status, source, published_at, expires_at)
       VALUES (?, ?, 'John Deere traktori sotiladi', 'Ishlatilgan traktor, yaxshi holatda', 15000, 'USD',
         'Samarqand', ?, 'active', 'posting_fee', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))`,
      [seller.userId, categoryId, seller.phone]
    );

    const res = await request(app).get('/api/listings').query({ q: 'traktor' });

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(
      res.body.data.every((listing: { title: string }) => listing.title.toLowerCase().includes('traktor'))
    ).toBe(true);
  });

  it('POST /api/listings without auth returns 401', async () => {
    const res = await request(app).post('/api/listings').send({ title: 'Sarlavha' });
    expect(res.status).toBe(401);
  });

  it('POST /api/listings with auth returns 201', async () => {
    const seller = await registerAndLogin('Listing Creator');
    const categoryId = await getAnyCategoryId();

    const res = await request(app)
      .post('/api/listings')
      .set('Authorization', `Bearer ${seller.token}`)
      .send({
        title: 'Test mahsulot',
        description: "Test uchun yaratilgan e'lon tavsifi",
        price: 100,
        currency: 'USD',
        category_id: categoryId,
        location: 'Toshkent',
        contact_phone: seller.phone,
      });

    expect(res.status).toBe(201);
    expect(res.body.listing).toBeDefined();
    expect(res.body.listing.status).toBe('pending_payment');
  });

  it('PUT /api/listings/:id by non-owner returns 403', async () => {
    const owner = await registerAndLogin('Owner');
    const other = await registerAndLogin('Other');
    const categoryId = await getAnyCategoryId();

    const createRes = await request(app)
      .post('/api/listings')
      .set('Authorization', `Bearer ${owner.token}`)
      .send({
        title: 'Owner mahsuloti',
        description: 'Tegishlilikni tekshirish uchun yaratilgan elon',
        price: 50,
        currency: 'USD',
        category_id: categoryId,
        location: 'Toshkent',
        contact_phone: owner.phone,
      });

    const res = await request(app)
      .put(`/api/listings/${createRes.body.listing.id}`)
      .set('Authorization', `Bearer ${other.token}`)
      .send({ title: 'Hacked title' });

    expect(res.status).toBe(403);
  });

  it('DELETE /api/listings/:id by owner returns 200', async () => {
    const owner = await registerAndLogin('Deleter');
    const categoryId = await getAnyCategoryId();

    const createRes = await request(app)
      .post('/api/listings')
      .set('Authorization', `Bearer ${owner.token}`)
      .send({
        title: "O'chiriladigan e'lon",
        description: "O'chirish testi uchun yaratilgan e'lon tavsifi",
        price: 75,
        currency: 'USD',
        category_id: categoryId,
        location: 'Toshkent',
        contact_phone: owner.phone,
      });

    const res = await request(app)
      .delete(`/api/listings/${createRes.body.listing.id}`)
      .set('Authorization', `Bearer ${owner.token}`);

    expect(res.status).toBe(200);
  });
});
