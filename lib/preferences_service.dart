// lib/preferences_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// הוספנו את הייבוא הזה כדי להכיר את enum Language:
import 'models/language.dart';

/// שירות לניהול העדפות המשתמש באמצעות SharedPreferences.
/// כולל שמירה ובדיקה של סטטוס השלמת שאלונים ושלבים,
/// וכן שמירת והחזרת שיאים לכל שאלון.
class PreferencesService {
  // פונקציה לקבלת קידומת לשפה
  static String _languagePrefix(Language lang) {
    return lang == Language.en ? 'EN' : 'HE';
  }

  /// יצירת מפתח לשאלון בהתאם לשפה
  static String _quizKey(String quizTitle, Language lang) {
    return 'quiz_completed_${_languagePrefix(lang)}_$quizTitle';
  }

  /// יצירת מפתח לשלב בהתאם לשפה
  static String _stageKey(int stageNumber, Language lang) {
    return 'stage_completed_${_languagePrefix(lang)}_$stageNumber';
  }

  /// יצירת מפתח לשיא השאלון בהתאם לשפה
  static String _quizScoreKey(String quizTitle, Language lang) {
    return 'quiz_best_score_${_languagePrefix(lang)}_$quizTitle';
  }

  /// יצירת מפתח למנוי פרימיום
  static String _premiumKey() {
    return 'isPremium';
  }

  /// מסמן שאלון כ"הושלם" בהתאם לשפה
  static Future<void> markQuizAsCompleted(
    String quizTitle,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_quizKey(quizTitle, lang), true);
    } catch (e) {
      debugPrint('Error marking quiz as completed: $e');
    }
  }

  /// בודק האם שאלון הושלם בשפה המסוימת
  static Future<bool> isQuizCompleted(
    String quizTitle,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_quizKey(quizTitle, lang)) ?? false;
    } catch (e) {
      debugPrint('Error checking quiz completion: $e');
      return false;
    }
  }

  /// מסמן שלב כ"הושלם" בהתאם לשפה
  static Future<void> markStageAsCompleted(
    int stageNumber,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_stageKey(stageNumber, lang), true);
    } catch (e) {
      debugPrint('Error marking stage as completed: $e');
    }
  }

  /// בודק האם שלב הושלם בשפה המסוימת
  static Future<bool> isStageCompleted(
    int stageNumber,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_stageKey(stageNumber, lang)) ?? false;
    } catch (e) {
      debugPrint('Error checking stage completion: $e');
      return false;
    }
  }

  /// שומר שיא ניקוד עבור שאלון בהתאם לשפה
  static Future<void> setQuizBestScore(
    String quizTitle,
    int score,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBest = prefs.getInt(_quizScoreKey(quizTitle, lang)) ?? 0;
      if (score > currentBest) {
        await prefs.setInt(_quizScoreKey(quizTitle, lang), score);
      }
    } catch (e) {
      debugPrint('Error setting quiz best score: $e');
    }
  }

  /// מחזיר שיא ניקוד עבור שאלון בהתאם לשפה
  static Future<int> getQuizBestScore(
    String quizTitle,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_quizScoreKey(quizTitle, lang)) ?? 0;
    } catch (e) {
      debugPrint('Error getting quiz best score: $e');
      return 0;
    }
  }

  /// איפוס סטטוס השלמת שאלון בהתאם לשפה
  static Future<void> resetQuizCompletion(
    String quizTitle,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_quizKey(quizTitle, lang));
    } catch (e) {
      debugPrint('Error resetting quiz completion: $e');
    }
  }

  /// איפוס שיא ניקוד של שאלון בהתאם לשפה
  static Future<void> resetQuizBestScore(
    String quizTitle,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_quizScoreKey(quizTitle, lang));
    } catch (e) {
      debugPrint('Error resetting quiz best score: $e');
    }
  }

  /// איפוס סטטוס השלמת שלב בהתאם לשפה
  static Future<void> resetStageCompletion(
    int stageNumber,
    Language lang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_stageKey(stageNumber, lang));
    } catch (e) {
      debugPrint('Error resetting stage completion: $e');
    }
  }

  /// איפוס מוחלט של כל ההעדפות
  static Future<void> resetAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error resetting all preferences: $e');
    }
  }

  /// בודק אם המשתמש הוא פרימיום
  static Future<bool> getIsPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_premiumKey()) ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// מסמן את המשתמש כפרימיום / לא פרימיום
  static Future<void> setIsPremium(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey(), value);
    } catch (e) {
      debugPrint('Error setting premium status: $e');
    }
  }
}
