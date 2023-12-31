import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/contact_model.dart';
import '../models/message_model.dart';

// Event

abstract class ChatEvent {}

// When chat is loading
class ChatLoading extends ChatEvent {}

// When chat is loaded
class ChatLoaded extends ChatEvent {}

// When a message is received
class ChatMessageReceived extends ChatEvent {
  final ChatMessageModel message;

  ChatMessageReceived(this.message);
}

// When a message is sent
class ChatMessageSent extends ChatEvent {
  final String message;

  ChatMessageSent(this.message);
}

// State

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<ChatMessageModel> messages;

  ChatLoadedState(this.messages);
}

// Bloc

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ContactModel contact;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  ChatBloc(this.contact) : super(ChatInitialState()) {
    // When chat is loading
    on<ChatLoading>((event, emit) async {
      try {
        final messages = await getMessages(userId, contact.id);
        emit(ChatLoadedState(messages));
        add(ChatLoaded());
      } catch (e) {
        print(e);
      }
    });

    // When chat is loaded
    on<ChatLoaded>((event, emit) async {
      try {
        print('Chat loaded');
        // Setup an asynchronous listener to listen for new messages sended and recieved in real time
        // FirebaseFirestore.instance
        //     .collection('messages')
        //     .where('from', isEqualTo: userId)
        //     .where('to', isEqualTo: contact.id)
        //     .where('timestamp', isGreaterThan: DateTime.now())
        //     .snapshots()
        //     .listen((event) {
        //   for (var doc in event.docs) {
        //     add(ChatMessageReceived(ChatMessageModel.fromDocument(doc)));
        //   }
        // });
      } catch (e) {
        print(e);
      }
    });

    // When a message is sent
    on<ChatMessageSent>((event, emit) async {
      try {
        await sendMessage(event.message);
      } catch (e) {
        print(e);
      }
    });
  }

  // Get messages
  Future<List<ChatMessageModel>> getMessages(
      String userId, String contactId) async {
    try {
      var sendedMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('from', isEqualTo: userId)
          .where('to', isEqualTo: contactId)
          .get();
      var receivedMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('from', isEqualTo: contactId)
          .where('to', isEqualTo: userId)
          .get();
      var messages = <ChatMessageModel>[];
      messages.addAll(
          sendedMessages.docs.map((e) => ChatMessageModel.fromDocument(e)));
      messages.addAll(
          receivedMessages.docs.map((e) => ChatMessageModel.fromDocument(e)));
      // Sort messages by date reverse
      messages.sort((a, b) => b.date.compareTo(a.date));
      return messages;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Send message
  Future<void> sendMessage(String message) async {
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'from': userId,
        'to': contact.id,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }
}
