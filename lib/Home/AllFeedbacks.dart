import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/FeedbackModification/EditFeedback.dart';
import 'package:fidbak/Public/Loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllFeedbacks extends StatefulWidget {
  @override
  _AllFeedbacksState createState() => _AllFeedbacksState();
}
// 1589343729
class _AllFeedbacksState extends State<AllFeedbacks> {
  bool isAdmin, isRoot;
  String email;
  List departments;

  // Initial logic starts
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
      appBar: AppBar(title: Text('All Feedbacks'),centerTitle: true,),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return rootContent();
          } else {
            return Loading();
          }
        }
      ),
    );
  }

  rootContent() {
    return FutureBuilder(
      future: fetchDepartments(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return StreamBuilder(
            stream: Firestore.instance
                .collection('/feedbacks')
                .where('type', whereIn: departments)
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
        } else {
          return Loading();
        }
      },
    );
  }
  // UI code ends

  // Logic starts
  fetchDepartments() async {
    var docs = await Firestore.instance
        .collection('/root')
        .where('email', isEqualTo: email)
        .getDocuments();

    departments = docs.documents[0].data['departments'];
    return true;
  }
}