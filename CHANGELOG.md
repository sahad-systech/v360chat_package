## 1.0.28
* Adding a message for out-of-office hours and supporting Arabic language for 'isInQueue'

## 1.0.27
* bug fixing receiving messages after reconnecting

## 1.0.23
* bug fixing in fetchMessages

## 1.0.20
* bug fixing creating chat session, make sure the firebase messaging token is set

## 1.0.19
* Update README, fixed bug in sendChatMessage()

## 1.0.17
* Update README

## 1.0.14
* Created a separate method for registering a chat session  
* Added local storage support for View360ChatPrefsModel  
* Included socket ID handling within the package itself  

## 1.0.13
* Added notificationToken() for push notifications

## 1.0.12
* update README

## 1.0.11
* Adding customerId to sendChatMessage() when sending a message from the chat list.

## 1.0.10
* Enhanced SocketManager with improved message handling using named parameters. Added null safety for optional file paths in received messages.

## 1.0.9
* Improves reliability by handling network and data parsing errors.
  Provides clear error responses to support user-friendly UI messages.

## 1.0.8
* Improved file upload validation and error handling in sendChatMessage()

## 1.0.7
* type added to socket
