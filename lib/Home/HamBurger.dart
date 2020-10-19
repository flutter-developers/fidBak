import 'package:fidbak/Services/AuthManagement.dart';
import 'package:fidbak/UserManagement/ManageAdmins.dart';
import 'package:fidbak/UserManagement/ManageRoot.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HamBurger {
  Auth auth;
  bool isAdmin;
  SharedPreferences _prefs;

  List<Widget> menu(BuildContext context, String email) {
    auth = new Auth(context);
    return <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('Logged in as'),
        accountEmail: Text(email),
        currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
            child: Text(email == '...' ? 'A' : email[0].toUpperCase(),
                style: TextStyle(fontSize: 40))),
      ),
      ListTile(
        title: Text('Create feedback'),
        onTap: () async {
          // Allow access only if the current user is admin
          _prefs = await SharedPreferences.getInstance();
          isAdmin = _prefs.getBool("admin");
          if (isAdmin) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/nameFeedback');
          } else {
            Fluttertoast.showToast(msg: "Permission denied!");
          }
        },
      ),
      ListTile(
        title: Text('Closed feedbacks'),
        onTap: () {
          // Public page, anyone can access
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/closedFeedback');
        },
      ),
      ListTile(
        title: Text('All feedbacks'),
        onTap: () async {
          // Allow access only to root user aka Department managers
          _prefs = await SharedPreferences.getInstance();
          bool isroot = _prefs.getBool("root");
          if (isroot) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/allFeedbacks');
          } else {
            Fluttertoast.showToast(msg: 'This page is only for managers');
          }
        },
      ),
      ListTile(
        title: Text('Manage admins'),
        onTap: () {
          // Public page, anyone can access
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ManageAdmins()));
        },
      ),
      ListTile(
        title: Text('Department managers'),
        onTap: () {
          // Public page, anyone can access
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ManageRoot()));
        },
      ),
      ListTile(
          title: Text('Logout'),
          onTap: () {
            auth.signOut();
          })
    ];
  }
}
