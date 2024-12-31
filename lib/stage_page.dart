// lib/stage_page.dart

import 'package:flutter/material.dart';
import 'quiz_page.dart';
import 'preferences_service.dart';
import 'models/language.dart'; // ייבוא קובץ השפה

class StagePage extends StatefulWidget {
  final List<dynamic> quizzes;
  final int stageNumber;
  final Language selectedLanguage; // הוספת פרמטר שפה

  const StagePage({
    super.key,
    required this.quizzes,
    required this.stageNumber,
    required this.selectedLanguage, // קבלה דרך הקונסטרקטור
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  /// מפת השלמות (completed) + מפת שיאים (best scores)
  final Map<String, bool> completedQuizzes = {};
  final Map<String, int> bestScores = {};

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  /// טוען מ־SharedPreferences עבור כל השאלונים בדף הנוכחי
  Future<void> _loadQuizData() async {
    for (var quiz in widget.quizzes) {
      final quizTitle = quiz['title'] as String;

      // בדיקה אם השאלון הושלם
      final isCompleted = await PreferencesService.isQuizCompleted(
        quizTitle,
        widget.selectedLanguage, // העברת שפה
      );

      // בדיקה מה השיא הקיים בשאלון (אם לא מוגדר, שיא = 0)
      final bestScore = await PreferencesService.getQuizBestScore(
        quizTitle,
        widget.selectedLanguage, // העברת שפה
      );

      if (!mounted) return; // בדיקה לפני setState

      setState(() {
        completedQuizzes[quizTitle] = isCompleted;
        bestScores[quizTitle] = bestScore;
      });
    }
  }

  bool _isQuizCompleted(String quizTitle) {
    return completedQuizzes[quizTitle] ?? false;
  }

  /// עדכון סטטוס השאלון והשיא
  Future<void> _markQuizAsCompleted(String quizTitle) async {
    await PreferencesService.markQuizAsCompleted(
      quizTitle,
      widget.selectedLanguage, // העברת שפה
    );
    final bestScore = await PreferencesService.getQuizBestScore(
      quizTitle,
      widget.selectedLanguage, // העברת שפה
    );

    if (!mounted) return; // בדיקה לפני setState

    setState(() {
      completedQuizzes[quizTitle] = true;
      bestScores[quizTitle] = bestScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // תמיכה ב-RTL
      child: Scaffold(
        appBar: AppBar(
          title: Text('שלב ${widget.stageNumber}'),
          centerTitle: true,
        ),
        body: widget.quizzes.isEmpty
            ? const Center(
                child: Text(
                  'אין שאלונים בשלב זה.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFB2EBF2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: buildQuizzesGrid(),
              ),
      ),
    );
  }

  /// תצוגת השאלונים ב־GridView
  Widget buildQuizzesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.quizzes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 כרטיסים בשורה
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final quiz = widget.quizzes[index];
        final quizTitle = quiz['title'] as String;
        final isCompleted = _isQuizCompleted(quizTitle);
        final bestScore = bestScores[quizTitle] ?? 0;
        final questionsCount = (quiz['questions'] as List<dynamic>).length;

        return buildQuizCard(
          quizTitle: quizTitle,
          isCompleted: isCompleted,
          bestScore: bestScore,
          questionsCount: questionsCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizPage(
                  questions: quiz['questions'] as List<dynamic>,
                  quizTitle: quizTitle,
                  selectedLanguage: widget.selectedLanguage, // העברת שפה
                ),
              ),
            ).then((allCorrect) async {
              if (!mounted) return; // בדיקה לפני שימוש ב-context

              if (allCorrect == true) {
                // סימון שהשאלון הושלם בהצלחה (ירוק)
                await _markQuizAsCompleted(quizTitle);
              }

              // בדיקה אם כל השאלונים בשלב הושלמו
              final allQuizzesCompleted = widget.quizzes.every(
                (q) => _isQuizCompleted(q['title'] as String),
              );

              if (allQuizzesCompleted) {
                Navigator.pop(context, true); // stage סומן כירוק בעמוד הראשי
              } else {
                // חזרה מהשאלון כדי לרענן
                setState(() {});
              }
            });
          },
        );
      },
    );
  }

  /// כרטיס יפה לשאלון ב־GridView
  Widget buildQuizCard({
    required String quizTitle,
    required bool isCompleted,
    required int bestScore,
    required int questionsCount,
    required VoidCallback onTap,
  }) {
    // צבעי רקע שונים עבור כרטיס מושלם או לא
    final Color bgColor =
        isCompleted ? Colors.green.shade50 : Colors.blue.shade50;
    final Color borderColor =
        isCompleted ? Colors.green.shade300 : Colors.blue.shade300;
    final IconData iconData =
        isCompleted ? Icons.check_circle : Icons.quiz_outlined;

    return Material(
      color: bgColor,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 40,
                color: borderColor,
              ),
              const SizedBox(height: 12),
              Text(
                quizTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              // מציגים אם מושלם או לא
              Text(
                isCompleted ? 'הושלם!' : 'לא הושלם',
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted
                      ? Colors.green.shade700
                      : Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // מציגים את השיא "bestScore" מתוך סך השאלות
              Text(
                'שיא תשובות נכונות: $bestScore / $questionsCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
