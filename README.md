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

Inside the `onMessage` callback:
- `content`: Message from the agent.
- `createdAt`: Timestamp of the message.
- `senderType`: Sender info (always the agent).
- `filePaths`: Any file attachments from the agent.

### Example

```dart
import 'package:view360_chat/view360_chat.dart';

final socketManager = SocketManager();

socketManager.connect(
  baseUrl: 'https://yourdomain.com',
  onMessage: ({
    required content,
    required createdAt,
    required response,
    required senderType,
    filePaths,
  }) {
    print('📩 New message: \$content');
  },
);


```
## ✉️ Create Chat Session

The `createChatSession` function is used to initiate a new chat session. During registration, you must provide either the `customerPhone` or the `customerEmail`. You may also provide both if available.

If no agent is currently available, the `success` status will still be `true`, and the `isInQueue` flag will be set to `true`.

# Example

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
  filePath: [], // optional
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
  print('💬 Chat History: \${history.messages}');
} else {
  print('❌ Error: \${history.error}');
}
```

## 📲 Push Notifications on iOS

To enable push notifications on iOS, the app must request notification permission from the user. Without this, Firebase Cloud Messaging (FCM) won't work. You need to call `requestPermission()` to prompt the user for permission.

### Steps to Request Notification Permission on iOS

1. **Add Permission Descriptions in `Info.plist`:**  
   First, make sure to add the following entries in your `Info.plist` file:

   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>fetch</string>
     <string>remote-notification</string>
   </array>
   <key>UIUserTrackingUsageDescription</key>
   <string>Your description of why you need to track the user.</string>


