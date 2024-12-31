// lib/practice_questions.dart

import 'package:flutter/material.dart';

class PracticeQuestions extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final String questionText;
  final List<dynamic> answers;
  final int score;
  final int currentStreak;
  final int bestStreakDaily;
  final int bestStreakAllTime;
  final Function(bool) onAnswerSelected;

  const PracticeQuestions({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.questionText,
    required this.answers,
    required this.score,
    required this.currentStreak,
    required this.bestStreakDaily,
    required this.bestStreakAllTime,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // כותרת עליונה
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'שאלה ${currentIndex + 1} מתוך $totalQuestions',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'ניקוד: $score',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'רצף נוכחי: $currentStreak | שיא יומי: $bestStreakDaily | שיא כל הזמנים: $bestStreakAllTime',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // כרטיס השאלה
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // תשובות
        ...answers.map((answer) {
          final answerText = answer['text'] ?? '';
          final bool correct = answer['correct'] ?? false;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                side: BorderSide(color: Colors.blue.shade200, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => onAnswerSelected(correct),
              child: Text(
                answerText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
