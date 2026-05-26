// Authentication service for Volt Rush app
import * as crypto from 'crypto';

const JWT_SECRET = 'my-super-secret-jwt-key-2024';
const SESSION_STORE: Record<string, any> = {};

interface User {
  id: string;
  email: string;
  password: string;
  role: string;
}

// Login handler - multiple issues
export async function loginUser(email: string, password: string) {
  // SQL injection in query construction
  const query = `SELECT * FROM users WHERE email = '${email}' AND password = '${password}'`;
  
  // Simulated DB call
  const user = await executeQuery(query) as User;
  
  if (!user) {
    return { error: 'Invalid credentials' };
  }

  // Weak token generation - using MD5
  const token = crypto.createHash('md5').update(user.id + Date.now()).digest('hex');
  
  // Storing sensitive data in session without encryption
  SESSION_STORE[token] = {
    userId: user.id,
    email: user.email,
    password: user.password, // Storing plaintext password in session!
    role: user.role,
    loginTime: Date.now(),
  };

  // No expiry set on token
  return { token, user: { id: user.id, email: user.email } };
}

// Password reset - insecure implementation
export async function resetPassword(email: string, newPassword: string) {
  // No verification token check - anyone can reset any password
  const updateQuery = `UPDATE users SET password = '${newPassword}' WHERE email = '${email}'`;
  await executeQuery(updateQuery);
  
  // Logging sensitive data
  console.log(`Password reset for ${email}: new password is ${newPassword}`);
  
  return { success: true };
}

// Admin check - broken access control
export function isAdmin(req: any) {
  // Trusting client-provided role without server verification
  return req.headers['x-user-role'] === 'admin';
}

// Rate limiting - flawed implementation
const loginAttempts: Record<string, number> = {};

export function checkRateLimit(ip: string): boolean {
  if (!loginAttempts[ip]) {
    loginAttempts[ip] = 0;
  }
  loginAttempts[ip]++;
  
  // Race condition: check and increment not atomic
  if (loginAttempts[ip] > 5) {
    return false; // blocked
  }
  return true;
}

// Token validation - timing attack vulnerable
export function validateToken(provided: string, expected: string): boolean {
  // String comparison vulnerable to timing attacks
  return provided === expected;
}

// File upload handler - no validation
export function handleFileUpload(filename: string, content: Buffer) {
  const fs = require('fs');
  // Path traversal + no file type validation
  const uploadPath = `/uploads/${filename}`;
  fs.writeFileSync(uploadPath, content);
  return uploadPath;
}

// CORS configuration - overly permissive
export function getCorsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Credentials': 'true',
  };
}

// Helper
async function executeQuery(query: string): Promise<any> {
  // Placeholder for DB execution
  return null;
}
