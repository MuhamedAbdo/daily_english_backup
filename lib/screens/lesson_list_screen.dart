import 'package:flutter/material.dart';
import 'package:daily_english/repositories/lesson_repository.dart';
import 'package:daily_english/screens/lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final repo = LessonRepository();
  bool isLoading = false;
  bool isOfflineData = false;
  List lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final data = repo.getAllLessons();
    setState(() {
      lessons = data;
      isOfflineData = true; // اعتبر أن البيانات من Hive مبدئيًا
    });
  }

  Future<void> _syncFromSupabase() async {
    setState(() {
      isLoading = true;
    });

    try {
      await repo.syncLessonsFromSupabase();
      final updatedLessons = repo.getAllLessons();
      setState(() {
        lessons = updatedLessons;
        isOfflineData = false; // تم التحديث من Supabase
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث الدروس من الإنترنت')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل التحديث: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدروس', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _syncFromSupabase,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessons.isEmpty
              ? const Center(child: Text('لا توجد دروس متاحة حالياً'))
              : Column(
                  children: [
                    if (isOfflineData)
                      Container(
                        color: Colors.orange.shade100,
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          '📡 عرض البيانات من النسخة المحفوظة (أوفلاين)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                lesson.titleAr,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
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
                    ),
                  ],
                ),
    );
  }
}
