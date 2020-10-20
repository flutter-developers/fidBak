import 'dart:math';

class Stats {
  String docId;
  var data;

  Stats(this.docId, this.data);

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  getAverageScores() {
    return data['average'];
  }

  getScoresSpectrum() {
    var averages = getAverageScores();
    List<int> bands = new List<int>.filled(4, 0, growable: false);

    averages.forEach((value) {
      if (value >= 1 && value < 2)
        bands[0] += 1;
      else if (value >= 2 && value < 3)
        bands[1] += 1;
      else if (value >= 3 && value < 4)
        bands[2] += 1;
      else
        bands[3] += 1;
    });
    return bands;
  }

  getOverallAverage() {
    var scores = getScores();
    int obtained = 0, total = 0;
    for (int i = 0; i < scores.length; i++) {
      var values = scores[i.toString()];
      var responses = 0;
      if (values.length == 3) {
        for (int j = 0; j < values.length; j++) {
          obtained += values[j] * (4 - (j + 1));
          responses += values[j];
        }
      } else {
        for (int j = 0; j < values.length; j++) {
          obtained += values[j] * (j + 1);
          responses += values[j];
        }
      }
      total += values.length * responses;
    }
    if (total == 0) return 0.0;
    double percentage = obtained / total;
    print(roundDouble(percentage, 2));
    return roundDouble(percentage, 2);
  }

  getScoresForIndex(index) {
    var scores = getScores();
    return scores[index.toString()];
  }

  getScores() {
    return data['scores'];
  }
}
