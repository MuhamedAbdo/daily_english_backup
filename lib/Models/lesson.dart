import 'dart:convert';
import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 0)
class Lesson extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int lessonOrder;

  @HiveField(2)
  String titleAr;

  @HiveField(3)
  String titleEn;

  @HiveField(4)
  String contentBlocks;

  @HiveField(5)
  String words;

  @HiveField(6)
  DateTime updatedAt;

  Lesson({
    required this.id,
    required this.lessonOrder,
    required this.titleAr,
    required this.titleEn,
    required this.contentBlocks,
    required this.words,
    required this.updatedAt,
  });

  /// ✅ لتحويل البيانات من Supabase إلى كائن Lesson
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? 0,
      lessonOrder: map['lesson_order'] ?? 0,
      titleAr: map['title_ar'] ?? '',
      titleEn: map['title_en'] ?? '',

      // ✅ تحويل أي قائمة JSON إلى String
      contentBlocks: map['content_blocks'] is String
          ? map['content_blocks']
          : jsonEncode(map['content_blocks']),

      words: map['words'] is String
          ? map['words']
          : jsonEncode(map['words']),

      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// ✅ لتحويل الكائن إلى Map (اختياري لو حبيت ترسله كـ JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_order': lessonOrder,
      'title_ar': titleAr,
      'title_en': titleEn,
      'content_blocks': contentBlocks,
      'words': words,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
