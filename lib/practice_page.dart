// lib/practice_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/language.dart';
import 'practice_main.dart';
import 'practice_lock.dart';

class PracticePage extends StatefulWidget {
  final List<dynamic> stages;
  final Language selectedLanguage;

  const PracticePage({
    super.key,
    required this.stages,
    required this.selectedLanguage,
  });

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool isPremium = false;
  int dailyUsedQuestions = 0;
  bool isLoading = true; // נשתמש בו כדי להציג טעינה

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// טוען את סטטוס הפרימיום ואת ספירת השאלות היומיות
  Future<void> _loadData() async {
    await _loadIsPremium();
    await _loadDailyUsage();
    setState(() {
      isLoading = false;
    });
  }

  /// בודק אם המשתמש פרימיום מ־SharedPreferences
  Future<void> _loadIsPremium() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium = prefs.getBool('isPremium') ?? false;
    debugPrint('[PracticePage] loaded isPremium=$isPremium');
  }

  /// בודק ומאפס את הספירה היומית אם היום השתנה
  Future<void> _loadDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final storedDateStr = prefs.getString('practice_daily_date');
    dailyUsedQuestions = prefs.getInt('practice_daily_usage') ?? 0;

    debugPrint(
      '[PracticePage] loaded dailyUsedQuestions=$dailyUsedQuestions (date=$storedDateStr)',
    );

    // אם אין תאריך שמור או שהתאריך השמור != היום => איפוס
    if (storedDateStr == null || storedDateStr != todayStr) {
      dailyUsedQuestions = 0;
      await prefs.setString('practice_daily_date', todayStr);
      await prefs.setInt('practice_daily_usage', dailyUsedQuestions);
      debugPrint('[PracticePage] Reset dailyUsedQuestions=0 for new day');
    }
  }

  /// מגדיל את ספירת השאלות (אם לא פרימיום)
  Future<void> _incrementDailyUsage() async {
    if (isPremium) return; // למנוי פרימיום אין הגבלה

    final prefs = await SharedPreferences.getInstance();
    dailyUsedQuestions++;
    await prefs.setInt('practice_daily_usage', dailyUsedQuestions);
    debugPrint(
      '[PracticePage] incrementDailyUsage => dailyUsedQuestions=$dailyUsedQuestions',
    );

    setState(() {
      // כדי שנעדכן את המסך במידה וחצינו את ה־10
    });
  }

  /// Callback שמגיע מ־PracticeMain בכל פעם שמשתמש עונה על שאלה
  void _onQuestionAnswered(bool correct) async {
    // מגדיל את הספירה ב־1
    await _incrementDailyUsage();
  }

  /// האם משתמש עדיין יכול לתרגל היום?
  bool get canPracticeToday {
    if (isPremium) return true; // פרימיום ללא הגבלה
    return dailyUsedQuestions < 10;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // בזמן הטעינה הראשונית
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('תרגול'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (canPracticeToday) ...[
            // המשתמש יכול לתרגל
            PracticeMain(
              stages: widget.stages,
              selectedLanguage: widget.selectedLanguage,
              onQuestionAnswered: _onQuestionAnswered,
            ),
          ] else ...[
            // הגיע ל-10 שאלות ביום
            PracticeLock(
              selectedLanguage: widget.selectedLanguage,
            ),
          ],
        ],
      ),
    );
  }
}
