import request from 'supertest';
import app from '../src/app';
import { pool } from '../src/config/db';
import { randomPhone } from './testUtils';

describe('Auth', () => {
  afterAll(async () => {
    await pool.end();
  });

  it('POST /api/auth/register returns 201 with tokens', async () => {
    const phone = randomPhone();
    const res = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Test User', phone, password: 'secret123' });

    expect(res.status).toBe(201);
    expect(res.body.user).toBeDefined();
    expect(res.body.user.password_hash).toBeUndefined();
    expect(res.body.user.phone).toBe(phone);
    expect(typeof res.body.accessToken).toBe('string');
    expect(typeof res.body.refreshToken).toBe('string');
  });

  it('POST /api/auth/register with duplicate phone returns 409', async () => {
    const phone = randomPhone();
    await request(app).post('/api/auth/register').send({ name: 'First', phone, password: 'secret123' });

    const res = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Second', phone, password: 'other123' });

    expect(res.status).toBe(409);
  });

  it('POST /api/auth/login with wrong password returns 401', async () => {
    const phone = randomPhone();
    await request(app).post('/api/auth/register').send({ name: 'Login Test', phone, password: 'correctpass' });

    const res = await request(app).post('/api/auth/login').send({ phone, password: 'wrongpass' });

    expect(res.status).toBe(401);
  });

  it('GET /api/auth/me without token returns 401', async () => {
    const res = await request(app).get('/api/auth/me');
    expect(res.status).toBe(401);
  });

  it('GET /api/auth/me with valid token returns 200 with user', async () => {
    const phone = randomPhone();
    const registerRes = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Me Test', phone, password: 'secret123' });

    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${registerRes.body.accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.user.phone).toBe(phone);
    expect(res.body.user.password_hash).toBeUndefined();
  });
});
