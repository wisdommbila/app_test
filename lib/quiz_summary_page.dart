// quiz_summary_page.dart
import 'package:flutter/material.dart';

class QuizSummaryPage extends StatelessWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> questionsData;
  final int totalQuestions;
  final int finalScore;
  final int bestScore;

  const QuizSummaryPage({
    super.key,
    required this.quizTitle,
    required this.questionsData,
    required this.totalQuestions,
    required this.finalScore,
    required this.bestScore,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$quizTitle - סיכום'),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFE1F5FE)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // כותרת
                Text(
                  'סיכום השאלון',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                // ניקוד
                Text(
                  'ניקוד סופי: $finalScore מתוך $totalQuestions\nשיא קודם: $bestScore',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildAnswersList(),
                ),
                const SizedBox(height: 12),
                // כפתור חזרה
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('חזרה'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// מציג את כל השאלות, התשובה שנבחרה, והתשובה הנכונה
  Widget _buildAnswersList() {
    return ListView.builder(
      itemCount: questionsData.length,
      itemBuilder: (context, index) {
        final data = questionsData[index];
        final question = data['question'] as String? ?? '';
        final chosenIndex = data['chosenAnswerIndex'] as int;
        final answers = data['answers'] as List<dynamic>? ?? [];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // טקסט השאלה
              Text(
                'שאלה ${index + 1}: $question',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // רשימת תשובות
              ...answers.asMap().entries.map((entry) {
                final ansIndex = entry.key;
                final ansValue = entry.value;
                final text = ansValue['text'] ?? '';
                final bool correct = ansValue['correct'] ?? false;

                // בדיקה אם התשובה היא שנבחרה
                final bool isChosen = (ansIndex == chosenIndex);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAnswerColor(isChosen, correct),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getAnswerTextColor(isChosen, correct),
                      fontWeight:
                          isChosen ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// הגדרת צבע רקע לכל תשובה, בהתאם לשאלה שנבחרה והאם נכונה
  Color _getAnswerColor(bool isChosen, bool isCorrect) {
    if (isChosen && isCorrect) {
      return Colors.green.shade100;
    } else if (isChosen && !isCorrect) {
      return Colors.red.shade100;
    } else if (!isChosen && isCorrect) {
      // תשובה נכונה שלא נבחרה
      return Colors.green.shade50;
    } else {
      return Colors.grey.shade50;
    }
  }

  /// הגדרת צבע טקסט
  Color _getAnswerTextColor(bool isChosen, bool isCorrect) {
    if (isChosen && isCorrect) {
      return Colors.green.shade900;
    } else if (isChosen && !isCorrect) {
      return Colors.red.shade900;
    } else if (!isChosen && isCorrect) {
      return Colors.green.shade700;
    } else {
      return Colors.black87;
    }
  }
}
