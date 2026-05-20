import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';

class CronogramaModal extends StatefulWidget {
  final int matriculaId;
  final String turmaHorario;
  
  const CronogramaModal({
    Key? key,
    required this.matriculaId,
    required this.turmaHorario,
  }) : super(key: key);

  @override
  _CronogramaModalState createState() => _CronogramaModalState();
}

class _CronogramaModalState extends State<CronogramaModal> {
  final AuthService _authService = AuthService();
  final Color _primaryDark = const Color(0xFF334155);
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  
  bool _isLoading = true;
  Map<String, dynamic>? _cronograma;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarCronograma();
  }

  Future<void> _carregarCronograma() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _authService.getCronograma(widget.matriculaId);
      setState(() {
        _cronograma = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cronograma de Aulas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.turmaHorario,
                          style: TextStyle(
                            fontSize: 12,
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
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildCronogramaContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregarCronograma,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
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

  Widget _buildCronogramaContent() {
    final aulas = List<Map<String, dynamic>>.from(_cronograma!['aulas']);
    final totalAulas = _cronograma!['total_aulas'];
    final dataInicio = _cronograma!['data_inicio'];
    final turma = _cronograma!['turma'];
    final proximaAula = _cronograma!['proxima_aula'];
    
    if (aulas.isEmpty) {
      return _buildEmptyWidget();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(turma, dataInicio, totalAulas, proximaAula),
          const SizedBox(height: 24),
          const Text(
            'Calendário de Aulas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ...aulas.map((aula) => _buildAulaCard(aula)),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today, size: 64, color: _warningColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma aula programada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'O cronograma de aulas ainda não foi definido para esta turma.\nAguardando definição da UPA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Voltar'),
              style: OutlinedButton.styleFrom(
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

  Widget _buildInfoCard(String turma, String dataInicio, int totalAulas, Map<String, dynamic>? proximaAula) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.calendar_today, color: _accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Programa de 6 meses',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'),
                    ),
                    Text(
                      turma,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_month, size: 20, color: _accentColor),
                      const SizedBox(height: 6),
                      const Text('Início', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                      const SizedBox(height: 4),
                      Text(dataInicio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.class_, size: 20, color: _accentColor),
                      const SizedBox(height: 6),
                      const Text('Total de Aulas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                      const SizedBox(height: 4),
                      Text('$totalAulas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.timer_outlined, size: 20, color: _accentColor),
                      const SizedBox(height: 6),
                      const Text('Duração', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                      const SizedBox(height: 4),
                      const Text('6 meses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (proximaAula != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _successColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.timer, color: _successColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Próxima Aula', style: TextStyle(fontSize: 11, color: _successColor, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        Text(
                          '${proximaAula['data_formatada']} às ${proximaAula['horario']}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAulaCard(Map<String, dynamic> aula) {
    final data = DateTime.parse(aula['data']);
    final hoje = DateTime.now();
    final isPassado = data.isBefore(hoje);
    final isHoje = data.year == hoje.year && data.month == hoje.month && data.day == hoje.day;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isHoje) {
      statusColor = _warningColor;
      statusText = 'Hoje';
      statusIcon = Icons.today;
    } else if (isPassado) {
      statusColor = const Color(0xFF94A3B8);
      statusText = 'Realizada';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = _successColor;
      statusText = 'Pendente';
      statusIcon = Icons.schedule;
    }
    
    String getMesTexto(int mes) {
      switch (mes) {
        case 1: return '1º Mês';
        case 2: return '2º Mês';
        case 3: return '3º Mês';
        case 4: return '4º Mês';
        case 5: return '5º Mês';
        case 6: return '6º Mês';
        default: return '${mes}º Mês';
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHoje ? _warningColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: isHoje ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${aula['numero']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getMesTexto(aula['mes']),
                    style: TextStyle(
                      fontSize: 10,
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aula['data_formatada'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      'Horário: ${aula['horario']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
}