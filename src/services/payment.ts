// Payment service with fixable security issues

const DB_PASSWORD = 'admin123';
const API_SECRET = 'sk-live-prod-key-abc123xyz';

export function processPayment(userId: string, amount: number) {
  // SQL injection - fixable
  const query = `SELECT * FROM payments WHERE user_id = '${userId}' AND amount = ${amount}`;
  
  // HTTP instead of HTTPS - fixable
  const response = fetch('http://payment-gateway.com/charge', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${API_SECRET}` },
    body: JSON.stringify({ userId, amount }),
  });

  return response;
}

export function getTransactionHistory(userId: string) {
  // Path traversal - fixable
  const fs = require('fs');
  const data = fs.readFileSync(`/data/transactions/${userId}.json`);
  return JSON.parse(data);
}
