import 'package:flutter/material.dart';
import 'package:reviews_slider/reviews_slider.dart';

import 'QuestionAndResponse.dart';

class SmileyRatingMeter extends StatefulWidget {
  QuestionAndResponse questionAndResponse;

  SmileyRatingMeter(this.questionAndResponse);

  @override
  _SmileyRatingMeterState createState() => _SmileyRatingMeterState();
}

class _SmileyRatingMeterState extends State<SmileyRatingMeter> {
  @override
  Widget build(BuildContext context) {
    return ReviewSlider(
        initialValue: widget.questionAndResponse.response - 1,
        onChange: (int value) {
          widget.questionAndResponse.response = value + 1;
        });
  }
}
