import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class HistoricoTurmaModal extends StatefulWidget {
  final String turmaNome;
  final String upaNome;

  const HistoricoTurmaModal({
    Key? key,
    required this.turmaNome,
    required this.upaNome,
  }) : super(key: key);

  @override
  _HistoricoTurmaModalState createState() => _HistoricoTurmaModalState();
}

class _HistoricoTurmaModalState extends State<HistoricoTurmaModal> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  
  List<String> _datas = [];
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      final response = await AuthService().getHistoricoDetalhado();
      final turmas = List<Map<String, dynamic>>.from(response['turmas']);
      final turmaEncontrada = turmas.firstWhere(
        (t) => t['turma'] == widget.turmaNome,
        orElse: () => {'datas': [], 'usuarios': []}
      );
      
      setState(() {
        _datas = List<String>.from(turmaEncontrada['datas'] ?? []);
        _usuarios = List<Map<String, dynamic>>.from(turmaEncontrada['usuarios'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError(context, 'Erro ao carregar histórico: $e');
    }
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
  if (observacao == '1- Está fumando') return _warningColor;
  if (observacao == '2- Sem fumar') return _accentColor;
  return const Color(0xFF64748B);
}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                      Icons.history,
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
                          isMobile ? 'Histórico' : 'Histórico de Presenças',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.turmaNome}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: Colors.white.withOpacity(0.8),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _datas.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 12 : 20),
                          child: Column(
                            children: [
                              _buildInfoCard(),
                              const SizedBox(height: 16),
                              _buildTableCard(),
                              const SizedBox(height: 16),
                              _buildLegendCard(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: isMobile ? 48 : 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum registro de presença',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta turma ainda não possui registros de presença',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildInfoCard() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 8 : 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: isMobile
        ? Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.people, color: _accentColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alunos',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                        ),
                        Text(
                          '${_usuarios.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.calendar_today, color: _accentColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aulas',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                        ),
                        Text(
                          '${_datas.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.people, color: _accentColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alunos',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                        ),
                        Text(
                          '${_usuarios.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.calendar_today, color: _accentColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aulas',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                        ),
                        Text(
                          '${_datas.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
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

  Widget _buildTableCard() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.table_chart, color: _accentColor, size: isMobile ? 14 : 16),
              ),
              const SizedBox(width: 8),
              Text(
                isMobile ? 'Presenças' : 'Registro de Presenças',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
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
                padding: EdgeInsets.all(isMobile ? 6 : 10),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: isMobile ? 42 : 60,
                      child: Text(
                        'Taxa',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 8 : 10,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? 120 : 180,
                      child: Text(
                        'Aluno',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 8 : 10,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    ..._datas.map((data) => Container(
                      width: isMobile ? 55 : 75,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        data,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 7 : 9,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ..._usuarios.asMap().entries.map((entry) {
                final index = entry.key;
                final usuario = entry.value;
                
                int presentes = 0;
                int total = 0;
                for (var data in _datas) {
                  final status = usuario['presencas'][data];
                  if (status != null) {
                    total++;
                    if (status == 'presente') presentes++;
                  }
                }
                final percentual = total > 0 ? (presentes / total * 100).toStringAsFixed(0) : '0';
                final percentualInt = int.parse(percentual);
                
                return Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 10),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isMobile ? 42 : 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: percentualInt >= 75 
                                ? _successColor.withOpacity(0.12) 
                                : percentualInt >= 50
                                    ? _warningColor.withOpacity(0.12)
                                    : _dangerColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$percentual%',
                            style: TextStyle(
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.w600,
                              color: percentualInt >= 75 
                                  ? _successColor 
                                  : percentualInt >= 50
                                      ? _warningColor
                                      : _dangerColor,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? 120 : 180,
                        child: Text(
                          usuario['nome'],
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ..._datas.map((data) {
                        final status = usuario['presencas'][data];
                        final observacao = usuario['observacoes'][data];
                        final isPresente = status == 'presente';
                        final isFalta = status == 'falta';
                        final statusColor = isPresente 
                            ? _successColor
                            : isFalta
                                ? _dangerColor
                                : Colors.grey.shade300;
                        final statusText = getStatusText(status);
                        
                        String obsText;
                        if (observacao != null && observacao.isNotEmpty) {
                          obsText = getObservacaoText(observacao);
                        } else {
                          obsText = '-';
                        }
                  Color obsColor;
                  if (observacao != null && observacao.isNotEmpty) {
                    obsColor = getObservacaoColor(observacao);
                  } else {
                    obsColor = Colors.grey.shade400;
                  }
                        return Container(
                          width: isMobile ? 55 : 75,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            children: [
                              Container(
                                width: isMobile ? 24 : 32,
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: isMobile ? 9 : 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
const SizedBox(height: 2),
Container(
  width: isMobile ? 24 : 32,
  padding: const EdgeInsets.symmetric(vertical: 1),
  decoration: BoxDecoration(
    color: obsColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Center(
    child: Text(
      obsText,
      style: TextStyle(
        fontSize: isMobile ? 6 : 8,
        fontWeight: FontWeight.w500,
        color: obsColor,
        fontFamily: 'Inter',
      ),
    ),
  ),
),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildLegendCard() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 8 : 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Wrap(
      spacing: isMobile ? 6 : 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(_successColor, 'Presente', 'P', isMobile),
        _buildLegendItem(_dangerColor, 'Falta', 'F', isMobile),
        _buildLegendItem(Colors.grey.shade400, 'Não registrado', '-', isMobile),
        _buildLegendItem(_warningColor, 'Fumando', 'F', isMobile),
        _buildLegendItem(_accentColor, 'Sem fumar', 'SM', isMobile),
      ],
    ),
  );
}

  Widget _buildLegendItem(Color color, String label, String code, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 16 : 20,
          height: isMobile ? 16 : 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                fontSize: isMobile ? 7 : 9,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 8 : 10,
            color: Color(0xFF475569),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}