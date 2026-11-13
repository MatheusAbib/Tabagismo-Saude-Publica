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
  State<CronogramaModal> createState() => _CronogramaModalState();
}

class _CronogramaModalState extends State<CronogramaModal> {
  final AuthService _authService = AuthService();

  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _danger = Color(0xFFB85F55);

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

      if (!mounted) return;

      setState(() {
        _cronograma = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  
@override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.sizeOf(context);
  final availableHeight = screenSize.height * 0.85;

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: availableHeight,
    ),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(
              height: 1,
              thickness: 1,
              color: _border,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildCronogramaContent(),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cronograma de aulas',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    height: 1.25,
                  ),
                ),
                if (widget.turmaHorario.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.turmaHorario,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.close,
                  color: _secondary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: _primary,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando cronograma...',
            style: TextStyle(
              color: _secondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8ECEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: _danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Não foi possível carregar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Ocorreu um erro ao buscar o cronograma.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(
                icon: Icons.refresh,
                label: 'Tentar novamente',
                onPressed: _carregarCronograma,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  color: _primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Nenhuma aula programada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'O cronograma de aulas ainda não foi definido para esta turma.\nAguardando definição da UPA.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 17,
                ),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  
Widget _buildCronogramaContent() {
  final cronograma = _cronograma;

  if (cronograma == null) {
    return _buildEmptyWidget();
  }

  final aulas = List<Map<String, dynamic>>.from(
    cronograma['aulas'] ?? [],
  );

  if (aulas.isEmpty) {
    return _buildEmptyWidget();
  }

  final totalAulas = cronograma['total_aulas'] ?? aulas.length;
  final dataInicio = cronograma['data_inicio']?.toString() ?? '-';
  final turma = cronograma['turma']?.toString() ?? 'Turma de apoio';

  final proximaAula = cronograma['proxima_aula'] is Map
      ? Map<String, dynamic>.from(cronograma['proxima_aula'])
      : null;

  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

return SingleChildScrollView(
  physics: const ClampingScrollPhysics(),
  padding: EdgeInsets.all(isMobile ? 14 : 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              turma,
              dataInicio,
              totalAulas,
              proximaAula,
              isMobile,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Calendário de aulas',
                    style: TextStyle(
                      color: _foreground,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Text(
                  '${aulas.length} ${aulas.length == 1 ? 'encontro' : 'encontros'}',
                  style: const TextStyle(
                    color: _secondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...aulas.map(
              (aula) => _buildAulaCard(aula, isMobile),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildInfoCard(
    String turma,
    String dataInicio,
    dynamic totalAulas,
    Map<String, dynamic>? proximaAula,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRAMA DE 6 MESES',
                      style: TextStyle(
                        color: _secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      turma,
                      style: TextStyle(
                        color: _foreground,
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            height: 1,
            color: _border,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoStat(
                  'INÍCIO',
                  dataInicio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoStat(
                  'AULAS',
                  '$totalAulas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoStat(
                  'DURAÇÃO',
                  '6 meses',
                ),
              ),
            ],
          ),
          if (proximaAula != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: _primary,
                    size: 21,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRÓXIMA AULA',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${proximaAula['data_formatada'] ?? '-'} às ${proximaAula['horario'] ?? '-'}',
                          style: const TextStyle(
                            color: _foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
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

  Widget _buildInfoStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _secondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _foreground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAulaCard(
    Map<String, dynamic> aula,
    bool isMobile,
  ) {
    final data = DateTime.tryParse(aula['data']?.toString() ?? '');
    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    final dataAula = data == null
        ? null
        : DateTime(
            data.year,
            data.month,
            data.day,
          );

    final isHoje = dataAula != null && dataAula.isAtSameMomentAs(hoje);
    final isPassado = dataAula != null && dataAula.isBefore(hoje);

    final String statusText;
    final IconData statusIcon;

    if (isHoje) {
      statusText = 'Hoje';
      statusIcon = Icons.today_outlined;
    } else if (isPassado) {
      statusText = 'Realizada';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusText = 'Pendente';
      statusIcon = Icons.schedule_outlined;
    }

    final numero = aula['numero']?.toString() ?? '-';
    final mes = _getMesTexto(aula['mes']);
    final dataFormatada = aula['data_formatada']?.toString() ?? '-';
    final horario = aula['horario']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isMobile ? 12 : 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHoje ? _primary : _border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 40 : 46,
            height: isMobile ? 40 : 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHoje ? _softBlue : const Color(0xFFF3F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              numero,
              style: const TextStyle(
                color: _primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mes,
                  style: const TextStyle(
                    color: _secondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    color: _foreground,
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      color: _secondary,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        horario,
                        style: const TextStyle(
                          color: _secondary,
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                Icon(
                  statusIcon,
                  color: isHoje ? _primary : _secondary,
                  size: 15,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                statusText,
                style: TextStyle(
                  color: isHoje ? _primary : _secondary,
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: isHoje ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMesTexto(dynamic mes) {
    final numeroMes = int.tryParse(mes?.toString() ?? '') ?? 0;

    switch (numeroMes) {
      case 1:
        return '1º Mês';
      case 2:
        return '2º Mês';
      case 3:
        return '3º Mês';
      case 4:
        return '4º Mês';
      case 5:
        return '5º Mês';
      case 6:
        return '6º Mês';
      default:
        return '${numeroMes}º Mês';
    }
  }
}