import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/timetable_item.dart';

class TimeTableService {
  static const baseUrl = "http://localhost:8000";

  //사용자 시간표 raw 목록 가져오기
  static Future<List<dynamic>> fetchRawTimetable(String userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/schedules/list/$userId"),
    );

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
  static Future<List<TimeTableItem>> fetchComposedTimetable(String userId) async {
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
}
