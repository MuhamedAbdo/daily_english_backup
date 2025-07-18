import 'package:flutter/material.dart';
import 'package:daily_english/screens/home_screen.dart';
import 'package:daily_english/repositories/lesson_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LessonRepository _repo = LessonRepository();

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      await _repo.syncLessonsFromSupabase(); // ✅ تحميل وتخزين الدروس
    } catch (e) {
      print('❌ خطأ في المزامنة: $e');
    }

    // تأخير بسيط للعرض
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, size: 100, color: Colors.red);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'جارٍ التحميل...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
