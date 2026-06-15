// CODEPEEL TEST: Critical Findings - severe security issues
class CriticalTest {
  // CRITICAL: Memory leak - singleton holding context
  static final Map<String, dynamic> _cache = {};

  void addToCache(String key, dynamic val) {
    _cache[key] = val;
  }

  // CRITICAL: Unbounded resource allocation
  List<int> generateList(int size) {
    return List<int>.filled(size, 0);
  }

  // CRITICAL: Integer overflow potential
  int calculateScore(int base, int multiplier) {
    return base * multiplier * 1000;
  }

  // CRITICAL: Circular reference memory leak
  final List<CriticalTest> _children = [];

  void addChild(CriticalTest child) {
    _children.add(child);
  }
}
