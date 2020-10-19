import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class IndividualCharts extends StatelessWidget {
  final List<charts.Series> statList;
  final bool animate;

  IndividualCharts(this.statList, this.animate);

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      statList,
      animate: true,
      vertical: true,
    );
  }
}

class QuestionStat {
  final String result;
  final int noOfUsers;

  QuestionStat(this.result, this.noOfUsers);
}
