import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'QuestionAndResponse.dart';

// ignore: must_be_immutable
class GoalCompletionRateMeter extends StatefulWidget {
  QuestionAndResponse questionAndResponse;

  GoalCompletionRateMeter(this.questionAndResponse);
  @override
  _GoalCompletionRateMeterState createState() =>
      _GoalCompletionRateMeterState();
}

class _GoalCompletionRateMeterState extends State<GoalCompletionRateMeter> {
  List<bool> isSelected;
  static TextStyle kTextStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  @override
  void initState() {
    super.initState();
    isSelected = [false, false, false];
    isSelected[widget.questionAndResponse.response - 1] =
        !isSelected[widget.questionAndResponse.response - 1];
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: <Widget>[
        Text(
          "Yes",
          style: kTextStyle,
        ),
        Text(
          "Partially",
          style: kTextStyle,
        ),
        Text(
          "No",
          style: kTextStyle,
        ),
      ],
      borderWidth: 3.0,
      borderRadius: BorderRadius.circular(15),
      borderColor: Colors.black12,
      fillColor: Colors.black12,
      onPressed: (int index) {
        setState(() {
          isSelected = [false, false, false];
          isSelected[index] = !isSelected[index];
          widget.questionAndResponse.response = index + 1;
        });
      },
      isSelected: isSelected,
    );
  }
}
