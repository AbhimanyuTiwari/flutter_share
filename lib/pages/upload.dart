import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  bool isLoadingLocation=false;


  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      file = File(pickedFile.path);
    });
  }

  hnadelFromGallery() async {
    Navigator.pop(context);
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Images in Galary"),
                onPressed: hnadelFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme
          .of(context)
          .accentColor
          .withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                "Upload",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 80));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$postId").putFile(imageFile);
    StorageTaskSnapshot storagesnap = await uploadTask.onComplete;
    String downloadUrl = await storagesnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String discription}) {
    postRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "description": discription,
      "location": location,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        discription: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white54,
        leading: IconButton(
          onPressed: clearImage,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Caption the post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Post",
              style: TextStyle(color: Colors.blueAccent),
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? LinearProgressIndicator() : Text(''),
          Container(
            height: 220.0,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(file),
                      )),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
              CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: captionController,
              decoration: InputDecoration(hintText: "Write Something...."),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.location_on,
              color: Colors.deepOrange,
              size: 33,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: isLoadingLocation?CircularProgressIndicator():RaisedButton.icon(
              onPressed: () => getUserLocation(),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                "Use Current location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blueAccent,
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    setState(() {
      isLoadingLocation=true;
    });
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.subThoroughfare}, ${placemark
        .thoroughfare},${placemark.subLocality}, ${placemark.locality}, ${placemark
        .subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark
        .postalCode}, ${placemark.country}';
    print(completeAddress);
    String formatAddress="${placemark.locality}, ${placemark.administrativeArea}";
    locationController.text=formatAddress;
    setState(() {
      isLoadingLocation=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
