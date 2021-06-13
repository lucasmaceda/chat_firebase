import 'package:chat_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage(String text) {
    FirebaseFirestore.instance.collection("messages").add({'text': text});
  }

  @override
  Widget build(BuildContext context) {
    return TextComposer(_sendMessage);
  }
}
