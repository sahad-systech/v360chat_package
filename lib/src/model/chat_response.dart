class ChatMessageResponse {
  final bool success;
  final String? customerId;
  final String? error;
  final bool isInQueue;

  ChatMessageResponse({
    required this.success,
    this.customerId,
    this.error,
    required this.isInQueue,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    final topLevelStatus = json['status'] == true || json['status'] == 'true';
    final contentStatus = json['content']?['status'];
    final customerId = json['content']?['id']?.toString();

    if (!topLevelStatus || contentStatus == false || contentStatus == 'false') {
      return ChatMessageResponse(
        success: true,
        error: json['content']?['message'] ?? 'Agent not available',
        isInQueue: true,
      );
    }

    return ChatMessageResponse(
      success: true,
      customerId: customerId,
      isInQueue: false,
    );
  }

  factory ChatMessageResponse.error(String errorMessage) {
    return ChatMessageResponse(
      success: false,
      error: errorMessage,
      isInQueue: false,
    );
  }
}
