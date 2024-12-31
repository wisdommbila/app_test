// lib/subscription_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isProcessing = false; // האם אנו במהלך רכישה

  @override
  Widget build(BuildContext context) {
    // RTL
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מסך רכישת מנוי פרימיום'),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(top: 32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'מנוי פרימיום חודשי מתחדש',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'מנוי פרימיום מעניק לך גישה לכל השלבים באפליקציה ללא הגבלה,'
                  ' וגם תרגול של יותר מ-10 שאלות ביום ללא הגבלה.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isProcessing ? null : _purchaseSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'רכוש מנוי חודשי מתחדש',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'התשלום יתבצע דרך חנות האפליקציות,\n'
                  'לא יידרשו פרטים נוספים כאן.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// סימולציית רכישה (בפועל יש לממש עם `in_app_purchase` וכד').
  Future<void> _purchaseSubscription() async {
    setState(() {
      isProcessing = true;
    });
    // סימולציה של רכישה
    await Future.delayed(const Duration(seconds: 2));

    // כאן תתבצע הרכישה בפועל עם `in_app_purchase`.
    // בהצלחה => נשמור 'isPremium = true'
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', true);

    setState(() {
      isProcessing = false;
    });

    // חוזרים אחורה עם הצלחה
    Navigator.pop(context);
  }
}
