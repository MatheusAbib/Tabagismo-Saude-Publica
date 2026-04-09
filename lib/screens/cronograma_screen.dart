import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';

class CronogramaScreen extends StatefulWidget {
  final int matriculaId;
  final String turmaHorario;
  
  const CronogramaScreen({
    Key? key,
    required this.matriculaId,
    required this.turmaHorario,
  }) : super(key: key);

  @override
  _CronogramaScreenState createState() => _CronogramaScreenState();
}

class _CronogramaScreenState extends State<CronogramaScreen> {
  final AuthService _authService = AuthService();
  final Color _primaryDark = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF2C7DA0);
  final Color _successColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _dangerColor = const Color(0xFFEF4444);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cronograma de Aulas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildCronogramaContent(),
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
              child: const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
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
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today, color: _accentColor, size: 24),
              ),
              const SizedBox(width: 12),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Início', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(dataInicio, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Column(
                  children: [
                    const Text('Total de Aulas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text('$totalAulas', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Column(
                  children: [
                    const Text('Duração', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    const Text('6 meses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
          if (proximaAula != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Próxima Aula', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontFamily: 'Inter')),
                        Text(
                          '${proximaAula['data_formatada']} às ${proximaAula['horario']}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                        ),
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
    
    if (isHoje) {
      statusColor = _warningColor;
      statusText = 'Hoje';
    } else if (isPassado) {
      statusColor = const Color(0xFF94A3B8);
      statusText = 'Realizada';
    } else {
      statusColor = _successColor;
      statusText = 'Pendente';
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHoje ? _warningColor : const Color(0xFFE2E8F0),
          width: isHoje ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${aula['numero']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                Text(
                  getMesTexto(aula['mes']),
                  style: TextStyle(fontSize: 11, color: _accentColor, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 4),
                Text(
                  aula['data_formatada'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                ),
                const SizedBox(height: 2),
                Text(
                  'Horário: ${aula['horario']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }
}