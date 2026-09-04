// CodePeel Team Billing Test Service
class TestBillingService {
  final String account;
  TestBillingService({required this.account});

  void logStatus() {
    print('Testing team billing owner review'); // violates rule: "Never use print() in production code"
  }
}
