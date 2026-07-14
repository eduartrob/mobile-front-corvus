class ActivityLogModel {
  final String id;
  final String userId;
  final String action;
  final String detail;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      detail: json['detail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
