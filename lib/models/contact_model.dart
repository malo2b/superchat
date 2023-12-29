

import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String id;
  String username;

  Contact({required this.id, required this.username});

  factory Contact.fromDocument(DocumentSnapshot doc) {
    return Contact(
      id: doc['id'],
      username: doc['displayName'],
    );
  }

}
