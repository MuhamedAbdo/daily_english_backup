import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:daily_english/screens/new_words_screen.dart';
import 'package:daily_english/screens/exam_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  /// 🔧 دالة لتحويل \\n إلى \n
  String fixLineBreaks(String text) {
    return text.replaceAll(r'\n', '\n');
  }

  /// ✅ دالة ذكية لعرض الصورة من الملف المحلي أو الإنترنت
  Widget buildImage(String url, {double height = 250}) {
    final local = File(url);
    final isLocal = url.startsWith('/') && local.existsSync();

    if (isLocal) {
      return Image.file(
        local,
        width: double.infinity,
        height: height,
        fit: BoxFit.fill,
      );
    } else {
      return Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => const Text("فشل تحميل الصورة"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawBlocks = lesson['content_blocks'];
    final contentBlocks =
        rawBlocks is String ? jsonDecode(rawBlocks) : (rawBlocks ?? []);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          lesson['title_ar'] ?? 'عنوان غير موجود',
          style: const TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'الشرح:',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: contentBlocks
                      .map<Widget>((block) => _buildContentBlock(block))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewWordsScreen(lesson: lesson),
                          ),
                        );
                      },
                      icon: const Icon(Icons.translate),
                      label: const Text('الكلمات الجديدة'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final lessonId = lesson['id'];
                        if (lessonId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ExamScreen(lessonId: lessonId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'لا يمكن فتح الامتحان: معرف الدرس غير متوفر')),
                          );
                        }
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text('امتحان الدرس'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlock(Map<String, dynamic> block) {
    final type = block['type'] ?? '';
    final en = block['en'] ?? '';
    final ar = fixLineBreaks(block['ar'] ?? '');
    final imageUrl = block['local_image_path'] ?? block['image_url'] ?? '';

    switch (type) {
      case 'text':
        final value = fixLineBreaks(block['value'] ?? '');
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildImage(imageUrl, height: 300),
                ),
              Text(
                value,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );

      case 'english_word':
        final value = fixLineBreaks(block['value'] ?? '');
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildImage(imageUrl, height: 150),
                ),
              Text(
                value,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );

      case 'example_sentence':
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  en,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
              Text(
                ar,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildImage(imageUrl, height: 180),
                ),
              const Divider(),
            ],
          ),
        );

      case 'table':
        final tableData = block['value'] as List?; // ✅ هنا يتم قراءة القائمة مباشرة
        if (tableData == null || tableData.isEmpty) return Container();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(3), // إذا كان الجدول له 3 أعمدة
              },
              children: tableData.map<TableRow>((row) {
                final cells = row is List ? row : [row];
                return TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: cells.map((cell) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cell.toString(),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )).toList(),
                );
              }).toList(),
            ),
          ),
        );

      default:
        return Container();
    }
  }
}