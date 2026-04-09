import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/cronograma_screen.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const MyEnrollmentsScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _MyEnrollmentsScreenState createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  final _enrollmentService = EnrollmentService();
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _dangerColor = Color(0xFFEF4444);
  
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  int _itemsPerPage = 4;
  int _totalPages = 1;
  List<Map<String, dynamic>> _paginatedEnrollments = [];

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
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
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history, color: _accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Meu Histórico de Presenças',
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
              _buildEstatisticasPresenca(estatisticas),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Registros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              _buildListaPresencas(presencas),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar histórico: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

Widget _buildEstatisticasPresenca(Map<String, dynamic> stats) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                stats['percentual'].toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
              ),
              const Text('Presença', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
        Expanded(
          child: Column(
            children: [
              Text(
                stats['presentes'].toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
              ),
              const Text('Presentes', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
        Expanded(
          child: Column(
            children: [
              Text(
                stats['faltas'].toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
              ),
              const Text('Faltas', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildListaPresencas(List<dynamic> presencas) {
  if (presencas.isEmpty) {
    return const Center(
      child: Text('Nenhum registro de presença encontrado', style: TextStyle(color: Color(0xFF64748B))),
    );
  }
  
  Map<String, Color> statusColors = {
    'presente': const Color(0xFF10B981),
    'falta': const Color(0xFFEF4444),
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
    if (observacao == '1- Está fumando') return const Color(0xFFF59E0B);
    if (observacao == '2- Sem fumar') return const Color(0xFF3B82F6);
    return const Color(0xFF94A3B8);
  }
  
  return Container(
    constraints: BoxConstraints(maxHeight: 300),
    child: ListView.separated(
      shrinkWrap: true,
      itemCount: presencas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = presencas[index];
        final status = p['status'];
        final observacao = p['observacao_semanal'];
        final color = statusColors[status] ?? Colors.grey;
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: Text(
                  _formatarData(p['data']),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getStatusText(status),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
                ),
              ),
              const SizedBox(width: 8),
              if (observacao != null && observacao.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getObservacaoColor(observacao).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                          fontWeight: FontWeight.w500,
                          color: getObservacaoColor(observacao),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _loadEnrollments() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
  });
  
  try {
    final response = await _enrollmentService.getMyEnrollments();
    
    if (response['success'] == true || response['data'] != null) {
      List<Map<String, dynamic>> enrollments = List<Map<String, dynamic>>.from(response['data']);
      
      enrollments.sort((a, b) {
        bool aCancelada = a['status'] == 'cancelada';
        bool bCancelada = b['status'] == 'cancelada';
        
        if (aCancelada && !bCancelada) return 1;
        if (!aCancelada && bCancelada) return -1;
        return 0;
      });
      
      setState(() {
        _enrollments = enrollments;
        _totalPages = (_enrollments.length / _itemsPerPage).ceil();
        if (_totalPages == 0) _totalPages = 1;
        _updatePagination();
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Erro ao carregar matrículas';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro ao carregar matrículas: $e';
    });
  } finally {
    setState(() => _isLoading = false);
  }
}

void _updatePagination() {
  int startIndex = (_currentPage - 1) * _itemsPerPage;
  int endIndex = startIndex + _itemsPerPage;
  if (endIndex > _enrollments.length) endIndex = _enrollments.length;
  setState(() {
    _paginatedEnrollments = _enrollments.sublist(startIndex, endIndex);
  });
}

void _goToPage(int page) {
  setState(() {
    _currentPage = page;
    _updatePagination();
  });
}

void _nextPage() => _goToPage(_currentPage + 1);
void _previousPage() => _goToPage(_currentPage - 1);

void _verDetalhes(Map<String, dynamic> enrollment) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(  
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.85,
          color: Colors.white,
          child: DetailsModal(
            enrollment: enrollment,
            onCancel: () => _confirmarCancelamento(enrollment),
          ),
        ),
      ),
    ),
  );
}

Future<void> _confirmarCancelamento(Map<String, dynamic> enrollment) async {
  showDialog(
    context: context,
    builder: (context) => Dialog(
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
                    child: const Text('Não, voltar'),
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matrícula cancelada com sucesso!'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    await _loadEnrollments();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao cancelar matrícula: $e'),
        backgroundColor: _dangerColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _isLoading = false);
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'em_espera':
      return Color(0xFFF59E0B);
    case 'confirmada':
      return Color(0xFF10B981);
    case 'matriculado':
      return Color(0xFF8B5CF6);
    case 'cancelada':
      return Color(0xFFEF4444);
      case 'concluida':
      return  Color(0xFF10B981);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          HeaderWidget(
            userName: widget.userData?['nomeCompleto'] ?? 'Usuário',
            userData: widget.userData,
            onNameUpdated: widget.onNameUpdated,
            showBackButton: true,
          ),
     Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildInfoBanner(),
              _isLoading
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: _accentColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _enrollments.isEmpty
                          ? _buildEmptyWidget()
                          : _buildEnrollmentsList(),
            ],
          ),
        ),
        SizedBox(height: 30),
        FooterWidget(),
      ],
    ),
  ),
),
        ],
      ),
    );
  }

Widget _buildInfoBanner() {
  return Container(
    margin: EdgeInsets.all(16),
    child: InkWell(
      onTap: _mostrarInformacoesGrupos,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Como funcionam as turmas de apoio?',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 14),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _dangerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 64, color: _dangerColor),
            ),
            SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: _dangerColor,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEnrollments,
              icon: Icon(Icons.refresh, size: 18),
              label: Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            ),
            SizedBox(height: 24),
            Text(
              'Você ainda não tem matrículas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vá em "Encontrar UPAs" e se matricule em uma turma',
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

Widget _buildEnrollmentsList() {
  return Column(
    children: [
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _paginatedEnrollments.length,
        itemBuilder: (context, index) {
          final enrollment = _paginatedEnrollments[index];
          return _buildEnrollmentCard(enrollment);
        },
      ),
      if (_totalPages > 1) _buildPagination(),
    ],
  );
}

Widget _buildPagination() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: _currentPage > 1 ? _accentColor : Colors.grey.shade400),
          onPressed: _currentPage > 1 ? _previousPage : null,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Página $_currentPage de $_totalPages',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _accentColor),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: _currentPage < _totalPages ? _accentColor : Colors.grey.shade400),
          onPressed: _currentPage < _totalPages ? _nextPage : null,
        ),
      ],
    ),
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
  
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: isCanceled ? Colors.grey.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCanceled ? Colors.grey.shade100 : const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryDark.withValues(alpha: isCanceled ? 0.05 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_outlined, color: isCanceled ? Colors.grey.shade500 : _primaryDark, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  enrollment['upa_nome'] ?? 'UPA não identificada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCanceled ? Colors.grey.shade600 : _primaryDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 16, color: isCanceled ? Colors.grey.shade400 : Colors.grey.shade500),
                  SizedBox(width: 8),
                  Text(
                    'Turma: ${enrollment['turma_horario'] ?? 'Não informado'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCanceled ? Colors.grey.shade500 : const Color(0xFF475569),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              if (enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 16, color: isCanceled ? Colors.grey.shade400 : _warningColor),
                    SizedBox(width: 8),
                    Text(
                      '2ª opção: ${enrollment['segunda_opcao_turma']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCanceled ? Colors.grey.shade500 : _warningColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: isCanceled ? Colors.grey.shade400 : Colors.grey.shade500),
                  SizedBox(width: 8),
                  Text(
                    'Data: ${_formatDate(enrollment['created_at'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCanceled ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              if (isConcluida) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, size: 16, color: const Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Parabéns! Você concluiu o programa com sucesso!',
                          style: TextStyle(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              Divider(color: isCanceled ? Colors.grey.shade200 : Colors.grey.shade200),
              SizedBox(height: 12),
              if (!isCanceled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Só em espera: botão Cancelar
                    if (isEmEspera)
                      TextButton.icon(
                        onPressed: () => _confirmarCancelamento(enrollment),
                        icon: Icon(Icons.delete_outline, size: 18, color: _dangerColor),
                        label: Text('Cancelar', style: TextStyle(color: _dangerColor, fontWeight: FontWeight.w500)),
                      ),
                    
                    if (!isConcluida && !isEmEspera)
                      OutlinedButton.icon(
                        onPressed: () => _verCronograma(enrollment['id'], enrollment['turma_horario']),
                        icon: Icon(Icons.calendar_month, size: 18, color: const Color(0xFF10B981)),
                        label: Text('Ver Cronograma', style: TextStyle(color: const Color(0xFF10B981))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF10B981)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    
                    SizedBox(width: 8),
                    
                    OutlinedButton.icon(
                      onPressed: () => _verDetalhes(enrollment),
                      icon: Icon(Icons.visibility_outlined, size: 18, color: _accentColor),
                      label: Text('Ver detalhes', style: TextStyle(color: _accentColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _accentColor),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    
                    if (isMatriculado)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _verHistoricoPresencas(enrollment['id']),
                          icon: Icon(Icons.history, size: 18, color: _accentColor),
                          label: Text('Lista de presença', style: TextStyle(color: _accentColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _accentColor),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    
                    if (isMatriculado)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmarAbandonoMatricula(enrollment),
                          icon: Icon(Icons.exit_to_app, size: 18, color: _dangerColor),
                          label: Text('Abandonar', style: TextStyle(color: _dangerColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _dangerColor),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

void _confirmarAbandonoMatricula(Map<String, dynamic> enrollment) {
  final TextEditingController confirmController = TextEditingController();
  bool isLoading = false;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
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
                    color: _dangerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app,
                    size: 48,
                    color: Color(0xFFEF4444),
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
                  style: TextStyle(
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (confirmController.text.trim().toUpperCase() != 'CONFIRMAR ABANDONO') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Digite a frase corretamente para confirmar'),
                                      backgroundColor: Color(0xFFEF4444),
                                    ),
                                  );
                                  return;
                                }
                                
                                setState(() => isLoading = true);
                                await _abandonarMatricula(enrollment);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        icon: isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          isLoading ? 'Processando...' : 'Confirmar Abandono',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dangerColor,
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matrícula abandonada com sucesso!'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    await _loadEnrollments();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao abandonar matrícula: $e'),
        backgroundColor: _dangerColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _isLoading = false);
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

void _mostrarInformacoesGrupos() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(  
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.85,
          color: Colors.white,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 231, 236, 240), 
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Como Funcionam as Turmas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: _primaryDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content remains the same
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          icon: Icons.how_to_reg_outlined,
                          title: 'Processo de Matrícula',
                          content:
                              'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a UPA entrará em contato pelo telefone cadastrado para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                          color: _accentColor,
                        ),
                        const SizedBox(height: 24),

                        _buildInfoSection(
                          icon: Icons.calendar_today_outlined,
                          title: 'Frequência dos Encontros',
                          content:
                              'O programa de apoio é estruturado da seguinte forma:\n\n• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\nCada encontro tem duração aproximada de 2 horas e é conduzido por profissionais de saúde especializados.',
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
                              _infoItem(Icons.health_and_safety_outlined, 'Educação em Saúde: Informações sobre os efeitos do tabagismo', _warningColor),
                              _infoItem(Icons.psychology_outlined, 'Estratégias de Enfrentamento: Técnicas para lidar com a fissura', _warningColor),
                              _infoItem(Icons.self_improvement_outlined, 'Atividades Práticas: Exercícios respiratórios e relaxamento', _warningColor),
                              _infoItem(Icons.person_outline, 'Acompanhamento Individual: Orientação personalizada', _warningColor),
                              _infoItem(Icons.people_outline, 'Rede de Apoio: Vínculos com pessoas na mesma jornada', _warningColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildInfoSection(
                          icon: Icons.medical_services_outlined,
                          title: 'Acompanhamento Profissional',
                          content:
                              'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n• Médicos especialistas em tabagismo\n• Psicólogos\n• Enfermeiros\n• Educadores físicos\n\nTodos os profissionais são capacitados para oferecer o melhor suporte durante todo o processo.',
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(height: 24),

                        _buildInfoSection(
                          icon: Icons.phone_android_outlined,
                          title: 'Comunicação e Suporte',
                          content:
                              'Além dos encontros presenciais, você receberá:\n\n✓ Mensagens de apoio e lembretes dos encontros via WhatsApp\n✓ Material informativo complementar\n✓ Acompanhamento via telefone nos intervalos\n✓ Grupo de suporte online para troca de experiências',
                          color: const Color(0xFF14B8A6),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Entendi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
              Icon(icon, color: color, size: 24),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class DetailsModal extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final VoidCallback? onCancel;

  DetailsModal({Key? key, required this.enrollment, this.onCancel}) : super(key: key);

  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _warningColor = Color(0xFFF59E0B);


  @override
  Widget build(BuildContext context) {
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

return Column(
  children: [
Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(255, 231, 236, 240),
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  child: SafeArea(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detalhes da Matrícula',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (enrollment['status'] == 'em_espera' && onCancel != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: _primaryDark),
              onPressed: () {
                Navigator.pop(context);
                onCancel!();
              },
              tooltip: 'Cancelar matrícula',
            ),
        ],
      ),
    ),
  ),
),
    Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard('UPA', enrollment['upa_nome'] ?? 'Não informado', Icons.location_on_outlined),
            SizedBox(height: 12),
            _buildDetailCard('Turma', enrollment['turma_horario'] ?? 'Não informado', Icons.schedule_outlined),
            SizedBox(height: 12),
            if (enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty)
              _buildDetailCard(
                'Segunda Opção', 
                enrollment['segunda_opcao_turma'],
                Icons.swap_horiz,
                color: _warningColor,
              ),
            SizedBox(height: 12),
            _buildDetailCard('Data da Matrícula', _formatDate(enrollment['created_at']), Icons.calendar_today_outlined),
            SizedBox(height: 12),
_buildDetailCard(
  'Status', 
  _getStatusText(enrollment['status'] ?? 'em_espera'),
  _getStatusIcon(enrollment['status'] ?? 'em_espera'),
  color: _getStatusColor(enrollment['status'] ?? 'em_espera'),
),
            SizedBox(height: 24),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 16),
            Text(
              'Informações Pessoais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 12),
            _buildDetailCard('Escolaridade', enrollment['escolaridade'] ?? 'Não informado', Icons.school_outlined),
            SizedBox(height: 12),
            _buildDetailCard('Score Fagerström', enrollment['score_fagestrom']?.toString() ?? 'Não informado', Icons.assessment_outlined),
            SizedBox(height: 12),
            _buildDetailCard('Medicamento', enrollment['medicamento'] ?? 'Não informado', Icons.medication_outlined),
            SizedBox(height: 24),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 16),
            Text(
              'Comorbidades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 12),
            _buildComorbidadesSection('Câncer', comorbidades['cancer'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Cardiovascular', comorbidades['cardiovascular'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Metabólico', comorbidades['metabolico'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Psiquiátrico', comorbidades['psiquiatrico'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Respiratório', comorbidades['respiratorio'] ?? []),
          ],
        ),
      ),
    ),
  ],
);
  }

Widget _buildDetailCard(String label, String value, IconData icon, {Color? color}) {
  final isStatusCard = label == 'Status';
  
  return Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isStatusCard && color != null ? color : _accentColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: isStatusCard && color != null ? color : _accentColor),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
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
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_information_outlined, size: 18, color: _accentColor),
            SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (itens.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nenhuma comorbidade registrada',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: itens.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
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

Color _getStatusColor(String status) {
  switch (status) {
    case 'em_espera':
      return const Color(0xFFF59E0B);
    case 'confirmada':
      return const Color(0xFF10B981);
    case 'matriculado':
      return const Color(0xFF8B5CF6);
    case 'cancelada':
      return const Color(0xFFEF4444);
    case 'concluida':
      return const Color(0xFF10B981);
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

}