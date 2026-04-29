import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';

class HistoricoTurmaScreen extends StatefulWidget {
  final String turmaNome;
  final String upaNome;

  const HistoricoTurmaScreen({
    Key? key,
    required this.turmaNome,
    required this.upaNome,
  }) : super(key: key);

  @override
  _HistoricoTurmaScreenState createState() => _HistoricoTurmaScreenState();
}

class _HistoricoTurmaScreenState extends State<HistoricoTurmaScreen> {
  final Color _primaryColor = const Color(0xFF0F2B3D);
  final Color _primaryMedium = Color.fromARGB(255, 19, 56, 85);
  final Color _accentColor = const Color(0xFF2C7DA0);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico: $e'), backgroundColor: Colors.red.shade400),
      );
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
    if (observacao == '1- Está fumando') return const Color(0xFFF59E0B);
    if (observacao == '2- Sem fumar') return const Color(0xFF3B82F6);
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 50.0;
    
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Column(
        children: [
          _buildHeader(horizontalPadding),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _datas.isEmpty
                    ? _buildEmptyState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double horizontalPadding) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      decoration: BoxDecoration(
color:  _primaryMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile ? 'Histórico' : 'Histórico de Presenças',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                isMobile ? widget.turmaNome : '${widget.turmaNome} • ${widget.upaNome}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum registro de presença',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta turma ainda não possui registros de presença',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Voltar'),
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: _accentColor),
                foregroundColor: _accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildContent() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 12.0 : 20.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildTableCard(),
          const SizedBox(height: 20),
          _buildLegendCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isMobile = MediaQuery.of(context).size.width < 500;
    
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.people, color: _accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de Alunos',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_usuarios.length} alunos',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.calendar_today, color: _accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de Aulas',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_datas.length} aulas',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.people, color: _accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total de Alunos',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_usuarios.length} alunos matriculados',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.calendar_today, color: _accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total de Aulas',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_datas.length} aulas registradas',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.table_chart, color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Registro de Presenças',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                  padding: const EdgeInsets.all(14),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 70, child: Text('Taxa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)), textAlign: TextAlign.center)),
                      const SizedBox(width: 200, child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)))),
                      ..._datas.map((data) => Container(
                        width: 85,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Text(
                              data,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF0F172A)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const Divider(height: 1),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: percentualInt >= 75 
                                  ? const Color(0xFF10B981).withOpacity(0.12) 
                                  : percentualInt >= 50
                                      ? const Color(0xFFF59E0B).withOpacity(0.12)
                                      : const Color(0xFFEF4444).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$percentual%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: percentualInt >= 75 
                                    ? const Color(0xFF10B981) 
                                    : percentualInt >= 50
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 188,
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  usuario['nome'],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._datas.map((data) {
                          final status = usuario['presencas'][data];
                          final observacao = usuario['observacoes'][data];
                          final isPresente = status == 'presente';
                          final isFalta = status == 'falta';
                          final statusColor = isPresente 
                              ? const Color(0xFF10B981)
                              : isFalta
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey.shade300;
                          final statusText = getStatusText(status);
                          final obsText = getObservacaoText(observacao);
                          final obsColor = getObservacaoColor(observacao);
                          
                          return Container(
                            width: 85,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ),
                                if (obsText != '-')
                                  const SizedBox(height: 4),
                                if (obsText != '-')
                                  Container(
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: obsColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        obsText,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: obsColor,
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
    final isMobile = MediaQuery.of(context).size.width < 500;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Wrap(
        spacing: isMobile ? 12 : 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(const Color(0xFF10B981), 'Presente', 'P'),
          _buildLegendItem(const Color(0xFFEF4444), 'Falta', 'F'),
          _buildLegendItem(Colors.grey.shade300, 'Não registrado', '-'),
          _buildLegendItem(const Color(0xFFF59E0B), 'Fumando', 'F'),
          _buildLegendItem(const Color(0xFF3B82F6), 'Sem fumar', 'SM'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String code) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 20 : 24,
          height: isMobile ? 20 : 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(fontSize: isMobile ? 9 : 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: isMobile ? 10 : 12, color: const Color(0xFF475569)),
        ),
      ],
    );
  }
}
