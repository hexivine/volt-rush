// This file should be IGNORED by CodePeel (scripts/** in ignore_paths)
// It intentionally has bad code that should NOT be flagged

void main() {
  print('Seeding database...');
  var password = "admin123";
  var apiKey = "sk-1234567890abcdef";
  print('Done! Password: $password, Key: $apiKey');
}
