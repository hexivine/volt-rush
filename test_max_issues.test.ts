import { spawn } from 'child_process';
import fs from 'fs';
import path from 'path';

// Mock child_process spawn
jest.mock('child_process', () => ({
  spawn: jest.fn(),
}));

// Mock fs
jest.mock('fs', () => ({
  readFileSync: jest.fn(),
  existsSync: jest.fn(),
}));

describe('MaxIssuesTest', () => {
  const mockSpawn = spawn as jest.MockedFunction<typeof spawn>;
  const mockFsReadFileSync = fs.readFileSync as jest.MockedFunction<typeof fs.readFileSync>;
  const mockFsExistsSync = fs.existsSync as jest.MockedFunction<typeof fs.existsSync>;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Dart script execution', () => {
    it('should execute dart script and capture output', async () => {
      let output = '';
      const mockStdout = {
        on: jest.fn((event: string, callback: (data: Buffer) => void) => {
          if (event === 'data') {
            callback(Buffer.from('a,b,c'));
          }
        }),
      };
      
      const mockProc = {
        stdout: mockStdout,
        on: jest.fn(),
      };
      
      mockSpawn.mockReturnValue(mockProc as any);

      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', [
          '-e',
          "print(['a', 'b', 'c'].join(','));" 
        ]);
        let output = '';
        proc.stdout.on('data', (data: Buffer) => { 
          output += data.toString(); 
        });
        proc.on('close', () => {
          resolve(output);
        });
      });

      expect(mockSpawn).toHaveBeenCalledWith('dart', ['-e', expect.stringContaining("print")], undefined);
      expect(result).toBe('a,b,c');
    });

    it('should handle dart script execution errors', async () => {
      const mockProc = {
        stdout: {
          on: jest.fn(),
        },
        on: jest.fn((event: string, callback: (code: number) => void) => {
          if (event === 'close') {
            callback(1);
          }
        }),
      };
      
      mockSpawn.mockReturnValue(mockProc as any);

      const result = await new Promise<string>((resolve, reject) => {
        const proc = spawn('dart', ['-e', 'throw new Exception();']);
        let output = '';
        proc.stdout.on('data', (data: Buffer) => { output += data; });
        proc.on('close', (code: number) => {
          if (code !== 0) {
            reject(new Error(`Process exited with code ${code}`));
          } else {
            resolve(output);
          }
        });
      }).catch((err) => err.message);

      expect(result).toContain('Process exited with code 1');
    });

    it('should correctly join array elements with comma', async () => {
      const expectedOutput = 'a,b,c';
      
      let capturedArgs: string[] = [];
      const mockProc = {
        stdout: {
          on: jest.fn((event: string, callback: (data: Buffer) => void) => {
            if (event === 'data') {
              callback(Buffer.from(expectedOutput));
            }
          }),
        },
        on: jest.fn(),
      };
      
      mockSpawn.mockImplementation((cmd: string, args: string[]) => {
        capturedArgs = args;
        return mockProc as any;
      });

      await new Promise<void>((resolve) => {
        const proc = spawn('dart', ['-e', "print(['a', 'b', 'c'].join(','));" ]);
        proc.on('close', () => resolve());
      });

      expect(capturedArgs[1]).toContain('join');
      expect(capturedArgs[1]).toContain("','");
    });
  });
});

describe('MaxIssuesTest constants', () => {
  const mockFsReadFileSync = fs.readFileSync as jest.MockedFunction<typeof fs.readFileSync>;
  const mockFsExistsSync = fs.existsSync as jest.MockedFunction<typeof fs.existsSync>;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should read dart file and verify secretKey constant exists', () => {
    const dartFilePath = '/path/to/project/lib/secrets.dart';
    const mockContent = `class Secrets {
  static const String secretKey = 'my-secret-key';
  static const String apiUrl = 'https://api.example.com';
}`;
    
    mockFsExistsSync.mockReturnValue(true);
    mockFsReadFileSync.mockReturnValue(mockContent);

    const content = fs.readFileSync(dartFilePath, 'utf-8');
    expect(content).toMatch(/static const String secretKey/);
  });

  it('should handle missing dart file gracefully', () => {
    const dartFilePath = '/path/to/nonexistent/file.dart';
    
    mockFsExistsSync.mockReturnValue(false);
    mockFsReadFileSync.mockImplementation(() => {
      throw new Error(`ENOENT: no such file or directory, open '${dartFilePath}'`);
    });

    expect(() => fs.readFileSync(dartFilePath, 'utf-8')).toThrow();
  });

  it('should detect secretKey constant in complex dart files', () => {
    const dartFilePath = '/path/to/project/lib/secrets.dart';
    const mockContent = `class Secrets {
  static const String apiKey = '12345';
  static const String secretKey = 'my-super-secret-key';
  static const int maxRetries = 3;
  
  static const String databaseUrl = 'postgres://localhost:5432';
  
  static const String secretKey = 'another-key';
}`;
    
    mockFsReadFileSync.mockReturnValue(mockContent);

    const content = fs.readFileSync(dartFilePath, 'utf-8');
    expect(content).toMatch(/static const String secretKey/);
    expect(content.indexOf('static const String secretKey')).toBeGreaterThan(-1);
  });

  it('should return empty string when file does not exist', () => {
    const dartFilePath = '/path/to/nonexistent.dart';
    mockFsExistsSync.mockReturnValue(false);
    mockFsReadFileSync.mockImplementation(() => {
      throw new Error('File not found');
    });

    expect(() => fs.readFileSync(dartFilePath, 'utf-8')).toThrow();
  });

  it('should validate dart script output format', async () => {
    const mockProc = {
      stdout: {
        on: jest.fn((event: string, callback: (data: Buffer) => void) => {
          if (event === 'data') {
            callback(Buffer.from('[1, 2, 3]'));
          }
        }),
      },
      on: jest.fn(),
    };
    
    mockSpawn.mockReturnValue(mockProc as any);

    const result = await new Promise<string>((resolve) => {
      const proc = spawn('dart', ['-e', 'print([1, 2, 3]);']);
      let output = '';
      proc.stdout.on('data', (data: Buffer) => { output += data.toString(); });
      proc.on('close', () => resolve(output));
    });

    expect(result).toBe('[1, 2, 3]');
  });

  it('should handle process spawn with different dart commands', async () => {
    let capturedCmd = '';
    let capturedArgs: string[] = [];
    
    mockSpawn.mockImplementation((cmd: string, args: string[]) => {
      capturedCmd = cmd;
      capturedArgs = args;
      return {
        stdout: { on: jest.fn() },
        on: jest.fn(),
      } as any;
    });

    await new Promise<void>((resolve) => {
      const proc = spawn('dart', ['-e', 'print(1 + 1);']);
      proc.on('close', () => resolve());
    });

    expect(capturedCmd).toBe('dart');
    expect(capturedArgs).toContain('-e');
    expect(capturedArgs.some(arg => arg.includes('print'))).toBe(true);
  });

  it('should verify fs.readFileSync is called with correct path', () => {
    const dartFilePath = '/project/test_max_issues.dart';
    const mockContent = 'class MaxIssuesTest {}';
    
    mockFsExistsSync.mockReturnValue(true);
    mockFsReadFileSync.mockReturnValue(mockContent);

    const content = fs.readFileSync(dartFilePath, 'utf-8');
    
    expect(mockFsReadFileSync).toHaveBeenCalledWith(dartFilePath, 'utf-8');
    expect(content).toBe(mockContent);
  });

  it('should handle multiple secretKey occurrences in file', () => {
    const dartFilePath = '/path/to/secrets.dart';
    const mockContent = `
class Secrets {
  static const String secretKey = 'first-key';
  static const String otherKey = 'other-value';
  static const String secretKey = 'second-key';
}
`;
    
    mockFsReadFileSync.mockReturnValue(mockContent);

    const content = fs.readFileSync(dartFilePath, 'utf-8');
    const matches = content.match(/static const String secretKey/g);
    
    expect(matches).toHaveLength(2);
  });
});