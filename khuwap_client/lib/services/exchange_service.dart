import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_item.dart';

class ExchangeService {
  static const baseUrl = "http://localhost:8000";

  // 교환글 목록 받아오기
  static Future<List<dynamic>> fetchExchangeRaw() async {
    final res = await http.get(
      Uri.parse("$baseUrl/exchange/list"),
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["data"]; // raw list
  }

  // 과목 상세 조회
  static Future<Map<String, dynamic>?> fetchCourseDetail(String code) async {
    final res = await http.get(
      Uri.parse("$baseUrl/courses/detail?course_code=$code"),
    );

    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    return body["data"];
  }

  // 최종 UI에 필요한 ExchangeItem 조립
  static Future<ExchangeItem?> composeExchangeItem(dynamic raw) async {
    final owned = await fetchCourseDetail(raw["current_course"]);
    final desired = await fetchCourseDetail(raw["desired_course"]);

    if (owned == null || desired == null) return null;

    return ExchangeItem(
      ownedTitle: owned["course_name"],
      ownedProfessor: owned["professor"],
      ownedDay: owned["day_of_week"],
      ownedStart: owned["start_time"],
      ownedEnd: owned["end_time"],
      ownedCourseCode: owned["course_code"],
      ownedRoom: owned["room"],
      ownedCredit: owned["credit"],
      desiredTitle: desired["course_name"],
      desiredProfessor: desired["professor"],
      desiredDay: desired["day_of_week"],
      desiredStart: desired["start_time"],
      desiredEnd: desired["end_time"],
      desiredCourseCode: desired["course_code"],
      desiredRoom: desired["room"],
      desiredCredit: desired["credit"],
      note: raw["note"],
    );
  }

  // 최종 결합된 ExchangeItem 리스트 반환
  static Future<List<ExchangeItem>> fetchComposedList() async {
    final rawList = await fetchExchangeRaw();
    List<ExchangeItem> result = [];

    for (var item in rawList) {
      final composed = await composeExchangeItem(item);
      if (composed != null) {
        result.add(composed);
      }
    }

    return result;
  }

  // 내 글 목록 RAW 데이터
static Future<List<dynamic>> fetchMyPostsRaw(String userId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/exchange/mylist/$userId"),
  );

  if (res.statusCode != 200) return [];

  final body = jsonDecode(res.body);

   return body["data"] ?? [];
}

static Future<List<ExchangeItem>> fetchMyPosts(String userId) async {
  final List<Map<String, dynamic>> rawList =
      List<Map<String, dynamic>>.from(await fetchMyPostsRaw(userId));

print("RAW LIST = $rawList");
  List<ExchangeItem> items = [];

  for (final raw in rawList) {
    print("RAW ITEM = $raw");      

    print("current_course = ${raw['current_course']}");   
    print("desired_course = ${raw['desired_course']}");
    final currentCode = raw['current_course'] as String;
    final desiredCode = raw['desired_course'] as String;

    // 과목 상세 정보 가져오기
    final currentDetail =
        await fetchCourseDetail(currentCode) as Map<String, dynamic>;
    final desiredDetail =
        await fetchCourseDetail(desiredCode) as Map<String, dynamic>;

    items.add(
      ExchangeItem(
        ownedTitle: currentDetail['course_name'],         
        ownedProfessor: currentDetail['professor'],
        ownedDay: currentDetail['day_of_week'],            
        ownedStart: currentDetail['start_time'],           
        ownedEnd: currentDetail['end_time'],               
        ownedCourseCode: currentDetail['course_code'],
        ownedRoom: currentDetail['room'],
        ownedCredit: currentDetail['credit'],

        desiredTitle: desiredDetail['course_name'],        
        desiredProfessor: desiredDetail['professor'],
        desiredDay: desiredDetail['day_of_week'],        
        desiredStart: desiredDetail['start_time'],         
        desiredEnd: desiredDetail['end_time'],             
        desiredCourseCode: desiredDetail['course_code'],
        desiredRoom: desiredDetail['room'],
        desiredCredit: desiredDetail['credit'],

        note: raw['note'],
      ),
    );
  }

  return items;
}



  
}
