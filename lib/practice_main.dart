// lib/practice_main.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/language.dart';
import 'practice_questions.dart';
import 'practice_feedback.dart';

class PracticeMain extends StatefulWidget {
  final List<dynamic> stages;
  final Language selectedLanguage;
  final Function(bool) onQuestionAnswered;

  const PracticeMain({
    super.key, // use the super parameter
    required this.stages,
    required this.selectedLanguage,
    required this.onQuestionAnswered,
  });

  @override
  State<PracticeMain> createState() => _PracticeMainState();
}

class _PracticeMainState extends State<PracticeMain>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final List<Map<String, dynamic>> _allQuestions = [];

  int currentIndex = 0; // אינדקס השאלה הנוכחית
  bool showFeedback = false; // מסך פידבק
  bool isCorrectAnswer = false;
  int score = 0; // ניקוד בסשן
  int currentStreak = 0; // רצף נכון
  int bestStreakDaily = 0;
  int bestStreakAllTime = 0;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _initQuestions();
    _loadStreaksFromPrefs();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// מערבבים את כל השאלות מכל השלבים
  void _initQuestions() {
    _allQuestions.clear();
    for (var stage in widget.stages) {
      final quizzes = stage['quizzes'] as List<dynamic>? ?? [];
      for (var quiz in quizzes) {
        final questions = quiz['questions'] as List<dynamic>? ?? [];
        for (var q in questions) {
          _allQuestions.add({
            "question": q['question'],
            "answers": q['answers'],
          });
        }
      }
    }
    _allQuestions.shuffle(_random);
    currentIndex = 0;
    showFeedback = false;
    score = 0;
    currentStreak = 0;
  }

  /// טוען שיא רצף (best streak)
  Future<void> _loadStreaksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy_MM_dd');
    final todayKey =
        'practice_best_streak_daily_${widget.selectedLanguage == Language.en ? 'EN' : 'HE'}_${formatter.format(now)}';
    final allTimeKey =
        'practice_best_streak_all_time_${widget.selectedLanguage == Language.en ? 'EN' : 'HE'}';

    bestStreakDaily = prefs.getInt(todayKey) ?? 0;
    bestStreakAllTime = prefs.getInt(allTimeKey) ?? 0;

    setState(() {});
  }

  /// שומר את הרצף
  Future<void> _saveStreaksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy_MM_dd');
    final todayKey =
        'practice_best_streak_daily_${widget.selectedLanguage == Language.en ? 'EN' : 'HE'}_${formatter.format(now)}';
    final allTimeKey =
        'practice_best_streak_all_time_${widget.selectedLanguage == Language.en ? 'EN' : 'HE'}';

    if (currentStreak > bestStreakDaily) {
      bestStreakDaily = currentStreak;
      await prefs.setInt(todayKey, bestStreakDaily);
    }
    if (currentStreak > bestStreakAllTime) {
      bestStreakAllTime = currentStreak;
      await prefs.setInt(allTimeKey, bestStreakAllTime);
    }
  }

  /// כאשר המשתמש עונה על שאלה
  Future<void> onAnswerSelected(bool correct) async {
    setState(() {
      showFeedback = true;
      isCorrectAnswer = correct;
      if (correct) {
        score++;
        currentStreak++;
        _confettiController.play();
      } else {
        currentStreak = 0;
      }
    });

    // עדכון שיא הרצף
    await _saveStreaksToPrefs();

    // החזרת הודעה ל-PracticePage (שם נספור את השאלה היומית)
    widget.onQuestionAnswered(correct);
  }

  /// מעבר לשאלה הבאה
  void nextQuestion() {
    setState(() {
      showFeedback = false;
      if (currentIndex < _allQuestions.length - 1) {
        currentIndex++;
      } else {
        // סיימנו את המאגר, נתחיל מהתחלה
        _initQuestions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_allQuestions.isEmpty) {
      return const Center(
        child: Text(
          'לא נמצאו שאלות לתרגול.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final currentQ = _allQuestions[currentIndex];
    final questionText = currentQ['question'] ?? '';
    final List<dynamic> answers = currentQ['answers'] as List<dynamic>? ?? [];

    return Stack(
      children: [
        // רקע
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFE3F2FD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // קונפטי
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.03,
            numberOfParticles: 25,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.orange
            ],
          ),
        ),
        // תוכן (שאלות או פידבק)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: showFeedback
              ? PracticeFeedback(
                  isCorrectAnswer: isCorrectAnswer,
                  score: score,
                  currentStreak: currentStreak,
                  bestStreakDaily: bestStreakDaily,
                  bestStreakAllTime: bestStreakAllTime,
                  onNextQuestion: nextQuestion,
                )
              : PracticeQuestions(
                  currentIndex: currentIndex,
                  totalQuestions: _allQuestions.length,
                  questionText: questionText,
                  answers: answers,
                  score: score,
                  currentStreak: currentStreak,
                  bestStreakDaily: bestStreakDaily,
                  bestStreakAllTime: bestStreakAllTime,
                  onAnswerSelected: onAnswerSelected,
                ),
        ),
      ],
    );
  }
}
