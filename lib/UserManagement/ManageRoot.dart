import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageRoot extends StatefulWidget {
  @override
  _ManageRootState createState() => _ManageRootState();
}

class _ManageRootState extends State<ManageRoot> {
  bool isAdmin,isRoot;

  Future<bool> getUserData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      isRoot = _prefs.getBool('root');
      isAdmin = _prefs.getBool('admin');
    });

    return isRoot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Managers'),),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return rootUserList();
          } else {
            return loading();
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          if(isRoot) {
            Navigator.of(context).pushNamed('/addManager');
          } else {
            Fluttertoast.showToast(msg: 'Permission Denied☹️');
          }
        },
      ),
    );
  }

  createNewManager() async {

  }

  removeUser(email) async {
    if(isRoot) {
      var rootDocs = await Firestore.instance
        .collection('/root')
        .where('email', isEqualTo: email)
        .getDocuments();
      
      await Firestore.instance
            .collection('/root')
            .document(rootDocs.documents[0].documentID)
            .delete()
            .catchError((e) {
          print(e);
        });
        Fluttertoast.showToast(msg: 'Successfully removed😄');
    } else {
      Fluttertoast.showToast(msg: 'Permission Denied☹️');
    }
  }

  rootUserList() {
    return StreamBuilder(
      stream: Firestore.instance.collection('/root').snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return ListView.separated(
            separatorBuilder: (context, index) =>
                Divider(height: 1.0, color: Colors.grey),
            itemBuilder: (context, index) {
              DocumentSnapshot userData = snapshot.data.documents[index];

              return ListTile(
                title: Text(userData.data['name']),
                subtitle: Text(userData.data['departments'].join(',')),
                trailing: IconButton(icon: Icon(MdiIcons.minusCircleOutline,color: Colors.red,),onPressed: () async {
                  ProgressDialog pr = new ProgressDialog(context);
                    pr.style(message: 'Processing request');
                    pr.show();
                    await removeUser(userData.data['email']);
                    pr.hide();
                },)
              );
            },
            itemCount: snapshot.data.documents.length,
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Center(child: Text('No Admins'));
        } else {
          return loading();
        }
      }
    );
  }

  loading() {
    return Center(
        child: SpinKitWave(
      color: Colors.blue,
    ));
  }
}