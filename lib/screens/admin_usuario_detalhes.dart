import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabagismo_app/services/auth_service.dart';
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
  final Color _primaryMedium = Color.fromARGB(255, 19, 56, 85);


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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red.shade400),
      );
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário matriculado com sucesso!'), backgroundColor: Color(0xFF10B981)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao alocar turma: $e'), backgroundColor: Colors.red.shade400),
    );
  } finally {
    setState(() => _atualizandoMatricula = false);
  }
}

  void _mostrarDetalhesMatricula() {
    if (_matricula == null) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Color(0xFF8B5CF6), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detalhes da Matrícula',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetalheRow('UPA', _matricula!['upa_nome'] ?? '-'),
                _buildDetalheRow('Escolaridade', _matricula!['escolaridade'] ?? '-'),
                _buildDetalheRow('Score Fagerström', _matricula!['score_fagestrom']?.toString() ?? '-'),
                _buildDetalheRow('Medicamento', _matricula!['medicamento'] ?? '-'),
                _buildDetalheRow('Primeira opção', _matricula!['turma_horario'] ?? '-'),
                if (_matricula!['segunda_opcao_turma'] != null)
                  _buildDetalheRow('Segunda opção', _matricula!['segunda_opcao_turma']),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Comorbidades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildComorbidadesWidget(),
                const SizedBox(height: 24),
            if (_matricula!['status'] == 'em_espera') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _atualizandoMatricula ? null : () {
                          Navigator.pop(context);
                          _alocarTurma('primeira');
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Alocar na 1ª opção'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_matricula!['segunda_opcao_turma'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _atualizandoMatricula ? null : () {
                            Navigator.pop(context);
                            _alocarTurma('segunda');
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Alocar na 2ª opção'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF10B981)),
                            foregroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalheRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }

  Widget _buildComorbidadesWidget() {
    final comorbidadesStr = _matricula!['comorbidades'];
    if (comorbidadesStr == null) return const Text('Nenhuma comorbidade registrada', style: TextStyle(color: Color(0xFF64748B)));
    
    Map<String, dynamic> comorbidades;
    try {
      comorbidades = Map<String, dynamic>.from(json.decode(comorbidadesStr));
    } catch (e) {
      return const Text('Nenhuma comorbidade registrada', style: TextStyle(color: Color(0xFF64748B)));
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(entry.value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Text(
                      valores.join(', '),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
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
      return const Text('Nenhuma comorbidade registrada', style: TextStyle(color: Color(0xFF64748B)));
    }
    
    return Column(children: itens);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
  title: Row(
    children: [
      const Icon(Icons.person, color: Colors.white, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          widget.usuarioNome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF0F2B3D), 
  foregroundColor: Colors.white,
  elevation: 0,
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoPessoalCard(),
                  const SizedBox(height: 20),
                  _buildObjetivosCard(),
                  const SizedBox(height: 20),
                  _buildMatriculaCard(),
                  const SizedBox(height: 20),
                  _buildSintomasCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoPessoalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: Color(0xFF3B82F6), size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dados Pessoais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.badge, 'Nome', _usuario?['nome_completo'] ?? '-'),
                _buildInfoRow(Icons.email, 'Email', _usuario?['email'] ?? '-'),
                _buildInfoRow(Icons.phone, 'Telefone', _formatarTelefone(_usuario?['telefone'])),
                _buildInfoRow(Icons.assignment_ind, 'CPF', _formatarCpf(_usuario?['cpf'])),
                _buildInfoRow(Icons.wc, 'Sexo', _usuario?['sexo'] ?? '-'),
                _buildInfoRow(Icons.cake, 'Data de Nascimento', _formatarData(_usuario?['data_nascimento'])),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flag, color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Objetivos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Usuário ainda não definiu metas', style: TextStyle(color: Color(0xFF64748B))),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Objetivos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Tempo sem fumar', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('$diasSemFumar dias', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Parou em: ${_formatarData(stopDate)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Meta', '${_usuario?['target_days']} dias', const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem('Cigarros/dia', '${_usuario?['cigarros_por_dia']}', const Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem('Economia', 'R\$${_usuario?['valor_carteira']?.toString() ?? '0'}', const Color(0xFFF59E0B)),
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
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: Color(0xFF8B5CF6), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Matrícula',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Usuário não possui matrícula', style: TextStyle(color: Color(0xFF64748B))),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF8B5CF6), size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Matrícula',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEmEspera ? const Color(0xFFF59E0B).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEmEspera ? 'Em espera' : 'Matriculado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isEmEspera ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.visibility, color: Color(0xFF64748B)),
                  onPressed: _mostrarDetalhesMatricula,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.local_hospital, 'UPA', _matricula!['upa_nome'] ?? '-'),
                _buildInfoRow(Icons.schedule, 'Turma', _matricula!['turma_horario']?.split(' - ')[0] ?? '-'),
                _buildInfoRow(Icons.assessment, 'Score Fagerström', _matricula!['score_fagestrom']?.toString() ?? '-'),
                _buildInfoRow(Icons.medication, 'Medicamento', _matricula!['medicamento'] ?? '-'),
                _buildInfoRow(Icons.access_time, 'Horário', _matricula!['turma_horario']?.split(' - ')[1] ?? '-'),
                if (_matricula!['segunda_opcao_turma'] != null)
                  _buildInfoRow(Icons.schedule, '2ª opção', _matricula!['segunda_opcao_turma']?.split(' - ')[0] ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7DA0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.show_chart, color: Color(0xFF2C7DA0), size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Evolução dos Sintomas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('Usuário ainda não registrou sintomas', style: TextStyle(color: Color(0xFF64748B))),
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
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C7DA0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFF2C7DA0), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Evolução dos Sintomas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 350,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: labels.length * 60 + 100,
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
              padding: const EdgeInsets.only(top: 8),
              child: Transform.rotate(
                angle: -0.5,
                child: Text(
                  labels[index],
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            );
          }
          return const Text('');
        },
        reservedSize: 50,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 35,
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
                            color: const Color(0xFF3B82F6),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(irritabilidade.length, (i) => FlSpot(i.toDouble(), irritabilidade[i])),
                            isCurved: true,
                            color: const Color(0xFFEF4444),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(insonia.length, (i) => FlSpot(i.toDouble(), insonia[i])),
                            isCurved: true,
                            color: const Color(0xFF8B5CF6),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(fome.length, (i) => FlSpot(i.toDouble(), fome[i])),
                            isCurved: true,
                            color: const Color(0xFFF97316),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(dificuldadeConcentracao.length, (i) => FlSpot(i.toDouble(), dificuldadeConcentracao[i])),
                            isCurved: true,
                            color: const Color(0xFF10B981),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(vontadeFumar.length, (i) => FlSpot(i.toDouble(), vontadeFumar[i])),
                            isCurved: true,
                            color: const Color(0xFFF59E0B),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegenda(const Color(0xFF3B82F6), 'Ansiedade'),
                  _buildLegenda(const Color(0xFFEF4444), 'Irritabilidade'),
                  _buildLegenda(const Color(0xFF8B5CF6), 'Insônia'),
                  _buildLegenda(const Color(0xFFF97316), 'Fome'),
                  _buildLegenda(const Color(0xFF10B981), 'Dificuldade Concentração'),
                  _buildLegenda(const Color(0xFFF59E0B), 'Vontade de Fumar'),
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
  const style = TextStyle(fontSize: 10, color: Color(0xFF64748B));
  return Text(value.toInt().toString(), style: style);
}

Widget _buildLegenda(Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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