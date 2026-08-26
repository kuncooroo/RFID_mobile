/// Buyer–seller conversation thread for Message list.
class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.storeId,
    this.memberId,
    this.isOnline = false,
  });

  final String id;
  final String title;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? storeId;
  final String? memberId;
  final bool isOnline;

  bool get hasUnread => unreadCount > 0;

  Conversation copyWith({
    String? id,
    String? title,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    String? storeId,
    String? memberId,
    bool? isOnline,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      storeId: storeId ?? this.storeId,
      memberId: memberId ?? this.memberId,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      storeId: json['store_id']?.toString(),
      memberId: json['member_id']?.toString(),
      isOnline: json['is_online'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'avatar_url': avatarUrl,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'store_id': storeId,
      'member_id': memberId,
      'is_online': isOnline,
    };
  }
}
