import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class ApiProvider {
  Future<Map<String, String>> getHeadersJsonWithAuth() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      Map<String, String> _headers = {
        'Authorization' : 'Bearer ${json.decode(prefs.get('userData') as String)['token']}',
        'Content-Type': 'application/json'
      };
      return _headers;
    } else {
      throw Exception('Failed to retrieve headers.');
    }
  }
}