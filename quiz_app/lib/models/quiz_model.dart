// lib/models/quiz_model.dart
class Question {
  final int id;
  final String description;
  final String topic;
  final String detailedSolution;
  final List<Option> options;
  Option? userAnswer; // Add this property to store the user's selected answer

  Question({
    required this.id,
    required this.description,
    required this.topic,
    required this.detailedSolution,
    required this.options,
    this.userAnswer, // Initialize as null by default
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      topic: json['topic'] ?? '',
      detailedSolution: json['detailed_solution'] ?? '',
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option))
          .toList(),
    );
  }

  // Method to get the correct option
  Option get correctOption {
    return options.firstWhere((option) => option.isCorrect);
  }
}

class Option {
  final int id;
  final String description;
  final bool isCorrect;

  Option({
    required this.id,
    required this.description,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}