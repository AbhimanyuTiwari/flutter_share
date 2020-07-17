import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String id;
  final String photoUrl;
  final String email;
  final String displayName;
  final String bio;
  User({this.email,this.bio,this.displayName,this.id,this.photoUrl,this.username});
  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      username: doc['username'],
      id:doc['id'],
      photoUrl: doc['photoUrl'],
      email: doc['email'],
      displayName: doc["displayName"],
      bio: doc["bio"],
    );
  }

}
