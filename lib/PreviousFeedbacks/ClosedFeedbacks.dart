import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/Public/Loading.dart';
import 'package:fidbak/Services/AuthManagement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ClosedFeedbacks extends StatefulWidget {
  @override
  _ClosedFeedbacksState createState() => _ClosedFeedbacksState();
}

class _ClosedFeedbacksState extends State<ClosedFeedbacks> {
  int section;
  Auth auth;
  bool isAdmin;
  String email;
  Stream<QuerySnapshot> feedbacks;
  SharedPreferences _prefs;

  // Initial logic starts
  instantiate() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool("admin")) {
      setState(() {
        isAdmin = true;
      });
    } else {
      setState(() {
        isAdmin = false;
      });
    }
    email = _prefs.getString("email");
  }

  @override
  void initState() {
    super.initState();
    auth = new Auth(context);
    instantiate();
  }

  Future<bool> getUserData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      email = _prefs.getString('email');
      isAdmin = _prefs.getBool('admin');
    });

    return isAdmin;
  }
  // Initial logic ends

  // UI code starts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Closed feedbacks'),
      ),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return closedList();
          } else {
            return Loading();
          }
        },
      ),
    );
  }

  closedList() {
    return StreamBuilder(
      // Fetch all the *closed* feedbacks hosted by the *current user* 
      stream: Firestore.instance
          .collection('/feedbacks')
          .where('host_id', isEqualTo: email)
          .where('status', isEqualTo: "close")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) return emptyContent();
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
                onTap: () {},
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return emptyContent();
        } else {
          return Loading();
        }
      },
    );
  }

  emptyContent() {
    return Center(
      child: Text('No feedbacks hosted'),
    );
  }
  // UI code ends
}
