import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/FeedbackModification/EditFeedback.dart';
import 'package:fidbak/Public/Loading.dart';
import 'package:fidbak/QRCode/Scanner.dart';
import 'package:fidbak/Services/AuthManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hamburger.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HamBurger hamBurger = new HamBurger();
  int section;
  Auth auth;
  bool isAdmin, isRoot;
  String email;
  String qrText;
  List departments;
  Stream<QuerySnapshot> feedbacks;

  // Initial logic starts
  @override
  void initState() {
    super.initState();
    auth = new Auth(context);
  }

  @override
  void deactivate() {
    // print('In deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    // print('in dispose');
    super.dispose();
  }

  Future<bool> getUserData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      email = _prefs.getString('email');
      isAdmin = _prefs.getBool('admin');
      isRoot = _prefs.getBool('root');
    });

    return isAdmin;
  }
  // Initial logic ends

  // UI code starts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(children: hamBurger.menu(context)),
      ),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return userContent();
          } else {
            return Loading();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'Scan',
          child: Icon(MdiIcons.qrcodeScan),
          backgroundColor: Colors.blue,
          onPressed: () async {
            await requestCamera();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Scanner()));
          },
          tooltip: 'QR Scanner'),
    );
  }

  userContent() {
    return StreamBuilder(
      stream: Firestore.instance
        .collection('/feedbacks')
        .where('host_id', isEqualTo: email)
        .where('status', isEqualTo: "open")
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text('No active feedbacks'),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) =>
                Divider(height: 1.0, color: Colors.grey),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot feedback = snapshot.data.documents[index];

              return ListTile(
                title: Text(feedback.data['name']),
                subtitle: Text('Host : ' + feedback.data['host']),
                trailing: Text(feedback.data['type'] ?? ""),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditFeedback(
                              feedback: feedback, isRoot: isRoot)));
                },
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Center(child: Text('No active feedbacks'));
        } else {
          return Loading();
        }
      },
    );
  }
  // UI code ends
  
  // Request camera permission upon clicking QR Scanner button
  requestCamera() async {
    if (Platform.isAndroid) {
      await Permission.camera.isUndetermined.then((status) async {
        await Permission.camera.request();
      });
      await Permission.camera.isDenied.then((status) async {
        await Permission.camera.request();
      });
    } else {
      await Permission.photos.isUndetermined.then((status) async {
        await Permission.photos.request();
      });
      await Permission.photos.isDenied.then((status) async {
        await Permission.photos.request();
      });
    }
  }
}
