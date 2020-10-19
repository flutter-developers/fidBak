import 'package:fidbak/FeedbackCreation/CreateFeedback.dart';

enum MetricType { Satisfaction, GoalCompletionRate, EffortScore, SmileyRating }

class FeedbackModel {
  List<Question> questionObjects;
  List<String> questions, metrics;
  Map<String, List<int>> scores;
  List<String> remarks;
  List<String> attended;
  List<String> allAttenders;
  bool restricted = false;
  String type;
  String name, host;
  String status;
  String hostId;

  // Constructor for Feedback model
  FeedbackModel(questions, type, name, host, allAttenders, hostId) {
    this.questionObjects = questions;
    this.remarks = new List<String>();
    this.attended = new List<String>();
    this.questions = new List<String>();
    this.metrics = new List<String>();
    this.status = "open";
    this.type = type;
    this.name = name;
    this.host = host;
    this.hostId = hostId;
    this.allAttenders = allAttenders;
    restricted = allAttenders.isNotEmpty;

    this.questionObjects.forEach((o) {
      decodeObject(o);
    });
    this.scores = initializeScores(metrics);
  }

  // This method initializes the scores to zero.
  // Scores is a 2D matrix that stores the count of responses to an option in a particular question
  // Example: SmileyRating contains 5 options, so question with SmileyRating metric will contain 5 zeros to store the count for 5 options.
  initializeScores(metrics) {
    Map<String, List<int>> scores = new Map<String, List<int>>();
    int idx = 0;
    metrics.forEach((metric) {
      int length;
      if (metric == 'EffortScore')
        length = 5;
      else if (metric == 'SmileyRating')
        length = 5;
      else if (metric == 'GoalCompletionRate')
        length = 3;
      else
        length = 5;
      List<int> tempList = new List<int>.filled(length, 0, growable: false);
      scores[idx.toString()] = (tempList);
      idx++;
    });
    return scores;
  }

  // Fetch question and metric from Question object
  decodeObject(Question object) {
    this.questions.add(object.questionData);
    this.metrics.add(enumToString(object.metricType));
  }

  // Converts given enum to String
  String enumToString(o) {
    return o.toString().split('.').last;
  }

  // Converts String to enum
  MetricType enumFromString(String val, List<MetricType> values) =>
      values.firstWhere((v) => val == enumToString(v), orElse: () => null);

  // Removes question at given index from questions list
  removeQuestion(int index) {
    questions.removeAt(index);
  }
}
