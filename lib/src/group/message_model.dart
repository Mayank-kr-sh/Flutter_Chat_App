class Message {
  final String id;
  final String chatId;
  final String messages;
  final String senderId;
  final String senderName;

  Message({
    required this.id,
    required this.messages,
    required this.senderId,
    required this.senderName,
    required this.chatId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      messages: json['message'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      chatId: json['chatId'],
    );

    // final Map<String, dynamic>? senderData =
    //     json['sender'] as Map<String, dynamic>?;

    // if (senderData != null) {
    //   return Message(
    //     id: json['_id'] ?? '',
    //     messages: json['content'] ?? '',
    //     senderId: senderData['_id'] ?? '',
    //     senderName: senderData['name'] ?? '',
    //     chatId: json['chatId'] ?? '',
    //   );
    // } else {
    //   throw const FormatException('Invalid message data');
    // }
  }

  // factory Message.fromReceivedData(Map<String, dynamic> data) {
  //   final String message = data['message'] ?? 'No message';
  //   final String chatId = data['chatId'] ?? '';
  //   final String senderId = data['senderId'] ?? '';
  //   final String senderName = data['senderName'] ?? 'Default Sender Name';
  //   return Message(
  //       id: chatId.isNotEmpty ? chatId : 'defaultId',
  //       content: message,
  //       senderId: senderId.isNotEmpty ? senderId : 'defaultSenderId',
  //       senderName: senderName);
  // }
}
