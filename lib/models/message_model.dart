

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String from;
  final String to;
  final String message;
  final Timestamp date;

  ChatMessageModel({
    required this.from,
    required this.to,
    required this.message,
    required this.date,
  });

}
