import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidbak/Stats/ViewStatistics.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'StatisticsUtil.dart';

class PositivityMeter extends StatefulWidget {
  String docId;

  PositivityMeter(this.docId);

  @override
  _PositivityMeterState createState() => _PositivityMeterState();
}

class _PositivityMeterState extends State<PositivityMeter> {
  var _data;
  var stats;
  var ready = false;

  setData() async {
    var data = await Firestore.instance
        .collection('/feedbacks')
        .document(widget.docId)
        .get();
    setState(() {
      _data = data;
    });
    stats = new Stats(widget.docId, _data);
    setState(() {
      ready = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double percentage = 1;
    return Container(
        color: Colors.white,
        child: ready
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FlatButton(
                        onPressed: null,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Positivity Meter",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width / 8,
                              )),
                        )),
                    SizedBox(height: 20),
                    CircularPercentIndicator(
                        radius: width - width / 10,
                        lineWidth: width / 25,
                        // percent: percentage = stats.getOverallAverage().toDouble(),
                        percent: percentage,
                        center: getCenterText(percentage * 100),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 1500,
                        progressColor: getColor(percentage * 100)),
                    SizedBox(height: 10),
                    FlatButton(
                        child: Text("Click here to view detailed report",
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 16)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Statistics(widget.docId)));
                        })
                  ],
                ),
              )
            : Center(
                child: CircularPercentIndicator(
                    radius: width - width / 10,
                    lineWidth: width / 25,
                    percent: 0,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    progressColor: Colors.green),
              ));
  }

  getCenterText(percentage) {
    var emoji;
    if (percentage <= 20)
      emoji = "👎🏻";
    else if (percentage > 20 && percentage <= 40)
      emoji = "😕";
    else if (percentage > 40 && percentage <= 60)
      emoji = "😐";
    else if (percentage > 60 && percentage <= 80)
      emoji = "🙂";
    else if (percentage > 80 && percentage < 95)
      emoji = "👍🏻";
    else
      emoji = "🤩";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: TextStyle(fontSize: 75)),
        SizedBox(height: 5),
        Text(percentage.toString() + "%", style: TextStyle(fontSize: 50)),
      ],
    );
  }

  getColor(percentage) {
    if (percentage <= 20)
      return Colors.red;
    else if (percentage > 20 && percentage <= 40)
      return Colors.orange;
    else if (percentage > 40 && percentage <= 60)
      return Colors.yellow[300];
    else if (percentage > 60 && percentage <= 80)
      return Colors.lightGreen;
    else
      return Colors.green;
  }
}
