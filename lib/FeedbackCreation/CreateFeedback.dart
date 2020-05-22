import 'package:fidbak/FeedbackCreation/crud.dart';
import 'package:fidbak/Models/FeedbackModel.dart';
import 'package:fidbak/Public/Metrics/EffortRating.dart';
import 'package:fidbak/Public/Metrics/GoalCompletionRate.dart';
import 'package:fidbak/Public/Metrics/QuestionAndResponse.dart';
import 'package:fidbak/Public/Metrics/SatisfactionRating.dart';
import 'package:fidbak/Public/Metrics/SmileyRating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MetricType { Satisfaction, GoalCompletionRate, EffortScore, SmileyRating }

const kActiveCardColor = Colors.black12;
const kInactiveCardColor = Colors.white;

class Question {
  String questionData = "";
  MetricType metricType = MetricType.SmileyRating;
}

class QuestionDialog extends StatefulWidget {
  final String questionAction;
  final Question question;

  QuestionDialog(this.questionAction, this.question);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  // MetricType _metricType = widget.question.metricType;
  MetricType _metricType = MetricType.SmileyRating;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionAction),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                    width: (width * 4) / 5,
                    child: TextField(
                      controller: TextEditingController()..text =  widget.question.questionData,
                      decoration: InputDecoration(hintText: 'Question'),
                      onChanged: (text) {
                        widget.question.questionData = text;
                      },
                    )),
                SizedBox(width: 5),
                SizedBox(
                    width: (width / 5),
                    child: RaisedButton(
                      child: Text('ADD', style: TextStyle(color: Colors.white)),
                      color: Colors.blue,
                      onPressed: () async {
                        if (widget.question.questionData.length != 0) {
                          widget.question.metricType = _metricType;
                          Navigator.pop(context, widget.question);
                        }
                      },
                    ))
              ],
            ),
            Container(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _metricType = MetricType.EffortScore;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 25.0),
                color: _metricType == MetricType.EffortScore
                    ? kActiveCardColor
                    : kInactiveCardColor,
                child: EffortRatingMeter(
                    QuestionAndResponse("EffortScore", "EffortScore")),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _metricType = MetricType.SmileyRating;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 25.0),
                color: _metricType == MetricType.SmileyRating
                    ? kActiveCardColor
                    : kInactiveCardColor,
                child: SmileyRatingMeter(
                    QuestionAndResponse("SmileyRating", "SmileyRating")),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _metricType = MetricType.GoalCompletionRate;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(50),
                color: _metricType == MetricType.GoalCompletionRate
                    ? kActiveCardColor
                    : kInactiveCardColor,
                child: Center(
                  child: GoalCompletionRateMeter(QuestionAndResponse(
                      "GoalCompletionRate", "GoalCompletionRate")),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _metricType = MetricType.Satisfaction;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(50),
                color: _metricType == MetricType.Satisfaction
                    ? kActiveCardColor
                    : kInactiveCardColor,
                child: SatisafactionRatingMeter(
                    QuestionAndResponse("Satisfaction", "Satisfaction")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateFeedback extends StatefulWidget {
  final String name, host, type;
  final List<String> allAttenders;

  CreateFeedback({this.name, this.host, this.type, this.allAttenders});

  @override
  _CreateFeedbackState createState() => _CreateFeedbackState();
}

class _CreateFeedbackState extends State<CreateFeedback> {
  List<Question> questionsList = List<Question>();
  final String content = "Can't add empty question";
  final String title = "Error";

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create feedback'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () async {
              dynamic questionReference = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuestionDialog("Create Question", Question()),
                  ));
              if (questionReference != null) {
                questionsList.add(questionReference);
              }
            },
          )
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) =>
            Divider(height: 1.0, color: Colors.grey),
        itemCount: questionsList.length,
        itemBuilder: (context, index) {
          return Dismissible(
              key: Key(questionsList[index].questionData),
              onDismissed: (direction) {
                setState(() {
                  questionsList.removeAt(index);
                });
                Scaffold.of(context).showSnackBar((SnackBar(
                  content: Text('Question deleted'),
                )));
              },
              background: slideBackground('start'),
              secondaryBackground: slideBackground('end'),
              child: ListTile(
                leading: Text(
                  (index + 1).toString() + ")",
                  style: TextStyle(fontSize: 15),
                ),
                title: Text(questionsList[index].questionData),
                trailing: Text(questionsList[index].metricType.toString()),
                onTap: () {
                  print('Here on Tap');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuestionDialog(
                            "Edit Question", questionsList[index])),
                  );
                },
              ));
        },
      ),
      persistentFooterButtons: <Widget>[
        SizedBox(
          width: width,
          child: RaisedButton(
            color: Colors.blue,
            child: Text('Post'),
            onPressed: () async {
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              String email = _prefs.getString("email");
              FeedbackModel feedback = new FeedbackModel(
                  //Modify Here
                  questionsList,
                  widget.type,
                  widget.name,
                  widget.host,
                  widget.allAttenders,
                  email);
              CrudMethods().postFeedback(context, feedback);
            },
          ),
        )
      ],
    );
  }

  slideBackground(position) {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: ((position == 'end')
              ? MainAxisAlignment.end
              : MainAxisAlignment.start),
          children: <Widget>[
            Icon(
              CupertinoIcons.delete,
              color: Colors.white,
              size: 40,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign:
                  ((position == 'end') ? TextAlign.right : TextAlign.left),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: ((position == 'end')
            ? Alignment.centerRight
            : Alignment.centerLeft),
      ),
    );
  }
}
