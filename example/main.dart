final socketManager = SocketManager();

socketManager.connect(
  baseUrl = 'https://yourdomain.com',
  onMessage = (content, files, response) {
    print('📩 New message: $content');
  },
);

final chatService = ChatService(
  baseUrl: 'yourdomain.com',
  appId: 'your-app-id',
);

// Send a message
final response = await chatService.sendChatMessage(
  chatContent: 'Hello from Flutter!',
  chatId: 'abc123',
  socketId: socketManager.socket.id!,
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '1234567890',
);

// Fetch message history
final history = await chatService.fetchMessages(customerId: 'abc123');

if (history.success) {
  print('💬 Chat History: ${history.messages}');
} else {
  print('❌ Error: ${history.error}');
}
