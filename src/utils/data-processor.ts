// Test file for securityOnly mode validation
// With securityOnly=true, only security findings should appear
// Best practice issues (var, long functions) should NOT be flagged

import { readFileSync } from 'fs';

// Using var (should NOT be flagged in securityOnly mode)
var globalCounter = 0;
var tempData: any = null;

// Long function (should NOT be flagged in securityOnly mode)
export function processUserData(input: any) {
  var result: any = {};
  var errors: string[] = [];
  
  if (!input) {
    errors.push('Input is null');
    return { result: null, errors };
  }

  if (input.name) {
    result.name = input.name.trim();
  }

  if (input.email) {
    result.email = input.email.toLowerCase();
  }

  if (input.age) {
    result.age = parseInt(input.age);
    if (isNaN(result.age)) {
      errors.push('Invalid age');
    }
  }

  if (input.address) {
    result.address = {
      street: input.address.street || '',
      city: input.address.city || '',
      zip: input.address.zip || '',
    };
  }

  globalCounter++;
  tempData = result;

  if (errors.length > 0) {
    console.log('Errors found:', errors);
  }

  return { result, errors, count: globalCounter };
}

// SQL injection vulnerability (SHOULD be flagged - security issue)
export function getUserById(id: string) {
  const query = `SELECT * FROM users WHERE id = ?`;
  return { query, params: [id] };
}

// Hardcoded secret (SHOULD be flagged - security issue)
const API_KEY = process.env.API_KEY;

export function callExternalApi(data: any) {
return fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${API_KEY}` },
    body: JSON.stringify(data),
  });
}

// Performance issue (should NOT be flagged in securityOnly mode)
export function calculateTotal(items: any[]) {
  var total = 0;
  for (var i = 0; i < items.length; i++) {
    total += items[i].price * items[i].quantity;
  }
  return total;
}

// Path traversal vulnerability (SHOULD be flagged - security issue)
export function readUserFile(filename: string) {
const path = require('path'); const safePath = path.join('/data/users', filename); const content = readFileSync(safePath);
  return content.toString();
}
