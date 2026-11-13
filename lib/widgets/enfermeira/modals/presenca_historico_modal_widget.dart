
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class HistoricoTurmaModal extends StatefulWidget {
  final String turmaNome;
  final String upaNome;

  const HistoricoTurmaModal({
    super.key,
    required this.turmaNome,
    required this.upaNome,
  });

  @override
  State<HistoricoTurmaModal> createState() => _HistoricoTurmaModalState();
}

class _HistoricoTurmaModalState extends State<HistoricoTurmaModal> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _cream = Color(0xFFFAF8F3);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _success = Color(0xFF397C69);
  static const Color _warning = Color(0xFFB87935);
  static const Color _danger = Color(0xFFC65D47);

  List<String> _datas = [];
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService().getHistoricoDetalhado();

      if (!mounted) return;

      final turmas = List<Map<String, dynamic>>.from(
        response['turmas'] ?? [],
      );

      final turmaEncontrada = turmas.firstWhere(
        (turma) => turma['turma'] == widget.turmaNome,
        orElse: () => {
          'datas': <String>[],
          'usuarios': <Map<String, dynamic>>[],
        },
      );

      setState(() {
        _datas = List<String>.from(turmaEncontrada['datas'] ?? []);
        _usuarios = List<Map<String, dynamic>>.from(
          turmaEncontrada['usuarios'] ?? [],
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ToastService.showError(
        context,
        'Erro ao carregar histórico: $e',
      );
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'presente':
        return 'P';
      case 'falta':
        return 'F';
      default:
        return '-';
    }
  }

  String getObservacaoText(String? observacao) {
    if (observacao == '1- Está fumando') return 'F';
    if (observacao == '2- Sem fumar') return 'SM';
    return '-';
  }

  Color getObservacaoColor(String? observacao) {
    if (observacao == '1- Está fumando') return _warning;
    if (observacao == '2- Sem fumar') return _primary;
    return _secondary;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < 600;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.85,
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
              _buildHeader(isMobile),
              const Divider(
                height: 1,
                thickness: 1,
                color: _border,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _datas.isEmpty
                            ? _buildEmptyState()
                            : _buildContent(isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
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
              Icons.history_outlined,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMobile ? 'Histórico' : 'Histórico de presenças',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.turmaNome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _secondary,
                  ),
                ),
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

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 65,
      ),
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
            'Carregando histórico...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF8ECEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: _danger,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Não foi possível carregar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _foreground,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ocorreu um problema ao consultar o histórico de presenças desta turma.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.6,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _carregarHistorico,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 32,
              color: _primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum registro de presença',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _foreground,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Esta turma ainda não possui registros de presença.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.6,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 17),
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
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(isMobile),
          const SizedBox(height: 16),
          _buildTableCard(isMobile),
          const SizedBox(height: 16),
          _buildLegendCard(isMobile),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isMobile) {
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
          const Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: _primary,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'Resumo da turma',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(
            height: 1,
            color: _border,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildInfoStat(
                  Icons.people_outline,
                  'Alunos',
                  '${_usuarios.length}',
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: _border,
              ),
              Expanded(
                child: _buildInfoStat(
                  Icons.calendar_today_outlined,
                  'Aulas registradas',
                  '${_datas.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 2,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _secondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(bool isMobile) {
    final taxaWidth = isMobile ? 62.0 : 85.0;
    final alunoWidth = isMobile ? 145.0 : 210.0;
    final dataWidth = isMobile ? 68.0 : 84.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              decoration: const BoxDecoration(
                color: _cream,
                border: Border(
                  bottom: BorderSide(color: _border),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _softBlue,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.table_chart_outlined,
                      color: _primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Registro de presenças',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _foreground,
                      ),
                    ),
                  ),
                  if (_datas.length > 3)
                    const Tooltip(
                      message: 'Deslize a tabela para visualizar mais datas',
                      child: Icon(
                        Icons.swipe_outlined,
                        color: _secondary,
                        size: 19,
                      ),
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: _softBlue.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTableHeaderCell(
                          'Taxa',
                          taxaWidth,
                          centered: true,
                        ),
                        _buildTableHeaderCell(
                          'Aluno',
                          alunoWidth,
                        ),
                        ..._datas.map(
                          (data) => _buildTableHeaderCell(
                            data,
                            dataWidth,
                            centered: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._usuarios.asMap().entries.map((entry) {
                    final index = entry.key;
                    final usuario = entry.value;

                    final presencas = usuario['presencas'] is Map
                        ? Map<String, dynamic>.from(
                            usuario['presencas'],
                          )
                        : <String, dynamic>{};

                    final observacoes = usuario['observacoes'] is Map
                        ? Map<String, dynamic>.from(
                            usuario['observacoes'],
                          )
                        : <String, dynamic>{};

                    int presentes = 0;
                    int total = 0;

                    for (final data in _datas) {
                      final status = presencas[data];

                      if (status != null) {
                        total++;

                        if (status == 'presente') {
                          presentes++;
                        }
                      }
                    }

                    final percentual = total > 0
                        ? (presentes / total * 100).round()
                        : 0;

                    final percentualColor = percentual >= 75
                        ? _success
                        : percentual >= 50
                            ? _warning
                            : _danger;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: index.isEven ? _surface : _cream,
                        border: const Border(
                          bottom: BorderSide(
                            color: _border,
                            width: 0.6,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: taxaWidth,
                            child: Center(
                              child: _buildStatusBadge(
                                '$percentual%',
                                percentualColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: alunoWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Tooltip(
                                message: usuario['nome']?.toString() ?? '-',
                                child: Text(
                                  usuario['nome']?.toString() ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ..._datas.map((data) {
                            final status = presencas[data]?.toString();
                            final observacao =
                                observacoes[data]?.toString();

                            final statusColor = status == 'presente'
                                ? _success
                                : status == 'falta'
                                    ? _danger
                                    : _secondary;

                            return SizedBox(
                              width: dataWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusBadge(
                                    getStatusText(status),
                                    statusColor,
                                  ),
                                  const SizedBox(height: 5),
                                  _buildStatusBadge(
                                    getObservacaoText(observacao),
                                    getObservacaoColor(observacao),
                                    compact: true,
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
      ),
    );
  }

  Widget _buildTableHeaderCell(
    String label,
    double width, {
    bool centered = false,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Text(
          label,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    String text,
    Color color, {
    bool compact = false,
    double fontSize = 10,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 30 : 34,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: compact ? 9 : fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLegendCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _primary,
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Legenda',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildLegendItem(_success, 'Presente', 'P'),
              _buildLegendItem(_danger, 'Falta', 'F'),
              _buildLegendItem(_secondary, 'Não registrado', '-'),
              _buildLegendItem(_warning, 'Fumando', 'F'),
              _buildLegendItem(_primary, 'Sem fumar', 'SM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String code,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBadge(
          code,
          color,
          compact: true,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: _secondary,
          ),
        ),
      ],
    );
  }
}
