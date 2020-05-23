import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/Public/Loading.dart';
import 'package:fidbak/Stats/IndividualStats.dart';
import 'package:fidbak/Stats/StatisticsUtil.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  final String docId;

  Statistics(this.docId);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  Stats stats;
  List<double> averages;
  List<int> bands;
  double overAllAverage;
  var scores;
  var _data;

  // Initial code starts
  @override
  void initState() {
    super.initState();
  }
  
  Future<bool> setData() async {
    var data = await Firestore.instance
        .collection('/feedbacks')
        .document(widget.docId)
        .get();
    setState(() {
      _data = data;
    });
    stats = new Stats(widget.docId, _data);
    return true;
  }
  // Initial code ends

  // UI code starts
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 10;
    var height = MediaQuery.of(context).size.height / 3;
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: FutureBuilder(
        future: setData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) =>
                  Divider(height: 1.0, color: Colors.grey),
              itemCount: _data['questions'].length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Text(_data['questions'][index]),
                    SizedBox(height: 5),
                    SizedBox(
                      width: width,
                      height: height,
                      child: IndividualCharts(
                          scoresToStatList(stats.getScoresForIndex(index),
                              _data['metrics'][index]),
                          true),
                    )
                  ],
                );
              },
            );
          } else {
            return Loading();
          }
        },
      ),
    );
  }
  // UI code ends

  // Logic starts
  List<charts.Series<QuestionStat, String>> scoresToStatList(
      scores, metricType) {
    var goal = ['Yes', 'Partially', 'No'];
    var effort = ['1', '2', '3', '4', '5'];
    var smiley = ['☹️', '😕', '😐', '🙂', '😄'];
    var satisfaction = ['1', '2', '3', '4', '5'];
    List<QuestionStat> data = new List<QuestionStat>();

    if (metricType == 'GoalCompletionRate') {
      int idx = 0;
      while (idx < goal.length) {
        data.add(QuestionStat(goal[idx], scores[idx]));
        idx++;
      }
    } else if (metricType == 'EffortScore') {
      int idx = 0;
      while (idx < effort.length) {
        data.add(QuestionStat(effort[idx], scores[idx]));
        idx++;
      }
    } else if (metricType == 'SmileyRating') {
      int idx = 0;
      while (idx < smiley.length) {
        data.add(QuestionStat(smiley[idx], scores[idx]));
        idx++;
      }
    } else {
      int idx = 0;
      while (idx < satisfaction.length) {
        data.add(QuestionStat(satisfaction[idx], scores[idx]));
        idx++;
      }
    }
    return [
      charts.Series<QuestionStat, String>(
        id: 'Question stats',
        measureFn: (stat, _) => stat.noOfUsers,
        domainFn: (stat, _) => stat.result,
        data: data,
      )
    ];
  }
}
