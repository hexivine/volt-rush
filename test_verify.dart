// TEST FILE — triggers all 4 pre-merge checks
class SecurityTest {
  static const String API_KEY = 'sk-live-abc123secret789xyz456';
  
  void login(String user, String pass) {
    var q = "SELECT * FROM users WHERE user = '" + user + "'";
    print(q);
  }
  
  int sum(List<int> nums) {
    int total = 0;
    for (int i = 0; i <= nums.length; i++) { total += nums[i]; }
    return total;
  }
}
