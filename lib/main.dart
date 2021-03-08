import 'package:cricket_scorer/screens/customer_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomerList();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.data}',
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
