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

Future<void> updateGoal(String stopDate, int targetDays, int? cigarrosPorDia, double? valorCarteira) async {
  try {
    await _api.put('/user/goal', {
      'stopDate': stopDate,
      'targetDays': targetDays,
      'cigarrosPorDia': cigarrosPorDia,
      'valorCarteira': valorCarteira,
    });
  } catch (e) {
    throw Exception('Erro ao atualizar meta: $e');
  }
}

Future<Map<String, dynamic>> getAdminStats() async {
  try {
    final response = await _api.get('/admin/stats');
    return response;
  } catch (e) {
    throw Exception('Erro ao carregar estatísticas: $e');
  }
}

Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('user_data', json.encode(user));
  await prefs.setString('user_nome', user['nomeCompleto']?.toString() ?? '');
  await prefs.setString('user_email', user['email']?.toString() ?? '');
  await prefs.setInt('user_id', user['id'] ?? 0);
  await prefs.setInt('is_admin', user['is_admin'] ?? 0);
  await prefs.setString('tipo_usuario', user['tipo_usuario'] ?? 'comum');
  if (user['upa_id'] != null) {
    await prefs.setInt('upa_id', user['upa_id']);
  }
}

Future<Map<String, dynamic>?> getSavedUser() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userName = prefs.getString('user_nome');
  final tipoUsuario = prefs.getString('tipo_usuario') ?? 'comum';
  final upaId = prefs.getInt('upa_id');
  
  print('Token recuperado: $token');
  print('UserName recuperado: $userName');
  print('tipoUsuario recuperado: $tipoUsuario');
  
  if (token != null && userName != null && userName.isNotEmpty) {
    _api.setToken(token);
    
    String upaNome = '';
    if (upaId != null && tipoUsuario == 'enfermeira') {
      try {
        final response = await _api.get('/admin/upas-lista');
        final upas = List<Map<String, dynamic>>.from(response['upas']);
        final upa = upas.firstWhere((u) => u['id'] == upaId, orElse: () => {'nome': ''});
        upaNome = upa['nome'];
      } catch (e) {
        print('Erro ao buscar nome da UPA: $e');
      }
    }
    
    final userData = {
      'token': token,
      'user': {
        'nomeCompleto': userName,
        'email': prefs.getString('user_email') ?? '',
        'id': prefs.getInt('user_id') ?? 0,
        'is_admin': prefs.getInt('is_admin') ?? 0,
        'tipo_usuario': tipoUsuario,
        'upa_id': upaId,
        'upa_nome': upaNome,
      }
    };
    
    print('UserData recuperado: $userData');
    return userData;
  }
  return null;
}

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _api.setToken(null);
  }


Future<List<Map<String, dynamic>>> getUsuarios() async {
  try {
    final response = await _api.get('/admin/usuarios');
    return List<Map<String, dynamic>>.from(response['usuarios']);
  } catch (e) {
    throw Exception('Erro ao buscar usuários: $e');
  }
}

Future<Map<String, dynamic>> getUsuarioDetalhes(int usuarioId) async {
  try {
    final response = await _api.get('/admin/usuarios/$usuarioId');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar detalhes do usuário: $e');
  }
}

Future<void> atualizarUsuario(int id, Map<String, dynamic> dados) async {
  try {
    await _api.put('/admin/usuarios/$id', dados);
  } catch (e) {
    throw Exception('Erro ao atualizar usuário: $e');
  }
}

Future<void> atualizarMatricula(int matriculaId, String status) async {
  try {
    await _api.put('/admin/matricula', {
      'matriculaId': matriculaId,
      'status': status,
    });
  } catch (e) {
    throw Exception('Erro ao atualizar matrícula: $e');
  }
}

Future<void> criarUPAComTurmas(Map<String, dynamic> data) async {
  try {
    await _api.post('/admin/upas-com-turmas', data);
  } catch (e) {
    throw Exception('Erro ao criar UPA com turmas: $e');
  }
}

Future<void> atualizarUPAComTurmas(int id, Map<String, dynamic> data) async {
  try {
    await _api.put('/admin/upas-com-turmas/$id', data);
  } catch (e) {
    throw Exception('Erro ao atualizar UPA com turmas: $e');
  }
}

Future<List<Map<String, dynamic>>> getTurmasPorUPA(int upaId) async {
  try {
    final response = await _api.get('/admin/turmas/$upaId');
    return List<Map<String, dynamic>>.from(response['turmas']);
  } catch (e) {
    throw Exception('Erro ao buscar turmas: $e');
  }
}

Future<Map<String, dynamic>> getUsuariosPaginados({int page = 1, int limit = 10, String search = ''}) async {
  try {
    final response = await _api.get('/admin/usuarios/paginados', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
      'search': search,
    });
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar usuários: $e');
  }
}

Future<Map<String, dynamic>> getUPAs({int page = 1, int limit = 10, String search = ''}) async {
  try {
    final response = await _api.get('/admin/upas', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
      'search': search,
    });
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar UPAs: $e');
  }
}

Future<void> criarUPA(Map<String, dynamic> data) async {
  try {
    await _api.post('/admin/upas', data);
  } catch (e) {
    throw Exception('Erro ao criar UPA: $e');
  }
}

Future<void> atualizarUPA(int id, Map<String, dynamic> data) async {
  try {
    await _api.put('/admin/upas/$id', data);
  } catch (e) {
    throw Exception('Erro ao atualizar UPA: $e');
  }
}

Future<void> deletarUPA(int id) async {
  try {
    await _api.delete('/admin/upas/$id');
  } catch (e) {
    throw Exception('Erro ao deletar UPA: $e');
  }
}

Future<List<Map<String, dynamic>>> getEnfermeiras() async {
  try {
    final response = await _api.get('/admin/enfermeiras');
    return List<Map<String, dynamic>>.from(response['enfermeiras']);
  } catch (e) {
    throw Exception('Erro ao buscar enfermeiras: $e');
  }
}

Future<void> criarEnfermeira(Map<String, dynamic> data) async {
  try {
    await _api.post('/admin/enfermeiras', data);
  } catch (e) {
    throw Exception('Erro ao criar enfermeira: $e');
  }
}

Future<Map<String, dynamic>> getAdminEvolucaoGeral() async {
  try {
    final response = await _api.get('/admin/evolucao-geral');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar evolução geral: $e');
  }
}

Future<Map<String, dynamic>> getAdminDashboardStats() async {
  try {
    final response = await _api.get('/admin/dashboard-stats');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar estatísticas do dashboard: $e');
  }
}

Future<void> atualizarEnfermeira(int id, Map<String, dynamic> data) async {
  try {
    await _api.put('/admin/enfermeiras/$id', data);
  } catch (e) {
    throw Exception('Erro ao atualizar enfermeira: $e');
  }
}

Future<void> deletarEnfermeira(int id) async {
  try {
    await _api.delete('/admin/enfermeiras/$id');
  } catch (e) {
    throw Exception('Erro ao deletar enfermeira: $e');
  }
}

Future<Map<String, dynamic>> getEnfermeiraDashboardStats() async {
  try {
    final response = await _api.get('/enfermeira/dashboard-stats');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar estatísticas: $e');
  }
}

Future<List<Map<String, dynamic>>> getUPAsLista() async {
  try {
    final response = await _api.get('/admin/upas-lista');
    return List<Map<String, dynamic>>.from(response['upas']);
  } catch (e) {
    throw Exception('Erro ao buscar UPAs: $e');
  }
}

Future<Map<String, dynamic>> getUsuariosEmEspera() async {
  try {
    final response = await _api.get('/enfermeira/usuarios-espera');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar usuários em espera: $e');
  }
}
Future<void> atualizarStatusMatricula(int matriculaId, String status) async {
  try {
    await _api.put('/enfermeira/matricula-status', {
      'matriculaId': matriculaId,
      'status': status,
    });
  } catch (e) {
    throw Exception('Erro ao atualizar status: $e');
  }
}

Future<Map<String, dynamic>> getUsuariosDaUPA({int page = 1, int limit = 10, String search = '', String status = ''}) async {
  try {
    final response = await _api.get('/enfermeira/usuarios', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
      'search': search,
      'status': status,
    });
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar usuários da UPA: $e');
  }
}


Future<void> registrarPresenca(int matriculaId, String data, String status, {String? observacoes}) async {
  try {
    await _api.post('/enfermeira/presenca', {
      'matriculaId': matriculaId,
      'data': data,
      'status': status,
      'observacoes': observacoes,
    });
  } catch (e) {
    throw Exception('Erro ao registrar presença: $e');
  }
}

Future<Map<String, dynamic>> getUsuariosMatriculadosComPresencas({String? data}) async {
  try {
    final Map<String, String> queryParams = {};
    if (data != null) {
      queryParams['data'] = data;
    }
    final response = await _api.get('/enfermeira/lista-presenca', queryParams: queryParams);
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar usuários: $e');
  }
}

Future<void> salvarPresencasEmLote(List<Map<String, dynamic>> presencas, List<Map<String, dynamic>> observacoesSemanais, String data) async {
  try {
    await _api.post('/enfermeira/presencas-lote', {
      'presencas': presencas,
      'observacoes_semanais': observacoesSemanais,
      'data': data,
    });
  } catch (e) {
    throw Exception('Erro ao salvar presenças: $e');
  }
}

Future<Map<String, dynamic>> getHistoricoDetalhado() async {
  try {
    final response = await _api.get('/enfermeira/historico-detalhado');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar histórico detalhado: $e');
  }
}

Future<Map<String, dynamic>> getMinhasPresencasPorMatricula(int matriculaId) async {
  try {
    final response = await _api.get('/enfermeira/presencas/$matriculaId');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar presenças: $e');
  }
}

Future<Map<String, dynamic>> getCronograma(int matriculaId) async {
  try {
    final response = await _api.get('/enrollment/cronograma/$matriculaId');
    return response;
  } catch (e) {
    throw Exception('Erro ao carregar cronograma: $e');
  }
}

Future<void> encerrarTurma(int upaId, String turmaHorario) async {
  try {
    await _api.post('/enfermeira/encerrar-turma', {
      'upaId': upaId,
      'turmaHorario': turmaHorario,
    });
  } catch (e) {
    throw Exception('Erro ao encerrar turma: $e');
  }
}

Future<Map<String, dynamic>> getEvolucaoGeral() async {
  try {
    final response = await _api.get('/enfermeira/evolucao-geral');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar evolução geral: $e');
  }
}

Future<Map<String, dynamic>> getHistoricoPorUsuario() async {
  try {
    final response = await _api.get('/enfermeira/historico-usuarios');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar histórico por usuário: $e');
  }
}

Future<Map<String, dynamic>> getMinhasPresencas() async {
  try {
    final response = await _api.get('/enrollment/minhas-presencas');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar presenças: $e');
  }
}

Future<List<Map<String, dynamic>>> getHistoricoPresencas() async {
  try {
    final response = await _api.get('/enfermeira/historico-presencas');
    return List<Map<String, dynamic>>.from(response['historico']);
  } catch (e) {
    throw Exception('Erro ao buscar histórico: $e');
  }
}

Future<List<Map<String, dynamic>>> getPresencasPorMatricula(int matriculaId) async {
  try {
    final response = await _api.get('/enfermeira/presencas/$matriculaId');
    return List<Map<String, dynamic>>.from(response['presencas']);
  } catch (e) {
    throw Exception('Erro ao buscar presenças: $e');
  }
}

Future<List<Map<String, dynamic>>> getPresencasDaUPA({String? data}) async {
  try {
    final Map<String, String> queryParams = {};
    if (data != null) {
      queryParams['data'] = data;
    }
    final response = await _api.get('/enfermeira/presencas', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['presencas']);
  } catch (e) {
    throw Exception('Erro ao buscar presenças da UPA: $e');
  }
}

Future<Map<String, dynamic>> getEstatisticasPresenca(int matriculaId) async {
  try {
    final response = await _api.get('/enfermeira/presencas/estatisticas/$matriculaId');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar estatísticas: $e');
  }
}

Future<Map<String, dynamic>> getUPAById(int id) async {
  try {
    final response = await _api.get('/upa/$id');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar UPA: $e');
  }
}


Future<Map<String, dynamic>> getTurmasComCronograma() async {
  try {
    final response = await _api.get('/enfermeira/turmas-cronograma');
    return response;
  } catch (e) {
    throw Exception('Erro ao buscar turmas: $e');
  }
}

Future<void> adicionarAulaCronograma(int turmaId, int numeroAula, String data, String horario, int mes) async {
  try {
    await _api.post('/enfermeira/cronograma', {
      'turmaId': turmaId,
      'numeroAula': numeroAula,
      'data': data,
      'horario': horario,
      'mes': mes,
    });
  } catch (e) {
    throw Exception('Erro ao adicionar aula: $e');
  }
}

Future<void> deletarAulaCronograma(int aulaId) async {
  try {
    await _api.delete('/enfermeira/cronograma/$aulaId');
  } catch (e) {
    throw Exception('Erro ao deletar aula: $e');
  }
}

}