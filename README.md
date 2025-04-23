<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# view360_chat

A Flutter package that enables seamless integration of **View360 chat** functionality through real-time socket connection and messaging APIs. This package is ideal for apps that need a customer chat widget with features like file sharing, message delivery, and live socket-based communication.

---

## 🧩 Features

- 🔌 **Socket connection** to View360's chat server.
- 💬 **Send customer messages** with optional file attachments.
- 📥 **Fetch all messages** in a chat conversation.
- 🧾 Built-in support for customer info (name, email, phone).
- 🔧 Easy to configure with your base URL and app ID.

---

## 💻 Full Example

```dart
import 'package:view360_chat_connector/view360_chat.dart';

void main() async {
  final socketManager = SocketManager();

  socketManager.connect(
    baseUrl: 'https://yourdomain.com',
    onMessage: (content, files, response) {
      print('📩 New message: $content');
    },
  );

  final chatService = ChatService(
    baseUrl: 'yourdomain.com',
    appId: 'your-app-id',
  );

  final response = await chatService.sendChatMessage(
    chatContent: 'Hello from Flutter!',
    chatId: 'abc123',
    socketId: socketManager.socket.id!,
    customerName: 'John Doe',
    customerEmail: 'john@example.com',
    customerPhone: '1234567890',
  );

  final history = await chatService.fetchMessages(customerId: 'abc123');

  if (history.success) {
    print('💬 Chat History: ${history.messages}');
  } else {
    print('❌ Error: ${history.error}');
  }
}





