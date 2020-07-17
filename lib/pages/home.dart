import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/auth.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:provider/provider.dart';

final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;
final StorageReference storageRef = FirebaseStorage.instance.ref();
final CollectionReference postRef = Firestore.instance.collection("post");

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthServices auth = AuthServices();
  bool isCheck = false;
  PageController pageController;
  int pageIndex = 0;
  bool loading = false;
  bool isUserDataExist = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    createUserInFirestore();
  }

  createUserInFirestore() async {
    try{
      FirebaseUser user = await AuthServices().currentUser;
      // 1) check if user exists in users collection in database (according to their id)
      DocumentSnapshot doc = await usersRef.document(user.uid).get();

      // 2) if the user doesn't exist, then we want to take them to the create account page
      if (!doc.exists) {
        final username = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateAccount()));

        // 3) get username from create account, use it to make new user document in users collection
        usersRef.document(user.uid).setData({
          "id": user.uid,
          "username": username,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": timestamp
        });

        doc = await usersRef.document(user.uid).get();
      }
      currentUser = User.fromDocument(doc);

      setState(() {
        isUserDataExist = true;
      });
    }catch(e){
      print(e.toString());
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        loading = true;
      });
      await auth.signInWithGoogle();
      await createUserInFirestore();
    } catch (e) {
      print(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  logout() {
    auth.signOut();
    setState(() {
      loading = false;
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // Timeline(),
          RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId:currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen(UserData user) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            loading || user != null
                ? circularProgress()
                : GestureDetector(
                    onTap: _signInWithGoogle,
                    child: Container(
                      width: 260.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/google_signin_button.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserData user = Provider.of<UserData>(context);
    if (user != null && isUserDataExist) {
      return buildAuthScreen();
    } else {
      return buildUnAuthScreen(user);
    }
  }
}
