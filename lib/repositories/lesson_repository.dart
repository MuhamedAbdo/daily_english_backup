import 'package:hive/hive.dart';
import 'package:daily_english/models/lesson.dart';
import 'package:daily_english/services/supabase_service.dart';

class LessonRepository {
  final _box = Hive.box<Lesson>('lessons');
  final _supabase = SupabaseService();

  Future<void> syncLessonsFromSupabase() async {
    final remoteLessons = await _supabase.getLessons();
    final remoteLessonObjects = remoteLessons.map((map) => Lesson.fromMap(map)).toList();

    int added = 0;
    int updated = 0;

    for (var remoteLesson in remoteLessonObjects) {
      // هل الدرس موجود بالفعل في Hive؟
      final localLesson = _box.values.where((l) => l.id == remoteLesson.id).cast<Lesson?>().firstOrNull;


      if (localLesson == null) {
        // جديد
        await _box.add(remoteLesson);
        added++;
      } else if (remoteLesson.updatedAt.isAfter(localLesson.updatedAt)) {
        // محدث
        localLesson
          ..lessonOrder = remoteLesson.lessonOrder
          ..titleAr = remoteLesson.titleAr
          ..titleEn = remoteLesson.titleEn
          ..contentBlocks = remoteLesson.contentBlocks
          ..words = remoteLesson.words
          ..updatedAt = remoteLesson.updatedAt;

        await localLesson.save();
        updated++;
      }
    }

    print('✅ تمت المزامنة: $added مضافة، $updated محدثة');
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
