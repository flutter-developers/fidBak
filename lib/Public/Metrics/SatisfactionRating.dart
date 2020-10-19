import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';

import 'QuestionAndResponse.dart';

// ignore: must_be_immutable
class SatisafactionRatingMeter extends StatefulWidget {
  QuestionAndResponse questionAndResponse;

  SatisafactionRatingMeter(this.questionAndResponse);
  @override
  _SatisafactionRatingMeterState createState() =>
      _SatisafactionRatingMeterState();
}

class _SatisafactionRatingMeterState extends State<SatisafactionRatingMeter> {
  @override
  Widget build(BuildContext context) {
    return FluidSlider(
      value: widget.questionAndResponse.response.toDouble(),
      onChanged: (double newValue) {
        setState(() {
          widget.questionAndResponse.response = newValue.round();
        });
      },
      min: 1.0,
      max: 5.0,
    );
  }
}
