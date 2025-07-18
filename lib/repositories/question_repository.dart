import 'package:hive/hive.dart';
import 'package:daily_english/models/question.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionRepository {
  final _box = Hive.box<Question>('questions');

  /// ✅ جلب الأسئلة من Supabase ثم تخزينها في Hive
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

      final questions = questionsJson
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList();

      // 🧹 امسح أسئلة الدرس القديمة (حسب lessonId)
      await _box.deleteAll(
        _box.keys.where((key) => key.toString().startsWith('$lessonId-')),
      );

      // 📝 خزّن الأسئلة الجديدة مع مفاتيح مخصصة (lessonId-index)
      for (int i = 0; i < questions.length; i++) {
        await _box.put('$lessonId-$i', questions[i]);
      }

      return questions;
    } catch (e) {
      print('❌ خطأ أثناء جلب الأسئلة من Supabase: $e');
      return [];
    }
  }

  /// ✅ جلب الأسئلة من Hive (أوفلاين)
  List<Question> getQuestionsFromCache(int lessonId) {
    return _box.values
        .where((q) => _box.keyAt(_box.values.toList().indexOf(q)).toString().startsWith('$lessonId-'))
        .toList();
  }
}
