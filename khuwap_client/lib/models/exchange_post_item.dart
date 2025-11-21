class ExchangePostItem {
  final int postId;
  final String exchangeUuid;
  final String authorId;
  final String currentCourseCode;
  final String desiredCourseCode;
  final String status;
  final String note;
  final DateTime createdAt;

  final Map<String, dynamic> currentCourseDetail;
  final Map<String, dynamic> desiredCourseDetail;

  ExchangePostItem({
    required this.postId,
    required this.exchangeUuid,
    required this.authorId,
    required this.currentCourseCode,
    required this.desiredCourseCode,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.currentCourseDetail,
    required this.desiredCourseDetail,
  });
}
