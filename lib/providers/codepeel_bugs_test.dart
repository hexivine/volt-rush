// CODEPEEL TEST: Bug Density - multiple bugs
class BugDensityTest {
  int? value;

  // BUG: Null pointer - may crash
  int getValueOrCrash() {
    return value!.toInt();
  }

  // BUG: Unused variable
  void process() {
    int unused = 42;
    print(unused);
  }

  // BUG: Division by zero possible
  double safeDivide(int a, int b) {
    return a / b;
  }

  // BUG: Async without await
  Future<String> fetchData() async {
    return Future.value('data');
  }

  String getResult() {
    // BUG: This returns before async completes
    fetchData();
    return 'not loaded';
  }
}
