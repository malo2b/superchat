import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/contact_model.dart';
import '../widgets/chat/bottom_input_widget.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatelessWidget {
  final Contact contact;

  const ChatPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(contact)..add(ChatLoading()),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoadedState) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Chat with ${contact.username}'),
                ),
                body: Column(
                  children: [
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return ListTile(
                            title: Text(message.message), subtitle: Text(message.date.toDate().toString()),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    BottomInputWidget(chatBloc: context.read<ChatBloc>()),
                  ],
                ));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
