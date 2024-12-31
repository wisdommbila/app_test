import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A8DFF), // כחול כהה
                Color(0xFF87CEFA), // כחול בהיר
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // כותרת מעוצבת לסרגל הצד
                buildDrawerHeader(),
                const Divider(color: Colors.white54, thickness: 1),
                // כפתורי התפריט עם סקרול
                Expanded(
                  child: ListView(
                    children: [
                      buildDrawerOption(
                        context,
                        icon: Icons.info_outline,
                        text: 'אודות האפליקציה',
                        title: 'אודות האפליקציה',
                        content: '''
ברוכים הבאים ל"פסיכו-לקסיקון"!

האפליקציה נועדה לסייע לך בשיפור אוצר המילים בעברית ובאנגלית, במיוחד לקראת מבחן הפסיכומטרי.
באמצעות האפליקציה, תוכלו לתרגל שאלוני מילים, לעקוב אחר התקדמותכם ולשפר את יכולותיכם הלשוניות לאורך זמן.

מומלץ לתרגל באופן יומיומי ולהתנסות במגוון השאלונים המוצעים.
מאחל לכם חוויית לימוד מהנה והצלחה רבה!
                        ''',
                      ),
                      buildDrawerOption(
                        context,
                        icon: Icons.contact_mail,
                        text: 'צור קשר',
                        title: 'צור קשר',
                        content: '''
בכל שאלה, הערה או הצעה לשיפור, ניתן לפנות:

• אימייל: afek10@gmail.com

אשמח לסייע ולשפר את חוויית המשתמש ככל האפשר.
                        ''',
                      ),
                      buildDrawerOption(
                        context,
                        icon: Icons.description,
                        text: 'תנאי שימוש',
                        title: 'תנאי שימוש',
                        content: '''
1. השימוש באפליקציה מיועד למטרות אישיות בלבד, ואין להעביר או לשכפל אותה ללא אישור.
2. אין להעתיק או להשתמש בתכני האפליקציה לצרכים מסחריים ללא רשות.
3. השימוש באפליקציה הוא על אחריות המשתמש בלבד, והמפתח לא יישא באחריות לנזקים אפשריים.
4. למידע נוסף או שאלות, ניתן ליצור קשר באימייל: afek10@gmail.com.
                        ''',
                      ),
                      buildDrawerOption(
                        context,
                        icon: Icons.privacy_tip,
                        text: 'מדיניות פרטיות',
                        title: 'מדיניות פרטיות',
                        content: '''
הפרטיות שלך חשובה לנו:

1. אנו שומרים מידע הדרוש להתאמת חוויית המשתמש, כגון תוצאות תרגול ונתוני התקדמות.
2. המידע אינו נמסר לצד שלישי, למעט אם יידרש על פי חוק או בהסכמתך.
3. אבטחת המידע מתבצעת באמצעים טכנולוגיים מתקדמים, בהתאם לסטנדרטים המקובלים.

למידע נוסף או בקשות בנושא פרטיות, פנה לאימייל: afek10@gmail.com.
                        ''',
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54, thickness: 1),
                // הסרנו את כפתור ההתנתקות
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// כותרת מעוצבת לסרגל הצד
  Widget buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3C72), // כחול עמוק
            Color(0xFF2A5298), // כחול בינוני
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30, // 30
            backgroundColor: Colors.white,
            child: Icon(
              Icons.school,
              size: 30, // 30
              color: Color(0xFF2A5298),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            // משתמש ב-Expanded כדי למנוע Overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'פסיכו-לקסיקון',
                  style: const TextStyle(
                    fontSize: 24, // 24
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  // הסרנו overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 4),
                Text(
                  'האפליקציה לשיפור אוצר המילים לפסיכומטרי.',
                  style: const TextStyle(
                    fontSize: 14, // 14
                    color: Colors.white70,
                  ),
                  // הסרנו overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// אלמנט תפריט (כפתור) עבור סרגל הצד
  Widget buildDrawerOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String title,
    required String content,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16, // 16
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        // הסרנו overflow: TextOverflow.ellipsis
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {
        Navigator.pop(context); // סגור את ה־Drawer
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (BuildContext ctx) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // כותרת וחצן סגירה
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20, // 20
                              fontWeight: FontWeight.bold,
                            ),
                            // הסרנו overflow: TextOverflow.ellipsis
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // תצוגת הטקסט הארוך עם גלילה
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: const TextStyle(
                            fontSize: 16, // 16
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // כפתור סגירה
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3A8DFF), // backgroundColor
                          padding:
                              const EdgeInsets.symmetric(vertical: 14), // 14
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 12
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          'סגור',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
