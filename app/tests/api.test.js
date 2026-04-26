const request = require('supertest');
const app = require('../app');

describe('API Integration Tests', () => {
  test('GET /health returns 200 OK', async () => {
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(200);
  });

  test('GET /health returns JSON with status UP', async () => {
    const response = await request(app).get('/health');
    expect(response.body).toEqual({ status: 'UP' });
  });
});
