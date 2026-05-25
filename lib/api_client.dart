class ApiClient {
  static const token = 'ghp_abc123secrettoken456';
  
  Future<String> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.body;
  }
}
