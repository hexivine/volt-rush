// Test file: Lots of issues across all categories for max issues check (threshold: 10)

import 'dart:convert';
import 'dart:io';

class MaxIssuesTest {
  static const String secretKey = 'ghp_abc123def456ghi789'; // hardcoded secret

  // Bug: off-by-one
  int get(int index, List<int> list) => list[index];

  // Bug: division by zero
  double divide(int a, int b) => a / b;

  // Bug: null deref
  String getName(Map? data) => data!['name'];

  // Security: SQL injection
  void query(String id) {
    final sql = "SELECT * FROM t WHERE id = $id";
  }

  // Security: command injection
  Future<int> run(String cmd) async => (await Process.run('sh', ['-c', cmd])).exitCode;

  // Performance: O(n^2) in hot path
  List<List<int>> findPairs(List<int> nums) {
    List<List<int>> pairs = [];
    for (var i = 0; i < nums.length; i++) {
      for (var j = 0; j < nums.length; j++) {
        if (nums[i] + nums[j] == 0) pairs.add([nums[i], nums[j]]);
      }
    }
    return pairs;
  }

  // Performance: unnecessary copies
  List<int> process(List<int> data) {
    var copy1 = List.from(data);
    var copy2 = List.from(copy1);
    var copy3 = List.from(copy2);
    return copy3.map((e) => e * 2).toList();
  }

  // Best practice: magic numbers everywhere
  double calculate(double input) {
    if (input > 3.14) return input * 1.414;
    return input * 2.718 + 1.618;
  }

  // Best practice: function does too many things
  void doEverything(String raw) {
    final parsed = json.decode(raw);
    final validated = parsed;
    final transformed = validated;
    final result = transformed;
    final file = File('output.txt');
    file.writeAsStringSync(result.toString());
    print('Done: $result');
  }

  // Bug: wrong return type
  int countItems(List items) {
    return items.length.toDouble().toInt(); // unnecessary conversion
  }

  // Best practice: catch-all exception handler
  void riskyOperation() {
    try {
      File('/etc/passwd').readAsStringSync();
    } catch (e) {
      // swallow everything
    }
  }

  // Performance: string concatenation in loop
  String buildOutput(List<String> parts) {
    String result = '';
    for (var p in parts) {
      result += p + ',';
    }
    return result;
  }

  // Bug: unused assignment
  int compute(int x) {
    int result = x * 2;
    result = x * 3; // previous assignment wasted
    return result;
  }

  // Best practice: inconsistent naming
  int user_count = 5;
  String userName = 'test';
  bool IS_ACTIVE = true;
}
