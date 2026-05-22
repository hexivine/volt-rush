// Test file for settings validation
// This file has intentional issues to test review preferences

import { readFileSync } from 'fs';

// Using var (should be flagged by custom instructions)
var globalCounter = 0;
var tempData: any = null;

// Long function (>20 lines - should be flagged by custom instructions)
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

// SQL injection vulnerability (security issue)
export function getUserById(id: string) {
  const query = `SELECT * FROM users WHERE id = '${id}'`;
  return query;
}

// Hardcoded secret (security issue)
const API_KEY = 'sk-proj-abc123def456ghi789';

export function callExternalApi(data: any) {
  return fetch('http://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${API_KEY}` },
    body: JSON.stringify(data),
  });
}

// Another function using var
export function calculateTotal(items: any[]) {
  var total = 0;
  for (var i = 0; i < items.length; i++) {
    total += items[i].price * items[i].quantity;
  }
  return total;
}
