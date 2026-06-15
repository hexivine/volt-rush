// CODEPEEL TEST: Max Issues - many mixed problems
class MaxIssuesTest {
  String? name;
  int? count;
  bool? flag;

  // Issue 1: null safety
  String getName() => name!;

  // Issue 2: unused variable
  void doSomething() {
    int x = 10;
    int y = 20;
    print(y);
  }

  // Issue 3: empty catch block
  void handleError() {
    try {
      int result = 1 ~/ 0;
    } catch (e) {
      // Empty catch - swallowed exception
    }
  }

  // Issue 4: type mismatch potential
  int parseCount(String input) {
    return int.parse(input);
  }

  // Issue 5: missing default case
  String getStatus(int code) {
    switch (code) {
      case 1:
        return 'active';
      case 2:
        return 'pending';
    }
    return 'unknown';
  }

  // Issue 6: inefficient string concat
  String buildMessage() {
    String msg = '';
    for (int i = 0; i < 5; i++) {
      msg = msg + 'item' + i.toString();
    }
    return msg;
  }
}
