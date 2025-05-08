class ChateRegisterResponse {
  final bool success;
  final String? error;
  final bool isInQueue;

  ChateRegisterResponse({
    required this.success,
    this.error,
    required this.isInQueue,
  });

  factory ChateRegisterResponse.fromJson(Map<String, dynamic> json) {
    final topLevelStatus = json['status'] == true || json['status'] == 'true';
    final contentStatus = json['content']?['status'];
    if (!topLevelStatus || contentStatus == false || contentStatus == 'false') {
      return ChateRegisterResponse(
        success: true,
        error: json['content']?['message'] ?? 'Agent not available',
        isInQueue: true,
      );
    }

    return ChateRegisterResponse(
      success: true,
      isInQueue: false,
    );
  }

  factory ChateRegisterResponse.error(String errorMessage) {
    return ChateRegisterResponse(
      success: false,
      error: errorMessage,
      isInQueue: false,
    );
  }
}
