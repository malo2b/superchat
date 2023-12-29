import 'package:flutter/material.dart';

class BottomInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final void Function(String) onSendPressed;

  const BottomInputWidget({
    Key? key,
    required this.textEditingController,
    required this.onSendPressed,
  }) : super(key: key);

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
                onSendPressed(message);
                textEditingController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
