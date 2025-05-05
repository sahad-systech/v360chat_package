import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../helper/function.dart';
import '../local/local_storage.dart';
import '../model/chat_list_response.dart';
import '../model/chat_response.dart';
import '../model/storage_pre_model.dart';
import '../socket/socket_managet.dart';

class ChatService {
  final String baseUrl;
  final String appId;

  ChatService({required this.baseUrl, required this.appId});

  Future<ChatMessageResponse> createChatSession({
    required String chatContent,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    final String updatedBaseUrl = baseUrl.replaceAll('https://', '');
    final String chatId = generateUniqueId();
    final String socketId = SocketManager().socket.id!;
    try {
      final uri =
          Uri.https(updatedBaseUrl, "/widgetapi/messages/customerMessage");

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = appId
        ..fields.addAll({
          'content': chatContent,
          'ChatId': chatId,
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'senderType': 'customer',
          'customerId': '',
          'socketId': socketId,
          'status': 'pending',
          'createdAt': DateTime.now().toString(),
          'customerInfo[name]': customerName,
          'customerInfo[email]': customerEmail ?? '',
          'customerInfo[mobile]': customerPhone ?? '',
        });

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(responseString);
        final topLevelStatus =
            json['status'] == true || json['status'] == 'true';
        final contentStatus = json['content']?['status'];
        final customerId = json['content']?['id']?.toString();
        await View360ChatPrefs.saveString(
            chatIdKeyValue: chatId,
            customerIdKeyValue: !topLevelStatus ||
                    contentStatus == false ||
                    contentStatus == 'false'
                ? json['customerId']?.toString() ?? ''
                : customerId ?? '',
            customerNameKeyValue: customerName,
            customerEmailKeyValue: customerEmail ?? '',
            customerPhoneKeyValue: customerPhone ?? '');

        final View360ChatPrefsModel data = await View360ChatPrefs.getString();
        log('chatId: ${data.chatId}');
        log('customerId: ${data.customerId}');
        log('customerName: ${data.customerName}');
        log('customerEmail: ${data.customerEmail}');
        log('customerPhone: ${data.customerPhone}');

        return ChatMessageResponse.fromJson(json);
      } else {
        return ChatMessageResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChatMessageResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatMessageResponse.error('Request timed out');
    } on HttpException {
      return ChatMessageResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatMessageResponse.error('Invalid response format');
    } catch (e, stack) {
      log('❗ Exception in sendChatMessage: $e', stackTrace: stack);
      return ChatMessageResponse.error(e.toString());
    }
  }

  Future<ChatMessageResponse> sendChatMessage({
    List<String>? filePath,
    required String chatContent,
  }) async {
    final String updatedBaseUrl = baseUrl.replaceAll('https://', '');
    final String socketId = SocketManager().socket.id!;
    const allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.pdf',
      '.gif',
      '.mp4',
      '.xlsx',
      '.csv',
    ];

    try {
      final uri =
          Uri.https(updatedBaseUrl, "/widgetapi/messages/customerMessage");
      final View360ChatPrefsModel localstorage =
          await View360ChatPrefs.getString();

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = appId
        ..fields.addAll({
          'content': chatContent,
          'ChatId': localstorage.chatId,
          'customerId': localstorage.customerId,
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'senderType': 'customer',
          'socketId': socketId,
          'status': 'pending',
          'createdAt': DateTime.now().toString(),
          'customerInfo[name]': localstorage.customerName,
          'customerInfo[email]': localstorage.customerEmail,
          'customerInfo[mobile]': localstorage.customerPhone,
        });

      if (filePath != null && filePath.isNotEmpty) {
        for (var file in filePath) {
          String ext = '.${file.split('.').last.toLowerCase()}';
          if (!allowedExtensions.contains(ext)) {
            return ChatMessageResponse.error(
                'Unsupported file extension: $ext');
          }
          String fileName = file.split('/').last;
          final mimeType = getMimeType(file);
          final parts = mimeType.split('/');
          final contentType = MediaType(parts[0], parts[1]);
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file,
            filename: fileName,
            contentType: contentType,
          ));
        }
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(responseString);
        return ChatMessageResponse.fromJson(json);
      } else {
        return ChatMessageResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChatMessageResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatMessageResponse.error('Request timed out');
    } on HttpException {
      return ChatMessageResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatMessageResponse.error('Invalid response format');
    } catch (e, stack) {
      log('❗ Exception in sendChatMessage: $e', stackTrace: stack);
      return ChatMessageResponse.error(e.toString());
    }
  }

  Future<ChatListResponse> fetchMessages({required String customerId}) async {
    final Uri url =
        Uri.parse('$baseUrl/widgetapi/messages/allMessages/$customerId');
    final headers = {'app-id': appId};

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20)); // Optional: set timeout

      await getFCMToken();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatListResponse.fromJson(data);
      } else {
        return ChatListResponse.error(
            'HTTP error - status code ${response.statusCode}');
      }
    } on SocketException {
      return ChatListResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatListResponse.error('Request timed out');
    } on HttpException {
      return ChatListResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatListResponse.error('Invalid response format');
    } catch (e) {
      return ChatListResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  Future<bool> notificationToken(
      {required String token, required String userId}) async {
    final url = Uri.parse('$baseUrl/widgetapi/messages/updateFCM');
    final headers = {'app-id': appId};
    final body = {"customerId": userId, "fcmToken": token};

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } on HttpException {
      return false;
    } on FormatException {
      return false;
    } catch (e) {
      return false;
    }
  }
}
