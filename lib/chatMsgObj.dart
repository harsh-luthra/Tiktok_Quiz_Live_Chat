class ChatMessage {
  final String userId;
  final String username;
  final String profileName;
  final String message;

  ChatMessage({required this.userId, required this.username, required this.profileName, required this.message});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userId: json['userId'],
      username: json['username'],
      profileName: json['profileName'],
      message: json['message'],
    );
  }
}
