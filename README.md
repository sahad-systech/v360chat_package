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

`view360_chat` is a Flutter package designed for seamless integration of **View360's real-time chat system** into your applications.  
It enables customer support chat functionality with features like live socket communication, file sharing, and message delivery tracking — ideal for apps requiring a responsive customer interaction experience.

---

## 🧩 Features

- 🔌 **Real-time Socket Connection** — Connect instantly to View360’s chat server.
- 💬 **Send Messages** — Deliver customer messages with optional file attachments.
- 📥 **Retrieve Chat History** — Fetch all previous messages in a conversation.
- 🧾 **Customer Information Support** — Easily handle customer name, email, and phone number.
- ⚙️ **Simple Setup** — Quick and easy configuration with your base URL and App ID.

---

## 🛠️ Connecting the Socket

First, you need to connect the socket. This is used to receive messages from the agent side.  
You can do this during the chat registration page, which helps you obtain `socketManager.socket.id` that is required for sending messages using `sendChatMessage()` for the first time.  
You also need to provide the `baseUrl`.  

In the `onMessage` callback:
- `content` refers to the message sent by the agent,
- `createdAt` indicates when the message was created,
- `senderType` always refers to the agent,
- `filePaths` contains any files sent by the agent.

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
    print('📩 New message: $content');
  },
);

```
## ✉️ Sending Messages

The `sendChatMessage` function is used to send messages to the agent.  
This is the same function used during the initial chat registration process.

During chat registration:
- You do **not** need to pass `filePath` and `customerId`.
- Make sure that the `chatId` is **unique**. This same `chatId` must be used when sending messages to the agent afterward.
- When getting the `socketId`, always fetch it **directly from** `socketManager.socket.id`, because there is a chance that the `socketId` can change while chatting.

When sending a message from the chat list:
- Make sure to provide the `customerId`.

After registering:
- If an agent is available, you will receive the `customerId` and the `status` will be `true`.
- If no agent is available, the `success` status will still be `true`, and `isInQueue` will be `true`. You can still access the `customerId` in this case.

After sending a message to the agent:
- You will get a `success` response if the message was sent successfully.

```dart
import 'package:view360_chat/view360_chat.dart';

final chatService = ChatService(
  baseUrl: 'yourdomain.com',
  appId: 'your-app-id',
);

final response = await chatService.sendChatMessage(
  filePath: [], // optional
  customerId,   // optional
  chatContent: 'Hello from View360!',
  chatId: 'abc123', // make it unique
  socketId: socketManager.socket.id!,
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '1234567890',
);

```
## 📜 Fetching Message History

The `fetchMessages` function is used to fetch the current list of chat messages.  
You need to provide the `customerId` to retrieve the conversation history.

```dart
import 'package:view360_chat/view360_chat.dart';

final history = await chatService.fetchMessages(customerId: '1234');

if (history.success) {
  print('💬 Chat History: ${history.messages}');
} else {
  print('❌ Error: ${history.error}');
}
```

## 🔔 Update FCM Token

```dart
final chatService = ChatService(
  baseUrl: 'https://your-api-url.com',
  appId: 'your-app-id',
);

void updateFcmToken() async {
  final success = await chatService.notificationToken(
    token: 'your-device-fcm-token',
    userId: 'customer-id-123',
  );

  if (success) {
    print('✅ FCM token updated successfully');
  } else {
    print('❌ Failed to update FCM token');
  }
}

```
### 📌 Description

- **Purpose**: Sends the current FCM token to your server to ensure the user can receive push notifications.
- **When to Use**: After login or whenever the FCM token changes.
- **Returns**: A `bool` indicating whether the update was successful.
- **Error Handling**: Manages common network and response-related exceptions gracefully.

