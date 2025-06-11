import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../helper/function.dart';
import '../local/local_storage.dart';
import '../model/chat_list_response.dart';
import '../model/chat_response.dart';
import '../model/sending_response.dart';
import '../model/storage_pre_model.dart';
import '../socket/socket_managet.dart';

class ChatService {
  final String baseUrl;
  final String appId;

  ChatService({required this.baseUrl, required this.appId});

  socketEmitIsWorking(String customerId) {
    SocketManager().socket.emit("joinRoom", "customer-$customerId");
  }

  Future<ChateRegisterResponse> createChatSession({
    required String chatContent,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? languageInstance,
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
          'lang': languageInstance ?? 'en',
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
        final bool isQuieue = json['is_queue'] ?? false;
        final contentId = json['chatId']?.toString();
        final customerId = json['customerId']?.toString();
        socketEmitIsWorking(customerId ?? '');
        await View360ChatPrefs.saveString(
            isInQueueValue: isQuieue,
            customerCondentIdValue: contentId ?? '',
            chatIdKeyValue: chatId,
            customerIdKeyValue: !topLevelStatus ||
                    contentStatus == false ||
                    contentStatus == 'false'
                ? json['customerId']?.toString() ?? ''
                : customerId ?? '',
            customerNameKeyValue: customerName,
            customerEmailKeyValue: customerEmail ?? '',
            customerPhoneKeyValue: customerPhone ?? '');
        getFCMToken(
            userId: customerId.toString(), baseUrl: baseUrl, appId: appId);

        return ChateRegisterResponse.fromJson(json);
      } else {
        return ChateRegisterResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChateRegisterResponse.error('No Internet connection');
    } on TimeoutException {
      return ChateRegisterResponse.error('Request timed out');
    } on HttpException {
      return ChateRegisterResponse.error('HTTP error occurred');
    } on FormatException {
      return ChateRegisterResponse.error('Invalid response format');
    } catch (e) {
      debugPrint('Exception in createChatSession: $e');
      return ChateRegisterResponse.error(e.toString());
    }
  }

  Future<ChatSentResponse> sendChatMessage({
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
        ..headers['app-id'] = appId;
      request.fields.addAll({
        'ChatId': localstorage.chatId,
        'content': chatContent,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'customerInfo[name]': localstorage.customerName,
        'customerInfo[mobile]': localstorage.customerPhone,
        'customerInfo[email]': localstorage.customerEmail,
        'messageId': '${DateTime.now().millisecondsSinceEpoch}',
        'senderType': 'customer',
        'socketId': socketId,
        'status': 'pending',
      });
      if (filePath != null && filePath.isNotEmpty) {
        for (var file in filePath) {
          String ext = '.${file.split('.').last.toLowerCase()}';
          if (!allowedExtensions.contains(ext)) {
            return ChatSentResponse.error('Unsupported file extension: $ext');
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
        return ChatSentResponse.fromJson(json);
      } else {
        return ChatSentResponse.error(
          'Failed with status ${response.statusCode}: $responseString',
        );
      }
    } on SocketException {
      return ChatSentResponse.error('No Internet connection');
    } on TimeoutException {
      return ChatSentResponse.error('Request timed out');
    } on HttpException {
      return ChatSentResponse.error('HTTP error occurred');
    } on FormatException {
      return ChatSentResponse.error('Invalid response format');
    } catch (e, stack) {
      log('❗ Exception in sendChatMessage: $e', stackTrace: stack);
      return ChatSentResponse.error(e.toString());
    }
  }

  Future<ChatListResponse> fetchMessages() async {
    final View360ChatPrefsModel localstorage =
        await View360ChatPrefs.getString();
    final String contentId = localstorage.customerContentId;
    final bool isInQueue = localstorage.isInQueue;
    Uri url;
    if (isInQueue) {
      final String customerId = localstorage.customerId;
      final String chatId = localstorage.chatId;
      url = Uri.parse(
          '$baseUrl/widgetapi/messages/chatQueueMessages?customerId=$customerId&channelChatId=$chatId');
    } else {
      url = Uri.parse('$baseUrl/widgetapi/messages/allMessages/$contentId');
    }
    final headers = {'app-id': appId};

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20)); // Optional: set timeout

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

  Future<void> notificationToken(
      {required String token, required String userId}) async {
    try {
      var headers = {'app-id': appId, 'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('$baseUrl/widgetapi/messages/updateFCM'));
      request.body = jsonEncode({"customerId": userId, "fcmToken": token});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("FCM token updated successfully");
      } else {
        // final errorBody = await response.stream.bytesToString();
        debugPrint('Failed to update FCM token');
      }
    } catch (e) {
      debugPrint('Failed to updating FCM token');
    }
  }
}
