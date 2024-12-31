import 'package:flutter/material.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // כאן ניתן לבצע פעולות מוקדמות, אם צריך, לפני הרצת האפליקציה
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'פסיכו-לקסיקון',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto', // הוספת פונט מותאם (ודא שקיים בפרויקט)
      ),
      home: const HomePage(), // עמוד הבית
      debugShowCheckedModeBanner: false, // הסרת הבאנר לדיבוג
    );
  }
}
