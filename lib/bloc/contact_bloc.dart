
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/contact_model.dart';

// Event
abstract class ContactEvent {}

class ContactLoaded extends ContactEvent {}

// State

abstract class ContactState {}

class ContactInitialState extends ContactState {}

class ContactsLoadedState extends ContactState {
  final List<ContactModel> contacts;

  ContactsLoadedState(this.contacts);
}



// Bloc
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitialState()) {
    on<ContactLoaded>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      try {
        final contacts = await getContacts(userId);
        emit(ContactsLoadedState(contacts));
      } catch (e) {
        print(e);
      }
    });
  }

  Future<List<ContactModel>> getContacts(String userId) async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isNotEqualTo: userId)
        .get();
    return data.docs.map((e) => ContactModel.fromDocument(e)).toList();
  }
}