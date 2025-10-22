class SubscriptionModel {
  final String id;
  final String plan;
  final String status;
  final DateTime startedAt;
  final DateTime endedAt;

  const SubscriptionModel({
    required this.id,
    required this.plan,
    required this.status,
    required this.startedAt,
    required this.endedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': plan,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? plan,
    String? status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

class CreateSubscriptionRequest {
  final String plan;
  final int durationMonths;

  const CreateSubscriptionRequest({
    required this.plan,
    required this.durationMonths,
  });

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionRequest(
      plan: json['plan'] as String,
      durationMonths: json['duration_months'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'plan': plan, 'duration_months': durationMonths};
  }
}

class SubscriptionResponse {
  final bool success;
  final SubscriptionModel? data;
  final String? message;

  const SubscriptionResponse({required this.success, this.data, this.message});

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] as bool,
      data: json['data'] != null
          ? SubscriptionModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson(), 'message': message};
  }
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String nameEn;
  final int price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final int displayOrder;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.price,
    required this.duration,
    required this.features,
    required this.isPopular,
    required this.displayOrder,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    // Parse features from JSON array
    List<String> featuresList = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        featuresList = (json['features'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (json['features'] is String) {
        // If backend sends JSON string, parse it
        try {
          final parsed = json['features'];
          if (parsed is List) {
            featuresList = parsed.map((e) => e.toString()).toList();
          }
        } catch (e) {
          featuresList = [];
        }
      }
    }

    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      price: json['price'] as int,
      duration: json['duration'] as String,
      features: featuresList,
      isPopular: (json['is_popular'] as int) == 1,
      displayOrder: json['display_order'] as int,
      isActive: (json['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'price': price,
      'duration': duration,
      'features': features,
      'is_popular': isPopular ? 1 : 0,
      'display_order': displayOrder,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class SubscriptionTransactionModel {
  final String id;
  final String planId;
  final String planName;
  final String planNameEn;
  final int amount;
  final String status;
  final String? paymentMethod;
  final String? transactionRef;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  const SubscriptionTransactionModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.planNameEn,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionRef,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  factory SubscriptionTransactionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransactionModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      planNameEn: json['plan_name_en'] as String,
      amount: json['amount'] as int,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      transactionRef: json['transaction_ref'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_name': planName,
      'plan_name_en': planNameEn,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'transaction_ref': transactionRef,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
