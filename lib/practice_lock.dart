// lib/practice_lock.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'subscription_page.dart';
import 'models/language.dart';

class PracticeLock extends StatelessWidget {
  final DateTime? nextFreePractice;
  final Language selectedLanguage;

  const PracticeLock({
    super.key,
    this.nextFreePractice,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final unlockTime =
        nextFreePractice ?? DateTime(now.year, now.month, now.day + 1);
    final unlockStr = DateFormat('dd/MM/yyyy 00:00').format(unlockTime);

    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'הגעת למקסימום 10 שאלות היומיות שלך!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'ניתן לתרגל שוב בחינם מחר, בתאריך:\n$unlockStr',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'לרכישת מנוי פרימיום ללא הגבלה',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
