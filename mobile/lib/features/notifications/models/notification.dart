/// In-app notification from Notification center screens.
///
/// Named [AppNotification] to avoid clashing with Flutter's [Notification].
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    this.body,
    this.type = NotificationType.system,
    this.imageUrl,
    this.isRead = false,
    this.createdAt,
    this.referenceId,
    this.referenceType,
  });

  final String id;
  final String title;
  final String? body;
  final NotificationType type;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;
  final String? referenceId;
  final String? referenceType;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
    String? referenceId,
    String? referenceType,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String?,
      type: NotificationType.fromJson(json['type'] as String?),
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toJson(),
      'image_url': imageUrl,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'reference_id': referenceId,
      'reference_type': referenceType,
    };
  }
}

enum NotificationType {
  system,
  order,
  promo,
  chat,
  payment;

  static NotificationType fromJson(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }

  String toJson() => name;
}
