import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class UserService {
  static String get baseUrl => "$coreUrl/users";

  static Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId"));

    if (response.statusCode == 200) {
      return json.decode(response.body)["data"];
    }
    return null;
  }
}
