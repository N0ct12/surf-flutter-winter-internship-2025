import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fruit.dart';

class FruityviceApiService {
  static const String _baseUrl = 'https://www.fruityvice.com/api';

  Future<List<Fruit>> fetchAllFruits() async {
    final uri = Uri.parse('$_baseUrl/fruit/all');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load fruits');
    }

    final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
    return decoded.map((item) => Fruit.fromJson(item)).toList();
  }
}
