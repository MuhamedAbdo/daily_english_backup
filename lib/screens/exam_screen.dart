import 'dart:io';
import 'package:flutter/material.dart';
import 'package:daily_english/models/question.dart';
import 'package:daily_english/repositories/question_repository.dart';

class ExamScreen extends StatefulWidget {
  final int lessonId;

  const ExamScreen({super.key, required this.lessonId});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final repo = QuestionRepository();
  late Future<List<Question>> questionsFuture;
  int score = 0;
  final Map<int, String> selectedAnswers = {};
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    questionsFuture = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final fromServer = await repo.fetchAndCacheQuestions(widget.lessonId);
    if (fromServer.isNotEmpty) return fromServer;

    final fromCache = repo.getQuestionsFromCache(widget.lessonId);
    if (fromCache.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📦 تم عرض بيانات محفوظة (أوفلاين)")),
      );
    }
    return fromCache;
  }

  void _submitAnswers() {
    score = 0;
    for (var i = 0; i < questions.length; i++) {
      final userAnswer = selectedAnswers[i];
      final correctAnswer = questions[i].correctAnswer;
      final options = questions[i].options;

      final correctIndex = options.indexOf(correctAnswer);
      final correctLetter = String.fromCharCode(65 + correctIndex);

      if (userAnswer == correctLetter) {
        score++;
      }
    }
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النتيجة', textAlign: TextAlign.right),
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

  Widget buildImage(String url, {double height = 180}) {
    final file = File(url);
    final isLocal = url.startsWith('/') && file.existsSync();

    if (isLocal) {
      return Image.file(
        file,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
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
    return FutureBuilder<List<Question>>(
      future: questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(body: Center(child: Text("لا توجد أسئلة لهذا الدرس")));
        }

        questions = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("امتحان الدرس", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.deepPurple,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث الأسئلة من الإنترنت',
                onPressed: () async {
                  final newQuestions = await repo.fetchAndCacheQuestions(widget.lessonId);
                  if (newQuestions.isNotEmpty) {
                    setState(() {
                      questions = newQuestions;
                      selectedAnswers.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ تم تحديث الأسئلة من الإنترنت")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⚠️ لم يتم تحميل أي أسئلة")),
                    );
                  }
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected = selectedAnswers[index];
                final imagePath = q.localImagePath?.isNotEmpty == true
                    ? q.localImagePath!
                    : q.imageUrl;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (q.type == 'image_based' && imagePath.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: buildImage(imagePath),
                            ),
                          Text(
  q.questionText,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  textDirection: q.questionText.contains(RegExp(r'[a-zA-Z]'))
      ? TextDirection.ltr
      : TextDirection.rtl,
      textAlign: TextAlign.left,
),

                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: q.options.length,
                            itemBuilder: (context, i) {
                              final letter = String.fromCharCode(65 + i);
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: ListTile(
                                  title: Text('$letter - ${q.options[i]}'),
                                  leading: Radio<String>(
                                    value: letter,
                                    groupValue: selected,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[index] = value!;
                                      });
                                    },
                                  ),
                                  tileColor: selected == letter
                                      ? Colors.deepPurple.withOpacity(0.1)
                                      : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (selected != null && q.explanation.isNotEmpty)
                            Text(
                              "الشرح: ${q.explanation}",
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
          bottomSheet: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: selectedAnswers.length == questions.length ? _submitAnswers : null,
              icon: const Icon(Icons.check),
              label: const Text("تقييم الإجابات"),
            ),
          ),
        );
      },
    );
  }
}