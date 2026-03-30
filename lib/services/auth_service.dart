import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabagismo_app/models/user.dart';
import 'package:tabagismo_app/services/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'senha': senha,
      });
      
      if (response['token'] != null) {
        _api.setToken(response['token']);
        await _saveUserData(response['token'], response['user']);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await _api.post('/auth/register', user.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

    Future<Map<String, dynamic>> getUserData() async {
      try {
        final response = await _api.get('/user/me');
        return response;
      } catch (e) {
        rethrow;
      }
    }

Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> data) async {
  try {
    final response = await _api.put('/user/update', data);
    return response;
  } catch (e) {
    rethrow;
  }
}

    Future<Map<String, dynamic>> changeUserPassword(String oldPassword, String newPassword) async {
      try {
        final response = await _api.put('/user/change-password', {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        });
        return response;
      } catch (e) {
        rethrow;
      }
    }



Future<List<Map<String, dynamic>>> searchUPA(String bairro) async {
  try {
    final response = await _api.get('/upa/search', queryParams: {'bairro': bairro});
    return List<Map<String, dynamic>>.from(response['data']);
  } catch (e) {
    rethrow;
  }
}



  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_data', json.encode(user));
    await prefs.setString('user_nome', user['nomeCompleto']?.toString() ?? '');
    await prefs.setString('user_email', user['email']?.toString() ?? '');
    await prefs.setInt('user_id', user['id'] ?? 0);
  }

  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userName = prefs.getString('user_nome');
    
    if (token != null && userName != null && userName.isNotEmpty) {
      _api.setToken(token);
      return {
        'token': token,
        'user': {
          'nomeCompleto': userName,
          'email': prefs.getString('user_email') ?? '',
          'id': prefs.getInt('user_id') ?? 0,
        }
      };
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _api.setToken(null);
  }
}