import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/QRCode/GenerateScreen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CrudMethods {

  // addData, getData, updateData
  postFeedback(context, feedback) {
    // Start showing progress indicator
    ProgressDialog pr = new ProgressDialog(context, isDismissible: false);
    pr.style(message: 'Generating QR Code');
    pr.show();
    // Generating unique ID for the feedback that is being hosted, alternative to QR Code
    int uniqueId = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Firestore.instance.collection('feedbacks').add({
      'id': uniqueId,
      'name': feedback.name,
      'host': feedback.host,
      'host_id': feedback.hostId,
      'type': feedback.type,
      'questions': feedback.questions,
      'metrics': feedback.metrics,
      'scores': feedback.scores,
      'remarks': feedback.remarks,
      'attended': feedback.attended,
      'status': feedback.status,
      'attenders': feedback.allAttenders,
      'restricted': feedback.restricted
    }).then((doc) {
      // Hide the progress indicator
      pr.hide();
      // Redirect to QR code generator screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenerateScreen(docID: doc.documentID,name: feedback.name,id: uniqueId,)
        )
      );
    }).catchError((e) {
      print(e);
      AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          tittle: 'Error',
          desc: 'Failed to upload the data',
          dismissOnTouchOutside: true,
          btnOkOnPress: () {
            Navigator.of(context, rootNavigator: false).pop();
          }).show();
    });
  }
  
  
}