import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tabagismo_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Future<String?> _getTokenFromStorage() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getTokenFromStorage();
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await _getTokenFromStorage();
    Uri url = Uri.parse('${Constants.baseUrl}$endpoint');
    if (queryParams != null) {
      url = url.replace(queryParameters: queryParams);
    }
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getTokenFromStorage();
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await _getTokenFromStorage();
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.delete(
      url,
      headers: headers,
    );
    
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      String mensagem = 'Erro na requisição: ${response.statusCode}';
      try {
        final body = json.decode(response.body);
        if (body['error'] != null) {
          mensagem = body['error'];
        } else if (body['message'] != null) {
          mensagem = body['message'];
        }
      } catch (_) {}
      throw Exception(mensagem);
    }
  }
}