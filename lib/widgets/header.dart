import 'package:flutter/material.dart';

AppBar header(context,{bool isApptitle=false,String titleText,bool removeBackButton=true })
{
  return AppBar(
    automaticallyImplyLeading: removeBackButton,
    title: Text(
      isApptitle?"Flutter Share":titleText,style: TextStyle(
      fontSize: isApptitle?50:22,
      color: Colors.white,
      fontFamily:isApptitle?"Signatra":"",
    ),
    ),
    backgroundColor: Theme.of(context).accentColor,
    centerTitle: true,
  );
}
