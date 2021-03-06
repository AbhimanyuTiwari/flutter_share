import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/models/user.dart';

class Profile extends StatefulWidget {
  final profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId=currentUser?.id;
  @override
  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }
  editProfile(){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUserId:currentUserId)));
  }
  buildButton({String text,Function function}){
    return Container(
      padding: EdgeInsets.only(top:2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width:245 ,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),

        ),

      ),
    );
  }

  Widget buildProfileButton() {
    //if we are viewing our own profile
    bool isProfileOwner=currentUserId==widget.profileId;
    if(isProfileOwner){
      return buildButton(text: "Edit Profile",function: editProfile);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    radius: 40.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("post", 1),
                            buildCountColumn("Followers", 1),
                            buildCountColumn("Following", 1),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],

                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,

                  ),
                ),

              ),
              Container(
                alignment: Alignment.centerLeft,
                padding:EdgeInsets.only(top:4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight:FontWeight.bold
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding:EdgeInsets.only(top: 2.0) ,
                child: Text(
                  user.bio,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[buildProfileHeader()],
      ),
    );
  }
}
