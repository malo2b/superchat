import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/contact_model.dart';
import '../models/message_model.dart';

// Event

abstract class ChatEvent {}

// When chat is loading
class ChatLoading extends ChatEvent {}

// When chat is loaded
class ChatLoaded extends ChatEvent {}

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

  StreamSubscription? messagesSubscription;

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

    // When a message is sent
    on<ChatMessageSent>((event, emit) async {
      try {
        await sendMessage(event.message);
      } catch (e) {
        print(e);
      }
    });

    // When chat is loaded
    on<ChatLoaded>((event, emit) async {
      print('Chat loaded');
    });
    // messagesSubscription = getStreamedMessages(userId, contact.id).listen((messages) {
    //   if (messages != null) {
    //     // ignore: invalid_use_of_visible_for_testing_member
    //     emit(ChatLoadedState(messages as List<ChatMessageModel>));
    //   }
    // });
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
      messages.sort((a, b) => a.date.compareTo(b.date));
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

  // Recieve messages from stream
  // NOTE: Need to be optimized to only get the last message and send event
  Stream<List<ChatMessageModel?>> getStreamedMessages(
      String userId, String contactId) async* {
    var sendedMessages = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: userId)
        .where('to', isEqualTo: contactId)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => ChatMessageModel.fromDocument(e)).toList());
    var receivedMessages = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: contactId)
        .where('to', isEqualTo: userId)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => ChatMessageModel.fromDocument(e)).toList());

    var mergedMessages = Rx.merge([sendedMessages, receivedMessages]);

    yield* mergedMessages.map((messages) {
      messages.sort((a, b) => a.date.compareTo(b.date));
      return messages;
    });

  }
}
