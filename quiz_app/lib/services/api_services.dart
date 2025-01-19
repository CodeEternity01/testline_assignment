

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_model.dart';

class ApiService {
  final String apiUrl = 'https://api.jsonserve.com/Uw5CrX';

  Future<List<Question>> fetchQuizData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    } else {
      throw Exception('Failed to load quiz data');
    }
  }
}