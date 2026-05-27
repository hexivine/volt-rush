// This file is in test/fixtures/ which is in ignore_paths
// NONE of these should trigger any rules

import 'package:cloud_firestore/cloud_firestore.dart';

// This has print, hardcoded URLs, DateTime.now() — all should be IGNORED
void setupMockData() {
  print('Setting up mock data...');
  final timestamp = DateTime.now();
  final url = 'https://mock-api.test.com/data';
  final key = 'AIzaSyBmockkeymockkeymockkeymockkeymock';
}
