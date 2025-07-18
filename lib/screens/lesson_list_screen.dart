import 'package:flutter/material.dart';
import 'package:daily_english/repositories/lesson_repository.dart';
import 'package:daily_english/screens/lesson_detail_screen.dart';

class LessonListScreen extends StatelessWidget {
   LessonListScreen({super.key});
  final repo =  LessonRepository(); // أنشئ نسخة من المستودع

  @override
  Widget build(BuildContext context) {
    final lessons = repo.getAllLessons(); // احصل على البيانات من Hive

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text('الدروس',style: TextStyle(
          color: Colors.white,
        ),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: lessons.isEmpty
          ? const Center(child: Text('لا توجد دروس متاحة حالياً'))
          : ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(lesson.titleAr, textDirection: TextDirection.rtl),
                    subtitle: Text(lesson.titleEn),
                    trailing: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text('${lesson.lessonOrder}', style: const TextStyle(color: Colors.white)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(lesson: lesson.toMap()),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
