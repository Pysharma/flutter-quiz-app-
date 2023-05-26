import 'dart:async';
import 'package:bloc/bloc.dart';
import 'api_service.dart';

enum QuizEvent { fetchQuestions, answerQuestion, fetchNextQuestion }

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final ApiService apiService;
  int score = 0;
  int currentQuestionIndex = 0;

  QuizBloc({required this.apiService}) : super(QuizInitial());

  @override
  Stream<QuizState> mapEventToState(QuizEvent event) async* {
    if (event == QuizEvent.fetchQuestions) {
      yield QuizLoading();
      try {
        final questions = await apiService.getQuestions();
        yield QuizLoaded(questions: questions);
      } catch (e) {
        yield QuizError(message: 'Failed to fetch questions');
      }
    } else if (event == QuizEvent.answerQuestion) {
      if (state is QuizLoaded) {
        final currentQuestion = (state as QuizLoaded).questions[currentQuestionIndex];
        final selectedOption = currentQuestion.options.firstWhere((option) => option.isSelected, orElse: () => Option(option: ''));
        final bool isCorrect = selectedOption.option == currentQuestion.correctAnswer;

        int updatedScore = score;
        if (isCorrect) {
          updatedScore++;
        }

        List<Question> updatedQuestions = List.from((state as QuizLoaded).questions);
        updatedQuestions[currentQuestionIndex] = Question(
          question: currentQuestion.question,
          options: currentQuestion.options.map((option) {
            if (option.isSelected) {
              return Option(
                option: option.option,
                isSelected: false,
              );
            }
            return option;
          }).toList(),

          correctAnswer: currentQuestion.correctAnswer,
        );

        yield QuizAnswered(
          questions: updatedQuestions,
          selectedOption: selectedOption,
          isCorrect: isCorrect,
          score: updatedScore,
        );
      }
    } else if (event == QuizEvent.fetchNextQuestion) {
      if (state is QuizLoaded) {
        currentQuestionIndex++;
        if (currentQuestionIndex < (state as QuizLoaded).questions.length) {
          yield QuizLoaded(questions: (state as QuizLoaded).questions);
        } else {
          yield QuizError(message: 'No more questions');
        }
      }
    }
  }
}

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;

  QuizLoaded({required this.questions});
}

class QuizAnswered extends QuizState {
  final List<Question> questions;
  final Option selectedOption;
  final bool isCorrect;
  final int score;

  QuizAnswered({
    required this.questions,
    required this.selectedOption,
    required this.isCorrect,
    required this.score,
  });
}

class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}
