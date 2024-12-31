// lib/language_switcher.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'models/language.dart';
import 'preferences_service.dart';

/// פונקציה שתציג את דיאלוג בחירת השפה, ותחזיר את [Language] הנבחר, או null אם בוטל.
Future<Language?> showLanguageDialog(
  BuildContext context,
  Language currentLanguage,
  Future<void> Function(Language newLang)? onLanguageSelected,
) async {
  // משתנה זמני לשמירת השפה
  Language tempLanguage = currentLanguage;

  final bool? userConfirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'בחר מצב לימוד',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'בחר האם תרצה ללמוד אוצר מילים בעברית או באנגלית.\nלכל מצב לימוד יש התקדמות ושיאים נפרדים.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [
                      tempLanguage == Language.he,
                      tempLanguage == Language.en,
                    ],
                    onPressed: (int index) {
                      setState(() {
                        tempLanguage = index == 0 ? Language.he : Language.en;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: Colors.blue.shade600,
                    color: Colors.blue.shade600,
                    constraints: const BoxConstraints(
                      minHeight: 50.0,
                      minWidth: 120.0,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/flags/israel.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.flag,
                                  color: Colors.white);
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'עברית',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/flags/usa.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.flag,
                                  color: Colors.white);
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'אנגלית',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'אישור',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
              ),
              child: const Text(
                'ביטול',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (userConfirmed == true && tempLanguage != currentLanguage) {
    if (onLanguageSelected != null) {
      // נקרא לפונקציה שמעבדת את בחירת השפה
      await onLanguageSelected(tempLanguage);
    }
    return tempLanguage;
  }
  return null; // אם בוטל
}

/// כפתור קטן ומעוצב שמציג את השפה הנבחרת, ובלחיצה פותח את הדיאלוג.
class LanguageSwitcherButton extends StatelessWidget {
  final Language selectedLanguage;
  final Future<void> Function(Language newLang) onLanguageSelected;

  const LanguageSwitcherButton({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // נקרא לפונקציה showLanguageDialog שמוגדרת למעלה
        final newLang = await showLanguageDialog(
          context,
          selectedLanguage,
          onLanguageSelected,
        );
        // אין צורך לטפל פה בתוצאה, כי onLanguageSelected מטפלת בזה.
      },
      icon: Image.asset(
        selectedLanguage == Language.he
            ? 'assets/flags/israel.png'
            : 'assets/flags/usa.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.flag, color: Colors.white);
        },
      ),
      label: Text(
        selectedLanguage == Language.he ? 'עברית' : 'אנגלית',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
