// Test file: Critical severity issues for premerge check testing

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

class CriticalTest {
  // CRITICAL: eval-equivalent - running arbitrary code from user input
  Future<void> executeUserCode(String code) async {
    // Spawning isolate with user-provided code - critical vulnerability
    await Isolate.run(() {
      // Dynamically executing user code
      throw Exception(code);
    });
  }

  // CRITICAL: Deserialization of untrusted data without validation
  dynamic deserializeInput(String base64Input) {
    final decoded = base64Decode(base64Input);
    final jsonString = utf8.decode(decoded);
    // No schema validation, no type checking
    final data = json.decode(jsonString);
    // Recursively processing untrusted nested data
    _processNested(data);
    return data;
  }

  void _processNested(dynamic data) {
    if (data is Map) {
      data.forEach((key, value) => _processNested(value));
    } else if (data is List) {
      data.forEach(_processNested);
    }
  }

  // CRITICAL: Prototype pollution equivalent - modifying global state
  void mergeConfig(Map<String, dynamic> userConfig) {
    // User can override security-critical configuration
    final defaults = {'timeout': 30, 'maxRetries': 3, 'sslVerify': true};
    defaults.addAll(userConfig); // User can set sslVerify: false
    _applyConfig(defaults);
  }

  // CRITICAL: Race condition in financial transaction
  double balance = 1000.0;
  Future<bool> withdraw(String accountId, double amount) async {
    // No synchronization - race condition
    if (balance >= amount) {
      // Simulating async delay between check and debit
      await Future.delayed(Duration(milliseconds: 100));
      balance -= amount;
      return true;
    }
    return false;
  }

  // CRITICAL: Unchecked integer overflow in financial calculation
  int calculateTotal(List<int> prices) {
    int total = 0;
    for (final price in prices) {
      total += price; // No overflow check
    }
    return total;
  }

  // CRITICAL: Memory leak - resources never freed
  final List<StreamSubscription> _subscriptions = [];
  void listenToAll(List<Stream> streams) {
    for (final stream in streams) {
      _subscriptions.add(stream.listen((_) {}));
      // Subscriptions never cancelled, list grows unbounded
    }
  }

  // CRITICAL: Silent data loss - exceptions swallowed
  Future<void> saveRecord(Map<String, dynamic> record) async {
    try {
      final file = File('data.json');
      await file.writeAsString(json.encode(record));
    } catch (e) {
      // Silently ignoring write failures - data loss
    }
  }

  void _applyConfig(Map<String, dynamic> config) {}
}
