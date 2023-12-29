import 'package:flutter/material.dart';

import '../models/contact_model.dart';

class ChatPage extends StatelessWidget {
  final Contact contact;

  const ChatPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${contact.username}'), // Affiche le nom du contact
      ),
    );
  }
}
