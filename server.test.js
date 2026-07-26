const request = require('supertest');
const app = require('./server');

describe('GET /health', () => {
  it('should return status healthy', async () => {
    const res = await request(app).get('/health');

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body).toHaveProperty('uptime');
    expect(res.body).toHaveProperty('timestamp');
  });
});

describe('GET /', () => {
  it('should return greeting', async () => {
    const res = await request(app).get('/');

    expect(res.statusCode).toBe(200);
    expect(res.text).toBe('Hello from DevOps Sandbox!');
  });
});
