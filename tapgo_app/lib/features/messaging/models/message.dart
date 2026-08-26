/// Single chat message inside Message Detail.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.senderId,
    this.senderType = MessageSenderType.member,
    this.sentAt,
    this.isRead = false,
    this.attachmentUrl,
  });

  final String id;
  final String conversationId;
  final String body;
  final String senderId;
  final MessageSenderType senderType;
  final DateTime? sentAt;
  final bool isRead;
  final String? attachmentUrl;

  bool get isMine => senderType == MessageSenderType.member;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      senderId: json['sender_id'].toString(),
      senderType: MessageSenderType.fromJson(json['sender_type'] as String?),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString())
                : null),
      isRead: json['is_read'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'body': body,
      'sender_id': senderId,
      'sender_type': senderType.toJson(),
      'sent_at': sentAt?.toIso8601String(),
      'is_read': isRead,
      'attachment_url': attachmentUrl,
    };
  }
}

enum MessageSenderType {
  member,
  store,
  system;

  static MessageSenderType fromJson(String? value) {
    return MessageSenderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageSenderType.member,
    );
  }

  String toJson() => name;
}
