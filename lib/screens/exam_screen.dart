import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamScreen extends StatefulWidget {
  final int lessonId;

  const ExamScreen({super.key, required this.lessonId});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Future<List<Map<String, dynamic>>> questionsFuture;
  int score = 0;
  final Map<int, String> selectedAnswers = {};
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    questionsFuture = _fetchQuestionsForLesson();
  }

  Future<List<Map<String, dynamic>>> _fetchQuestionsForLesson() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('lessons')
        .select('questions')
        .eq('id', widget.lessonId)
        .single();

    final questionsJson = response['questions'] as List?;
    if (questionsJson != null) {
      return questionsJson.cast<Map<String, dynamic>>();
    }

    return [];
  }

  void _submitAnswers() {
    score = 0;

    for (var i = 0; i < questions.length; i++) {
      final userAnswer = selectedAnswers[i];

      if (userAnswer != null) {
        final correctAnswer = questions[i]['correct_answer'] as String?;
        final options = (questions[i]['options'] as List?)?.map((e) => e.toString()).toList() ?? [];

        if (options.isNotEmpty) {
          final correctIndex = options.indexOf(correctAnswer ?? '') + 65;
          final correctLetter = String.fromCharCode(correctIndex);

          if (userAnswer == correctLetter) {
            score++;
          }
        }
      }
    }

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النتيجة',
            textAlign: TextAlign.right),
        content: Text('أجبت بشكل صحيح على $score من ${questions.length} سؤال'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('حسنًا'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("لا توجد أسئلة لهذا الدرس")),
          );
        }

        questions = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("امتحان الدرس", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.deepPurple,
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 80.0), // <<< مساحة لأسفل لتجنب التغطية
            child: ListView.builder(
              key: const Key('exam_list'),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionType = question['type'] ?? '';
                final questionText = question['question_text'] ?? '';
                final options = (question['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
                final imageUrl = question['image_url'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // ✅ عرض الصورة فقط في الأسئلة من نوع image_based
                          if (questionType == 'image_based' && imageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (_, __, ___) => const Text("فشل تحميل الصورة"),
                              ),
                            ),

                          // ✅ نص السؤال
                          Text(
                            questionText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 10),

                          // ✅ عرض الخيارات فقط إذا كانت موجودة
                          if (options.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: options.length,
                              itemBuilder: (context, optionIndex) {
                                final optionLetter = String.fromCharCode(65 + optionIndex); // A, B, C, D
                                final selected = selectedAnswers[index] == optionLetter;

                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: ListTile(
                                    title: Text('$optionLetter - ${options[optionIndex]}'),
                                    leading: Radio<String>(
                                      value: optionLetter,
                                      groupValue: selectedAnswers[index],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAnswers[index] = value!;
                                        });
                                      },
                                    ),
                                    tileColor: selected ? Colors.deepPurple.withOpacity(0.1) : null,
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 10),

                          // ✅ عرض الشرح عند اختيار إجابة
                          if (question.containsKey('explanation') && selectedAnswers[index] != null)
                            Text(
                              "الشرح: ${question['explanation']}",
                              style: const TextStyle(color: Colors.grey),
                              textDirection: TextDirection.rtl,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ زر في الأسفل لتجنب التغطية
          bottomSheet: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 40),
              
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
              ),
              onPressed: selectedAnswers.length == questions.length ? _submitAnswers : null,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("تقييم الإجابات", style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}