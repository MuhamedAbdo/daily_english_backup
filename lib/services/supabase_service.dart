import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final response = await client
          .from('lessons')
          .select()
          .order('lesson_order', ascending: true);
      return response;
    } catch (e) {
      print('Error getting lessons: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getLessonById(int id) async {
    try {
      final response = await client
          .from('lessons')
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      print('Error getting lesson by id: $e');
      return {};
    }
  }
}