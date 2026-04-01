import 'package:tabagismo_app/services/api_service.dart';

class SintomaService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> registrarSintoma({
    required String data,
    required int ansiedade,
    required int irritabilidade,
    required int insonia,
    required int fome,
    required int dificuldadeConcentracao,
    required int vontadeFumar,
    String? observacoes,
  }) async {
    try {
      final response = await _api.post('/user/sintomas', {
        'data': data,
        'ansiedade': ansiedade,
        'irritabilidade': irritabilidade,
        'insonia': insonia,
        'fome': fome,
        'dificuldade_concentracao': dificuldadeConcentracao,
        'vontade_fumar': vontadeFumar,
        'observacoes': observacoes,
      });
      return response;
    } catch (e) {
      throw Exception('Erro ao registrar sintoma: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSintomas({int limit = 30}) async {
    try {
      final response = await _api.get('/user/sintomas', queryParams: {'limit': limit.toString()});
      return List<Map<String, dynamic>>.from(response['sintomas']);
    } catch (e) {
      throw Exception('Erro ao buscar sintomas: $e');
    }
  }

  Future<Map<String, dynamic>?> getSintomaHoje() async {
    try {
      final response = await _api.get('/user/sintomas/hoje');
      return response['sintoma'];
    } catch (e) {
      throw Exception('Erro ao buscar sintoma de hoje: $e');
    }
  }
}