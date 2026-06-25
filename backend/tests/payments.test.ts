import request from 'supertest';
import app from '../src/app';
import { pool, query } from '../src/config/db';
import { randomPhone, getAnyCategoryId } from './testUtils';

async function registerAndLogin(name: string) {
  const phone = randomPhone();
  const res = await request(app).post('/api/auth/register').send({ name, phone, password: 'secret123' });
  return { phone, token: res.body.accessToken as string };
}

function paymeAuthHeader(key: string): string {
  return `Basic ${Buffer.from(`Paycom:${key}`).toString('base64')}`;
}

describe('Payments', () => {
  afterAll(async () => {
    await pool.end();
  });

  it('POST /api/payments/payme CheckPerformTransaction returns correct JSON-RPC response', async () => {
    const seller = await registerAndLogin('Payme Seller');
    const categoryId = await getAnyCategoryId();

    const createRes = await request(app)
      .post('/api/listings')
      .set('Authorization', `Bearer ${seller.token}`)
      .send({
        title: 'Payme test mahsuloti',
        description: "To'lov testi uchun yaratilgan e'lon tavsifi",
        price: 190,
        currency: 'UZS',
        category_id: categoryId,
        location: 'Toshkent',
        contact_phone: seller.phone,
      });

    const orderId = createRes.body.order_id;
    expect(orderId).toBeDefined();

    const [order] = await query<{ amount: number }>('SELECT amount FROM ad_orders WHERE id = ?', [orderId]);

    const res = await request(app)
      .post('/api/payments/payme')
      .set('Authorization', paymeAuthHeader(process.env.PAYME_KEY || ''))
      .send({
        method: 'CheckPerformTransaction',
        params: { amount: Math.round(order.amount * 100), account: { order_id: orderId } },
        id: 1,
      });

    expect(res.status).toBe(200);
    expect(res.body.jsonrpc).toBe('2.0');
    expect(res.body.result).toEqual({ allow: true });
    expect(res.body.id).toBe(1);
  });

  it('POST /api/payments/payme with wrong Basic auth returns 401', async () => {
    const res = await request(app)
      .post('/api/payments/payme')
      .set('Authorization', paymeAuthHeader('definitely-the-wrong-key'))
      .send({
        method: 'CheckPerformTransaction',
        params: { amount: 100, account: { order_id: 1 } },
        id: 1,
      });

    expect(res.status).toBe(401);
  });

  it('POST /api/payments/click with wrong sign returns error code -1', async () => {
    const res = await request(app).post('/api/payments/click').send({
      click_trans_id: 123,
      service_id: 456,
      merchant_trans_id: 1,
      amount: 1000,
      action: 0,
      sign_time: '2024-01-01 00:00:00',
      sign_string: 'definitely-the-wrong-signature',
    });

    expect(res.status).toBe(200);
    expect(res.body.error).toBe(-1);
  });
});
