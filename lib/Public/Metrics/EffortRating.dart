import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

import 'QuestionAndResponse.dart';

class EffortRatingMeter extends StatefulWidget {
  QuestionAndResponse questionAndResponse;

  EffortRatingMeter(this.questionAndResponse);

  @override
  _EffortRatingMeterState createState() => _EffortRatingMeterState();
}

class _EffortRatingMeterState extends State<EffortRatingMeter> {
  List<String> labels = [
    "Option 1",
    "Option 2",
    "Option 3",
    "Option 4",
    "Option 5",
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        RadioButtonGroup(
          labels: labels,
          onChange: (String label, int index) {
            setState(() {
              widget.questionAndResponse.response = index + 1;
            });
          },
          picked: labels[widget.questionAndResponse.response - 1],
        ),
      ],
    );
  }
}
