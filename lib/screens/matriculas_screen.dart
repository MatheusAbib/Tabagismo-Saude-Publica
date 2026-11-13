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
  final Color _primaryDark = const Color(0xFF333333);
  final Color _accentColor = const Color(0xFF426E8C);
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


Future<void> _abrirModalPadronizado({
  required Widget child,
  double maxWidth = 700,
  bool barrierDismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      final mobile = size.width < 600;

      return Dialog(
        backgroundColor: const Color(0xFFFFFDF9),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFE6E5DF),
            width: 1,
          ),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: mobile ? 12 : 24,
          vertical: 20,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: size.height * 0.85,
          ),
          child: child,
        ),
      );
    },
  );
}

Widget _buildModalHeader({
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onClose,
  Widget? action,
  Color iconColor = const Color(0xFF426E8C),
  Color iconBackground = const Color(0xFFE1EDF6),
}) {
  final mobile = MediaQuery.sizeOf(context).width < 600;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: mobile ? 16 : 22,
      vertical: 18,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFFFFFDF9),
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFE6E5DF),
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: mobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF667078),
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action,
        ],
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose ?? () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6E5DF),
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFF667078),
                size: 19,
              ),
            ),
          ),
        ),
      ],
    ),
  );
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
    final response = await authService.getMinhasPresencasPorMatricula(
      matriculaId,
    );

    if (!mounted) return;

    final presencas = response['presencas'] as List? ?? [];
    final estatisticas =
        response['estatisticas'] as Map<String, dynamic>? ??
        {
          'percentual': '0',
          'presentes': 0,
          'faltas': 0,
          'total': 0,
        };

    await _abrirModalPadronizado(
      child: _buildHistoricoPresencasContent(
        presencas,
        estatisticas,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ToastService.showError(
      context,
      'Erro ao carregar histórico: $e',
    );
  }
}

Widget _buildHistoricoPresencasContent(
  List<dynamic> presencas,
  Map<String, dynamic> estatisticas,
) {
  final mobile = MediaQuery.sizeOf(context).width < 600;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildModalHeader(
        icon: Icons.history_outlined,
        title: 'Minhas presenças',
        subtitle: 'Histórico de frequência',
      ),
      Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(mobile ? 16 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstatisticasCard(estatisticas),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    size: 20,
                    color: Color(0xFF426E8C),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Registros de presença',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildListaPresencasModal(presencas),
            ],
          ),
        ),
      ),
    ],
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
              Container(width: 1, height: 50, color: const Color(0xFFDCE5EB)),
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
              Container(width: 1, height: 50, color: const Color(0xFFDCE5EB)),
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
          color: const Color(0xFFFAF8F3),
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
        color: const Color(0xFFFAF8F3),
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
  _abrirModalPadronizado(
    child: _buildDetailsModalContent(enrollment),
  );
}

Widget _buildDetailsModalContent(
  Map<String, dynamic> enrollment,
) {
  Map<String, dynamic> comorbidades = {};

  if (enrollment['comorbidades'] != null) {
    if (enrollment['comorbidades'] is String) {
      try {
        comorbidades = Map<String, dynamic>.from(
          json.decode(enrollment['comorbidades']),
        );
      } catch (e) {
        comorbidades = {};
      }
    } else {
      comorbidades = Map<String, dynamic>.from(
        enrollment['comorbidades'],
      );
    }
  }

  final enderecoUpa =
      enrollment['upa_endereco']?.toString() ?? 'Não informado';
  final cidadeUpa =
      enrollment['upa_cidade']?.toString() ?? 'Não informado';
  final cepUpa = enrollment['upa_cep']?.toString() ?? '';

  String enderecoCompleto = '$enderecoUpa, $cidadeUpa';

  if (cepUpa.isNotEmpty) {
    enderecoCompleto += ' • ${_formatarCep(cepUpa)}';
  }

  final mobile = MediaQuery.sizeOf(context).width < 600;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildModalHeader(
        icon: Icons.assignment_ind_outlined,
        title: 'Detalhes da matrícula',
        subtitle: 'Informações completas',
        action: enrollment['status'] == 'em_espera'
            ? Tooltip(
                message: 'Cancelar matrícula',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _confirmarCancelamento(enrollment);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8ECEA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFEFD6D0),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFC65D47),
                        size: 19,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(mobile ? 16 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              _buildSectionHeader('Informações da turma'),
              const SizedBox(height: 12),
              _buildDetailCard(
                'UPA',
                enrollment['upa_nome']?.toString() ??
                    'Não informado',
                Icons.local_hospital_outlined,
                color: _accentColor,
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                'Turma',
                enrollment['turma_horario']?.toString() ??
                    'Não informado',
                Icons.schedule_outlined,
                color: _successColor,
              ),
              if (enrollment['segunda_opcao_turma'] != null &&
                  enrollment['segunda_opcao_turma']
                      .toString()
                      .isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailCard(
                  'Segunda opção',
                  enrollment['segunda_opcao_turma'].toString(),
                  Icons.swap_horiz_outlined,
                  color: _warningColor,
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailCard(
                'Data da matrícula',
                _formatDate(enrollment['created_at']),
                Icons.calendar_today_outlined,
                color: _accentColor,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Informações pessoais'),
              const SizedBox(height: 12),
              _buildDetailCard(
                'Escolaridade',
                enrollment['escolaridade']?.toString() ??
                    'Não informado',
                Icons.school_outlined,
                color: _accentColor,
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                'Score Fagerström',
                enrollment['score_fagestrom']?.toString() ??
                    'Não informado',
                Icons.assessment_outlined,
                color: _accentColor,
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                'Medicamento',
                enrollment['medicamento']?.toString() ??
                    'Não informado',
                Icons.medication_outlined,
                color: _accentColor,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Comorbidades'),
              const SizedBox(height: 12),
              _buildComorbidadesSection(
                'Câncer',
                comorbidades['cancer'] ?? [],
              ),
              const SizedBox(height: 12),
              _buildComorbidadesSection(
                'Cardiovascular',
                comorbidades['cardiovascular'] ?? [],
              ),
              const SizedBox(height: 12),
              _buildComorbidadesSection(
                'Metabólico',
                comorbidades['metabolico'] ?? [],
              ),
              const SizedBox(height: 12),
              _buildComorbidadesSection(
                'Psiquiátrico',
                comorbidades['psiquiatrico'] ?? [],
              ),
              const SizedBox(height: 12),
              _buildComorbidadesSection(
                'Respiratório',
                comorbidades['respiratorio'] ?? [],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


Widget _buildSectionHeader(String title) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  return Text(
    title,
    style: TextStyle(
      fontSize: isMobile ? 15 : 17,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF333333),
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
                  color: const Color(0xFF737A80),
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
    final useColor = _accentColor;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE5EB)),
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
                    color: const Color(0xFF333333),
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
        color: const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE5EB)),
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
                    color: const Color(0xFFDCE5EB),
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


Future<void> _confirmarCancelamento(
  Map<String, dynamic> enrollment,
) async {
  final mobile = MediaQuery.sizeOf(context).width < 600;

  await _abrirModalPadronizado(
    maxWidth: 460,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModalHeader(
          icon: Icons.warning_amber_rounded,
          title: 'Cancelar matrícula',
          subtitle: 'Confirmação necessária',
          iconColor: const Color(0xFFC65D47),
          iconBackground: const Color(0xFFF8ECEA),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.all(mobile ? 18 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tem certeza que deseja cancelar sua matrícula?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Confira as informações abaixo antes de confirmar.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF667078),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE6E5DF),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unidade de atendimento',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF667078),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        enrollment['upa_nome']?.toString() ??
                            'Não informado',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Turma',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF667078),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        enrollment['turma_horario']?.toString() ??
                            'Não informado',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8ECEA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEFD6D0),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFC65D47),
                        size: 19,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Esta ação não pode ser desfeita.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            height: 1.5,
                            color: Color(0xFF9B4939),
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
                          foregroundColor: const Color(0xFF667078),
                          side: const BorderSide(
                            color: Color(0xFFE6E5DF),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _cancelarMatricula(enrollment);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 17,
                        ),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC65D47),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
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
        ),
      ],
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
  _abrirModalPadronizado(
    maxWidth: 800,
    child: _buildInformacoesGruposContent(),
  );
}

Widget _buildInformacoesGruposContent() {
  final mobile = MediaQuery.sizeOf(context).width < 600;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildModalHeader(
        icon: Icons.info_outline,
        title: 'Como funcionam as turmas',
        subtitle: 'Tudo o que você precisa saber',
      ),
      Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(mobile ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                icon: Icons.how_to_reg_outlined,
                title: 'Processo de matrícula',
                content:
                    'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a unidade entrará em contato pelo telefone e email cadastrados para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                color: _accentColor,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                icon: Icons.calendar_today_outlined,
                title: 'Frequência dos encontros',
                content:
                    'O programa de apoio é estruturado da seguinte forma:\n\n• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\nCada encontro tem duração aproximada de 2 horas.',
                color: _accentColor,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                icon: Icons.group_outlined,
                title: 'Dinâmica dos grupos',
                color: _accentColor,
                contentWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF4E4E4E),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoItem(
                      Icons.chat_bubble_outline,
                      'Roda de Conversa: Compartilhamento de experiências e desafios',
                      _accentColor,
                    ),
                    _infoItem(
                      Icons.health_and_safety_outlined,
                      'Educação em Saúde: Informações sobre os efeitos do tabagismo',
                      _accentColor,
                    ),
                    _infoItem(
                      Icons.psychology_outlined,
                      'Estratégias de Enfrentamento: Técnicas para lidar com a fissura',
                      _accentColor,
                    ),
                    _infoItem(
                      Icons.self_improvement_outlined,
                      'Atividades Práticas: Exercícios respiratórios e relaxamento',
                      _accentColor,
                    ),
                    _infoItem(
                      Icons.person_outline,
                      'Acompanhamento Individual: Orientação personalizada',
                      _accentColor,
                    ),
                    _infoItem(
                      Icons.people_outline,
                      'Rede de Apoio: Vínculos com pessoas na mesma jornada',
                      _accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                icon: Icons.medical_services_outlined,
                title: 'Acompanhamento profissional',
                content:
                    'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n• Médicos especialistas em tabagismo\n• Psicólogos',
                color: _accentColor,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                icon: Icons.phone_android_outlined,
                title: 'Comunicação e suporte',
                content:
                    'Além dos encontros presenciais, você receberá:\n\n✓ Mensagens de apoio via WhatsApp\n✓ Material informativo complementar\n✓ Acompanhamento telefônico\n✓ Grupo de suporte online',
                color: _accentColor,
              ),
            ],
          ),
        ),
      ),
    ],
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
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFE6E5DF),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE1EDF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF426E8C),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(
          height: 1,
          color: Color(0xFFE6E5DF),
        ),
        const SizedBox(height: 14),
        if (contentWidget != null)
          contentWidget
        else if (content != null)
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.65,
              color: Color(0xFF667078),
            ),
          ),
      ],
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
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 600 ? 18.0 : width < 900 ? 28.0 : 42.0;
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) _recarregarSilenciosamente();
        }
        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F3),
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
                        padding: EdgeInsets.fromLTRB(padding, width < 600 ? 26 : 48, padding, 0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1250),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildEnrollmentHero(),
                                const SizedBox(height: 26),
                                if (!_isLoading && _errorMessage == null && _enrollments.isNotEmpty) ...[
                                  _buildEnrollmentSummary(),
                                  const SizedBox(height: 26),
                                ],
                                if (_isLoading)
                                  const Padding(
                                    padding: EdgeInsets.all(65),
                                    child: Center(child: CircularProgressIndicator(color: Color(0xFF426E8C))),
                                  )
                                else if (_errorMessage != null)
                                  _buildErrorWidget()
                                else if (_enrollments.isEmpty)
                                  _buildEmptyWidget()
                                else
                                  _buildTabsContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
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

  Widget _buildEnrollmentHero() {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 44),
      decoration: BoxDecoration(
        color: const Color(0xFFE1EDF6),
        border: Border.all(color: const Color(0xFFC9DEED)),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, color: Color(0xFF426E8C), size: 18),
              SizedBox(width: 9),
              Text('ACOMPANHAMENTO', style: TextStyle(fontFamily: 'Inter', fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.w700, color: Color(0xFF426E8C))),
            ],
          ),
          const SizedBox(height: 18),
          Text('Minhas matrículas.', style: TextStyle(fontFamily: 'DMSerifDisplay', fontSize: compact ? 37 : 49, height: 1.15, color: const Color(0xFF333333))),
          const SizedBox(height: 12),
           ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 610),
            child: Text('Consulte suas turmas, acompanhe suas matrículas e acesse os registros dos encontros.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.7, color: Color(0xFF4E4E4E))),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _mostrarInformacoesGrupos,
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('Como funcionam as turmas?'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF426E8C),
              side: const BorderSide(color: Color(0xFFB7D2E4)),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSummary() {
    final items = [
      ('Ativas', _ativas.length, Icons.event_available_outlined),
      ('Concluídas', _concluidas.length, Icons.task_alt_outlined),
      ('Canceladas', _canceladas.length, Icons.event_busy_outlined),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 580;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((item) {
          final w = compact ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 24) / 3;
          return SizedBox(
            width: w,
            child: Container(
              padding: EdgeInsets.all(compact ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDCE5EB)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$3, color: const Color(0xFF426E8C), size: compact ? 20 : 25),
                  const SizedBox(height: 13),
                  Text('${item.$2}', style: TextStyle(fontFamily: 'Inter', fontSize: compact ? 24 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF333333))),
                  const SizedBox(height: 3),
                  Text(item.$1, style: TextStyle(fontFamily: 'Inter', fontSize: compact ? 11 : 13, color: const Color(0xFF737A80))),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }


Widget _buildTabsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE5EB)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: const Color(0xFFE1EDF6), borderRadius: BorderRadius.circular(12)),
            indicatorPadding: const EdgeInsets.all(5),
            dividerColor: Colors.transparent,
            labelColor: const Color(0xFF426E8C),
            unselectedLabelColor: const Color(0xFF737A80),
            labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),
            tabs: [
              Tab(text: 'Ativas (${_ativas.length})'),
              Tab(text: 'Concluídas (${_concluidas.length})'),
              Tab(text: 'Canceladas (${_canceladas.length})'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            final index = _tabController.index;
            return _buildListaMatriculas(
              index == 0 ? _ativas : index == 1 ? _concluidas : _canceladas,
              index == 0 ? 'Nenhuma matrícula ativa' : index == 1 ? 'Nenhuma matrícula concluída' : 'Nenhuma matrícula cancelada',
            );
          },
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
                  color: isSelected ? _accentColor : const Color(0xFF737A80),
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

Widget _buildListaMatriculas(
  List<Map<String, dynamic>> lista,
  String mensagemVazia,
) {
  if (lista.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 56,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EB),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            color: Color(0xFF426E8C),
            size: 38,
          ),
          const SizedBox(height: 15),
          Text(
            mensagemVazia,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UPAScreen(
                  userData: widget.userData,
                  onNameUpdated: widget.onNameUpdated,
                ),
              ),
            ),
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Encontrar turmas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF426E8C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    children: lista.map((enrollment) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: double.infinity,
          child: _buildEnrollmentCard(enrollment),
        ),
      );
    }).toList(),
  );
}

  Widget _buildEnrollmentCard(Map<String, dynamic> enrollment) {
  final status = (enrollment['status'] ??
          enrollment['status_display'] ??
          '')
      .toString();

  final isEmEspera = status == 'em_espera';
  final isConcluida = status == 'concluida';
  final isMatriculado = status == 'matriculado';

  final endereco = (enrollment['upa_endereco'] ?? '').toString();
  final cidade = (enrollment['upa_cidade'] ?? '').toString();
  final cep = (enrollment['upa_cep'] ?? '').toString();

  final enderecoCompleto = endereco.isEmpty
      ? 'Endereço não informado'
      : '$endereco${cidade.isNotEmpty ? ', $cidade' : ''}${cep.isNotEmpty ? ' • ${_formatarCep(cep)}' : ''}';

  final actions = <Widget>[
    ElevatedButton.icon(
      onPressed: () => _verDetalhes(enrollment),
      icon: const Icon(Icons.description_outlined, size: 18),
      label: const Text('Ver detalhes'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF426E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    if (!isEmEspera && !isConcluida)
      OutlinedButton.icon(
        onPressed: () => _verCronograma(
          enrollment['id'],
          enrollment['turma_horario'],
        ),
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: const Text('Ver cronograma'),
        style: _secondaryEnrollmentButton(),
      ),
    if (isMatriculado)
      OutlinedButton.icon(
        onPressed: () => _verHistoricoPresencas(enrollment['id']),
        icon: const Icon(Icons.fact_check_outlined, size: 18),
        label: const Text('Ver presenças'),
        style: _secondaryEnrollmentButton(),
      ),
    if (isMatriculado)
      OutlinedButton.icon(
        onPressed: () => _confirmarAbandonoMatricula(enrollment),
        icon: const Icon(Icons.exit_to_app, size: 18),
        label: const Text('Abandonar matrícula'),
        style: _dangerEnrollmentButton(),
      ),
    if (isEmEspera)
      OutlinedButton.icon(
        onPressed: () => _confirmarCancelamento(enrollment),
        icon: const Icon(Icons.close, size: 18),
        label: const Text('Cancelar matrícula'),
        style: _dangerEnrollmentButton(),
      ),
  ];

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color(0xFFDCE5EB),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EDF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: Color(0xFF426E8C),
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (enrollment['upa_nome'] ??
                            'Unidade não identificada')
                        .toString(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cidade.isEmpty ? 'Unidade de saúde' : cidade,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF737A80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
Align(
  alignment: Alignment.topRight,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 11,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: _getStatusColor(status).withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getStatusIcon(status),
          size: 15,
          color: _getStatusColor(status),
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusText(status),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _getStatusColor(status),
          ),
        ),
      ],
    ),
  ),
),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(
          height: 1,
          color: Color(0xFFE4E0D6),
        ),
        const SizedBox(height: 20),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _enrollmentInfoLine(
      Icons.schedule_outlined,
      'Turma: ${enrollment['turma_horario'] ?? 'Não informado'}',
    ),
    if (isEmEspera &&
        enrollment['segunda_opcao_turma'] != null &&
        enrollment['segunda_opcao_turma'].toString().isNotEmpty) ...[
      const SizedBox(height: 12),
      _enrollmentInfoLine(
        Icons.swap_horiz,
        '2ª opção: ${enrollment['segunda_opcao_turma']}',
      ),
    ],
    const SizedBox(height: 12),
    _enrollmentInfoLine(
      Icons.location_on_outlined,
      enderecoCompleto,
    ),
    const SizedBox(height: 12),
    _enrollmentInfoLine(
      Icons.calendar_today_outlined,
      'Matrícula: ${_formatDate(enrollment['created_at']?.toString())}',
    ),
  ],
),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 950
                ? actions.length
                : width >= 550
                    ? 2
                    : 1;

            const spacing = 10.0;

            final buttonWidth =
                (width - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: actions.map((action) {
                return SizedBox(
                  width: buttonWidth,
                  height: 48,
                  child: action,
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _enrollmentInfoLine(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 17, color: const Color(0xFF426E8C)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.5, color: Color(0xFF4E4E4E)))),
    ],
  );

  ButtonStyle _secondaryEnrollmentButton() => OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF426E8C),
    side: const BorderSide(color: Color(0xFFC9DEED)),
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ButtonStyle _dangerEnrollmentButton() => OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFC65D47),
    side: const BorderSide(color: Color(0xFFE7B9AD)),
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );


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


Future<void> _confirmarAbandonoMatricula(
  Map<String, dynamic> enrollment,
) async {
  final confirmController = TextEditingController();
  bool isLoading = false;
  bool isConfirmValid = false;

  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final size = MediaQuery.sizeOf(context);
            final isMobile = size.width < 600;
            final isSmallMobile = size.width < 400;

            return Dialog(
              backgroundColor: const Color(0xFFFFFDF9),
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Color(0xFFE6E5DF),
                  width: 1,
                ),
              ),
              insetPadding: EdgeInsets.only(
                left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
                right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
                top: 20,
                bottom: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  maxHeight: size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 22,
                        vertical: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFDF9),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE6E5DF),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8ECEA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.exit_to_app_outlined,
                              color: Color(0xFFC65D47),
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Abandonar matrícula',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Confirmação necessária',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF667078),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE6E5DF),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Color(0xFF667078),
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tem certeza que deseja abandonar sua matrícula?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Confira as informações abaixo antes de continuar.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Color(0xFF667078),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF8F3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE6E5DF),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unidade de atendimento',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Color(0xFF667078),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    enrollment['upa_nome']?.toString() ??
                                        'Não informado',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Turma',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Color(0xFF667078),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    enrollment['turma_horario']?.toString() ??
                                        'Não informado',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8ECEA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEFD6D0),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    color: Color(0xFFC65D47),
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Esta ação não pode ser desfeita. Você perderá o acesso ao cronograma e às atividades.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF9B4939),
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Confirmação de abandono',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Para confirmar, digite exatamente a frase abaixo:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFF667078),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF8F3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE6E5DF),
                                ),
                              ),
                              child: const Text(
                                'CONFIRMAR ABANDONO',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC65D47),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: confirmController,
                              enabled: !isLoading,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                setModalState(() {
                                  isConfirmValid =
                                      value.trim().toUpperCase() ==
                                      'CONFIRMAR ABANDONO';
                                });
                              },
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Color(0xFF333333),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Digite a frase acima',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF667078),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 15,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE6E5DF),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFC65D47),
                                    width: 1.5,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE6E5DF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF667078),
                                      side: const BorderSide(
                                        color: Color(0xFFE6E5DF),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: (isLoading || !isConfirmValid)
                                        ? null
                                        : () async {
                                            setModalState(() {
                                              isLoading = true;
                                            });

                                            try {
                                              await _abandonarMatricula(
                                                enrollment,
                                              );

                                              if (dialogContext.mounted) {
                                                Navigator.pop(dialogContext);
                                              }
                                            } catch (_) {
                                              if (dialogContext.mounted) {
                                                setModalState(() {
                                                  isLoading = false;
                                                });
                                              }
                                            }
                                          },
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 17,
                                            height: 17,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check,
                                            size: 17,
                                          ),
                                    label: Text(
                                      isLoading
                                          ? 'Processando...'
                                          : 'Confirmar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFC65D47),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          const Color(0xFFE4E1DD),
                                      disabledForegroundColor:
                                          const Color(0xFF8A8A8A),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      confirmController.dispose();
    });
  }
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