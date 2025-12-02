

class RequestItem {
  final String requestUUID;
  final String requesterId;
  final String status;
  final String createdAt;
  final String postUUID;

  RequestItem({
    required this.requestUUID,
    required this.requesterId,
    required this.status,
    required this.createdAt,
    required this.postUUID,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      requestUUID: json["request_uuid"] ?? "",
      requesterId: json["requester_id"] ?? "",
      status: json["status"] ?? "",
      createdAt: json["created_at"] ?? "",
      postUUID: json["post_uuid"] ?? "",
    );
  }



}
