class UserDeletionResponse {
  const UserDeletionResponse({
    required this.userId,
    required this.success,
    required this.timestamp,
    this.errorMessage,
    this.message,
  });

  final String userId;
  final bool success;
  final String? errorMessage;
  final String? message;
  final int timestamp;

  factory UserDeletionResponse.fromJson(Map<String, dynamic> json) {
    return UserDeletionResponse(
      userId: json['userId'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      message: json['message'] as String?,
      timestamp:
          json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'success': success,
      'errorMessage': errorMessage,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
