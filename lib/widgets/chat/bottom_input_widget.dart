import 'package:flutter/material.dart';
import 'package:superchat/bloc/chat_bloc.dart';

class BottomInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final ChatBloc chatBloc;

  BottomInputWidget({super.key, required this.chatBloc}) : textEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = textEditingController.text.trim();
              if (message.isNotEmpty) {
                textEditingController.clear();
                // Send event to bloc
                chatBloc.add(ChatMessageSent(message));
              }
            },
          ),
        ],
      ),
    );
  }
}
