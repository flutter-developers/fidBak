import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fidbak/QRCode/GenerateScreen.dart';
import 'package:fidbak/Stats/NormalStats.dart';
import 'package:fidbak/Stats/PositivityMeter.dart';
import 'package:fidbak/Stats/ViewStatistics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EditFeedback extends StatefulWidget {
  final DocumentSnapshot feedback;
  final bool isRoot;

  EditFeedback({this.feedback, this.isRoot});

  @override
  _EditFeedbackState createState() => _EditFeedbackState();
}

class _EditFeedbackState extends State<EditFeedback> {
  @override
  Widget build(BuildContext context) {
    // Gets width of the screen
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text(
                      (index + 1).toString() + ")",
                      style: TextStyle(fontSize: 15),
                    ),
                    title: Text(widget.feedback.data['questions'][index]),
                  );
                },
                separatorBuilder: (context, index) =>
                    Divider(height: 1.0, color: Colors.grey),
                itemCount: widget.feedback.data['questions'].length)),
        bottomNavigationBar: BottomAppBar(
          child: widget.isRoot
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      SizedBox(
                        width: width / 2 - 5,
                        child: RaisedButton(
                          color: Colors.blue,
                          child: Text('Attendees',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            // Shows stats accordingly to the user's privileges
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NormalStats(
                                        widget.feedback.documentID)));
                          },
                        ),
                      ),
                      SizedBox(
                        width: width / 2 - 5,
                        child: RaisedButton(
                          color: Colors.blue,
                          child: Text('Statistics',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => Statistics(
                            //             widget.feedback.documentID)));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PositivityMeter(
                                        widget.feedback.documentID)));
                          },
                        ),
                      )
                    ])
              : RaisedButton(
                  color: Colors.blue,
                  child:
                      Text('Attendees', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NormalStats(widget.feedback.documentID)));
                  },
                ),
        ),
        floatingActionButton: getOptions());
  }

  // Returns Speed dial UI component
  getOptions() {
    return SpeedDial(
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.7,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Show options',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(MdiIcons.cancel),
            backgroundColor: Colors.red,
            label: 'End feedback',
            labelBackgroundColor: Colors.black,
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.white70),
            onTap: () {
              endFeedback();
            }),
        SpeedDialChild(
            child: Icon(MdiIcons.qrcode),
            backgroundColor: Colors.blue,
            label: 'Generate QR',
            labelBackgroundColor: Colors.black,
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.white70),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GenerateScreen(
                            docID: widget.feedback.documentID,
                            name: widget.feedback.data['name'],
                            id: widget.feedback.data['id'],
                          )));
            }),
      ],
    );
  }

  // Logic starts
  endFeedback() async {
    // Start showing progress indicator
    ProgressDialog pr = new ProgressDialog(context, isDismissible: false);
    pr.style(message: 'Closing feedback');
    pr.show();

    // Updates current feedback status to close
    await Firestore.instance
        .collection('/feedbacks')
        .document(widget.feedback.documentID)
        .updateData({'status': 'close'}).then((val) {
      pr.hide();
      AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          tittle: 'Success',
          desc: 'Feedback closed successfully',
          dismissOnTouchOutside: false,
          btnOkOnPress: () {
            // Navigates back to home screen
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/homepage', (r) => false);
          }).show();
    }).catchError((e) {
      pr.hide();
      Fluttertoast.showToast(msg: 'Error occured');
    });
  }
}
