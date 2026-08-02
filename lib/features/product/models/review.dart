/// Product review item for Detail screens.
class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.rating,
    this.memberName,
    this.memberAvatarUrl,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String productId;
  final double rating;
  final String? memberName;
  final String? memberAvatarUrl;
  final String? comment;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      memberName:
          json['member_name'] as String? ?? json['user_name'] as String?,
      memberAvatarUrl: json['member_avatar_url'] as String?,
      comment: json['comment'] as String? ?? json['body'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'rating': rating,
      'member_name': memberName,
      'member_avatar_url': memberAvatarUrl,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
