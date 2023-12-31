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

// State

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<ChatMessageModel> messages;

  ChatLoadedState(this.messages);
}

// Bloc

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Contact contact;

  ChatBloc(this.contact) : super(ChatInitialState()) {
    on<ChatLoading>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      try {
        final messages = await getMessages(userId, contact.id);
        emit(ChatLoadedState(messages));
      } catch (e) {
        print(e);
      }
    });
  }

  // Get messages
  Future<List<ChatMessageModel>> getMessages(String userId, String contactId) async {
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
      messages.addAll(sendedMessages.docs.map((e) => ChatMessageModel.fromDocument(e)));
      messages.addAll(receivedMessages.docs.map((e) => ChatMessageModel.fromDocument(e)));
      messages.sort((a, b) => a.date.compareTo(b.date));
      return messages;
    } catch (e) {
      print(e);
      return [];
    }
  }
}