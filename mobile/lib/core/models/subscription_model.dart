class SubscriptionModel {
  final String id;
  final String userId;
  final String planName;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      planName: json['plan_name'] ?? '',
      status: SubscriptionStatus.fromString(json['status'] ?? 'ACTIVE'),
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      autoRenew: json['auto_renew'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_name': planName,
      'status': status.value,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isCancelled => status == SubscriptionStatus.cancelled;
}

enum SubscriptionStatus {
  active('ACTIVE'),
  cancelled('CANCELLED'),
  expired('EXPIRED');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.active,
    );
  }
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationMonths;
  final List<String> features;
  final bool isPopular;
  final bool isRecommended;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationMonths,
    this.features = const [],
    this.isPopular = false,
    this.isRecommended = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      durationMonths: json['duration_months'] ?? 1,
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] ?? false,
      isRecommended: json['is_recommended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration_months': durationMonths,
      'features': features,
      'is_popular': isPopular,
      'is_recommended': isRecommended,
    };
  }
}


