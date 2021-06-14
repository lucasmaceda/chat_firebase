import 'dart:io';

import 'package:chat_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User _currentUser;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  _sendMessage({String text, File imgFile}) async {
    final User user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possivel fazer o login, tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      File file = imgFile;

      TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child(DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(file);

      setState(() {
        _isLoading = true;
      });

      String url = await task.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null
              ? 'Olá, ${_currentUser.displayName}'
              : 'Chat App',
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().signOut();
                    SnackBar(content: Text("Você saiu com sucesso."));
                  },
                )
              : Container(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.docs.reversed.toList();

                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          documents[index]['text'],
                          documents[index]['uid'] == _currentUser?.uid,
                        );
                      },
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
