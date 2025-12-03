import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = "http://localhost:8000/users";

  static Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId"));

    if (response.statusCode == 200) {
      return json.decode(response.body)["data"];
    }
    return null;
  }
}
