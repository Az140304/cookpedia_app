import 'dart:convert';

import 'package:http/http.dart' as http;

class BaseNetwork {
  static const String baseUrl = "https://themealdb.com/api/json/v1/1/";

  static Future<List<dynamic>> getData(String endpoint) async{
    final response = await http.get(Uri.parse(baseUrl + endpoint));

    if(response.statusCode == 200){
      print('Response body: ${response.body}');
      final data = jsonDecode(response.body);
      final meals = data['meals'];
      return meals ?? [];
    } else {
      throw Exception('Failed to load');
    }
  }

  static Future<Map<String, dynamic>> getDetailData(String id) async{
    print(id);
    final response = await http.get(Uri.parse(baseUrl + 'lookup.php?i=$id'));

    print('API Response Body: ${response.body}');

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load detail data');
    }
  }
}