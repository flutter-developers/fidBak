import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/Public/Loading.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_it/share_it.dart';

class NormalStats extends StatefulWidget {
  final String docId;

  NormalStats(this.docId);

  @override
  _NormalStatsState createState() => _NormalStatsState();
}

class _NormalStatsState extends State<NormalStats> {
  var _data, attended, notAttended, attenders;

  Future<bool> setData() async {
    var data = await Firestore.instance
        .collection('/feedbacks')
        .document(widget.docId)
        .get();
    setState(() {
      _data = data;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats'),
        actions: <Widget>[
          IconButton(icon: Icon(MdiIcons.share),onPressed: () {
            String shareString = 'The following list of users are yet to give their feedback to ${_data['name']} hosted by ${_data['host']}\n\n${notAttended.join('\n')}\n\nYou\'re requested to give your valuable feedback as soon as possible';
            // print(shareString);
            ShareIt.text(
              content: shareString,
              androidSheetTitle: 'Share list of users'
            );
          },tooltip: 'Share the following list',)
        ],
      ),
      body: FutureBuilder(
        future: setData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return statsWidget();
          } else {
            return Loading();
          }
        },
      ),
    );
  }

  Widget statsWidget() {
    notAttended = [];
    attended = _data['attended'];
    attenders = _data['attenders'];

    for (var user in attenders) {
      if (!attended.contains(user)) notAttended.add(user);
    }
    attended.add('Finish');
    var finalList = attended + notAttended;

    return ListView.separated(
      separatorBuilder: (context, index) =>
          Divider(height: 1.0, color: Colors.grey),
      itemCount: finalList.length,
      itemBuilder: (context, index) {
        if (index == 0 && finalList[index] != 'Finish') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
                child: Text(
                  '${attended.length - 1} people gave the feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green),
                ),
              ),
              ListTile(
                title: Text(finalList[index]),
              )
            ],
          );
        }
        if (finalList[index] == 'Finish') {
          return Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
            child: Text(
              'Yet to give feedback',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
          );
        }
        return ListTile(
          title: Text(finalList[index]),
        );
      },
    );
  }
}
