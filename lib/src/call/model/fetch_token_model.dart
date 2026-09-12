/// Documented.
class FetchTokenModel {
  /// Documented.
  final String token;
  /// Documented.
  final String room;

  /// Documented.
  FetchTokenModel({required this.token, required this.room});

  /// Documented.
  factory FetchTokenModel.fromJson(Map<String, dynamic> json) {
    return FetchTokenModel(
      token: json['token'] as String? ?? '',
      room: json['room'] as String? ?? '',
    );
  }
}
