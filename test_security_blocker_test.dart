import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:test_security_blocker/test_security_blocker.dart';

void main() {
  late SecurityTest securityTest;

  setUp(() {
    securityTest = SecurityTest();
  });

  group('SecurityTest', () {
    group('API Keys and Secrets', () {
      test('should expose hardcoded apiKey constant', () {
        expect(
          SecurityTest.apiKey,
          equals('sk-abc123def456ghi789jkl012mno345pqr678'),
        );
      });

      test('should expose hardcoded dbPassword constant', () {
        expect(
          SecurityTest.dbPassword,
          equals('super_secret_db_password_2024'),
        );
      });

      test('should expose hardcoded awsSecretKey constant', () {
        expect(
          SecurityTest.awsSecretKey,
          equals('wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'),
        );
      });

      test('should expose hardcoded jwtSecret constant', () {
        expect(
          SecurityTest.jwtSecret,
          equals('my-super-secret-jwt-key-that-nobody-should-know'),
        );
      });
    });

    group('getUserData - SQL Injection Vulnerability', () {
      test('should accept userId parameter', () async {
        // Note: This method contains SQL injection vulnerability
        // Direct string interpolation in SQL query
        final result = await securityTest.getUserData('123');
        expect(result, isA<List>());
      });

      test('should allow malicious SQL injection input', () async {
        // Simulating SQL injection attack vector
        const maliciousInput = "1' OR '1'='1";
        final result = await securityTest.getUserData(maliciousInput);
        expect(result, isA<List>());
        // The vulnerability exists - query uses unsanitized input directly
      });
    });

    group('pingHost - Command Injection Vulnerability', () {
      test('should execute ping command with host parameter', () async {
        // Note: This method contains command injection vulnerability
        // Unsanitized input passed to shell command
        final result = await securityTest.pingHost('localhost');
        expect(result, isA<String>());
      });

      test('should allow shell metacharacters in host', () async {
        // Simulating potential command injection via shell metacharacters
        const maliciousHost = 'localhost; rm -rf /';
        final result = await securityTest.pingHost(maliciousHost);
        expect(result, isA<String>());
        // The vulnerability exists - no sanitization of input
      });
    });

    group('parseUserData - Insecure Deserialization', () {
      test('should parse valid JSON input without validation', () {
        // Note: This method contains insecure deserialization vulnerability
        // No validation before parsing
        const validJson = '{"name": "test", "value": 123}';
        final result = securityTest.parseUserData(validJson);
        expect(result, isA<Map>());
        expect(result['name'], equals('test'));
        expect(result['value'], equals(123));
      });

      test('should parse nested JSON objects', () {
        const nestedJson = '{"user": {"id": 1, "data": {"key": "value"}}}';
        final result = securityTest.parseUserData(nestedJson);
        expect(result['user']['id'], equals(1));
      });

      test('should parse JSON arrays', () {
        const jsonArray = '[1, 2, 3, 4, 5]';
        final result = securityTest.parseUserData(jsonArray);
        expect(result, isA<List>());
        expect(result.length, equals(5));
      });
    });

    group('readFile - Path Traversal Vulnerability', () {
      test('should construct file path from filename parameter', () async {
        // Note: This method contains path traversal vulnerability
        // No sanitization of filename
        // This test verifies the method exists and accepts parameters
        try {
          final result = await securityTest.readFile('data.txt');
          // If file exists, result is returned
          expect(result, isA<String>());
        } on FileSystemException {
          // Expected if file doesn't exist in test environment
          expect(true, isTrue);
        }
      });

      test('should allow path traversal sequences', () async {
        // Simulating path traversal attack vector
        try {
          await securityTest.readFile('../../../etc/passwd');
        } on FileSystemException {
          // Expected behavior in test environment
          expect(true, isTrue);
        }
        // The vulnerability exists - no path sanitization
      });

      test('should allow absolute path input', () async {
        try {
          await securityTest.readFile('/etc/passwd');
        } on FileSystemException {
          expect(true, isTrue);
        }
      });
    });

    group('hashPassword - Weak Cryptography', () {
      test('should return hashed password as string', () {
        // Note: This method uses weak cryptography (MD5-like hashCode)
        final result = securityTest.hashPassword('testPassword123');
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should return consistent hash for same input', () {
        const password = 'consistentPassword';
        final hash1 = securityTest.hashPassword(password);
        final hash2 = securityTest.hashPassword(password);
        expect(hash1, equals(hash2));
      });

      test('should return different hashes for different passwords', () {
        final hash1 = securityTest.hashPassword('password1');
        final hash2 = securityTest.hashPassword('password2');
        expect(hash1, isNot(equals(hash2)));
      });

      test('should be vulnerable to hash collision via hashCode', () {
        // hashCode is not cryptographically secure
        final result = securityTest.hashPassword('anyPassword');
        // This exposes the weak cryptography vulnerability
        expect(result.length, greaterThan(0));
      });
    });

    group('fetchData - Insecure HTTP Connection', () {
      test('should return HttpClientRequest', () async {
        // Note: This method uses insecure HTTP instead of HTTPS
        final result = await securityTest.fetchData('test');
        expect(result, isA<HttpClientRequest>());
      });

      test('should construct http URL (not https)', () async {
        // This exposes the insecure HTTP vulnerability
        final result = await securityTest.fetchData('api/data');
        expect(result.uri.scheme, equals('http'));
        expect(result.uri.host, equals('api.example.com'));
      });
    });

    group('logUserData - Logging Sensitive Data', () {
      test('should log user data including password', () {
        // Note: This method logs sensitive data (passwords, tokens)
        final userData = <String, dynamic>{
          'username': 'testuser',
          'password': 'secretPassword',
          'auth_token': 'jwt-token-12345',
        };

        // Method should not throw - it logs everything
        expect(
          () => securityTest.logUserData(userData),
          returnsNormally,
        );
      });

      test('should accept map with password field', () {
        final userData = <String, dynamic>{
          'password': 'superSecret',
        };
        expect(
          () => securityTest.logUserData(userData),
          returnsNormally,
        );
      });

      test('should accept map with auth_token field', () {
        final userData = <String, dynamic>{
          'auth_token': 'bearer-token-xyz',
        };
        expect(
          () => securityTest.logUserData(userData),
          returnsNormally,
        );
      });
    });

    group('deleteAccount - Missing Authentication Check', () {
      test('should accept userId parameter without auth verification', () async {
        // Note: This method lacks authentication check before deletion
        // No auth check before deletion - security vulnerability
        await expectLater(
          securityTest.deleteAccount('user-123'),
          completes,
        );
      });

      test('should allow deletion of arbitrary users without auth', () async {
        // Exposes the missing authentication vulnerability
        await securityTest.deleteAccount('any-user-id');
        // No authentication check prevents this vulnerable operation
      });
    });

    group('Integration Tests for Vulnerability Detection', () {
      test('should have all documented vulnerabilities present', () async {
        // This test documents all expected vulnerabilities
        // SQL Injection: getUserData uses string interpolation
        final sqlResult = await securityTest.getUserData("1' OR '1'='1");
        expect(sqlResult, isA<List>());

        // Command Injection: pingHost accepts unsanitized input
        final cmdResult = await securityTest.pingHost('localhost; ls');
        expect(cmdResult, isA<String>());

        // Insecure Deserialization: parseUserData has no validation
        final deserResult = securityTest.parseUserData('{"test": true}');
        expect(deserResult, isA<Map>());

        // Path Traversal: readFile has no path sanitization
        try {
          await securityTest.readFile('../etc/passwd');
        } catch (_) {}

        // Weak Cryptography: hashPassword uses hashCode
        final hash = securityTest.hashPassword('password');
        expect(hash, isA<String>());

        // Insecure HTTP: fetchData uses http://
        final httpResult = await securityTest.fetchData('data');
        expect(httpResult.uri.scheme, equals('http'));

        // Logging Sensitive Data
        securityTest.logUserData({'password': 'secret', 'auth_token': 'token'});

        // Missing Authentication
        await securityTest.deleteAccount('any-user');
      });
    });
  });
}
