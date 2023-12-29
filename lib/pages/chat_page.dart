import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import '../widgets/chat/bottom_input_widget.dart';

class ChatPage extends StatelessWidget {
  final Contact contact;

  const ChatPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${contact.username}'), // Affiche le nom du contact
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message $index'),
                );
              },
            ),
          ),
          const Divider(height: 1),
          BottomInputWidget(
            textEditingController: TextEditingController(),
            onSendPressed: (message) {},
          ),
        ],
      )
    );
  }
}
