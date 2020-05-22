class Stats {
  String docId;
  var data;

  Stats(this.docId, this.data);

  getAverageScores() {
    return data['average'];
  }

  getScoresSpectrum() {
    var averages = getAverageScores();
    List<int> bands = new List<int>.filled(4, 0, growable: false);

    averages.forEach((value) {
      if(value >= 1 && value < 2) bands[0]+=1;
      else if(value >=2 && value < 3) bands[1] += 1;
      else if(value >= 3 && value < 4) bands[2] += 1;
      else bands[3] += 1;
    });
    return bands;
  }

  getOverallAverage() {
    var averages = getAverageScores();
    double result = 0;
    averages.forEach((score) => result += score);
    return result / averages.length;
  }

  getScoresForIndex(index) {
    var scores = getScores();
    return scores[index.toString()];
  }

  getScores() {
    return data['scores'];
  }
}