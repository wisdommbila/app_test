// lib/quiz_page.dart

import 'package:flutter/material.dart';
import 'preferences_service.dart';
import 'quiz_summary_page.dart';
import 'models/language.dart'; // ייבוא קובץ השפה

class QuizPage extends StatefulWidget {
  final List<dynamic> questions;
  final String quizTitle; // שם השאלון למעקב
  final Language selectedLanguage; // הוספת פרמטר שפה

  const QuizPage({
    super.key,
    required this.questions,
    required this.quizTitle,
    required this.selectedLanguage, // קבלה דרך הקונסטרקטור
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int currentQuestionIndex = 0;
  int score = 0;
  int bestScore = 0; // שיא תשובות נכונות עד כה
  final List<Map<String, dynamic>> _answeredQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadBestScore();

    // הגדרת האנימציות הקלות
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// טוען את השיא (best score) הקיים עבור שאלון זה
  Future<void> _loadBestScore() async {
    final storedBest = await PreferencesService.getQuizBestScore(
      widget.quizTitle,
      widget.selectedLanguage, // העברת שפה
    );
    if (!mounted) return; // בדיקה לפני setState
    setState(() {
      bestScore = storedBest;
    });
  }

  /// בודק תשובה
  void answerQuestion(int chosenIndex, bool correct) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    final answers = currentQuestion['answers'] as List<dynamic>;

    // שמירת המידע לתצוגה במסך הסיכום
    _answeredQuestions.add({
      "question": currentQuestion['question'],
      "answers": answers,
      "chosenAnswerIndex": chosenIndex,
    });

    if (correct) {
      setState(() {
        score++;
      });
    }

    // אפקט מעבר לשאלה הבאה - reset האנימציה
    _animationController.reset();
    _animationController.forward();

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // בסיום
      _goToSummaryPage();
    }
  }

  /// מעבר למסך סיכום השאלון
  Future<void> _goToSummaryPage() async {
    // בודקים אם צריך לעדכן שיא
    if (score > bestScore) {
      await PreferencesService.setQuizBestScore(
        widget.quizTitle,
        score,
        widget.selectedLanguage, // העברת שפה
      );
      if (!mounted) return; // בדיקה לפני setState
      setState(() {
        bestScore = score;
      });
    }

    final totalQuestions = widget.questions.length;
    final allCorrect = (score == totalQuestions);

    // מעבר למסך הסיכום, ושם נחליט כיצד לחזור ל-StagePage
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryPage(
          quizTitle: widget.quizTitle,
          questionsData: _answeredQuestions,
          totalQuestions: totalQuestions,
          finalScore: score,
          bestScore: bestScore,
        ),
      ),
    );

    // בדיקה אם הקומפוננטה עדיין מחוברת
    if (!mounted) return;

    // מעבר חזרה ל-StagePage עם תוצאה
    Navigator.pop(context, allCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.questions.length;
    final currentQuestion = widget.questions.isNotEmpty
        ? widget.questions[currentQuestionIndex]
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quizTitle),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFE0F7FA)],
            ),
          ),
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => Opacity(
              opacity: _fadeAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
            child: Column(
              children: [
                _buildProgressBar(totalQuestions),
                const SizedBox(height: 16),
                if (currentQuestion != null)
                  _buildQuestionContainer(currentQuestion),
                const SizedBox(height: 24),
                if (currentQuestion != null)
                  _buildAnswerButtons(currentQuestion),
                const Spacer(),
                _buildQuestionCounter(totalQuestions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// פס התקדמות והצגת מידע (שאלה נוכחית, שיא, ניקוד זמני)
  Widget _buildProgressBar(int totalQuestions) {
    final progress =
        (currentQuestionIndex + 1) / (totalQuestions == 0 ? 1 : totalQuestions);

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor:
              Colors.grey.withAlpha(51), // החלפת withOpacity ל-withAlpha
          color: Colors.blue,
          minHeight: 8.0,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'שיא: $bestScore',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            Text(
              'נקודות: $score',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ],
        ),
      ],
    );
  }

  /// תיבת השאלה
  Widget _buildQuestionContainer(dynamic currentQuestion) {
    final questionText = currentQuestion['question'] ?? 'שאלה לא נמצאה';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(25), // החלפת withOpacity ל-withAlpha
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        questionText,
        style: TextStyle(
          fontSize: 20,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// בניית כפתורי תשובות
  Widget _buildAnswerButtons(dynamic currentQuestion) {
    final answers = currentQuestion['answers'] as List<dynamic>? ?? [];

    return Column(
      children: answers.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final answer = entry.value;
        final text = answer['text'] ?? '';
        final bool correct = answer['correct'] ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[900],
              shadowColor:
                  Colors.grey.withAlpha(51), // החלפת withOpacity ל-withAlpha
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              side: BorderSide(color: Colors.blue.shade200, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => answerQuestion(index, correct),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// כיתוב "שאלה X מתוך Y"
  Widget _buildQuestionCounter(int totalQuestions) {
    return Text(
      totalQuestions == 0
          ? 'אין שאלות'
          : 'שאלה ${currentQuestionIndex + 1} מתוך $totalQuestions',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}
