import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'dart:convert';

class AdminUsuarioDetalhesScreen extends StatefulWidget {
  final int usuarioId;
  final String usuarioNome;

  const AdminUsuarioDetalhesScreen({
    Key? key,
    required this.usuarioId,
    required this.usuarioNome,
  }) : super(key: key);

  @override
  _AdminUsuarioDetalhesScreenState createState() => _AdminUsuarioDetalhesScreenState();
}

class _AdminUsuarioDetalhesScreenState extends State<AdminUsuarioDetalhesScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _usuario;
  List<Map<String, dynamic>> _sintomas = [];
  Map<String, dynamic>? _matricula;
  bool _atualizandoMatricula = false;

  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final response = await authService.getUsuarioDetalhes(widget.usuarioId);
      setState(() {
        _usuario = response['usuario'];
        _sintomas = List<Map<String, dynamic>>.from(response['sintomas']);
        _matricula = response['matricula'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError(context, 'Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _alocarTurma(String opcao) async {
    if (_matricula == null) return;
    
    String turmaEscolhida;
    if (opcao == 'primeira') {
      turmaEscolhida = _matricula!['turma_horario'];
    } else {
      turmaEscolhida = _matricula!['segunda_opcao_turma'];
    }
    
    setState(() => _atualizandoMatricula = true);
    try {
      final authService = AuthService();
      await authService.atualizarMatricula(
        _matricula!['id'],
        'matriculado',
        turmaEscolhida,
      );
      
      await _carregarDados();
      
      ToastService.showSuccess(context, 'Usuário matriculado com sucesso na turma: $turmaEscolhida');
    } catch (e) {
      ToastService.showError(context, 'Erro ao alocar turma: $e');
    } finally {
      setState(() => _atualizandoMatricula = false);
    }
  }

  void _mostrarDetalhesMatricula() {
    if (_matricula == null) return;
    
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
            right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
            top: 20,
            bottom: 20,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: EdgeInsets.all(isSmallMobile ? 16 : 20),
            width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B21A8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Color(0xFF6B21A8), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Detalhes da Matrícula',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetalheRow('UPA', _matricula!['upa_nome'] ?? '-'),
                      _buildDetalheRow('Escolaridade', _matricula!['escolaridade'] ?? '-'),
                      _buildDetalheRow('Score Fagerström', _matricula!['score_fagestrom']?.toString() ?? '-'),
                      _buildDetalheRow('Medicamento', _matricula!['medicamento'] ?? '-'),
                      _buildDetalheRow('Turma', _matricula!['turma_horario'] ?? '-'),
                      if (_matricula!['segunda_opcao_turma'] != null)
                        _buildDetalheRow('2ª opção', _matricula!['segunda_opcao_turma']),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Comorbidades', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildComorbidadesWidget(),
                ),
                const SizedBox(height: 20),
                if (_matricula!['status'] == 'em_espera') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _atualizandoMatricula ? null : () {
                            Navigator.pop(context);
                            _alocarTurma('primeira');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _successColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Alocar 1ª opção', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (_matricula!['segunda_opcao_turma'] != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _atualizandoMatricula ? null : () {
                              Navigator.pop(context);
                              _alocarTurma('segunda');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _successColor),
                              foregroundColor: _successColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('2ª opção', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (_matricula!['status'] != 'em_espera')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalheRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComorbidadesWidget() {
    final comorbidadesStr = _matricula!['comorbidades'];
    if (comorbidadesStr == null) return const Text('Nenhuma comorbidade registrada', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)));
    
    Map<String, dynamic> comorbidades;
    try {
      comorbidades = Map<String, dynamic>.from(json.decode(comorbidadesStr));
    } catch (e) {
      return const Text('Nenhuma comorbidade registrada', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)));
    }
    
    final List<Widget> itens = [];
    final Map<String, String> categorias = {
      'cancer': 'Câncer',
      'cardiovascular': 'Cardiovascular',
      'metabolico': 'Metabólico',
      'psiquiatrico': 'Psiquiátrico',
      'respiratorio': 'Respiratório',
    };
    
    for (var entry in categorias.entries) {
      final lista = comorbidades[entry.key];
      if (lista != null && lista is List && lista.isNotEmpty) {
        final valores = lista.where((item) => item['valor'] != 'nenhum').map((item) => item['valor']).toList();
        if (valores.isNotEmpty) {
          itens.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(entry.value, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Text(
                      valores.join(', '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    
    if (itens.isEmpty) {
      return const Text('Nenhuma comorbidade registrada', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)));
    }
    
    return Column(children: itens);
  }

 @override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 900;
  
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: Row(
        children: [
          const Icon(Icons.person, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.usuarioNome,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF334155),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile
                    ? Column(
                        children: [
                          _buildInfoPessoalCard(),
                          const SizedBox(height: 12),
                          _buildObjetivosCard(),
                          const SizedBox(height: 12),
                          _buildMatriculaCard(),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: _buildInfoPessoalCard(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: _buildMatriculaCard(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildObjetivosCard(),
                        ],
                      ),
                const SizedBox(height: 12),
                _buildSintomasCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
  );
}

  Widget _buildInfoPessoalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_outline, color: Color(0xFF1F4E6E), size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Dados Pessoais',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow(Icons.badge, 'Nome', _usuario?['nome_completo'] ?? '-'),
                _buildInfoRow(Icons.email, 'Email', _usuario?['email'] ?? '-'),
                _buildInfoRow(Icons.phone, 'Telefone', _formatarTelefone(_usuario?['telefone'])),
                _buildInfoRow(Icons.assignment_ind, 'CPF', _formatarCpf(_usuario?['cpf'])),
                _buildInfoRow(Icons.wc, 'Sexo', _usuario?['sexo'] ?? '-'),
                _buildInfoRow(Icons.cake, 'Nascimento', _formatarData(_usuario?['data_nascimento'])),
                _buildInfoRow(Icons.numbers, 'Idade', _usuario?['idade']?.toString() ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjetivosCard() {
    if (_usuario?['stop_date'] == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flag, color: Color(0xFF2E8B6A), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Objetivos',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Nenhuma meta definida', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            ),
          ],
        ),
      );
    }

    final stopDate = _usuario!['stop_date'].toString();
    final diasSemFumar = DateTime.now().difference(DateTime.parse(_usuario!['stop_date'])).inDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flag, color: Color(0xFF2E8B6A), size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Objetivos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2E8B6A), Color(0xFF257A5C)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Tempo sem fumar', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 2),
                      Text('$diasSemFumar dias', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text('Parou em: ${_formatarData(stopDate)}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Meta', '${_usuario?['target_days']} dias', _successColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem('Cigarros/dia', '${_usuario?['cigarros_por_dia']}', _dangerColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem('Economia', 'R\$${_usuario?['valor_carteira']?.toString() ?? '0'}', _warningColor),
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

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) return '-';
    
    String dataLimpa = data.split(' ')[0];
    String dataLimpa2 = dataLimpa.split('T')[0];
    
    final partes = dataLimpa2.split('-');
    if (partes.length != 3) return dataLimpa2;
    
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatriculaCard() {
    if (_matricula == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B21A8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: Color(0xFF6B21A8), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Matrícula',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Sem matrícula ativa', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            ),
          ],
        ),
      );
    }

    final status = _matricula!['status'];
    final isEmEspera = status == 'em_espera';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B21A8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF6B21A8), size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Matrícula',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isEmEspera ? _warningColor.withOpacity(0.1) : _successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEmEspera ? 'Em espera' : 'Matriculado',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isEmEspera ? _warningColor : _successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _mostrarDetalhesMatricula,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.visibility, color: Color(0xFF64748B), size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow(Icons.local_hospital, 'UPA', _matricula!['upa_nome'] ?? '-'),
                _buildInfoRow(Icons.assessment, 'Fagerström', _matricula!['score_fagestrom']?.toString() ?? '-'),
                _buildInfoRow(Icons.medication, 'Medicamento', _matricula!['medicamento'] ?? '-'),
                _buildInfoRow(Icons.schedule, 'Turma', _matricula!['turma_horario'] ?? '-'),
                if (_matricula!['segunda_opcao_turma'] != null)
                  _buildInfoRow(Icons.swap_horiz, '2ª opção', _matricula!['segunda_opcao_turma'] ?? '-'),
                if (isEmEspera) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _atualizandoMatricula ? null : () => _alocarTurma('primeira'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _successColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Matricular 1ª opção', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (_matricula!['segunda_opcao_turma'] != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _atualizandoMatricula ? null : () => _alocarTurma('segunda'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _successColor),
                              foregroundColor: _successColor,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('2ª opção', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSintomasCard() {
    if (_sintomas.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.show_chart, color: Color(0xFF1F4E6E), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Evolução',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Sem registros de sintomas', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            ),
          ],
        ),
      );
    }

    final sintomasReverso = _sintomas.reversed.toList();
    
    List<double> ansiedade = [];
    List<double> irritabilidade = [];
    List<double> insonia = [];
    List<double> fome = [];
    List<double> dificuldadeConcentracao = [];
    List<double> vontadeFumar = [];
    List<String> labels = [];

    for (var s in sintomasReverso) {
      ansiedade.add((s['ansiedade'] ?? 0).toDouble());
      irritabilidade.add((s['irritabilidade'] ?? 0).toDouble());
      insonia.add((s['insonia'] ?? 0).toDouble());
      fome.add((s['fome'] ?? 0).toDouble());
      dificuldadeConcentracao.add((s['dificuldade_concentracao'] ?? 0).toDouble());
      vontadeFumar.add((s['vontade_fumar'] ?? 0).toDouble());
      
      String dataStr = s['data'].toString();
      String dataFormatada = '';
      
      if (dataStr.contains('T')) {
        dataStr = dataStr.split('T')[0];
      }
      
      final dataParts = dataStr.split('-');
      if (dataParts.length >= 3) {
        dataFormatada = '${dataParts[2]}/${dataParts[1]}';
      } else {
        dataFormatada = dataStr;
      }
      
      labels.add(dataFormatada);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart, color: Color(0xFF1F4E6E), size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Evolução dos Sintomas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: labels.length * 55 + 80,
                      child: LineChart(
                        LineChartData(
                          clipData: const FlClipData.all(),
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Transform.rotate(
                                        angle: -0.5,
                                        child: Text(
                                          labels[index],
                                          style: const TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: _leftTitleWidgets,
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: (sintomasReverso.length - 1).toDouble(),
                          minY: 0,
                          maxY: 10,
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(ansiedade.length, (i) => FlSpot(i.toDouble(), ansiedade[i])),
                              isCurved: true,
                              color: _accentColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(irritabilidade.length, (i) => FlSpot(i.toDouble(), irritabilidade[i])),
                              isCurved: true,
                              color: _dangerColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(insonia.length, (i) => FlSpot(i.toDouble(), insonia[i])),
                              isCurved: true,
                              color: const Color(0xFF6B21A8),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(fome.length, (i) => FlSpot(i.toDouble(), fome[i])),
                              isCurved: true,
                              color: const Color(0xFFF97316),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(dificuldadeConcentracao.length, (i) => FlSpot(i.toDouble(), dificuldadeConcentracao[i])),
                              isCurved: true,
                              color: _successColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(vontadeFumar.length, (i) => FlSpot(i.toDouble(), vontadeFumar[i])),
                              isCurved: true,
                              color: _warningColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegenda(_accentColor, 'Ansiedade'),
                    _buildLegenda(_dangerColor, 'Irritabilidade'),
                    _buildLegenda(const Color(0xFF6B21A8), 'Insônia'),
                    _buildLegenda(const Color(0xFFF97316), 'Fome'),
                    _buildLegenda(_successColor, 'Concentração'),
                    _buildLegenda(_warningColor, 'Vontade fumar'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 9, color: Color(0xFF94A3B8));
    return Text(value.toInt().toString(), style: style);
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  String _formatarTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) return '-';
    String limpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (limpo.length == 11) {
      return '(${limpo.substring(0, 2)}) ${limpo.substring(2, 7)}-${limpo.substring(7)}';
    }
    return telefone;
  }

  String _formatarCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return '-';
    String limpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (limpo.length == 11) {
      return '${limpo.substring(0, 3)}.${limpo.substring(3, 6)}.${limpo.substring(6, 9)}-${limpo.substring(9)}';
    }
    return cpf;
  }
}