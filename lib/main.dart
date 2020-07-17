import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
        value: AuthServices().user,
        child: MaterialApp(
          title: 'FlutterShare',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            accentColor: Colors.teal,
            primarySwatch: Colors.deepPurple,
          ),
          home: Home(),
        ));
  }
}
