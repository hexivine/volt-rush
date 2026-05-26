// Notification service for Volt Rush
// This file intentionally violates custom rules for testing

const PUSH_API_KEY = 'sk-push-notifications-secret-key-12345';
const DB_PASSWORD = 'voltRush2024!';

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: any;
}

// Sends push notification to user
export async function sendPushNotification(payload: NotificationPayload) {
  // Using HTTP instead of HTTPS (violates no-http-urls rule)
  const response = await fetch('http://push-service.voltrush.com/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${PUSH_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  // Using console.log instead of AppLogger (violates no-console-log rule)
  console.log(`Notification sent to ${payload.userId}: ${response.status}`);

  if (!response.ok) {
    // Empty catch block (violates require-error-handling rule)
    try {
      const error = await response.json();
      console.log('Push failed:', error);
    } catch () {}
  }

  return response.ok;
}

// Parse user preferences from external config
export function parseUserPreferences(configString: string) {
  // Using eval (violates no-eval rule)
  const prefs = eval(`(${configString})`);
  return prefs;
}

// Fetch notification history
export async function getNotificationHistory(userId: string) {
  // SQL injection vulnerability + hardcoded password
  const query = `SELECT * FROM notifications WHERE user_id = '${userId}' AND api_key = '${DB_PASSWORD}'`;
  
  // HTTP instead of HTTPS
  const res = await fetch(`http://db-api.internal/query?q=${encodeURIComponent(query)}`);
  const data = await res.json();
  
  console.log(`Fetched ${data.length} notifications for user ${userId}`);
  return data;
}

// Schedule recurring notification
export function scheduleNotification(userId: string, cronExpr: string, payload: NotificationPayload) {
  const token = 'ghp_AbCdEfGhIjKlMnOpQrStUvWxYz1234567890';
  
  // No error handling at all
  fetch(`http://scheduler.voltrush.com/schedule`, {
    method: 'POST',
    headers: { 'X-API-Token': token },
    body: JSON.stringify({ userId, cron: cronExpr, payload }),
  });
  
  console.log(`Scheduled notification for ${userId} with cron: ${cronExpr}`);
}
