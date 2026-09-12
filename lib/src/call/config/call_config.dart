/// Documented.
class View360CallConfig {
  /// Documented.
  final String tokenUrl;
  /// Documented.
  final String sdkId;
  /// Documented.
  final String apiKey;
  /// Documented.
  final String livekitUrl;
  /// Documented.
  final String notificationTitle;
  /// Documented.
  final String notificationText;

  /// Documented.
  const View360CallConfig({
    required this.tokenUrl,
    required this.sdkId,
    required this.apiKey,
    required this.livekitUrl,
    this.notificationTitle = 'Active Voice Call',
    this.notificationText = 'AI voice call is running in the background.',
  });
}
