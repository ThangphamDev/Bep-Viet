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
