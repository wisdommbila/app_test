import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // הוספת SharedPreferences

import 'sidebar.dart';
import 'stages_tab.dart';
import 'preferences_service.dart';
import 'practice_page.dart';
import 'models/language.dart'; // הגדרת enum Language
import 'language_switcher.dart'; // הקובץ החדש

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // הוספת WidgetsBindingObserver
  late TabController _tabController;

  // השפה הנבחרת, ברירת מחדל: עברית
  Language _selectedLanguage = Language.he;

  // נתונים עבור "שלבים"
  List<dynamic> stages = [];
  final Map<int, bool> completedStages = {};
  final Map<String, bool> completedQuizzes = {};

  // משתנים לניהול סטטוס פרימיום
  bool isPremium = false;
  bool isLoading = true; // לניהול מצב טעינה

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // הוספת Observer
    _tabController = TabController(length: 2, vsync: this);
    _initData(); // פונקציה שמבצעת את הטעינות הראשוניות
  }

  /// פונקציה אסינכרונית שמבצעת את הטעינות הראשוניות:
  /// 1. טוענת את השלבים (loadStagesData).
  /// 2. טוענת את סטטוס הפרימיום (_loadIsPremium).
  /// בסיום מעדכנת isLoading = false.
  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });

    await loadStagesData();
    await _loadIsPremium();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // הסרת Observer
    _tabController.dispose();
    super.dispose();
  }

  /// מטפל בשינויים במצב האפליקציה
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadIsPremium(); // טען מחדש את סטטוס הפרימיום כאשר האפליקציה חוזרת לפעולה
    }
  }

  /// מחזיר את שם הקובץ המתאים (למשל quiz_data_he.json או quiz_data_en.json)
  String getJsonFileName() {
    return _selectedLanguage == Language.en
        ? 'assets/quiz_data_en.json'
        : 'assets/quiz_data_he.json';
  }

  /// טוען את ה-JSON המתאים + סטטוס השלמה
  Future<void> loadStagesData() async {
    try {
      final String jsonFile = getJsonFileName();
      final String response = await rootBundle.loadString(jsonFile);
      final data = json.decode(response);
      final loadedStages = data['stages'] as List<dynamic>;

      completedQuizzes.clear();
      completedStages.clear();

      // טוען את סטטוס השלמת כל השאלונים
      for (var stage in loadedStages) {
        for (var quiz in stage['quizzes']) {
          final quizTitle = quiz['title'] as String;
          final isCompleted = await PreferencesService.isQuizCompleted(
            quizTitle,
            _selectedLanguage,
          );
          completedQuizzes[quizTitle] = isCompleted;
        }
      }

      // מעדכן את סטטוס השלמת השלבים
      for (var stage in loadedStages) {
        final stageNumber = stage['stage'] as int;
        final quizzes = stage['quizzes'] as List<dynamic>;
        final allQuizzesCompleted =
            quizzes.every((quiz) => completedQuizzes[quiz['title']] ?? false);
        completedStages[stageNumber] = allQuizzesCompleted;
      }

      if (!mounted) return;
      setState(() {
        stages = loadedStages;
      });
    } catch (error) {
      debugPrint('Error loading JSON data: $error');
    }
  }

  /// כשיוצאים וחוזרים למסך הראשי (ייתכן הושלם שאלון)
  Future<void> reloadDataIfNeeded() async {
    await loadStagesData();
  }

  bool isStageCompleted(int stageNumber) {
    return completedStages[stageNumber] ?? false;
  }

  /// סימון שאלון כ"הושלם"
  Future<void> markQuizAsCompleted(String quizTitle) async {
    await PreferencesService.markQuizAsCompleted(quizTitle, _selectedLanguage);
    setState(() {
      completedQuizzes[quizTitle] = true;
      updateStageCompletionStatus();
    });
  }

  /// עדכון סטטוס השלמת שלבים
  void updateStageCompletionStatus() {
    bool anyChange = false;
    for (var stage in stages) {
      final stageNumber = stage['stage'] as int;
      final quizzes = stage['quizzes'] as List<dynamic>;

      final allQuizzesCompleted =
          quizzes.every((quiz) => completedQuizzes[quiz['title']] ?? false);

      if (completedStages[stageNumber] != allQuizzesCompleted) {
        completedStages[stageNumber] = allQuizzesCompleted;
        anyChange = true;
      }
    }
    if (anyChange) {
      setState(() {});
    }
  }

  /// כאשר המשתמש בוחר שפה חדשה
  Future<void> onLanguageSelected(Language newLang) async {
    setState(() {
      _selectedLanguage = newLang;
      isLoading = true; // הצגת מצב טעינה לפני הטעינה מחדש
    });
    // טוענים שלבים וסטטוס פרימיום מחדש
    await loadStagesData();
    await _loadIsPremium();
    setState(() {
      isLoading = false;
    });
  }

  /// טוען את סטטוס הפרימיום מ־SharedPreferences
  Future<void> _loadIsPremium() async {
    final prefs = await SharedPreferences.getInstance();
    bool premiumStatus = prefs.getBool('isPremium') ?? false;
    if (premiumStatus != isPremium) {
      setState(() {
        isPremium = premiumStatus;
      });
      debugPrint('[HomePage] loaded isPremium=$isPremium');
    }
  }

  @override
  Widget build(BuildContext context) {
    // נשארים ב-RTL
    const textDirection = TextDirection.rtl;

    // כותרת הדף קבועה
    final appBarTitle = 'פסיכו-לקסיקון';

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80.0,
          titleSpacing: 8.0,
          centerTitle: false,
          title: Row(
            children: [
              if (isPremium)
                Icon(
                  Icons.workspace_premium_sharp,
                  color: const Color(0xFFFFD700), // זהב בולט
                  size: 28,
                ),
              const SizedBox(width: 8),
              Text(
                appBarTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isPremium
                      ? const Color(0xFFFFD700)
                      : Colors.black, // כותרת זהב אם פרימיום
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LanguageSwitcherButton(
                selectedLanguage: _selectedLanguage,
                onLanguageSelected: onLanguageSelected,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'שלבים'),
              Tab(icon: Icon(Icons.flash_on), text: 'תרגול'),
            ],
          ),
        ),
        drawer: const Sidebar(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // מסך השלבים
                  StagesTab(
                    stages: stages,
                    completedStages: completedStages,
                    completedQuizzes: completedQuizzes,
                    markQuizAsCompleted: markQuizAsCompleted,
                    reloadDataIfNeeded: reloadDataIfNeeded,
                    selectedLanguage: _selectedLanguage,
                    isSubscribed: isPremium,
                  ),

                  // מסך התרגול
                  PracticePage(
                    key: ValueKey('practice_${_selectedLanguage.name}'),
                    stages: stages,
                    selectedLanguage: _selectedLanguage,
                  ),
                ],
              ),
      ),
    );
  }
}
