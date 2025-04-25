import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../helper/function.dart';
import '../model/chat_list_response.dart';
import '../model/chat_response.dart';

class ChatService {
  final String baseUrl;
  final String appId;

  ChatService({required this.baseUrl, required this.appId});

  Future<ChatMessageResponse> sendChatMessagee({
    List<String>? filePath,
    required String chatContent,
    required String chatId,
    required String socketId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final String updatedBaseUrl = baseUrl.replaceAll('https://', '');

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

      final request = http.MultipartRequest('POST', uri)
        ..headers['app-id'] = appId
        ..fields.addAll({
          'content': chatContent,
          'ChatId': chatId,
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'senderType': 'customer',
          'socketId': socketId,
          'status': 'pending',
          'createdAt': DateTime.now().toString(),
          'customerInfo[name]': customerName,
          'customerInfo[email]': customerEmail,
          'customerInfo[mobile]': customerPhone,
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
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatListResponse.fromJson(data);
      } else {
        return ChatListResponse.error(
            'HTTP error - status code ${response.statusCode}');
      }
    } catch (e) {
      return ChatListResponse.error('Exception: ${e.toString()}');
    }
  }
}
