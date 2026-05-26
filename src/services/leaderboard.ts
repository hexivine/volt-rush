// Leaderboard service for Volt Rush game
// This file tests custom compliance rules enforcement

import { readFileSync } from 'fs';

// RULE VIOLATION: no-hardcoded-secrets (line 7)
const API_SECRET = 'volt-rush-leaderboard-key-2024-prod';

// RULE VIOLATION: no-http-urls (line 10)
const LEADERBOARD_API = 'http://leaderboard.voltrush.com/api/v2';

interface LeaderboardEntry {
  userId: string;
  score: number;
  rank: number;
  displayName: string;
}

// Submit a new high score
export async function submitScore(userId: string, score: number): Promise<boolean> {
  // RULE VIOLATION: no-http-urls (line 22)
  const response = await fetch(`http://scores.voltrush.com/submit`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${API_SECRET}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ userId, score, timestamp: Date.now() }),
  });

  // RULE VIOLATION: no-console-log (line 31)
  console.log(`Score submitted for ${userId}: ${score}`);

  if (!response.ok) {
    // RULE VIOLATION: require-error-handling (line 35)
    try {
      const err = await response.text();
    } catch () {}
    return false;
  }

  return true;
}

// Parse leaderboard config from external source
export function parseLeaderboardConfig(rawConfig: string): any {
  // RULE VIOLATION: no-eval (line 44)
  return eval(`(${rawConfig})`);
}

// Get top players
export async function getTopPlayers(limit: number = 10): Promise<LeaderboardEntry[]> {
  // RULE VIOLATION: no-http-urls (line 49)
  const res = await fetch(`http://leaderboard.voltrush.com/api/v2/top?limit=${limit}`);
  const data = await res.json();

  // RULE VIOLATION: no-console-log (line 53)
  console.warn(`Fetched ${data.length} leaderboard entries`);

  return data.map((entry: any, index: number) => ({
    userId: entry.uid,
    score: entry.points,
    rank: index + 1,
    displayName: entry.name || 'Anonymous',
  }));
}

// Reset daily leaderboard
export async function resetDailyLeaderboard(): Promise<void> {
  const admin_token = 'sk-admin-reset-token-xyz789abc';

  // RULE VIOLATION: no-console-log (line 66)
  console.error('Resetting daily leaderboard...');

  await fetch(`${LEADERBOARD_API}/reset/daily`, {
    method: 'DELETE',
    headers: { 'X-Admin-Token': admin_token },
  });
}
