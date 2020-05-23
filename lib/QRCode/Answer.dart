import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/Public/Metrics/EffortRating.dart';
import 'package:fidbak/Public/Metrics/GoalCompletionRate.dart';
import 'package:fidbak/Public/Metrics/QuestionAndResponse.dart';
import 'package:fidbak/Public/Metrics/SatisfactionRating.dart';
import 'package:fidbak/Public/Metrics/SmileyRating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Answer extends StatefulWidget {
  final String data;

  Answer({this.data});

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  var data;
  double avg = 0;
  var attended;
  bool perform = false;
  String email;
  var updated;
  List<QuestionAndResponse> questionObjectList =
      new List<QuestionAndResponse>();

  // Initial code starts
  instantiate() async {
    // Answer.dart constructor receives document ID from the QR Scanner
    // Fetch the feedback from the given document ID
    // If no feedback exists with given ID, mark data variable as 'Error'
    // Else set the variable to the feedback data
    await Firestore.instance
        .collection('/feedbacks')
        .document(widget.data)
        .get()
        .then((_data) {
      if (!_data.exists) {
        setState(() {
          data = 'Error';
        });
      } else {
        setState(() {
          data = _data;
        });
      }
    });
  }

  getSharedPreferences() async {
    await SharedPreferences.getInstance().then((val) {
      setState(() {
        email = val.getString("email");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
    instantiate();
  }
  // Initial code ends
  
  // UI code starts
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (data == null)
      return SpinKitThreeBounce(color: Colors.blue); // Data is still loading
    else if (data == 'Error')
      return stopUser('Feedback no longer exists'); // Not a valid document ID
    else if (data['attended'].contains(email))
      return stopUser('Can\'t give feedback more than once'); // User already gave the feedback
    else if(data['restricted']==true && !data['attenders'].contains(email)) {
      return stopUser('You\'re not allowed to answer this feedback'); // Feedback is restricted to limited users
    }
    else
      return fetchDocument(width); // User is allowed to give the feedback
  }

  stopUser(data) {
    return Scaffold(
        body: Center(
      child: Text(data),
    ));
  }

  fetchDocument(double width) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name']),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) =>
            Divider(height: 1.0, color: Colors.grey),
        itemBuilder: (context, index) {
          if (index == data['questions'].length) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: RaisedButton(
                color: Color(0xff23272B),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  // User clicked submit
                  uploadFeedback(context);
                },
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Text(
                    (index + 1).toString() + ")",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    data['questions'][index],
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                metric(index) // Renders widget accordingly to the question
              ],
            ),
          );
        },
        itemCount: data['questions'].length + 1,
      ),
    );
  }

  metric(int index) {
    switch (data['metrics'][index]) {
      case 'Satisfaction':
        return slider(index);
      case 'SmileyRating':
        return smiley(index);
      case 'EffortScore':
        return effortScore(index);
      case 'GoalCompletionRate':
        return goalCompletionRate(index);
      default:
        return Text('Unexpected error');
    }
  }

  goalCompletionRate(int index) {
    QuestionAndResponse temp =
        QuestionAndResponse(data['questions'][index], "GoalCompletionRate");
    questionObjectList.add(temp);
    return GoalCompletionRateMeter(temp);
  }

  effortScore(int index) {
    QuestionAndResponse temp =
        QuestionAndResponse(data['questions'][index], "EffortScore");
    questionObjectList.add(temp);
    return EffortRatingMeter(temp);
  }

  smiley(int index) {
    QuestionAndResponse temp =
        QuestionAndResponse(data['questions'][index], "SmileyRating");
    questionObjectList.add(temp);
    return SmileyRatingMeter(temp);
  }

  slider(int index) {
    QuestionAndResponse temp =
        QuestionAndResponse(data['questions'][index], "Satisfaction");
    questionObjectList.add(temp);
    return SatisafactionRatingMeter(temp);
  }
  // UI code ends

  // Logic starts
  uploadFeedback(context) {
    // Start showing progress indicator
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: 'Submitting response');
    pr.show();
    var ref = Firestore.instance.collection('/feedbacks').document(widget.data);
    
    // Following transaction uploads the user response
    Firestore.instance.runTransaction((tx) async {
      await ref.get().then((doc) {
        var prev = doc['scores'];
        attended = doc['attended'];
        attended.add(email);
        for (int i = 0; i < questionObjectList.length; i++) {
          int response = questionObjectList[i].response;
          prev[i.toString()][response - 1] += 1;
        }
        updated = prev;
      });
      await tx.update(ref, {
        'scores': updated,
        'attended': attended,
      });
    }).then((val) async {
      await ref.get().then((doc) {
        if (!(doc['attended'].contains(email))) {
          print(email);
          throw Exception('Error');
        }
      }).catchError((e) {
        throw Exception('Error');
      });
      pr.hide();
      Fluttertoast.showToast(msg: 'Feedback submitted succesfully');
      Navigator.of(context, rootNavigator: false).pop();
      Navigator.of(context).pushNamedAndRemoveUntil('/homepage', (r) => false);
    }).catchError((e) {
      pr.hide();
      print(e);
      uploadFeedback(context);
    });
  }
}
