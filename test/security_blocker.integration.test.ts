import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

describe('Security Blocker Integration', () => {
  const vulnerableDartFile = path.join(__dirname, 'test_security_blocker.dart');

  beforeAll(() => {
    // Create a mock vulnerable Dart file for testing
    const mockContent = `
// Test file: Security vulnerabilities for premerge check testing

import 'dart:convert';
import 'dart:io';

class SecurityTest {
  static const String apiKey = 'sk-abc123def456ghi789jkl012mno345pqr678';
  static const String dbPassword = 'super_secret_db_password_2024';

  Future<List> getUserData(String userId) async {
    final db = await _getDb();
    final result = await db.query("SELECT * FROM users WHERE id = '$userId'");
    return result;
  }

  Future<String> readFile(String filename) async {
    final file = File('/var/data/\$filename');
    return await file.readAsString();
  }

  String hashPassword(String password) {
    return password.hashCode.toString();
  }

  Future<dynamic> _getDb() async => {};
}
`;
    fs.writeFileSync(vulnerableDartFile, mockContent);
  });

  afterAll(() => {
    if (fs.existsSync(vulnerableDartFile)) {
      fs.unlinkSync(vulnerableDartFile);
    }
  });

  it('should fail premerge check when vulnerabilities are detected', () => {
    const result = execSync(`node scripts/security_checker.js --file ${vulnerableDartFile}`, {
      encoding: 'utf-8',
      expectNonZero: false,
    });
    expect(result).toContain('VULNERABILITIES_DETECTED');
  });

  it('should block merge when critical vulnerabilities exist', () => {
    try {
      execSync(`node scripts/security_checker.js --file ${vulnerableDartFile} --block-merge`, {
        encoding: 'utf-8',
      });
      fail('Expected command to fail due to security violations');
    } catch (error: any) {
      expect(error.status).toBe(1);
      expect(error.stdout).toContain('BLOCKED');
    }
  });

  it('should output detailed violation report', () => {
    const result = execSync(`node scripts/security_checker.js --file ${vulnerableDartFile} --verbose`, {
      encoding: 'utf-8',
    });
    expect(result).toMatch(/CRITICAL|SQL_INJECTION|HARDCODED_SECRET/);
  });
});