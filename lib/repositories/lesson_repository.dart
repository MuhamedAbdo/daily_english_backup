import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:daily_english/utils/image_utils.dart';
import 'package:hive/hive.dart';
import 'package:daily_english/models/lesson.dart';
import 'package:daily_english/services/supabase_service.dart';

class LessonRepository {
  final _box = Hive.box<Lesson>('lessons');
  final _supabase = SupabaseService();

  Future<void> syncLessonsFromSupabase() async {
    final remoteLessons = await _supabase.getLessons();
    int added = 0;
    int updated = 0;

    for (final map in remoteLessons) {
      final remoteLesson = Lesson.fromMap(map);

      // ✅ تحميل صورة الدرس الرئيسية (image_url)
      final imageUrl = map['image_url'];
      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        final savedPath = await downloadAndSaveImage(
          imageUrl,
          'lesson_${remoteLesson.id}.jpg',
        );
        if (savedPath.isNotEmpty) {
          remoteLesson.imagePath = savedPath;
        }
      }

      // ✅ تحميل صور البلوكات داخل content_blocks
      final contentBlocks = map['content_blocks'];
      if (contentBlocks is List) {
        for (var block in contentBlocks) {
          final blockImageUrl = block['image_url'];
          if (blockImageUrl != null && blockImageUrl.toString().isNotEmpty) {
            final savedBlockPath = await downloadAndSaveImage(
              blockImageUrl,
              'lesson_${remoteLesson.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            if (savedBlockPath.isNotEmpty) {
              block['local_image_path'] = savedBlockPath;
            }
          }
        }

        // ✅ حفظ contentBlocks المعدلة كـ JSON String
        remoteLesson.contentBlocks = jsonEncode(contentBlocks);
      }

      // ✅ التحقق هل الدرس موجود في الصندوق المحلي؟
      final localLesson = _box.values.firstWhereOrNull(
        (l) => l.id == remoteLesson.id,
      );

      if (localLesson == null) {
        await _box.add(remoteLesson);
        added++;
      } else if (remoteLesson.updatedAt.isAfter(localLesson.updatedAt)) {
        localLesson
          ..lessonOrder = remoteLesson.lessonOrder
          ..titleAr = remoteLesson.titleAr
          ..titleEn = remoteLesson.titleEn
          ..contentBlocks = remoteLesson.contentBlocks
          ..words = remoteLesson.words
          ..updatedAt = remoteLesson.updatedAt
          ..imagePath = remoteLesson.imagePath;

        await localLesson.save();
        updated++;
      }
    }
  }

  List<Lesson> getAllLessons() => _box.values.toList();

  Lesson? getLessonById(int id) {
    try {
      return _box.values.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}