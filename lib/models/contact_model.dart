

import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String id;
  String username;

  ContactModel({required this.id, required this.username});

  factory ContactModel.fromDocument(DocumentSnapshot doc) {
    return ContactModel(
      id: doc['id'],
      username: doc['displayName'],
    );
  }

}
