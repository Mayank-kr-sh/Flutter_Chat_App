class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      content: json['content'],
      senderId: json['sender']['_id'],
      senderName: json['sender']['name'],
    );
  }
}
