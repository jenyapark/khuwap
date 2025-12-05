import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/timetable_item.dart';
import '../config/api.dart';

class TimeTableService {
  static String get baseUrl => coreUrl;

  //사용자 시간표 raw 목록 가져오기
  static Future<List<dynamic>> fetchRawTimetable(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/schedules/list/$userId"));

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["data"]; // [{course_code: "..."} ...]
  }

  // 학수번호 통해서 과목 상세 요청
  static Future<Map<String, dynamic>?> fetchCourseDetail(String code) async {
    final res = await http.get(
      Uri.parse("$baseUrl/courses/detail?course_code=$code"),
    );

    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    return body["data"];
  }

  static Future<TimeTableItem?> composeTimetableItem(dynamic raw) async {
    final detail = await fetchCourseDetail(raw["course_code"]);
    if (detail == null) return null;

    return TimeTableItem(
      courseCode: detail["course_code"],
      courseName: detail["course_name"],
      professor: detail["professor"],
      day: detail["day_of_week"],
      startTime: detail["start_time"],
      endTime: detail["end_time"],
      room: detail["room"],
      credit: detail["credit"],
    );
  }

  // 최종 시간표 리스트 반환
  static Future<List<TimeTableItem>> fetchComposedTimetable(
    String userId,
  ) async {
    final rawList = await fetchRawTimetable(userId);
    List<TimeTableItem> result = [];

    for (var item in rawList) {
      final composed = await composeTimetableItem(item);
      if (composed != null) {
        result.add(composed);
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>> addTimetable({
    required String userId,
    required String courseCode,
  }) async {
    final body = {"user_id": userId, "course_code": courseCode};

    final response = await http.post(
      Uri.parse("$baseUrl/schedules/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final jsonBody = jsonDecode(response.body);

  return {
    "success": response.statusCode >= 200 && response.statusCode < 300,
    "message": jsonBody["message"] ?? "오류가 발생했습니다.",
  };
  
  }

  static Future<bool> deleteTimetable({
    required String userId,
    required String courseCode,
  }) async {
    final url = Uri.parse("$baseUrl/schedules/$userId/$courseCode");

    final response = await http.delete(url);

    return response.statusCode >= 200 && response.statusCode < 300;
}
}
