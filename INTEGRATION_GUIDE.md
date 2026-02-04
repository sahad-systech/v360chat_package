# View360 Chat Integration Guide

**Version:** 1.0.32  
**Date:** February 2026

## Overview

The `view360_chat` package enables seamless integration of View360's real-time customer support chat into your Flutter applications. It provides a robust API for socket-based communication, file sharing, message history retrieval, and push notifications.

---

## 📋 Requirements

- **Flutter SDK**: >=1.17.0
- **Dart SDK**: ^3.6.0
- **Android**: API 21+
- **iOS**: iOS 11.0+

---

## 🛠 Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  view360_chat: ^1.0.32
  # Functionality dependencies
  firebase_messaging: ^16.0.4
  file_picker: ^8.0.0 # Recommended for file selection
```

Run the installation command:

```bash
flutter pub get
```

---

## ⚙️ Configuration

### Android Setup

No specific configuration is required beyond standard Flutter Android setup.

### iOS Setup (Push Notifications)

To enable push notifications on iOS, update your `ios/Runner/Info.plist` with the following permissions:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>

<key>NSUserTrackingUsageDescription</key>
<string>We need your permission to send notifications for chat updates.</string>
```

Additionally, ensure you have your Firebase project configured with `GoogleService-Info.plist`.

---

## 🚀 Usage Guide

### 1. Initialize & Connect Socket

The `SocketManager` handles real-time communication. You should establish a connection early in your chat view lifecycle.

```dart
import 'package:view360_chat/view360_chat.dart';

final socketManager = SocketManager();

void connectToChat() {
  socketManager.connect(
    baseUrl: 'https://your-view360-instance.com',
    onConnected: () {
      print('✅ Connected to View360 Chat Server');
    },
    onMessage: ({
      required content,
      required createdAt,
      required response,
      required senderType,
      filePaths,
    }) {
      print('📩 New Message Received: $content');
      // Trigger UI update here
    },
  );
}
```

### 2. Start a Chat Session

To begin a conversation, create a chat session. usage of `ChatService` handles the API calls.

```dart
final chatService = ChatService(
  baseUrl: 'https://your-view360-instance.com',
  appId: 'YOUR_APP_ID',
);

Future<void> startSession() async {
  final response = await chatService.createChatSession(
    chatContent: 'Hello, I need assistance.',
    customerName: 'Customer Name',
    customerEmail: 'customer@example.com',
    customerPhone: '1234567890',
    languageInstance: 'en', // Optional: defaults to 'en'
  );

  if (response.success) {
    print('✅ Session Started: ${response.chatId}');
  } else {
    print('❌ Error: ${response.error}');
  }
}
```

### 3. Send Messages

You can send text messages and optionally attach files (images, PDFs, etc.).

```dart
Future<void> sendMessage(String text, [List<String>? newFilePaths]) async {
  final result = await chatService.sendChatMessage(
    chatContent: text,
    filePath: newFilePaths, // Optional list of local file paths
  );

  if (result.success) {
    print('✅ Message Sent');
  } else {
    print('❌ Failed to send: ${result.error}');
  }
}
```

**Supported File Types:**
- Images: `.jpg`, `.jpeg`, `.png`, `.gif`
- Documents: `.pdf`, `.csv`, `.xlsx`
- Video: `.mp4`

### 4. Fetch Message History

Retrieve previous conversation history when the user opens the chat screen.

```dart
Future<void> loadHistory() async {
  final history = await chatService.fetchMessages();

  if (history.success) {
    print('📜 History loaded with ${history.messages?.length} messages');
    // Update your message list
  } else {
    print('❌ Failed to load history: ${history.error}');
  }
}
```

---

## 🧩 API Reference

### `SocketManager`

| Method | Description |
| :--- | :--- |
| `connect({baseUrl, onMessage, onConnected})` | Establishes a socket connection to the chat server. |
| `disconnect()` | Disconnects the socket and clears listeners. |

### `ChatService`

| Method | Description |
| :--- | :--- |
| `createChatSession(...)` | Registers a new chat session with customer details. |
| `sendChatMessage(...)` | Sends a text message with optional file attachments. |
| `fetchMessages()` | Retrieves the chat history for the current session. |

---

## ❓ Troubleshooting

**Q: Socket connects but no messages are received?**  
A: Ensure your `baseUrl` is correct and explicitly uses `https`. Also check if the `appId` matches your configuration.

**Q: File uploads failing?**  
A: Verify that the file extensions are supported (e.g., .jpg, .pdf) and that the file paths are valid absolute paths on the device.

**Q: Push notifications not working?**  
A: Ensure you have called `FirebaseMessaging.instance.requestPermission()` in your app and that the `firebase_messaging` plugin is properly configured in your project settings.
