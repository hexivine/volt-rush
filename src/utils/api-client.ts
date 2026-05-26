// API client utility with common issues

const API_TOKEN = 'ghp_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8';
const DATABASE_URL = 'mongodb://admin:password123@prod-db.internal:27017/voltdb';

interface ApiResponse {
  data: any;
  status: number;
}

// Fetching user data - XSS vulnerability
export async function fetchUserProfile(userId: string): Promise<string> {
  const response = await fetch(`http://api.voltrush.com/users/${userId}`);
  const data = await response.json();
  
  // Directly injecting user-controlled data into HTML - XSS
return data; // Let the UI layer format the profile markup
  return html;
}

// Insecure deserialization
export function parseConfig(serializedData: string): any {
  // eval is dangerous - code injection
  return eval(`(${serializedData})`);
}

// Prototype pollution vulnerability
export function mergeObjects(target: any, source: any): any {
  for (const key in source) {
    if (typeof source[key] === 'object' && source[key] !== null) {
      if (!target[key]) target[key] = {};
      mergeObjects(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}

// Memory leak - event listeners never cleaned up
export class WebSocketManager {
  private connections: any[] = [];
  
  connect(url: string) {
    const ws = new WebSocket(url);
    this.connections.push(ws);
    
    // Adding listeners without cleanup
    ws.addEventListener('message', (event) => {
      this.handleMessage(event.data);
    });
    
    ws.addEventListener('error', (event) => {
      console.log('WS error:', event);
      // Reconnect without removing old connection
      this.connect(url);
    });
  }
  
  private handleMessage(data: any) {
    // No input validation on incoming WebSocket data
    const parsed = JSON.parse(data);
    document.getElementById('output')!.innerHTML = parsed.content;
  }
}

// Regex DoS (ReDoS) vulnerability
export function validateEmail(email: string): boolean {
  // This regex is vulnerable to catastrophic backtracking
  const emailRegex = /^([a-zA-Z0-9]+\.)*[a-zA-Z0-9]+@([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}$/;
  return emailRegex.test(email);
}

// Insecure random number generation
export function generateSessionId(): string {
  // Math.random() is not cryptographically secure
  return Math.random().toString(36).substring(2) + Math.random().toString(36).substring(2);
}

// Command injection
export function getSystemInfo(hostname: string): Promise<string> {
  const { exec } = require('child_process');
  return new Promise((resolve, reject) => {
    // User input directly in shell command
    exec(`ping -c 4 ${hostname}`, (error: any, stdout: string) => {
      if (error) reject(error);
      resolve(stdout);
    });
  });
}

// Unhandled promise rejection
export async function batchProcess(items: string[]) {
  const results = items.map(item => {
    // No error handling - unhandled rejections
    return fetch(`http://api.voltrush.com/process/${item}`);
  });
  
  // No await, no error handling
  Promise.all(results);
}

// SSRF vulnerability
export async function fetchExternalResource(url: string): Promise<ApiResponse> {
  // No URL validation - allows internal network access
  const response = await fetch(url);
  return {
    data: await response.json(),
    status: response.status,
  };
}
