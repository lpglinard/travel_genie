class UserDeletionRequest {
  const UserDeletionRequest({
    required this.userId,
  });

  final String userId;

  factory UserDeletionRequest.fromJson(Map<String, dynamic> json) {
    return UserDeletionRequest(
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
    };
  }
}