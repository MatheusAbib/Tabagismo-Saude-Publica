import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/screens/upa_screen.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/widgets/cronograma_modal_widget.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const MyEnrollmentsScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _MyEnrollmentsScreenState createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> with SingleTickerProviderStateMixin {
  final _enrollmentService = EnrollmentService();
  final Color _primaryDark = const Color(0xFF334155);
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  final Color _purpleColor = const Color(0xFF6B21A8);
  
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _ultimaVersao = 0;

  late TabController _tabController;
  
  List<Map<String, dynamic>> _ativas = [];
  List<Map<String, dynamic>> _concluidas = [];
  List<Map<String, dynamic>> _canceladas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEnrollments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _enrollmentService.getMyEnrollments();
      
      if (response['success'] == true || response['data'] != null) {
        List<Map<String, dynamic>> enrollments = List<Map<String, dynamic>>.from(response['data']);
        
        _ativas = [];
        _concluidas = [];
        _canceladas = [];
        
        for (var e in enrollments) {
          final status = e['status'] ?? e['status_display'] ?? '';
          if (status == 'cancelada') {
            _canceladas.add(e);
          } else if (status == 'concluida') {
            _concluidas.add(e);
          } else {
            _ativas.add(e);
          }
        }
        
        setState(() {
          _enrollments = enrollments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erro ao carregar matrículas';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar matrículas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _recarregarSilenciosamente() async {
    try {
      final response = await _enrollmentService.getMyEnrollments();
      
      if (response['success'] == true || response['data'] != null) {
        List<Map<String, dynamic>> enrollments = List<Map<String, dynamic>>.from(response['data']);
        
        _ativas = [];
        _concluidas = [];
        _canceladas = [];
        
        for (var e in enrollments) {
          final status = e['status'] ?? e['status_display'] ?? '';
          if (status == 'cancelada') {
            _canceladas.add(e);
          } else if (status == 'concluida') {
            _concluidas.add(e);
          } else {
            _ativas.add(e);
          }
        }
        
        if (mounted) {
          setState(() {
            _enrollments = enrollments;
          });
        }
      }
    } catch (e) {
      // ignora erro silenciosamente
    }
  }

  Future<void> _verHistoricoPresencas(int matriculaId) async {
    try {
      final authService = AuthService();
      final response = await authService.getMinhasPresencasPorMatricula(matriculaId);
      
      final presencas = response['presencas'] as List? ?? [];
      final estatisticas = response['estatisticas'] as Map<String, dynamic>? ?? {
        'percentual': '0',
        'presentes': 0,
        'faltas': 0,
        'total': 0
      };
      
      final isMobile = MediaQuery.of(context).size.width < 800;
      final isSmallMobile = MediaQuery.of(context).size.width < 480;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.only(
            left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            top: 20,
            bottom: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95),
            constraints: BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _buildHistoricoPresencasContent(presencas, estatisticas),
            ),
          ),
        ),
      );
    } catch (e) {
      ToastService.showError(context, 'Erro ao carregar histórico: $e');
    }
  }

  Widget _buildHistoricoPresencasContent(List<dynamic> presencas, Map<String, dynamic> estatisticas) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minhas Presenças',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Histórico de frequência',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstatisticasCard(estatisticas),
                  const SizedBox(height: 24),
                  const Text(
                    'Registros de Presença',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListaPresencasModal(presencas),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticasCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _successColor.withOpacity(0.1),
            _accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _successColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats['percentual'].toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _successColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Presença',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats['presentes'].toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _successColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Presentes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      stats['faltas'].toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _dangerColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Faltas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (stats['presentes'] ?? 0) / 
                   ((stats['presentes'] ?? 0) + (stats['faltas'] ?? 0) > 0 
                       ? (stats['presentes'] ?? 0) + (stats['faltas'] ?? 0) 
                       : 1),
            backgroundColor: _dangerColor.withOpacity(0.2),
            color: _successColor,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildListaPresencasModal(List<dynamic> presencas) {
    if (presencas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.hourglass_empty, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'Nenhum registro de presença encontrado',
                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
      );
    }
    
    Map<String, Color> statusColors = {
      'presente': _successColor,
      'falta': _dangerColor,
    };
    
    String getStatusText(String status) {
      switch (status) {
        case 'presente': return 'Presente';
        case 'falta': return 'Falta';
        default: return status;
      }
    }
    
    String getObservacaoText(String? observacao) {
      if (observacao == '1- Está fumando') return 'Fumando';
      if (observacao == '2- Sem fumar') return 'Sem fumar';
      return '-';
    }
    
    Color getObservacaoColor(String? observacao) {
      if (observacao == '1- Está fumando') return _warningColor;
      if (observacao == '2- Sem fumar') return _accentColor;
      return const Color(0xFF94A3B8);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: presencas.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
        itemBuilder: (context, index) {
          final p = presencas[index];
          final status = p['status'];
          final observacao = p['observacao_semanal'];
          final color = statusColors[status] ?? Colors.grey;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatarData(p['data']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (observacao != null && observacao.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: getObservacaoColor(observacao),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                getObservacaoText(observacao),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: getObservacaoColor(observacao),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _verDetalhes(Map<String, dynamic> enrollment) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95),
          constraints: BoxConstraints(maxWidth: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _buildDetailsModalContent(enrollment),
          ),
        ),
      ),
    );
  }

Widget _buildDetailsModalContent(Map<String, dynamic> enrollment) {
  Map<String, dynamic> comorbidades = {};
  if (enrollment['comorbidades'] != null) {
    if (enrollment['comorbidades'] is String) {
      try {
        comorbidades = Map<String, dynamic>.from(
          json.decode(enrollment['comorbidades'])
        );
      } catch (e) {
        comorbidades = {};
      }
    } else {
      comorbidades = Map<String, dynamic>.from(enrollment['comorbidades']);
    }
  }

  String enderecoUpa = enrollment['upa_endereco'] ?? 'Não informado';
  String cidadeUpa = enrollment['upa_cidade'] ?? 'Não informado';
  String cepUpa = enrollment['upa_cep'] ?? '';
  String enderecoCompleto = '$enderecoUpa, $cidadeUpa';
  if (cepUpa.isNotEmpty) {
    enderecoCompleto += ' • ${_formatarCep(cepUpa)}';
  }

  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  return Container(
    color: Colors.white,
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_ind,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSmallMobile ? 'Detalhes' : 'Detalhes da Matrícula',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Informações completas',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (enrollment['status'] == 'em_espera')
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white, size: isMobile ? 18 : 24),
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmarCancelamento(enrollment);
                  },
                  tooltip: 'Cancelar matrícula',
                ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(enrollment),
                const SizedBox(height: 24),
                _buildSectionHeader('Localização'),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Endereço',
                  enderecoCompleto,
                  Icons.location_on_outlined,
                  color: _accentColor,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Informações da Turma'),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'UPA',
                  enrollment['upa_nome'] ?? 'Não informado',
                  Icons.local_hospital_outlined,
                  color: _accentColor,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Turma',
                  enrollment['turma_horario'] ?? 'Não informado',
                  Icons.schedule_outlined,
                  color: _successColor,
                ),
                if (enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Segunda Opção',
                    enrollment['segunda_opcao_turma'],
                    Icons.swap_horiz,
                    color: _warningColor,
                  ),
                ],
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Data da Matrícula',
                  _formatDate(enrollment['created_at']),
                  Icons.calendar_today_outlined,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Informações Pessoais'),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Escolaridade',
                  enrollment['escolaridade'] ?? 'Não informado',
                  Icons.school_outlined,
                  color: _purpleColor,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Score Fagerström',
                  enrollment['score_fagestrom']?.toString() ?? 'Não informado',
                  Icons.assessment_outlined,
                  color: _warningColor,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Medicamento',
                  enrollment['medicamento'] ?? 'Não informado',
                  Icons.medication_outlined,
                  color: _successColor,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Comorbidades'),
                const SizedBox(height: 12),
                _buildComorbidadesSection('Câncer', comorbidades['cancer'] ?? []),
                const SizedBox(height: 12),
                _buildComorbidadesSection('Cardiovascular', comorbidades['cardiovascular'] ?? []),
                const SizedBox(height: 12),
                _buildComorbidadesSection('Metabólico', comorbidades['metabolico'] ?? []),
                const SizedBox(height: 12),
                _buildComorbidadesSection('Psiquiátrico', comorbidades['psiquiatrico'] ?? []),
                const SizedBox(height: 12),
                _buildComorbidadesSection('Respiratório', comorbidades['respiratorio'] ?? []),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionHeader(String title) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  return Text(
    title,
    style: TextStyle(
      fontSize: isMobile ? 15 : 17,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF0F172A),
      fontFamily: 'Poppins',
    ),
  );
}

Widget _buildStatusBanner(Map<String, dynamic> enrollment) {
  final status = enrollment['status'] ?? 'em_espera';
  final statusColor = _getStatusColor(status);
  final statusIcon = _getStatusIcon(status);
  final statusText = _getStatusText(status);
  final isMobile = MediaQuery.of(context).size.width < 600;

  return Container(
    padding: EdgeInsets.all(isMobile ? 14 : 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          statusColor.withOpacity(0.12),
          statusColor.withOpacity(0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: statusColor.withOpacity(0.3),
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: isMobile ? 24 : 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status da Matrícula',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: const Color(0xFF64748B),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  String _formatarCep(String cep) {
    if (cep.isEmpty) return '';
    String limpo = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (limpo.length == 8) {
      return '${limpo.substring(0, 5)}-${limpo.substring(5)}';
    }
    return cep;
  }

  Widget _buildDetailCard(String label, String value, IconData icon, {Color? color}) {
    final useColor = color ?? _accentColor;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: useColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: useColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color ?? const Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComorbidadesSection(String titulo, List<dynamic> comorbidades) {
    List<String> itens = [];
    for (var item in comorbidades) {
      if (item is Map) {
        String valor = item['valor'] ?? '';
        if (valor != 'nenhum') {
          if (item['outroTexto'] != null && item['outroTexto'].toString().isNotEmpty) {
            valor = '${valor}: ${item['outroTexto']}';
          }
          itens.add(valor);
        }
      } else if (item is String && item != 'nenhum') {
        itens.add(item);
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_information_outlined, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (itens.isEmpty)
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nenhuma comorbidade registrada',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: itens.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: _accentColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarCancelamento(Map<String, dynamic> enrollment) async {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: _dangerColor, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Cancelar Matrícula',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _primaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tem certeza que deseja cancelar sua matrícula na ${enrollment['upa_nome']}?\n\nTurma: ${enrollment['turma_horario']}\n\nEsta ação não pode ser desfeita.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Não, sair',
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
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _cancelarMatricula(enrollment);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Sim, cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelarMatricula(Map<String, dynamic> enrollment) async {
    setState(() => _isLoading = true);
    
    try {
      await _enrollmentService.cancelEnrollment(enrollment['id']);
      ToastService.showSuccess(context, 'Matrícula cancelada com sucesso!');
      await _loadEnrollments();
    } catch (e) {
      ToastService.showError(context, 'Erro ao cancelar matrícula: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera':
        return _warningColor;
      case 'confirmada':
        return _successColor;
      case 'matriculado':
        return _purpleColor;
      case 'cancelada':
        return _dangerColor;
      case 'concluida':
        return _successColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'em_espera':
        return Icons.hourglass_empty;
      case 'confirmada':
        return Icons.check_circle;
      case 'matriculado':
        return Icons.verified;
      case 'cancelada':
        return Icons.cancel;
      case 'concluida':
        return Icons.celebration;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera':
        return 'Em Espera';
      case 'confirmada':
        return 'Confirmada';
      case 'matriculado':
        return 'Matriculado';
      case 'cancelada':
        return 'Cancelada';
      case 'concluida':
        return 'Concluída';
      default:
        return status;
    }
  }

  String _formatarData(String dataStr) {
    try {
      DateTime date = DateTime.parse(dataStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dataStr;
    }
  }

  void _verCronograma(int matriculaId, String turmaHorario) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            top: 20,
            bottom: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95),
            constraints: BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: CronogramaModal(
                matriculaId: matriculaId,
                turmaHorario: turmaHorario,
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildInfoBanner() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  
  return Container(
    margin: const EdgeInsets.only(top: 16, bottom: 8),
    child: InkWell(
      onTap: _mostrarInformacoesGrupos,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile ? 12 : 16,
          vertical: isSmallMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: _accentColor,
              size: isSmallMobile ? 14 : 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Como funcionam as turmas?',
              style: TextStyle(
                fontSize: isSmallMobile ? 11 : 12,
                color: _accentColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              color: _accentColor.withOpacity(0.6),
              size: isSmallMobile ? 10 : 12,
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _dangerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 64, color: _dangerColor),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: _dangerColor,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEnrollments,
              icon: Icon(Icons.refresh, size: 18),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'Você ainda não tem matrículas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vá em "Turmas de Apoio" e se matricule em uma turma',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInformacoesGrupos() {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 800 : MediaQuery.of(context).size.width * 0.95),
          constraints: BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _buildInformacoesGruposContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildInformacoesGruposContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como Funcionam as Turmas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tudo o que você precisa saber',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    icon: Icons.how_to_reg_outlined,
                    title: 'Processo de Matrícula',
                    content: 'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a unidade entrará em contato pelo telefone e email cadastrados para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                    color: _accentColor,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.calendar_today_outlined,
                    title: 'Frequência dos Encontros',
                    content: 'O programa de apoio é estruturado da seguinte forma:\n\n• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\nCada encontro tem duração aproximada de 2 horas.',
                    color: _successColor,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.group_outlined,
                    title: 'Dinâmica dos Grupos',
                    color: _warningColor,
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo.\n',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF475569),
                            fontFamily: 'Inter',
                          ),
                        ),
                        _infoItem(Icons.chat_bubble_outline, 'Roda de Conversa: Compartilhamento de experiências e desafios', _warningColor),
                        const SizedBox(height: 8),
                        _infoItem(Icons.health_and_safety_outlined, 'Educação em Saúde: Informações sobre os efeitos do tabagismo', _warningColor),
                        const SizedBox(height: 8),
                        _infoItem(Icons.psychology_outlined, 'Estratégias de Enfrentamento: Técnicas para lidar com a fissura', _warningColor),
                        const SizedBox(height: 8),
                        _infoItem(Icons.self_improvement_outlined, 'Atividades Práticas: Exercícios respiratórios e relaxamento', _warningColor),
                        const SizedBox(height: 8),
                        _infoItem(Icons.person_outline, 'Acompanhamento Individual: Orientação personalizada', _warningColor),
                        const SizedBox(height: 8),
                        _infoItem(Icons.people_outline, 'Rede de Apoio: Vínculos com pessoas na mesma jornada', _warningColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.medical_services_outlined,
                    title: 'Acompanhamento Profissional',
                    content: 'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n• Médicos especialistas em tabagismo\n• Psicólogos',
                    color: _purpleColor,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.phone_android_outlined,
                    title: 'Comunicação e Suporte',
                    content: 'Além dos encontros presenciais, você receberá:\n\n✓ Mensagens de apoio via WhatsApp\n✓ Material informativo complementar\n✓ Acompanhamento telefônico\n✓ Grupo de suporte online',
                    color: const Color(0xFF14B8A6),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildInfoSection({
  required IconData icon,
  required String title,
  String? content,
  Widget? contentWidget,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contentWidget != null)
            contentWidget
          else if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    ),
  );
}
  Widget _infoItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) {
            _recarregarSilenciosamente();
          }
        }
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              HeaderWidget(
                title: 'DESFUMO',
                subtitle: 'Apoio ao Tabagismo',
                icon: Icons.smoke_free_outlined,
                userData: widget.userData ?? {},
                isHome: true,
                onNameUpdated: widget.onNameUpdated,
                showBackButton: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            _buildInfoBanner(),
                            _isLoading
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(48),
                                      child: CircularProgressIndicator(color: _accentColor),
                                    ),
                                  )
                                : _errorMessage != null
                                    ? _buildErrorWidget()
                                    : _enrollments.isEmpty
                                        ? _buildEmptyWidget()
                                        : _buildTabsContent(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const FooterWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildTabsContent() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Column(
    children: [
      Container(
        color: Colors.white,
        child: isMobile
            ? Row(
  children: [
    Expanded(
      child: _buildTabItemWidget('Ativas', _ativas.length, _successColor, 0),
    ),
    Expanded(
      child: _buildTabItemWidget('Concluídas', _concluidas.length, _purpleColor, 1),
    ),
    Expanded(
      child: _buildTabItemWidget('Canceladas', _canceladas.length, _dangerColor, 2),
    ),
  ],
)
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: _accentColor,
                indicatorWeight: 3,
                labelColor: _accentColor,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                tabs: [
                  _buildTabItem('Ativas', _ativas.length, _successColor),
                  _buildTabItem('Concluídas', _concluidas.length, _purpleColor),
                  _buildTabItem('Canceladas', _canceladas.length, _dangerColor),
                ],
              ),
        ),
      const SizedBox(height: 16),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildListaMatriculas(_ativas, 'Nenhuma matrícula ativa'),
            _buildListaMatriculas(_concluidas, 'Nenhuma matrícula concluída'),
            _buildListaMatriculas(_canceladas, 'Nenhuma matrícula cancelada'),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTabItemWidget(String label, int count, Color color, int index) {
  return AnimatedBuilder(
    animation: _tabController,
    builder: (context, child) {
      final isSelected = _tabController.index == index;
      
      return GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? _accentColor : const Color(0xFF64748B),
                  fontFamily: 'Poppins',
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentColor : color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildTabItem(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildListaMatriculas(List<Map<String, dynamic>> lista, String mensagemVazia) {
  if (lista.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mensagemVazia,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UPAScreen(
                    userData: widget.userData,
                    onNameUpdated: widget.onNameUpdated,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search, size: 18),
            label: const Text(
              'Encontrar turmas',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: lista.length,
    itemBuilder: (context, index) {
      return _buildEnrollmentCard(lista[index]);
    },
  );
}

  Widget _buildEnrollmentCard(Map<String, dynamic> enrollment) {
  String statusDisplay = enrollment['status_display'] ?? enrollment['status'];
  Color statusColor = _getStatusColor(statusDisplay);
  IconData statusIcon = _getStatusIcon(statusDisplay);
  String statusText = _getStatusText(statusDisplay);
  bool isCanceled = statusDisplay == 'cancelada';
  bool isConcluida = statusDisplay == 'concluida';
  bool isEmEspera = statusDisplay == 'em_espera';
  bool isMatriculado = enrollment['status'] == 'matriculado';
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  String enderecoUpa = enrollment['upa_endereco'] ?? '';
  String cidadeUpa = enrollment['upa_cidade'] ?? '';
  String cepUpa = enrollment['upa_cep'] ?? '';
  String enderecoCompleto = enderecoUpa.isNotEmpty 
      ? '$enderecoUpa, $cidadeUpa${cepUpa.isNotEmpty ? ' • ${_formatarCep(cepUpa)}' : ''}'
      : 'Endereço não informado';
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: isCanceled ? Colors.grey.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isCanceled ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                isCanceled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: _primaryDark.withValues(alpha: isCanceled ? 0.05 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: isCanceled ? Colors.grey.shade500 : _primaryDark,
                  size: isMobile ? 18 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment['upa_nome'] ?? 'UPA não identificada',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: isCanceled ? Colors.grey.shade600 : _primaryDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (!isMobile)
                      Text(
                        enderecoCompleto,
                        style: TextStyle(
                          fontSize: 11,
                          color: isCanceled ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: isMobile ? 12 : 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 10 : 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
Padding(
  padding: EdgeInsets.all(isMobile ? 12 : 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: isCanceled ? Colors.grey.shade400 : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enderecoCompleto,
                        style: TextStyle(
                          fontSize: 11,
                          color: isCanceled ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontFamily: 'Inter',
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: isMobile ? 14 : 16, color: isCanceled ? Colors.grey.shade400 : const Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Turma: ${enrollment['turma_horario'] ?? 'Não informado'}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: isCanceled ? Colors.grey.shade500 : const Color(0xFF475569),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            if (isEmEspera && enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.swap_horiz, size: isMobile ? 14 : 16, color: _warningColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '2ª opção: ${enrollment['segunda_opcao_turma']}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: _warningColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: isMobile ? 14 : 16, color: isCanceled ? Colors.grey.shade400 : const Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data: ${_formatDate(enrollment['created_at'])}',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: isCanceled ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (isConcluida) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _successColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _successColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.celebration, size: isMobile ? 16 : 18, color: _successColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Parabéns! Você concluiu o programa com sucesso!',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: _successColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 14),
      const Divider(color: Color(0xFFE2E8F0)),
      const SizedBox(height: 12),
      isMobile
          ? _buildMobileActionButtons(enrollment, isEmEspera, isConcluida, isMatriculado)
          : _buildDesktopActionButtons(enrollment, isEmEspera, isConcluida, isMatriculado),
    ],
  ),
),
      ],
    ),
  );
}

  Widget _buildMobileActionButtons(Map<String, dynamic> enrollment, bool isEmEspera, bool isConcluida, bool isMatriculado) {
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (isEmEspera)
        Expanded(
          child: TextButton.icon(
            onPressed: () => _confirmarCancelamento(enrollment),
            icon: Icon(Icons.delete_outline, size: isSmallMobile ? 16 : 18, color: _dangerColor),
            label: Text(
              'Cancelar',
              style: TextStyle(
                color: _dangerColor,
                fontWeight: FontWeight.w500,
                fontSize: isSmallMobile ? 11 : 13,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      PopupMenuButton<String>(
        offset: const Offset(0, 40),
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 12 : 16, vertical: isSmallMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accentColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_vert, color: _accentColor, size: isSmallMobile ? 16 : 20),
              const SizedBox(width: 6),
              Text(
                'Opções',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: isSmallMobile ? 11 : 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        onSelected: (String value) {
          if (value == 'cronograma') {
            _verCronograma(enrollment['id'], enrollment['turma_horario']);
          } else if (value == 'detalhes') {
            _verDetalhes(enrollment);
          } else if (value == 'presencas' && isMatriculado) {
            _verHistoricoPresencas(enrollment['id']);
          } else if (value == 'abandonar' && isMatriculado) {
            _confirmarAbandonoMatricula(enrollment);
          }
        },
        itemBuilder: (context) => [
          if (!isConcluida && !isEmEspera)
            const PopupMenuItem<String>(
              value: 'cronograma',
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 20, color: Color(0xFF2E8B6A)),
                  SizedBox(width: 12),
                  Text('Ver Cronograma', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          const PopupMenuItem<String>(
            value: 'detalhes',
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF1F4E6E)),
                SizedBox(width: 12),
                Text('Ver detalhes', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (isMatriculado)
            const PopupMenuItem<String>(
              value: 'presencas',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: Color(0xFF1F4E6E)),
                  SizedBox(width: 12),
                  Text('Lista de presença', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          if (isMatriculado)
            const PopupMenuItem<String>(
              value: 'abandonar',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: Color(0xFFC65D47)),
                  SizedBox(width: 12),
                  Text('Abandonar', style: TextStyle(fontSize: 14, color: Color(0xFFC65D47))),
                ],
              ),
            ),
        ],
      ),
    ],
  );
}

  Widget _buildDesktopActionButtons(Map<String, dynamic> enrollment, bool isEmEspera, bool isConcluida, bool isMatriculado) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isEmEspera)
          TextButton.icon(
            onPressed: () => _confirmarCancelamento(enrollment),
            icon: Icon(Icons.delete_outline, size: 18, color: _dangerColor),
            label: Text(
              'Cancelar',
              style: TextStyle(
                color: _dangerColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        if (!isConcluida && !isEmEspera)
          OutlinedButton.icon(
            onPressed: () => _verCronograma(enrollment['id'], enrollment['turma_horario']),
            icon: const Icon(Icons.calendar_month, size: 18, color: Color(0xFF2E8B6A)),
            label: const Text(
              'Ver Cronograma',
              style: TextStyle(color: Color(0xFF2E8B6A)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF10B981)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => _verDetalhes(enrollment),
          icon: Icon(Icons.visibility_outlined, size: 18, color: _accentColor),
          label: Text(
            'Ver detalhes',
            style: TextStyle(color: _accentColor),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _accentColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (isMatriculado)
          OutlinedButton.icon(
            onPressed: () => _verHistoricoPresencas(enrollment['id']),
            icon: Icon(Icons.history, size: 18, color: _accentColor),
            label: const Text(
              'Lista de presença',
              style: TextStyle(color: Color(0xFF1F4E6E)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _accentColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        if (isMatriculado)
          OutlinedButton.icon(
            onPressed: () => _confirmarAbandonoMatricula(enrollment),
            icon: Icon(Icons.exit_to_app, size: 18, color: _dangerColor),
            label: const Text(
              'Abandonar',
              style: TextStyle(color: Color(0xFFC65D47)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _dangerColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }

Future<void> _confirmarAbandonoMatricula(Map<String, dynamic> enrollment) async {
  final TextEditingController confirmController = TextEditingController();
  bool isLoading = false;
  bool isConfirmValid = false;

  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            top: 20,
            bottom: 20,
          ),
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
                    color: _dangerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app,
                    size: 48,
                    color: Color(0xFFC65D47),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Abandonar Matrícula',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tem certeza que deseja abandonar sua matrícula na ${enrollment['upa_nome']}?\n\n'
                  'Turma: ${enrollment['turma_horario']}\n\n'
                  'Esta ação não pode ser desfeita e você perderá o acesso ao cronograma e às atividades.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Para confirmar, digite a frase abaixo:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'CONFIRMAR ABANDONO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _dangerColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmController,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {
                            isConfirmValid = value.trim().toUpperCase() == 'CONFIRMAR ABANDONO';
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Digite a frase acima',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _dangerColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || !isConfirmValid)
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                await _abandonarMatricula(enrollment);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          isLoading ? 'Processando...' : 'Confirmar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (isLoading || !isConfirmValid) ? Colors.grey.shade400 : _dangerColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    ),
  );
}

  Future<void> _abandonarMatricula(Map<String, dynamic> enrollment) async {
    setState(() => _isLoading = true);
    
    try {
      await _enrollmentService.cancelEnrollment(enrollment['id']);
      ToastService.showSuccess(context, 'Matrícula abandonada com sucesso!');
      await _loadEnrollments();
    } catch (e) {
      ToastService.showError(context, 'Erro ao abandonar matrícula: $e');
      setState(() => _isLoading = false);
    }
  }
}