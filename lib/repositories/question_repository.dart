import 'package:hive/hive.dart';
import 'package:daily_english/models/question.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_english/utils/image_utils.dart';

class QuestionRepository {
  final _box = Hive.box<Question>('questions');

  /// ✅ جلب الأسئلة من Supabase وتخزينها مع تحميل الصور
  Future<List<Question>> fetchAndCacheQuestions(int lessonId) async {
    try {
      final client = Supabase.instance.client;

      final response = await client
          .from('lessons')
          .select('questions')
          .eq('id', lessonId)
          .single();

      final questionsJson = response['questions'] as List?;
      if (questionsJson == null || questionsJson.isEmpty) {
        return [];
      }

      // 🧹 حذف الأسئلة القديمة المرتبطة بالدرس
      await _box.deleteAll(
        _box.keys.where((key) => key.toString().startsWith('$lessonId-')),
      );

      final List<Question> result = [];

      for (int i = 0; i < questionsJson.length; i++) {
        final map = questionsJson[i] as Map<String, dynamic>;

        // ✅ تحميل الصورة وتخزين مسارها المحلي باسم فريد
        final imageUrl = map['image_url'];
        if (imageUrl != null && imageUrl.toString().isNotEmpty) {
          final savedPath = await downloadAndSaveImage(
            imageUrl,
            'question_${lessonId}_$i.jpg', // اسم مميز لكل صورة
          );
          if (savedPath.isNotEmpty) {
            map['local_image_path'] = savedPath;
          }
        }

        final question = Question.fromMap(map);
        await _box.put('$lessonId-$i', question);
        result.add(question);
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  /// ✅ استرجاع الأسئلة من التخزين المحلي (Hive)
  List<Question> getQuestionsFromCache(int lessonId) {
    return _box.values
        .where((q) => _box.keyAt(_box.values.toList().indexOf(q)).toString().startsWith('$lessonId-'))
        .toList();
  }
}
