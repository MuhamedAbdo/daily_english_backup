import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String> downloadAndSaveImage(String imageUrl, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$fileName';

  final file = File(filePath);
  if (await file.exists()) return file.path;

  try {
    final response = await Dio().download(imageUrl, filePath);
    if (response.statusCode == 200) return file.path;
  } catch (e) {
    print("❌ Error downloading image: $e");
  }

  return '';
}
