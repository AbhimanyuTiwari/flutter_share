//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final CollectionReference userRef=Firestore.instance.collection("users");
  @override

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isApptitle:true),
      body:Text('Dhushi')
    );
  }
}
