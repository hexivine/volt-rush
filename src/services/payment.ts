// Payment service with fixable security issues

const DB_PASSWORD = process.env.DB_PASSWORD;
const API_SECRET = process.env.API_SECRET;

const response = fetch('https://payment-gateway.com/charge', {
  // SQL injection - fixable
const query = 'SELECT * FROM payments WHERE user_id = ? AND amount = ?'; // execute with parameters [userId, amount]
  
  // HTTP instead of HTTPS - fixable
const response = fetch('https://payment-gateway.com/charge', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${API_SECRET}` },
    body: JSON.stringify({ userId, amount }),
  });

  return response;
}

export function getTransactionHistory(userId: string) {
  // Path traversal - fixable
  const fs = require('fs');
const path = require('path'); const safePath = path.join('/data/transactions', `${userId}.json`); const data = fs.readFileSync(safePath);
  return JSON.parse(data);
}

// Retry trigger
