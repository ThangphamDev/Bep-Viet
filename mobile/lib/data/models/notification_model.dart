class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final DateTime deliveredAt;
  final DateTime? readAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    required this.deliveredAt,
    this.readAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>?,
      deliveredAt: _parseDate(json['delivered_at'] ?? json['deliveredAt']),
      readAt: json['read_at'] != null || json['readAt'] != null
          ? _parseDate(json['read_at'] ?? json['readAt'])
          : null,
      isRead: _parseBool(json['is_read'] ?? json['isRead']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'payload': payload,
      'deliveredAt': deliveredAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Helper getters for UI
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(deliveredAt);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${(difference.inDays / 7).floor()} tuần trước';
    }
  }

  String get iconByType {
    switch (type) {
      case 'ACCOUNT_BLOCKED':
      case 'ACCOUNT_UNBLOCKED':
        return '🔐';
      case 'RECIPE_PROMOTED_TO_OFFICIAL':
      case 'RECIPE_APPROVED':
        return '🎉';
      case 'RECIPE_REJECTED':
        return '❌';
      case 'COMMENT_RECEIVED':
        return '💬';
      case 'RATING_RECEIVED':
        return '⭐';
      default:
        return '📬';
    }
  }
}
