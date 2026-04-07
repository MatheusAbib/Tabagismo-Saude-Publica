import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>> buscarEndereco(String cep) async {
    String cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cepLimpo.length != 8) {
      throw Exception('CEP inválido');
    }
    
    final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data.containsKey('erro')) {
        throw Exception('CEP não encontrado');
      }
      
      return {
        'logradouro': data['logradouro'] ?? '',
        'bairro': data['bairro'] ?? '',
        'cidade': data['localidade'] ?? '',
        'uf': data['uf'] ?? '',
        'cep': data['cep'] ?? '',
      };
    } else {
      throw Exception('Erro ao buscar CEP');
    }
  }
}