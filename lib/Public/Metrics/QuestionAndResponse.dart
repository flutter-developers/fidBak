class QuestionAndResponse {
  //int listIndex;
  String question;
  int response;
  String metricType;

  QuestionAndResponse(this.question, this.metricType) {
    switch (this.metricType) {
      case 'Satisfaction':
        this.response = 3;
        break;
      case 'SmileyRating':
        this.response = 3;
        break;
      case 'EffortScore':
        this.response = 3;
        break;
      case 'GoalCompletionRate':
        this.response = 2;
        break;
    }
  }
}
