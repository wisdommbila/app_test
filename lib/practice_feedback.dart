// lib/practice_feedback.dart

import 'package:flutter/material.dart';

class PracticeFeedback extends StatelessWidget {
  final bool isCorrectAnswer;
  final int score;
  final int currentStreak;
  final int bestStreakDaily;
  final int bestStreakAllTime;
  final VoidCallback onNextQuestion;

  const PracticeFeedback({
    super.key,
    required this.isCorrectAnswer,
    required this.score,
    required this.currentStreak,
    required this.bestStreakDaily,
    required this.bestStreakAllTime,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrectAnswer ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: isCorrectAnswer ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isCorrectAnswer ? 'תשובה נכונה!' : 'תשובה שגויה...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  isCorrectAnswer ? Colors.green.shade800 : Colors.red.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onNextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'הבא',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('ניקוד (בסשן): $score', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('רצף נוכחי: $currentStreak',
              style: TextStyle(fontSize: 16, color: Colors.blue.shade900)),
          const SizedBox(height: 8),
          Text('השיא היומי: $bestStreakDaily',
              style: TextStyle(fontSize: 16, color: Colors.orange.shade800)),
          const SizedBox(height: 8),
          Text('השיא בכל הזמנים: $bestStreakAllTime',
              style: TextStyle(fontSize: 16, color: Colors.green.shade800)),
        ],
      ),
    );
  }
}
