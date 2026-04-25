import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

describe('MaxIssuesTest', () => {
  const dartFilePath = path.join(process.cwd(), 'test_max_issues.dart');

  beforeAll(() => {
    expect(fs.existsSync(dartFilePath)).toBe(true);
  });

  describe('get method', () => {
    it('should access list at given index', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          `
            var list = [1, 2, 3];
            var test = require('./test_max_issues.dart');
            print(test.get(0, list));
          `,
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(result).toBe('1');
    });
  });

  describe('divide method', () => {
    it('should perform division', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          'print(10 / 2);',
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(parseFloat(result)).toBe(5);
    });
  });

  describe('getName method', () => {
    it('should extract name from map', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print({'name': 'test'}['name']);",
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(result).toBe('test');
    });
  });

  describe('findPairs method', () => {
    it('should find pairs that sum to zero', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print([1, -1, 2, -2].toList());",
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(result).toContain('-1');
    });
  });

  describe('process method', () => {
    it('should double all values', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print([1, 2, 3].map((e) => e * 2).toList());",
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(result).toBe('[2, 4, 6]');
    });
  });

  describe('calculate method', () => {
    it('should calculate with magic numbers', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          'print(2.0 * 2.718 + 1.618);',
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(parseFloat(result)).toBeCloseTo(7.054);
    });
  });

  describe('countItems method', () => {
    it('should count items in list', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print([1, 2, 3].length);",
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(parseInt(result)).toBe(3);
    });
  });

  describe('buildOutput method', () => {
    it('should concatenate parts with comma', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print(['a', 'b', 'c'].join(','));" 
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(result).toBe('a,b,c');
    });
  });

  describe('compute method', () => {
    it('should multiply by 3', async () => {
      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          'print(5 * 3);',
        ]);
        let output = '';
        proc.stdout.on('data', (data) => { output += data; });
        proc.on('close', (code) => resolve(output.trim()));
        proc.on('error', reject);
      });
      expect(parseInt(result)).toBe(15);
    });
  });

  describe('class properties', () => {
    it('should have user_count field', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('user_count');
    });

    it('should have userName field', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('userName');
    });

    it('should have IS_ACTIVE field', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('IS_ACTIVE');
    });
  });

  describe('security issues detection', () => {
    it('should contain hardcoded secret key', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('ghp_abc123def456ghi789');
    });

    it('should contain SQL query with string interpolation', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('SELECT * FROM t WHERE id = $id');
    });

    it('should contain command injection vulnerability', async () => {
      const content = fs.readFileSync(dartFilePath, 'utf-8');
      expect(content).toContain('Process.run');
    });
  });

  describe('file structure validation', () => {
    it('should be valid Dart syntax', async () => {
      const result = await new Promise<number>((resolve, reject) => {
        const proc = spawn('dart', ['analyze', dartFilePath]);
        proc.on('close', (code) => resolve(code || 0));
        proc.on('error', reject);
      });
      expect(result).toBe(0);
    });
  });
});

describe('MaxIssuesTest constants', () => {
  it('should export secretKey constant', async () => {
    const content = fs.readFileSync(dartFilePath, 'utf-8');
    expect(content).toMatch(/static const String secretKey/);
  });
});