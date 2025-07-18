import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 1)
class Question extends HiveObject {
  @HiveField(0)
  String questionText;

  @HiveField(1)
  List<String> options;

  @HiveField(2)
  String correctAnswer;

  @HiveField(3)
  String explanation;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  String type;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.imageUrl,
    required this.type,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['question_text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correct_answer'] ?? '',
      explanation: map['explanation'] ?? '',
      imageUrl: map['image_url'] ?? '',
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'image_url': imageUrl,
      'type': type,
    };
  }
}
