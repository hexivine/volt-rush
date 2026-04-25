// Test file: Multiple bugs for bug density premerge check testing (threshold: 5)

import 'dart:io';

class BugDensityTest {
  List<int> items = [];

  // Bug 1: Off-by-one error
  int getLastItem() {
    return items[items.length]; // Should be items[items.length - 1]
  }

  // Bug 2: Null pointer - no null check
  String getUserName(Map<String, dynamic>? user) {
    return user['name']; // user could be null
  }

  // Bug 3: Wrong comparison operator
  bool isAdmin(int role) {
    return role = 1; // Assignment instead of comparison (==)
  }

  // Bug 4: Infinite loop potential
  List<int> filterPositive(List<int> numbers) {
    List<int> result = [];
    int i = 0;
    while (i < numbers.length) {
      if (numbers[i] > 0) {
        result.add(numbers[i]);
      }
      // Missing i++ - infinite loop if any element <= 0
    }
    return result;
  }

  // Bug 5: Type confusion
  double calculateAverage(List<dynamic> values) {
    int sum = 0;
    for (var v in values) {
      sum += v; // v might not be int - runtime error
    }
    return sum / values.length; // Division by zero if empty
  }

  // Bug 6: Resource leak
  String readFile(String path) {
    final file = File(path);
    final stream = file.openRead();
    // Stream never closed, file handle leaked
    return stream.toString();
  }

  // Bug 7: Mutable default argument equivalent
  List<int> getItems([List<int>? cache]) {
    cache ??= items;
    cache.add(999); // Mutates the original list
    return cache;
  }

  // Bug 8: Wrong loop boundary
  List<int> reverseList(List<int> input) {
    List<int> result = [];
    for (int i = input.length; i >= 0; i--) { // Starts at length, out of bounds
      result.add(input[i]);
    }
    return result;
  }

  // Bug 9: String comparison with == for identity
  bool checkStatus(Object status) {
    return status == 'active'; // May fail if status is not String
  }

  // Bug 10: Concurrent modification
  void removeNegative(List<int> numbers) {
    for (var n in numbers) {
      if (n < 0) {
        numbers.remove(n); // Concurrent modification during iteration
      }
    }
  }
}
