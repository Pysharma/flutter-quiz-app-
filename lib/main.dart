import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'api_service.dart';
import 'blocq.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  final QuizBloc quizBloc = QuizBloc(apiService: ApiService());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<QuizBloc>(
        create: (context) => quizBloc..add(QuizEvent.fetchQuestions),
        child: QuizScreen(),
      ),
    );
  }
}


class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Option? selectedOption;
  int currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Container(
        padding: EdgeInsets.all(19),
        child: Card(
          margin: EdgeInsets.only(top: 30,left: 15,right: 15,bottom: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),

          ),
          child: BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state is QuizLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is QuizLoaded || state is QuizAnswered) {
                final List<Question> questions = (state is QuizLoaded) ? state.questions : (state as QuizAnswered).questions;
                final Question currentQuestion = questions.first;
                final bool isAnswered = state is QuizAnswered;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        currentQuestion.question,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...currentQuestion.options.map((option) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isAnswered) {
                              setState(() {
                                selectedOption = option;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: (isAnswered && option.option == currentQuestion.correctAnswer)
                                ? Colors.green // Correct answer
                                : (isAnswered && option == selectedOption && option.option != currentQuestion.correctAnswer)
                                ? Colors.red // Incorrect answer
                                : (option == selectedOption)
                                ? Colors.purple // Selected option
                                : null,
                          ),
                          child: Text(option.option),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: (isAnswered || selectedOption == null)
                          ? null // Disable the button by setting the onPressed callback to null
                          : () {
                        BlocProvider.of<QuizBloc>(context).add(QuizEvent.answerQuestion);
                        setState(() {
                          selectedOption = null;
                        });
                      },
                      child: Text(isAnswered ? 'Next Question' : 'Submit'),
                      style: ElevatedButton.styleFrom(
                        primary: (isAnswered || selectedOption == null)
                            ? Colors.grey // Use a different color to indicate it's disabled
                            : null,
                        onPrimary: Colors.white, // Change the text color when disabled
                      ),
                    ),

                    SizedBox(height: 16),
                    if (isAnswered)
                      Text(
                        (state as QuizAnswered).isCorrect ? 'Correct Answer!' : 'Incorrect Answer! Correct answer: ${currentQuestion.correctAnswer}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (state as QuizAnswered).isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    SizedBox(height: 16),
                    if (isAnswered)
                      Text(
                        'Score: ${(state as QuizAnswered).score}',
                        style: TextStyle(fontSize: 18),
                      ),
                  ],
                );
              } else if (state is QuizError) {
                return Center(
                  child: Text(state.message),
                );
              }
              return Container();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<QuizBloc>(context).add(QuizEvent.fetchNextQuestion);
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
