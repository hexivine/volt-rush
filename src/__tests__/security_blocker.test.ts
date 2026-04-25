import { analyzeSecurityVulnerabilities, SecurityViolation } from '../security_blocker';

describe('Security Blocker', () => {
  describe('analyzeSecurityVulnerabilities', () => {
    it('should detect hardcoded API keys', () => {
      const code = `
        static const String apiKey = 'sk-abc123def456ghi789jkl012mno345pqr678';
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'HARDCODED_SECRET',
          severity: 'HIGH',
          line: expect.any(Number),
        })
      );
    });

    it('should detect SQL injection vulnerabilities', () => {
      const code = `
        final result = await db.query("SELECT * FROM users WHERE id = '$userId'");
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'SQL_INJECTION',
          severity: 'CRITICAL',
        })
      );
    });

    it('should detect command injection vulnerabilities', () => {
      const code = `
        final result = await Process.run('ping', ['-c', '3', host]);
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'COMMAND_INJECTION',
          severity: 'CRITICAL',
        })
      );
    });

    it('should detect path traversal vulnerabilities', () => {
      const code = `
        final file = File('/var/data/$filename');
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'PATH_TRAVERSAL',
          severity: 'HIGH',
        })
      );
    });

    it('should detect weak cryptography (MD5 hashing)', () => {
      const code = `
        return password.hashCode.toString();
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'WEAK_CRYPTOGRAPHY',
          severity: 'HIGH',
        })
      );
    });

    it('should detect insecure HTTP connections', () => {
      const code = `
        return await client.getUrl(Uri.parse('http://api.example.com/$url'));
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'INSECURE_HTTP',
          severity: 'MEDIUM',
        })
      );
    });

    it('should detect logging of sensitive data', () => {
      const code = `
        print('Password: ${user['password']}');
        print('Token: ${user['auth_token']}');
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'SENSITIVE_DATA_LOGGING',
          severity: 'HIGH',
        })
      );
    });

    it('should detect missing authentication checks', () => {
      const code = `
        Future<void> deleteAccount(String userId) async {
          final db = await _getDb();
          await db.execute("DELETE FROM users WHERE id = '$userId'");
        }
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'MISSING_AUTH_CHECK',
          severity: 'CRITICAL',
        })
      );
    });

    it('should detect insecure deserialization', () => {
      const code = `
        return json.decode(input);
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toContainEqual(
        expect.objectContaining({
          type: 'INSECURE_DESERIALIZATION',
          severity: 'HIGH',
        })
      );
    });

    it('should return empty array for clean code', () => {
      const code = `
        String sanitize(String input) {
          return input.replaceAll(RegExp(r'[^\w]'), '');
        }
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations).toHaveLength(0);
    });

    it('should detect multiple vulnerabilities in same file', () => {
      const code = `
        static const String apiKey = 'sk-secret-key';
        final result = await db.query("SELECT * FROM users WHERE id = '$userId'");
        final file = File('/var/data/$filename');
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      expect(violations.length).toBeGreaterThanOrEqual(3);
    });

    it('should prioritize CRITICAL severity violations', () => {
      const code = `
        await db.execute("DELETE FROM users WHERE id = '$userId'");
        static const String apiKey = 'sk-secret';
      `;
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(code);
      const sortedViolations = [...violations].sort((a, b) => {
        const severityOrder = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };
        return severityOrder[a.severity] - severityOrder[b.severity];
      });
      expect(sortedViolations[0].severity).toBe('CRITICAL');
    });

    it('should handle empty input gracefully', () => {
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities('');
      expect(violations).toEqual([]);
    });

    it('should handle null input gracefully', () => {
      const violations: SecurityViolation[] = analyzeSecurityVulnerabilities(null as any);
      expect(violations).toEqual([]);
    });
  });
});