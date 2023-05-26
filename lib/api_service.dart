import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Question>> getQuestions() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=10&type=multiple'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> jsonList = data['results'];
      return jsonList.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

class Question {
  final String question;
  final List<Option> options;
  final String correctAnswer;

  Question({required this.question, required this.options, required this.correctAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    final List<dynamic> incorrectAnswers = json['incorrect_answers'];
    final List<String> options = List<String>.from(incorrectAnswers)..add(json['correct_answer']);
    options.shuffle();
    final List<Option> optionList = options.map((option) => Option(option: option)).toList();
    return Question(
      question: json['question'],
      options: optionList,
      correctAnswer: json['correct_answer'],
    );
  }
}

class Option {
  final String option;
  bool isSelected;

  Option({required this.option, this.isSelected = false});
}
