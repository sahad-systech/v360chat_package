class View360ChatPrefsModel {
  final String chatId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerContentId;

  View360ChatPrefsModel({
    required this.customerContentId,
    required this.chatId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });
}
