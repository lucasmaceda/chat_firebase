import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var fsconnect = FirebaseFirestore.instance;

  myget() async {
    var d = await fsconnect.collection("students").get();
    // print(d.docs[0].data());

    for (var i in d.docs) {
      print(i.data());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Firebase Firestore App'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text('send data'),
            onPressed: () {
              // fsconnect.collection("students").add({
              //   'name': 'sarah',
              //   'title': 'xyz',
              //   'email': 'sarah@gmail.com',
              // });
              fsconnect
                  .collection("col")
                  .doc("doc")
                  .set({"texto": "pumba la pumba"});

              print("send ..");
            },
          ),
          ElevatedButton(
            child: Text('get data'),
            onPressed: () {
              myget();
              print("get data ...");
            },
          )
        ],
      ),
    ));
  }
}
