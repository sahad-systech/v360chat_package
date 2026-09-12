import 'package:shared_preferences/shared_preferences.dart';

import '../model/storage_pre_model.dart';

/// Documented.
class View360ChatPrefs {
  /// Documented.
  static String chatIdKey = 'CHAT_ID_KEY';
  /// Documented.
  static String customerIdKey = 'CUSTOMER_ID_KEY';
  /// Documented.
  static String customerNameKey = 'CUSTOMER_NAME_KEY';
  /// Documented.
  static String customerEmailKey = 'CUSTOMER_EMAIL_KEY';
  /// Documented.
  static String customerPhoneKey = 'CUSTOMER_PHONE_KEY';
  /// Documented.
  static String customerCondentIdKey = 'CUSTOMER_CONDENT_ID_KEY';
  /// Documented.
  static String isInQueue = 'IS_IN_QUEUE';

  /// Documented.
  static Future<void> saveString(
      {required String chatIdKeyValue,
      required String customerIdKeyValue,
      required String customerNameKeyValue,
      required String customerEmailKeyValue,
      required String customerPhoneKeyValue,
      required String customerCondentIdValue,
      required bool isInQueueValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chatIdKey, chatIdKeyValue);
    await prefs.setBool(isInQueue, isInQueueValue);
    await prefs.setString(customerIdKey, customerIdKeyValue);
    await prefs.setString(customerNameKey, customerNameKeyValue);
    await prefs.setString(customerEmailKey, customerEmailKeyValue);
    await prefs.setString(customerPhoneKey, customerPhoneKeyValue);
    await prefs.setString(customerCondentIdKey, customerCondentIdValue);
  }

  /// Documented.
  static Future<View360ChatPrefsModel> getString() async {
    final prefs = await SharedPreferences.getInstance();
    return View360ChatPrefsModel(
      chatId: prefs.getString(chatIdKey) ?? '',
      customerId: prefs.getString(customerIdKey) ?? '',
      customerName: prefs.getString(customerNameKey) ?? '',
      isInQueue: prefs.getBool(isInQueue) ?? false,
      customerEmail: prefs.getString(customerEmailKey) ?? '',
      customerPhone: prefs.getString(customerPhoneKey) ?? '',
      customerContentId: prefs.getString(customerCondentIdKey) ?? 'false',
    );
  }

  /// Documented.
  static Future<void> remove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chatIdKey);
    await prefs.remove(customerIdKey);
    await prefs.remove(customerNameKey);
    await prefs.remove(customerEmailKey);
    await prefs.remove(customerPhoneKey);
    await prefs.remove(isInQueue);
    await prefs.remove(customerCondentIdKey);
  }

  /// Documented.
  static Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(customerIdKey);
  }

  /// Documented.
  static Future<String?> getChatId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(chatIdKey);
  }

  /// Documented.
  static Future<bool> removeCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(customerIdKey);
  }

  /// Documented.
  static Future<void> changeQueueStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isInQueue, value);
  }

  /// Documented.
  static Future<void> condentIdInQueue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(customerCondentIdKey, value);
  }

  /// Documented.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
