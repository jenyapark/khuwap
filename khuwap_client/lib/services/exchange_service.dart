import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_item.dart';
import '../models/request_item.dart';
import '../config/api.dart';

class ExchangeService {
  static String get baseUrl => coreUrl;

  // 교환글 목록 받아오기
  static Future<List<dynamic>> fetchExchangeRaw() async {
    final res = await http.get(Uri.parse("$baseUrl/exchange/list"));

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
      postUUID: raw['post_uuid'],
      authorId: raw['author_id'],
      status: raw["status"],
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
    final res = await http.get(Uri.parse("$baseUrl/exchange/mylist/$userId"));
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body);
    return body["data"] ?? [];
  }

  static Future<List<ExchangeItem>> fetchMyPosts(String userId) async {
    final List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(
      await fetchMyPostsRaw(userId),
    );

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

          postUUID: raw['post_uuid'],
          authorId: raw['author_id'],
          status: raw["status"],
        ),
      );
    }

    return items;
  }

  String buildChatRoomTitle(ExchangeItem post) {
    if (post.ownedTitle.isEmpty || post.desiredTitle.isEmpty) {
      return "과목 정보 없음";
    }
    return "${post.ownedTitle} ↔ ${post.desiredTitle}";
  }

  // 특정 교환글 RAW 조회
  static Future<Map<String, dynamic>?> fetchPostRaw(String postUUID) async {
    final res = await http.get(Uri.parse("$baseUrl/exchange/$postUUID"));
    if (res.statusCode != 200) return null;

    return jsonDecode(res.body)["data"];
  }

  static Future<String?> fetchAuthorId(String postUUID) async {
    final res = await http.get(Uri.parse("$baseUrl/exchange/post/$postUUID"));
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    return data["data"]["author_id"];
  }

  // 게시글 삭제
  static Future<bool> deletePost(String postUuid) async {
    final url = Uri.parse("$baseUrl/exchange/$postUuid");

    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("삭제 실패: ${response.body}");
      return false;
    }
  }

  static Future<bool> createPost({
    required String authorId,
    required String ownedCourseCode,
    required String desiredCourseCode,
    required String note,
  }) async {
    final url = Uri.parse("$baseUrl/exchange/");

    final body = {
      "author_id": authorId,
      "current_course": ownedCourseCode,
      "desired_course": desiredCourseCode,
      "note": note,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return response.statusCode == 201;
  }

  static Future<bool> updatePost(String postUUID, String newNote) async {
    final url = Uri.parse("$baseUrl/exchange/$postUUID");

    final body = {"note": newNote};

    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  static Future<List<RequestItem>> fetchSentRequests(String userId) async {
    final url = Uri.parse("$baseUrl/exchange/request/sent/$userId");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("보낸 요청 조회 실패");
    }
    final decoded = json.decode(response.body);
    final List data = decoded["data"];

    return data.map((item) => RequestItem.fromJson(item)).toList();
  }

  static Future<Map<String, dynamic>?> getRawByPostUUID(String postUUID) async {
    final rawList = await fetchExchangeRaw();

    for (var raw in rawList) {
      if (raw["post_uuid"] == postUUID) {
        return raw;
      }
    }
    return null;
  }

  static Future<ExchangeItem?> requestItemToExchangeItem(
    RequestItem req,
  ) async {
    final raw = await getRawByPostUUID(req.postUUID);
    if (raw == null) return null;

    return composeExchangeItem(raw);
  }

  static Future<bool> cancelRequest(String requestUUID) async {
    final url = Uri.parse("$baseUrl/exchange/request/sent/$requestUUID");

    final res = await http.delete(url);

    if (res.statusCode == 200) return true;
    return false;
  }

  static Future<bool> acceptRequest(String requestUUID) async {
    final url = Uri.parse("$baseUrl/exchange/request/$requestUUID/accept");

    final res = await http.patch(url);

    if (res.statusCode == 200) return true;
    return false;
  }

  static Future<bool> sendRequest({
    required String requesterId,
    required String postUUID,
  }) async {
    final url = Uri.parse("$baseUrl/exchange/request/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requester_id": requesterId, "post_uuid": postUUID}),
    );

    return res.statusCode == 201;
  }

  static Future<List<RequestItem>> listRequests(String postUUID) async {
    final url = Uri.parse("$baseUrl/exchange/request/list/$postUUID");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("FAILED TO FETCH REQUEST LIST");
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) => RequestItem.fromJson(json)).toList();
  }
}
