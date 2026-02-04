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

# 📦 view360_chat

`view360_chat` is a Flutter package designed for seamless integration of **View360's real-time chat system** into your applications.  
It enables customer support chat functionality with features like live socket communication, file sharing, and message delivery tracking — ideal for apps requiring responsive customer interaction.

---

## 🧩 Features

- 🔌 **Real-time Socket Connection** — Instantly connect to View360’s chat server.
- 💬 **Send Messages** — Send messages with optional file attachments.
- 📥 **Retrieve Chat History** — Access the full conversation history.
- 🧾 **Customer Information Handling** — Easily pass customer name, email, and phone number.
- ⚙️ **Simple Setup** — Configure quickly with your base URL and App ID.
- 📲 **Push Notifications** — Receive notifications directly from View360.

---

## 🛠️ Connecting the Socket

First, connect the socket to start receiving messages from the agent side.  


### Parameters:
- `baseUrl`:  View360 server URL.
- `onMessage`: Callback triggered when a message is received from the agent.
- `onConnected`: (Optional) Callback triggered when the socket connection is successfully established.

Inside the `onMessage` callback:
- `content`: Message from the agent.
- `createdAt`: Timestamp of the message.
- `senderType`: Sender info (always the agent).
- `filePaths`: Any file attachments from the agent.
- `response`: Full JSON response object.

### Example

```dart
import 'package:view360_chat/view360_chat.dart';

final socketManager = SocketManager();

socketManager.connect(
  baseUrl: 'https://yourdomain.com',
  onConnected: () {
    print('✅ Socket connected!');
  },
  onMessage: ({
    required content,
    required createdAt,
    required response,
    required senderType,
    filePaths,
  }) {
    print('📩 New message: $content');
  },
);
```

## ✉️ Create Chat Session

The `createChatSession` function is used to initiate a new chat session. During registration, you must provide either the `customerPhone` or the `customerEmail`. You may also provide both if available.

This method also automatically retrieves and updates the Firebase Cloud Messaging (FCM) token for push notifications if Firebase is configured in your app.

### Parameters
- `chatContent`: Initial message content.
- `customerName`: Name of the customer.
- `customerEmail`: (Optional) Email of the customer.
- `customerPhone`: (Optional) Phone number of the customer.
- `languageInstance`: (Optional) Language code (default is 'en').

If no agent is currently available, the `success` status will still be `true`, and the `isInQueue` flag will be set to `true`.

### Example

```dart
import 'package:view360_chat/view360_chat.dart';

final chatService = ChatService(
  baseUrl: 'https://yourdomain.com',
  appId: 'your-app-id',
);

final response = await chatService.createChatSession(
  chatContent: 'Hello from View360!',
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '1234567890',
  languageInstance: 'en', // Optional, defaults to 'en'
);

if (response.success) {
  print('✅ Chat session created successfully');
} else {
  print('❌ Failed to create chat session: ${response.error}');
}
```

## ✉️ Sending Messages

The `sendChatMessage` function is used to send messages to the agent.

After sending a message:
- A `success` response indicates that the message was sent successfully.

```dart
import 'package:view360_chat/view360_chat.dart';

final response = await chatService.sendChatMessage(
  filePath: [], // optional list of file paths
  chatContent: 'Hello from View360!',
);
```

### 📎 Supported File Attachments

You can optionally attach files while sending a message. The following file types are supported:

- **Images**: `.jpg`, `.jpeg`, `.png`, `.gif`
- **Documents**: `.pdf`, `.xlsx`, `.csv`
- **Videos**: `.mp4`

> ✅ Ensure that the file path(s) you pass in `filePath` end with one of the supported extensions.

## 📜 Fetching Message History

The `fetchMessages` function is used to retrieve the current list of chat messages.

### Example

```dart
import 'package:view360_chat/view360_chat.dart';

final history = await chatService.fetchMessages();

if (history.success) {
  print('💬 Chat History: ${history.messages}');
} else {
  print('❌ Error: ${history.error}');
}
```

## 📲 Push Notifications

`view360_chat` uses `firebase_messaging` to handle push notifications. Ensure you have configured Firebase in your Flutter project (adding `google-services.json` for Android and `GoogleService-Info.plist` for iOS).

### iOS Configuration

To enable push notifications on iOS, the app must request notification permission from the user.

1. **Add Permission Descriptions in `Info.plist`:**  
   Add the following entries to your `ios/Runner/Info.plist` file:

   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>fetch</string>
     <string>remote-notification</string>
   </array>
   <key>NSUserTrackingUsageDescription</key>
   <string>We need your permission to send notifications for chat updates.</string>
   ```

2. **Request Permission:**
   You should request permission using `firebase_messaging` in your app logic:

   ```dart
   import 'package:firebase_messaging/firebase_messaging.dart';

   FirebaseMessaging messaging = FirebaseMessaging.instance;
   NotificationSettings settings = await messaging.requestPermission(
     alert: true,
     badge: true,
     sound: true,
   );
   ```


