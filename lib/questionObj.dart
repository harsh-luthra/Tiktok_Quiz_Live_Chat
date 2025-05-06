class Question {
  String question;
  String answer;

  Question({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
  };

  static Question fromJson(Map<String, dynamic> json) => Question(
    question: json['question'],
    answer: json['answer'],
  );
}