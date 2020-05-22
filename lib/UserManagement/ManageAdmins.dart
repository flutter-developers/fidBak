import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageAdmins extends StatefulWidget {
  @override
  _ManageAdminsState createState() => _ManageAdminsState();
}

class _ManageAdminsState extends State<ManageAdmins> {
  bool isRoot;
  bool isAdmin;
  String query = '';
  String newAdminEmail;
  Widget appBarContent = new Text('Manage admins');
  List<dynamic> _list = List<dynamic>();
  Icon appBarIcon = Icon(Icons.search);

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getUserData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      isRoot = _prefs.getBool('root');
      isAdmin = _prefs.getBool('admin');
    });

    return isRoot;
  }

  createNewAdmin() async {
    var userDocs = await Firestore.instance
        .collection('/users')
        .where('email', isEqualTo: newAdminEmail)
        .getDocuments();

    if (userDocs.documents.length == 0) {
      Fluttertoast.showToast(msg: 'User doesn\'t exist');
      return;
    } else {
      userDocs.documents.forEach((d) async {
        await Firestore.instance
            .collection('/users')
            .document(d.documentID)
            .updateData({'isadmin': true}).then((val) {
          Fluttertoast.showToast(msg: 'Successfully added');
        }).catchError((e) {
          print(e);
        });
      });
    }
  }

  searchPressed() {
    if (this.appBarIcon.icon == Icons.search) {
      this.appBarIcon = Icon(Icons.close);
      this.appBarContent = TextField(
        decoration: InputDecoration(hintText: 'Search admins'),
        onChanged: (value) {
          setState(() {
            query = value;
          });
        },
      );
    } else {
      this.appBarIcon = Icon(Icons.search);
      this.appBarContent = new Text('Manage admins');
      query = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: appBarIcon,
            onPressed: searchPressed,
          ),
        ],
        title: appBarContent,
      ),
      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return listWidget();
          } else {
            return loading();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (isAdmin || isRoot) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: TextField(
                      autofocus: true,
                      decoration: InputDecoration(hintText: 'Enter user email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => (newAdminEmail = value),
                    ),
                    title: Text('Add user'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Add'),
                        onPressed: () async {
                          await createNewAdmin();
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          } else {
            Fluttertoast.showToast(msg: 'Permission Denied☹️');
          }
        },
      ),
    );
  }

  listWidget() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('/users')
          .where('isadmin', isEqualTo: true)
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          var temp = snapshot.data.documents;
          _list.clear();
          for (DocumentSnapshot userData in temp) {
            if (query == '' ||
                userData.data['name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                userData.data['email']
                    .toLowerCase()
                    .contains(query.toLowerCase())) {
              _list.add(userData);
            }
          }
          return ListView.separated(
            separatorBuilder: (context, index) =>
                Divider(height: 1.0, color: Colors.grey),
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_list[index].data['name']),
                subtitle: Text(_list[index].data['email']),
                trailing: IconButton(
                  icon: Icon(
                    MdiIcons.minusCircleOutline,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    ProgressDialog pr = new ProgressDialog(context);
                    pr.style(message: 'Processing request');
                    pr.show();
                    await removeUser(_list[index]);
                    pr.hide();
                  },
                ),
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Center(child: Text('No Admins'));
        } else {
          return loading();
        }
      },
    );
  }

  removeUser(user) async {
    var rootDocs = await Firestore.instance
        .collection('/root')
        .where('email', isEqualTo: user.data['email'])
        .getDocuments();
    var userDocs = await Firestore.instance
        .collection('/users')
        .where('email', isEqualTo: user.data['email'])
        .getDocuments();

    if (isRoot) {
      if (rootDocs.documents.length > 0) {
        await Firestore.instance
            .collection('/root')
            .document(rootDocs.documents[0].documentID)
            .delete()
            .catchError((e) {
          print(e);
        });
        Fluttertoast.showToast(msg: 'Successfully removed😄');
      } else {
        userDocs.documents.forEach((d) async {
          await Firestore.instance
              .collection('/users')
              .document(d.documentID)
              .updateData({'isadmin': false}).catchError((e) {
            print(e);
          });
          Fluttertoast.showToast(msg: 'Successfully removed😄');
        });
      }
    } else if (isAdmin) {
      if (rootDocs.documents.length > 0) {
        Fluttertoast.showToast(msg: 'Permission denied☹️');
      } else {
        userDocs.documents.forEach((d) async {
          await Firestore.instance
              .collection('/users')
              .document(d.documentID)
              .updateData({'isadmin': false}).catchError((e) {
            print(e);
          });
        });
        Fluttertoast.showToast(msg: 'Successfully removed😄');
      }
    } else {
      Fluttertoast.showToast(msg: 'Permission denied☹️');
    }
  }

  loading() {
    return Center(
        child: SpinKitWave(
      color: Colors.blue,
    ));
  }
}
