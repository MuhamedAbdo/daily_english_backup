import 'package:hive/hive.dart';
import 'package:daily_english/models/lesson.dart';
import 'package:daily_english/services/supabase_service.dart';

class LessonRepository {
  final _box = Hive.box<Lesson>('lessons');
  final _supabase = SupabaseService();

  Future<void> syncLessonsFromSupabase() async {
    final remoteLessons = await _supabase.getLessons();

    final lessonObjects = remoteLessons.map((map) => Lesson.fromMap(map)).toList();

    // اختياري: امسح البيانات القديمة
    await _box.clear();

    // خزّن الدروس الجديدة
    for (var lesson in lessonObjects) {
      await _box.add(lesson);
    }

    print('✅ تم مزامنة ${lessonObjects.length} درس من Supabase إلى Hive');
  }

  List<Lesson> getAllLessons() {
    return _box.values.toList();
  }

 Lesson? getLessonById(int id) {
  try {
    return _box.values.firstWhere((l) => l.id == id);
  } catch (e) {
    return null;
  }
}

}
