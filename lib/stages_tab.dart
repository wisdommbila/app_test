import 'package:flutter/material.dart';

import 'stage_page.dart';
import 'subscription_page.dart'; // עמוד רכישת המנוי החדש
import 'models/language.dart';

class StagesTab extends StatelessWidget {
  final List<dynamic> stages;
  final Map<int, bool> completedStages;
  final Map<String, bool> completedQuizzes;
  final Function(String) markQuizAsCompleted;
  final Future<void> Function() reloadDataIfNeeded;
  final Language selectedLanguage;
  final bool isSubscribed; // הוספת פרמטר לבדיקת מנוי

  const StagesTab({
    super.key,
    required this.stages,
    required this.completedStages,
    required this.completedQuizzes,
    required this.markQuizAsCompleted,
    required this.reloadDataIfNeeded,
    required this.selectedLanguage,
    required this.isSubscribed, // קבלה דרך הקונסטרקטור
  });

  bool isStageCompleted(int stageNumber) {
    return completedStages[stageNumber] ?? false;
  }

  // פונקציה שתבדוק אם שלב נעול
  bool isStageLocked(int stageNumber) {
    if (isSubscribed) {
      // משתמש מנוי - כל השלבים פתוחים
      return false;
    } else {
      // משתמש לא מנוי - רק שלב 1 פתוח
      return stageNumber != 1;
    }
  }

  Widget buildGlobalStatus() {
    int totalQuizzes = 0;
    int completedCount = 0;

    for (var stage in stages) {
      final quizzes = stage['quizzes'] as List<dynamic>;
      totalQuizzes += quizzes.length;
      for (var quiz in quizzes) {
        if (completedQuizzes[quiz['title'] as String] == true) {
          completedCount++;
        }
      }
    }

    final double progress =
        totalQuizzes == 0 ? 0 : (completedCount / totalQuizzes).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'סיכום ההתקדמות שלך',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 8.0,
          ),
          const SizedBox(height: 8),
          Text(
            'הושלמו $completedCount מתוך $totalQuizzes שאלונים',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStageCard({
    required BuildContext context,
    required int stageNumber,
    required bool isCompleted,
    required int stageCompletedCount,
    required int stageTotalCount,
    required List<dynamic> quizzes,
    required bool locked,
  }) {
    final double stageProgress = stageTotalCount == 0
        ? 0
        : (stageCompletedCount / stageTotalCount).clamp(0.0, 1.0);

    // אם השלב נעול, נשתמש בעיצוב "נעול"
    final Color bgColor = locked
        ? Colors.grey.shade300
        : (isCompleted ? Colors.green.shade50 : Colors.red.shade50);
    final Color iconColor = locked
        ? Colors.grey
        : (isCompleted ? Colors.green.shade300 : Colors.red.shade300);
    final IconData iconData =
        locked ? Icons.lock : (isCompleted ? Icons.check : Icons.clear);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: locked
              ? () {
                  // לחיצה על שלב נעול => מעבר לדף המנוי
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                }
              : () async {
                  // לחיצה על שלב פתוח => מעבר לעמוד השלב
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StagePage(
                        quizzes: quizzes,
                        stageNumber: stageNumber,
                        selectedLanguage: selectedLanguage,
                      ),
                    ),
                  );
                  await reloadDataIfNeeded();
                },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: iconColor,
                      radius: 24,
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'שלב $stageNumber',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: locked
                              ? Colors.grey.shade700
                              : isCompleted
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  locked
                      ? 'השלב נעול, נא לרכוש מנוי לפתיחה'
                      : 'נפתרו $stageCompletedCount מתוך $stageTotalCount שאלונים',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                if (!locked)
                  LinearProgressIndicator(
                    value: stageProgress,
                    backgroundColor: Colors.grey[300],
                    color: isCompleted ? Colors.green : Colors.blue,
                    minHeight: 6.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStagesList(BuildContext context) {
    return ListView.builder(
      itemCount: stages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildGlobalStatus();
        }

        final stageIndex = index - 1;
        final stage = stages[stageIndex];
        final stageNumber = stage['stage'] as int;
        final quizzes = stage['quizzes'] as List<dynamic>;
        final isCompleted = isStageCompleted(stageNumber);

        // ספירת השאלונים שהושלמו בשלב הנוכחי
        final stageCompletedCount = quizzes.where((quiz) {
          final quizTitle = quiz['title'] as String;
          return completedQuizzes[quizTitle] == true;
        }).length;
        final int stageTotalCount = quizzes.length;

        // בדיקה אם השלב נעול
        final bool locked = isStageLocked(stageNumber);

        return buildStageCard(
          context: context,
          stageNumber: stageNumber,
          isCompleted: isCompleted,
          stageCompletedCount: stageCompletedCount,
          stageTotalCount: stageTotalCount,
          quizzes: quizzes,
          locked: locked,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return stages.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildStagesList(context);
  }
}
