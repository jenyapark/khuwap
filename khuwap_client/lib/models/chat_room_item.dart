class ChatRoomItem {
  final String roomId;          
  final String postUUID;  
  final String peerIdFromApi; //fastapi에서 내려온 peer_id 서버 검증용
  String peerId; // 현재 로그인한 나 기준으로 상대방 아이디   
  String lastMessage;  

  int unreadCount;

  String? postTitle;        
  String? ownedCourseName;    
  String? desiredCourseName;

  ChatRoomItem({
    required this.roomId,
    required this.postUUID,
    required this.peerIdFromApi,
    required this.peerId,
    required this.lastMessage,
    this.postTitle,
    this.ownedCourseName,
    this.desiredCourseName,
    this.unreadCount = 0,
  });
}
