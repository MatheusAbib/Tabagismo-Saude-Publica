import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/admin_usuario_detalhes.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:tabagismo_app/screens/cronograma_screen.dart';
import 'dart:async';

class EnfermeiraScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const EnfermeiraScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EnfermeiraScreenState createState() => _EnfermeiraScreenState();
}

class _EnfermeiraScreenState extends State<EnfermeiraScreen> {
  
  final Color _primaryColor = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF2C7DA0);

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregandoUsuarios = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsuarios = 0;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  int _alunosPage = 0;
  int _alunosPerPage = 5;

  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Dashboard', 'Em Espera', 'Matriculados', 'Cancelados', 'Lista de Presença', 'Histórico'];
  
  String _upaNome = '';

  @override
  void initState() {
    super.initState();
    
    final nome = widget.userData['upa_nome'];
    _upaNome = (nome != null && nome.toString().isNotEmpty) ? nome : 'Carregando...';
    _carregarUsuarios();
  }


Widget _buildEvolucaoSection(Map<String, dynamic> data) {
  final alunosAtivos = data['alunos_ativos'] ?? {};
  final alunosConcluidos = data['alunos_concluidos'] ?? {};
  
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Evolução dos Alunos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildEvolucaoCard('Alunos Ativos', alunosAtivos, const Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEvolucaoCard('Alunos Concluídos', alunosConcluidos, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 24),
              _buildEvolucaoChart(data),
              const SizedBox(height: 24),
              _buildAlunosDetalhados(data),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEvolucaoCard(String titulo, Map<String, dynamic> dados, Color cor) {
  
  final total = _parseToInt(dados['total']);
  final fumando = _parseToInt(dados['fumando']);
  final semFumar = _parseToInt(dados['sem_fumar']);
  final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
  print('Dados recebidos: ${dados['total']} - ${dados['fumando']} - ${dados['sem_fumar']} - ${dados['taxa_sucesso']}');
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cor.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cor)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(total.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFF59E0B), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(fumando.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B))),
                    ],
                  ),
                  const Text('Fumando', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(semFumar.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                    ],
                  ),
                  const Text('Sem fumar', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: total > 0 ? semFumar / total : 0,
          backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: taxaSucesso >= 50 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
        ),
      ],
    ),
  );
}

int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    return 0;
  }
  return 0;
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
    return 0.0;
  }
  return 0.0;
}

Widget _buildEvolucaoChart(Map<String, dynamic> data) {
  final evolucaoAtivos = List<Map<String, dynamic>>.from(data['evolucao_mensal_ativos'] ?? []);
  
  if (evolucaoAtivos.isEmpty) {
    return const Center(child: Text('Sem dados para exibir', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Evolução Mensal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      _buildMensalChart(evolucaoAtivos, 'Alunos Ativos'),
    ],
  );
}

Widget _buildMensalChart(List<Map<String, dynamic>> dados, String titulo) {
  final maxValor = dados.fold<int>(0, (max, item) {
    final fumando = _parseToInt(item['fumando']);
    final semFumar = _parseToInt(item['sem_fumar']);
    final total = fumando + semFumar;
    return total > max ? total : max;
  });
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      const SizedBox(height: 8),
      SizedBox(
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: dados.map((item) {
              final mes = item['mes'] as String;
              final fumando = _parseToInt(item['fumando']).toDouble();
              final semFumar = _parseToInt(item['sem_fumar']).toDouble();
              final total = fumando + semFumar;
              final altura = maxValor > 0 ? (total / maxValor) * 120 : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(total.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 35,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        if (altura > 0)
                          Column(
                            children: [
                              if (semFumar > 0)
                                Container(
                                  width: 35,
                                  height: (semFumar / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              if (fumando > 0)
                                Container(
                                  width: 35,
                                  height: (fumando / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.vertical(
                                      top: semFumar > 0 ? Radius.zero : Radius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 45,
                      child: Text(
                        mes.substring(5),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendaItem(const Color(0xFFF59E0B), 'Fumando'),
          const SizedBox(width: 16),
          _buildLegendaItem(const Color(0xFF3B82F6), 'Sem fumar'),
        ],
      ),
    ],
  );
}

Widget _buildMensalChartConcluidos(List<Map<String, dynamic>> dados) {
  final maxValor = dados.fold<int>(0, (max, item) {
    final sucesso = _parseToInt(item['sucesso']);
    final insucesso = _parseToInt(item['insucesso']);
    final total = sucesso + insucesso;
    return total > max ? total : max;
  });
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Turmas Concluídas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      const SizedBox(height: 8),
      SizedBox(
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: dados.map((item) {
              final mes = item['mes'] as String;
              final sucesso = _parseToInt(item['sucesso']).toDouble();
              final insucesso = _parseToInt(item['insucesso']).toDouble();
              final total = sucesso + insucesso;
              final altura = maxValor > 0 ? (total / maxValor) * 120 : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(total.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 35,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        if (altura > 0)
                          Column(
                            children: [
                              if (sucesso > 0)
                                Container(
                                  width: 35,
                                  height: (sucesso / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              if (insucesso > 0)
                                Container(
                                  width: 35,
                                  height: (insucesso / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.vertical(
                                      top: sucesso > 0 ? Radius.zero : Radius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 45,
                      child: Text(
                        mes.substring(5),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendaItem(const Color(0xFF10B981), 'Sucesso'),
          const SizedBox(width: 16),
          _buildLegendaItem(const Color(0xFFEF4444), 'Insucesso'),
        ],
      ),
    ],
  );
}



Widget _buildAlunosDetalhados(Map<String, dynamic> data) {
  final alunos = List<Map<String, dynamic>>.from(data['alunos_detalhados'] ?? []);
  
  if (alunos.isEmpty) {
    return const SizedBox.shrink();
  }
  
  final totalPages = (alunos.length / _alunosPerPage).ceil();
  final startIndex = _alunosPage * _alunosPerPage;
  final endIndex = (startIndex + _alunosPerPage) > alunos.length ? alunos.length : (startIndex + _alunosPerPage);
  final alunosPaginados = alunos.sublist(startIndex, endIndex);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Situação Atual dos Alunos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  SizedBox(width: 80, child: Text('Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                  SizedBox(width: 80, child: Text('Situação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                ],
              ),
            ),
            ...alunosPaginados.map((aluno) {
              final ultimaObservacao = aluno['ultima_observacao'];
              final semanasFumando = aluno['semanas_fumando'] ?? 0;
              final semanasSemFumar = aluno['semanas_sem_fumar'] ?? 0;
              
              String situacao;
              Color situacaoCor;
              
              if (ultimaObservacao == '2- Sem fumar') {
                situacao = 'Sem fumar';
                situacaoCor = const Color(0xFF3B82F6);
              } else if (ultimaObservacao == '1- Está fumando') {
                situacao = 'Fumando';
                situacaoCor = const Color(0xFFF59E0B);
              } else {
                situacao = 'Sem registro';
                situacaoCor = const Color(0xFF94A3B8);
              }
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aluno['nome_completo'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            'F: $semanasFumando • SF: $semanasSemFumar',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        aluno['turma_horario']?.split(' - ')[0] ?? '-',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: situacaoCor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          situacao,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: situacaoCor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _alunosPage > 0 ? () {
                        setState(() {
                          _alunosPage--;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_alunosPage + 1} de $totalPages',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8B5CF6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _alunosPage < totalPages - 1 ? () {
                        setState(() {
                          _alunosPage++;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}


  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.lock_outline, color: _accentColor, size: 26),
                const SizedBox(width: 10),
                const Text(
                  'Alterar Senha',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha Atual',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nova Senha',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nova Senha',
                      prefixIcon: Icon(Icons.verified_user_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (newPasswordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('As senhas não coincidem')),
                    );
                    return;
                  }
                  setState(() => isLoading = true);
                  try {
                    final authService = AuthService();
                    await authService.changeUserPassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Senha alterada com sucesso!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao alterar senha: $e')),
                      );
                    }
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Alterar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(),
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: _accentColor,
                labelColor: _accentColor,
                unselectedLabelColor: const Color(0xFF64748B),
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    _searchQuery = '';
                    _searchController.clear();
                    _currentPage = 1;
                  });
                  if (index != 0 && index != 4 && index != 5) {
                    _carregarUsuarios(page: 1);
                  }
                },
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildDashboard(),
                  _buildUsuariosList(),
                  _buildUsuariosList(),
                  _buildUsuariosList(),
                  _buildListaPresenca(),
                  _buildHistoricoPresencas(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildListaPresenca() {
  return FutureBuilder(
    future: AuthService().getUsuariosMatriculadosComPresencas(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar: ${snapshot.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final response = snapshot.data as Map<String, dynamic>;
      final turmas = List<Map<String, dynamic>>.from(response['turmas']);
      final dataAtual = response['dataAtual'] as String;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Expanded(
                child: turmas.isEmpty
                    ? const Center(child: Text('Nenhum usuário matriculado'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: turmas.asMap().entries.map((entry) {
                            final index = entry.key;
                            final turma = entry.value;
                            DateTime dataSelecionada = DateTime.parse(dataAtual);
                            return _buildTurmaPresenca(
                              turma, 
                              index, 
                              dataSelecionada,
                              (novaTurma) {
                                setState(() {
                                  turmas[index] = novaTurma;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTurmaPresenca(Map<String, dynamic> turma, int turmaIndex, DateTime dataSelecionada, Function(Map<String, dynamic>) onTurmaUpdate) {
  final usuarios = List<Map<String, dynamic>>.from(turma['usuarios']);
  
  return StatefulBuilder(
    builder: (context, setState) {
      bool _salvando = false;
      bool _encerrando = false;
      final DateTime _dataAtual = DateTime.now();
      
      Future<void> salvarPresencas() async {
        setState(() {
          _salvando = true;
        });
        try {
          final authService = AuthService();
          final presencasParaSalvar = usuarios.map((u) => ({
            'matriculaId': u['matricula_id'],
            'status': u['presenca_status'] ?? 'falta',
            'observacoes': u['presenca_observacoes'],
          })).toList();
          
          final observacoesParaSalvar = usuarios
              .where((u) => u['observacao_semanal'] != null && u['observacao_semanal'] != '')
              .map((u) => ({
                'matriculaId': u['matricula_id'],
                'observacao': u['observacao_semanal'],
              })).toList();
          
          await authService.salvarPresencasEmLote(
            presencasParaSalvar,
            observacoesParaSalvar,
            '${_dataAtual.year}-${_dataAtual.month.toString().padLeft(2, '0')}-${_dataAtual.day.toString().padLeft(2, '0')}',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Presenças salvas com sucesso!'), backgroundColor: const Color(0xFF10B981)),
            );
          }
          
          final novaDataStr = '${_dataAtual.year}-${_dataAtual.month.toString().padLeft(2, '0')}-${_dataAtual.day.toString().padLeft(2, '0')}';
          final newResponse = await AuthService().getUsuariosMatriculadosComPresencas(data: novaDataStr);
          if (mounted) {
            final novasTurmas = List<Map<String, dynamic>>.from(newResponse['turmas']);
            onTurmaUpdate(novasTurmas[turmaIndex]);
            setState(() {
              _salvando = false;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red.shade400),
            );
            setState(() {
              _salvando = false;
            });
          }
        }
      }
      
      Future<void> encerrarTurma() async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Encerrar Turma'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tem certeza que deseja encerrar esta turma?'),
                const SizedBox(height: 12),
                Text('Turma: ${turma['nome']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Isso irá:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text('• Arquivar todos os alunos'),
                const Text('• Salvar histórico de presenças e observações'),
                const Text('• Limpar a lista de presença atual'),
                const Text('• Liberar vagas para nova turma'),
                const SizedBox(height: 12),
                const Text(
                  'Esta ação não pode ser desfeita!',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          setState(() {
            _encerrando = true;
          });
          try {
            final authService = AuthService();
            final upaId = widget.userData['upa_id'];
            await authService.encerrarTurma(upaId, turma['nome']);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Turma encerrada com sucesso!'), backgroundColor: Color(0xFF10B981)),
              );
              
              final newResponse = await AuthService().getUsuariosMatriculadosComPresencas();
              if (mounted) {
                final novasTurmas = List<Map<String, dynamic>>.from(newResponse['turmas']);
                onTurmaUpdate(novasTurmas[turmaIndex]);
                setState(() {
                  _encerrando = false;
                });
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao encerrar turma: $e'), backgroundColor: Colors.red.shade400),
              );
              setState(() {
                _encerrando = false;
              });
            }
          }
        }
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text(
                  turma['nome'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${usuarios.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _encerrando ? null : encerrarTurma,
                  icon: _encerrando
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                      : const Icon(Icons.archive, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Encerrar Turma', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        '${_dataAtual.day}/${_dataAtual.month}/${_dataAtual.year}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _salvando ? null : salvarPresencas,
                  icon: _salvando
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save, size: 16),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: Text('Nome', style: TextStyle(fontWeight: FontWeight.w600))),
                      SizedBox(width: 120, child: Text('Presença', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      SizedBox(width: 140, child: Text('Observação', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                ...usuarios.map((usuario) => _buildLinhaPresenca(usuario, setState)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    },
  );
}




Widget _buildLinhaPresenca(Map<String, dynamic> usuario, Function setState) {
  String? status = usuario['presenca_status'];
  String statusDisplay = status ?? 'nenhum';
  String? observacao = usuario['observacao_semanal'];
  String observacaoDisplay = observacao ?? '';
  
  Map<String, String> statusOptions = {
    'presente': 'Presente',
    'falta': 'Falta',
    'nenhum': '-',
  };
  
  Map<String, Color> statusColors = {
    'presente': const Color(0xFF10B981),
    'falta': const Color(0xFFEF4444),
    'nenhum': const Color(0xFF94A3B8),
  };
  
  Map<String, String> observacaoOptions = {
    '': '-',
    '1- Está fumando': '1- Está fumando',
    '2- Sem fumar': '2- Sem fumar',
  };
  

Color getObservacaoColor(String? observacao) {
  if (observacao == '1- Está fumando') return const Color(0xFFF59E0B);
  if (observacao == '2- Sem fumar') return const Color(0xFF3B82F6);
  return const Color(0xFF94A3B8);
}
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            usuario['nome_completo'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: statusColors[statusDisplay]?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statusDisplay,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              iconSize: 18,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColors[statusDisplay],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              items: statusOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: entry.key == 'nenhum' ? const Color(0xFF94A3B8) : statusColors[entry.key],
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != 'nenhum') {
                  setState(() {
                    usuario['presenca_status'] = newValue;
                  });
                } else if (newValue == 'nenhum') {
                  setState(() {
                    usuario['presenca_status'] = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 140,
          decoration: BoxDecoration(
            color: getObservacaoColor(observacaoDisplay).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: observacaoDisplay,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              iconSize: 18,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: getObservacaoColor(observacaoDisplay),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              items: observacaoOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: getObservacaoColor(entry.key),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  usuario['observacao_semanal'] = newValue == '' ? null : newValue;
                });
              },
            ),
          ),
        ),
const SizedBox(width: 8),
IconButton(
  icon: const Icon(Icons.calendar_month, color: Color(0xFF10B981)),
  onPressed: () => _verCronograma(usuario['matricula_id'], usuario['turma_horario']),
  tooltip: 'Ver Cronograma',
),
      ],
    ),
  );
}

void _verCronograma(int matriculaId, String turmaHorario) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CronogramaScreen(
        matriculaId: matriculaId,
        turmaHorario: turmaHorario,
      ),
    ),
  );
}


Widget _buildHistoricoPresencas() {
  return FutureBuilder(
    future: AuthService().getHistoricoDetalhado(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar: ${snapshot.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final responseDetalhado = snapshot.data as Map<String, dynamic>;
      final turmasDetalhado = List<Map<String, dynamic>>.from(responseDetalhado['turmas']);
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Presenças por Turma',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            ...turmasDetalhado.map((turma) => _buildTurmaHistorico(turma)).toList(),
          ],
        ),
      );
    },
  );
}

Widget _buildTurmaHistorico(Map<String, dynamic> turma) {
  final datas = List<String>.from(turma['datas']);
  final usuarios = List<Map<String, dynamic>>.from(turma['usuarios']);
  
  Map<String, Color> statusColors = {
    'presente': const Color(0xFF10B981),
    'falta': const Color(0xFFEF4444),
    'justificada': const Color(0xFFF59E0B),
  };
  
  for (var usuario in usuarios) {
    int presentes = 0;
    int total = 0;
    for (var data in datas) {
      final status = usuario['presencas'][data];
      if (status != null) {
        total++;
        if (status == 'presente') {
          presentes++;
        }
      }
    }
    usuario['percentual'] = total > 0 ? (presentes / total * 100).toStringAsFixed(0) : '0';
  }
  
String getStatusText(String? status) {
  switch (status) {
    case 'presente': return 'P';
    case 'falta': return 'F';
    default: return '-';
  }
}
  
  String getObservacaoText(String? observacao) {
    if (observacao == '1- Está fumando') return 'F';
    if (observacao == '2- Sem fumar') return 'SM';
    return '-';
  }
  
  Color getObservacaoColor(String? observacao) {
    if (observacao == '1- Está fumando') return const Color(0xFFF59E0B);
    if (observacao == '2- Sem fumar') return const Color(0xFF3B82F6);
    return const Color(0xFF94A3B8);
  }
  
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Text(
                turma['turma'],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${usuarios.length} alunos',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6)),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 70, child: Text('%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11), textAlign: TextAlign.center)),
                    const SizedBox(width: 200, child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11))),
                    ...datas.map((data) => SizedBox(
                      width: 80,
                      child: Text(
                        data,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    )),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...usuarios.map((usuario) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: int.parse(usuario['percentual']) >= 75 
                              ? const Color(0xFF10B981).withOpacity(0.1) 
                              : const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${usuario['percentual']}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: int.parse(usuario['percentual']) >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 192,
                      child: Text(
                        usuario['nome'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...datas.map((data) {
                      final status = usuario['presencas'][data];
                      final observacao = usuario['observacoes'][data];
                      final color = status != null ? statusColors[status] : Colors.grey.shade400;
                      final text = getStatusText(status);
                      final obsText = getObservacaoText(observacao);
                      final obsColor = getObservacaoColor(observacao);
                      return SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: color != null ? color.withOpacity(0.15) : Colors.grey.shade400.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            if (obsText != '-')
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: obsColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  obsText,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: obsColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendaItem(const Color(0xFF10B981), 'Presente (P)'),
              _buildLegendaItem(const Color(0xFFEF4444), 'Falta (F)'),
              _buildLegendaItem(Colors.grey.shade400, 'Não registrado (-)'),
              const SizedBox(width: 16),
              _buildLegendaItem(const Color(0xFFF59E0B), 'Fumando (F)'),
              _buildLegendaItem(const Color(0xFF3B82F6), 'Sem fumar (SF)'),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildLegendaItem(Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        texto,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
    ],
  );
}

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 50,
        right: 50,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            const Color(0xFF1A4A6F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(Icons.medical_services, color: Colors.white, size: 29),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel Enfermeira • $_upaNome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 52),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Bem-vinda, ${_getUserFirstName()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ],
          ),
        ),
        onSelected: (String value) {
          if (value == 'alterar_senha') {
            _changePassword();
          } else if (value == 'sair') {
            _logout();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'alterar_senha',
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: Color(0xFF0F2B3D)),
                SizedBox(width: 12),
                Text('Alterar Senha', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'sair',
            child: Row(
              children: [
                Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                const SizedBox(width: 12),
                Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserFirstName() {
    String nomeCompleto = widget.userData['nomeCompleto'] ?? 'Enfermeira';
    if (nomeCompleto.isNotEmpty && nomeCompleto.contains(' ')) {
      return nomeCompleto.split(' ').first;
    }
    return nomeCompleto;
  }

void _showLogoutConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sair da conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja sair?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _performLogout() async {
  final authService = AuthService();
  await authService.logout();
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}

void _logout() {
  _showLogoutConfirmationDialog();
}

  Widget _buildDashboard() {
  return FutureBuilder(
    future: Future.wait([
      AuthService().getEnfermeiraDashboardStats(),
      AuthService().getEvolucaoGeral(),
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados: ${snapshot.error}'),
            ],
          ),
        );
      }
      
      final data = snapshot.data![0];
      final evolucaoData = snapshot.data![1];
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportarPDF(data, evolucaoData),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Exportar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(data),
            const SizedBox(height: 24),
            _buildDemographicSection(data),
            const SizedBox(height: 24),
            _buildHealthSection(data),
            const SizedBox(height: 24),
            _buildEvolucaoSection(evolucaoData),
            const SizedBox(height: 24),
            _buildChartSection(data),
          ],
        ),
      );
    },
  );
}

Future<void> _exportarPDF(Map<String, dynamic> data, Map<String, dynamic> evolucaoData) async {
  try {
    final nomeEnfermeira = widget.userData['nomeCompleto'] ?? _getUserFirstName();
    await PdfService.gerarRelatorioDashboardCompleto(data, evolucaoData, nomeEnfermeira, _upaNome);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

  Widget _buildStatsRow(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Usuários', data['totalUsuarios'].toString(), Icons.people, const Color(0xFF3B82F6))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Em Espera', data['totalEmEspera'].toString(), Icons.hourglass_empty, const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Matriculados', data['totalMatriculados'].toString(), Icons.check_circle, const Color(0xFF10B981))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Cancelados', data['totalCancelados'].toString(), Icons.cancel, const Color(0xFFEF4444))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildDemographicSection(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text('Demografia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Maiores de 18', '${data['maiores18']} usuários', Icons.person, const Color(0xFF3B82F6))),
                    Expanded(child: _buildInfoItem('Menores de 18', '${data['menores18']} usuários', Icons.child_care, const Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSexoDistribution(data['distribuicaoSexo']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDistribution(List<dynamic> sexoData) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;
    
    for (var item in sexoData) {
      if (item['sexo'] == 'Masculino') masculino = item['total'];
      else if (item['sexo'] == 'Feminino') feminino = item['total'];
      else outro = item['total'];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distribuição por Sexo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSexoBar('Masculino', masculino, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Feminino', feminino, const Color(0xFFEC4899))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Outro', outro, const Color(0xFF8B5CF6))),
          ],
        ),
      ],
    );
  }

  Widget _buildSexoBar(String label, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(total.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildHealthSection(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.health_and_safety, size: 20, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Saúde', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildHealthItem('Comorbidade - Câncer', '${data['usuariosComCancer']} usuários', Icons.health_and_safety, const Color(0xFFEF4444))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHealthItem('Comorbidade - Cardiovascular', '${data['usuariosComCardiovascular']} usuários', Icons.favorite, const Color(0xFFEC4899))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHealthItem('Média Score Fagerström', '${double.parse(data['mediaScoreFagestrom'].toString()).toStringAsFixed(1)} pontos', Icons.assessment, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, dynamic> data) {
    final usuariosPorMes = data['usuariosPorMes'] as List;
    
    if (usuariosPorMes.isEmpty) {
      return Container();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text('Matrículas por Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: usuariosPorMes.reversed.toList().isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : _buildBarChart(usuariosPorMes.reversed.toList()),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBarChart(List<dynamic> dados) {
  List<String> meses = [];
  List<double> valores = [];
  
  for (var item in dados) {
    meses.add(item['mes']);
    double valor = (item['total'] as num).toDouble();
    valores.add(valor);
  }
  
  if (valores.isEmpty) {
    return const Center(child: Text('Sem dados', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  final maxValor = valores.reduce((a, b) => a > b ? a : b);
  
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(dados.length, (index) {
      double altura = 0;
      if (maxValor > 0) {
        altura = (valores[index] / maxValor) * 150;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valores[index].toInt().toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: altura,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(meses[index].toString().substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      );
    }),
  );
}

  Widget _buildUsuariosList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou email...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                            onPressed: _limparBusca,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (_) => _buscarUsuarios(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _carregandoUsuarios
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _searchQuery.isEmpty ? 'Usuários da UPA' : 'Resultados para: "$_searchQuery"',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      Text('Total: $_totalUsuarios usuários', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      ..._usuarios.map((usuario) => _buildUsuarioCard(usuario)),
                      const SizedBox(height: 16),
                      _buildPagination(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final status = usuario['status'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                  child: Text(usuario['nome_completo'][0].toUpperCase(), style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario['nome_completo'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF0F172A))),
                      Text(usuario['email'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_getStatusText(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(status))),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Telefone', usuario['telefone'] ?? 'Não informado'),
                if (usuario['turma_horario'] != null)
                  _buildInfoRow(Icons.schedule, 'Turma', usuario['turma_horario']),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _verDetalhes(usuario),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Detalhes'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8B5CF6)),
                          foregroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1 ? () => _carregarUsuarios(page: _currentPage - 1) : null,
          style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Página $_currentPage de $_totalPages', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8B5CF6))),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalPages ? () => _carregarUsuarios(page: _currentPage + 1) : null,
          style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

  Future<void> _carregarUsuarios({int page = 1}) async {
    setState(() {
      _carregandoUsuarios = true;
      _currentPage = page;
    });
    
    String statusFilter = '';
    if (_selectedTabIndex == 1) {
      statusFilter = 'em_espera';
    } else if (_selectedTabIndex == 2) {
      statusFilter = 'matriculado';
    } else if (_selectedTabIndex == 3) {
      statusFilter = 'cancelada';
    }
    
    try {
      final authService = AuthService();
      final response = await authService.getUsuariosDaUPA(
        page: page,
        limit: 10,
        search: _searchQuery,
        status: statusFilter,
      );
      
      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(response['usuarios']);
        _totalPages = response['totalPages'];
        _totalUsuarios = response['total'];
        _carregandoUsuarios = false;
      });
    } catch (e) {
      setState(() => _carregandoUsuarios = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar usuários: $e'), backgroundColor: Colors.red.shade400),
      );
    }
  }

  void _buscarUsuarios() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = _searchController.text;
      _carregarUsuarios(page: 1);
    });
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
    _carregarUsuarios(page: 1);
  }

  void _verDetalhes(Map<String, dynamic> usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUsuarioDetalhesScreen(
          usuarioId: usuario['id'],
          usuarioNome: usuario['nome_completo'],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera': return 'Em Espera';
      case 'confirmada': return 'Confirmada';
      case 'matriculado': return 'Matriculado';
      case 'recusada': return 'Recusada';
      case 'cancelada': return 'Cancelada';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera': return const Color(0xFFF59E0B);
      case 'confirmada': return const Color(0xFF10B981);
      case 'matriculado': return const Color(0xFF8B5CF6);
      case 'recusada': return Colors.red;
      case 'cancelada': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }
}