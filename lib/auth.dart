import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

String errorMessage;

class UserData {
  final String uid;

  UserData({this.uid});
}

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;

  UserData _userfromFirebase(FirebaseUser user) {
    return (user != null) ? UserData(uid: user.uid) : null;
  }

  Stream<UserData> get user {
    return _auth.onAuthStateChanged.map(_userfromFirebase);
  }

  Future<FirebaseUser> get currentUser async {
    final FirebaseUser user = await _auth.currentUser();
    return user == null ? null : user;
  }

  Future<UserData> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserData> signInWithGoogle() async {

    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        return _userfromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }
}
