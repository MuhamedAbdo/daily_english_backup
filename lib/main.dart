import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_english/models/lesson.dart';
import 'package:daily_english/models/question.dart';
import 'package:daily_english/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Hive وتسجيل الـ Adapters
  await Hive.initFlutter();
  Hive.registerAdapter(LessonAdapter());
  Hive.registerAdapter(QuestionAdapter());

  await Hive.openBox<Lesson>('lessons');
  await Hive.openBox<Question>('questions');

  // ✅ تهيئة Supabase
  await Supabase.initialize(
    url: 'https://mgpbuusgwskuaupmlwez.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ncGJ1dXNnd3NrdWF1cG1sd2V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3NjkwMTIsImV4cCI6MjA2ODM0NTAxMn0.rT7dg6dJSzi_t5qOK0y64nAiyWMTJzK4YSW_0UJE6CA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English Lessons App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}
