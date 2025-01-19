import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../models/quiz_model.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  String errorMessage = '';
  int mistakeCount = 0;
  final int maxMistakes = 9;
  final int questionTimeLimit = 30; // 30 seconds per question
  late int remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  Future<void> fetchQuizData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jsonserve.com/Uw5CrX'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          questions = (data['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList();
          isLoading = false;
          startTimer();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load quiz data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void startTimer() {
    remainingTime = questionTimeLimit;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          handleTimeout();
        }
      });
    });
  }

  void handleTimeout() {
    showFeedback(false);
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        mistakeCount++;
        currentQuestionIndex++;
        startTimer();
      });
    } else {
      navigateToResultScreen();
    }
  }

  void answerQuestion(Option selectedOption) {
    final bool isCorrect = selectedOption.isCorrect;

    setState(() {
      questions[currentQuestionIndex].userAnswer = selectedOption;

      if (isCorrect) {
        score += 4;
      } else {
        score -= 1;
        mistakeCount++;
      }
    });

    showFeedback(isCorrect);
    timer.cancel();

    if (mistakeCount >= maxMistakes) {
      navigateToResultScreen();
      return;
    }

    if (currentQuestionIndex < questions.length - 1) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          currentQuestionIndex++;
          startTimer();
        });
      });
    } else {
      navigateToResultScreen();
    }
  }

  void navigateToResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: questions.length,
          questions: questions,
        ),
      ),
    );
  }

  void showFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'Correct! +4 points' : 'Incorrect! -1 point',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestionIndex + 1}/${questions.length}'),
        backgroundColor: Colors.blue,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
              const SizedBox(height: 24),
              Text(
                currentQuestion.description,
                style: TextStyle(
                  fontSize: isPortrait ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Topic: ${currentQuestion.topic}',
                style: TextStyle(
                  fontSize: isPortrait ? 14 : 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Time Remaining: $remainingTime seconds',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          side: BorderSide(color: Colors.blue[200]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => answerQuestion(option),
                        child: Text(
                          option.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Mistakes: $mistakeCount/$maxMistakes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}