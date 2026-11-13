
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class CronogramaWidget extends StatefulWidget {
  final int upaId;

  const CronogramaWidget({
    super.key,
    required this.upaId,
  });

  @override
  State<CronogramaWidget> createState() => _CronogramaWidgetState();
}

class _CronogramaWidgetState extends State<CronogramaWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accentColor = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);
  static const Color _successColor = Color(0xFF397C69);
  static const Color _successSoft = Color(0xFFE7F2EC);
  static const Color _dangerColor = Color(0xFFC65D47);
  static const Color _dangerSoft = Color(0xFFF8ECEA);

  List<Map<String, dynamic>> _turmas = [];
  bool _carregando = true;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _carregarCronograma();
  }

  @override
  void dispose() {
    _requestId++;
    super.dispose();
  }

  String _texto(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int _inteiro(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _obterAulas(Map<String, dynamic> turma) {
    final aulas = turma['aulas'];

    if (aulas is! List) return [];

    final resultado = aulas
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    resultado.sort((a, b) {
      return _inteiro(a['numero_aula'])
          .compareTo(_inteiro(b['numero_aula']));
    });

    return resultado;
  }

  BoxDecoration _cardDecoration({
    Color color = _surface,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _border),
    );
  }

  Future<void> _carregarCronograma() async {
    final requestId = ++_requestId;

    setState(() => _carregando = true);

    try {
      final response = await AuthService().getTurmasComCronograma();

      if (!mounted || requestId != _requestId) return;

      final turmas = (response['turmas'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        _turmas = turmas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() => _carregando = false);

      ToastService.showError(
        context,
        'Erro ao carregar cronograma: $e',
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _agruparTurmasPorDia(
    List<Map<String, dynamic>> turmas,
  ) {
    final grupos = <String, List<Map<String, dynamic>>>{};

    for (final turma in turmas) {
      final nome = _texto(turma['nome']);
      final diaInformado = _texto(turma['dia_semana']);

      final dia = diaInformado.isNotEmpty
          ? diaInformado
          : (nome.isNotEmpty ? nome.split(' - ').first : 'Outros dias');

      grupos.putIfAbsent(dia, () => []);
      grupos[dia]!.add(turma);
    }

    const ordem = [
      'segunda',
      'terça',
      'terca',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
      'sabado',
      'domingo',
    ];

    int indiceDia(String dia) {
      final normalizado = dia.toLowerCase();

      for (var i = 0; i < ordem.length; i++) {
        if (normalizado.contains(ordem[i])) return i;
      }

      return 99;
    }

    final entries = grupos.entries.toList()
      ..sort((a, b) {
        final comparison =
            indiceDia(a.key).compareTo(indiceDia(b.key));

        if (comparison != 0) return comparison;

        return a.key.compareTo(b.key);
      });

    return Map.fromEntries(entries);
  }

  int get _totalAulas {
    return _turmas.fold<int>(
      0,
      (total, turma) => total + _obterAulas(turma).length,
    );
  }

  int get _turmasComAulas {
    return _turmas
        .where((turma) => _obterAulas(turma).isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final turmasPorDia = _agruparTurmasPorDia(_turmas);

    return ColoredBox(
      color: _background,
      child: RefreshIndicator(
        color: _accentColor,
        onRefresh: _carregarCronograma,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width < 400 ? 12 : (mobile ? 16 : 28),
            vertical: mobile ? 20 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(mobile),
                  const SizedBox(height: 26),
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  if (_carregando)
                    _buildLoading()
                  else if (turmasPorDia.isEmpty)
                    _buildEmptyCronograma()
                  else
                    ...turmasPorDia.entries.map(
                      (entry) => _buildDiaCard(
                        entry.key,
                        entry.value,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool mobile) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORGANIZAÇÃO DAS ATIVIDADES',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Cronograma',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 27 : 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.9,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Organize as aulas do programa e acompanhe as atividades de cada turma.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.6,
            color: _textSecondary,
          ),
        ),
      ],
    );

    final refreshButton = OutlinedButton.icon(
      onPressed: _carregando ? null : _carregarCronograma,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Atualizar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accentColor,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
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
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 18),
          refreshButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 20),
        refreshButton,
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      _CronogramaStat(
        'Turmas cadastradas',
        _turmas.length,
        Icons.groups_outlined,
        _accentColor,
        _accentSoft,
      ),
      _CronogramaStat(
        'Aulas programadas',
        _totalAulas,
        Icons.event_note_outlined,
        _successColor,
        _successSoft,
      ),
      _CronogramaStat(
        'Turmas com aulas',
        _turmasComAulas,
        Icons.event_available_outlined,
        _accentColor,
        _accentSoft,
      ),
      _CronogramaStat(
        'Sem aulas',
        _turmas.length - _turmasComAulas,
        Icons.event_busy_outlined,
        _dangerColor,
        _dangerSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 4 : 2;
        final gap = width < 400 ? 10.0 : 14.0;
        final cardWidth =
            (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats.map((stat) {
            return SizedBox(
              width: cardWidth,
              child: _buildStatCard(stat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(_CronogramaStat stat) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: stat.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 21,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            '${stat.value}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: _accentColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programação das turmas',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aulas organizadas por dia da semana',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: _cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(
          color: _accentColor,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildEmptyCronograma() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 60,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: _accentColor,
          ),
          SizedBox(height: 18),
          Text(
            'Nenhum cronograma cadastrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cadastre turmas para organizar as aulas do programa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaCard(
    String dia,
    List<Map<String, dynamic>> turmas,
  ) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(mobile ? 15 : 20),
            decoration: const BoxDecoration(
              color: _surfaceSoft,
              border: Border(
                bottom: BorderSide(color: _border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.today_outlined,
                    color: _accentColor,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dia,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${turmas.length} ${turmas.length == 1 ? 'turma cadastrada' : 'turmas cadastradas'}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 12 : 20),
            child: Column(
              children: turmas
                  .map(_buildTurmaCronogramaCard)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurmaCronogramaCard(
    Map<String, dynamic> turma,
  ) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final aulas = _obterAulas(turma);
    final nome = _texto(turma['nome'], fallback: 'Turma');
    final horario = _texto(turma['horario']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(
        color: _surface,
        radius: 12,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(mobile ? 14 : 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 530;

                final info = Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_outlined,
                        size: 20,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            horario.isEmpty
                                ? '${aulas.length} aulas cadastradas'
                                : '$horario  •  ${aulas.length} aulas',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final button = ElevatedButton.icon(
                  onPressed: () => _abrirModalCronograma(turma),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 18,
                  ),
                  label: const Text('Adicionar aula'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
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
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info,
                      const SizedBox(height: 15),
                      button,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    button,
                  ],
                );
              },
            ),
          ),
          const Divider(
            color: _border,
            height: 1,
          ),
          if (aulas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 28,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 32,
                      color: _textSecondary.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nenhuma aula cadastrada',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(mobile ? 10 : 14),
              child: Column(
                children: aulas
                    .map((aula) => _buildAulaItem(aula, turma))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAulaItem(
    Map<String, dynamic> aula,
    Map<String, dynamic> turma,
  ) {
    final numero = _texto(aula['numero_aula'], fallback: '-');
    final data = _texto(
      aula['data_formatada'],
      fallback: 'Data não informada',
    );
    final horario = _texto(aula['horario']);
    final turmaId = _inteiro(turma['id']);
    final aulaId = _inteiro(aula['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              numero,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aula $numero',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  horario.isEmpty ? data : '$data • $horario',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 1.5,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Excluir aula',
            onPressed: () => _confirmarDeletarAula(
              turmaId,
              aulaId,
            ),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 19,
            ),
            style: IconButton.styleFrom(
              foregroundColor: _dangerColor,
              backgroundColor: _dangerSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _textSecondary,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _textSecondary,
      ),
      prefixIcon: Icon(
        icon,
        color: _accentColor,
        size: 20,
      ),
      filled: true,
      fillColor: readOnly ? _surfaceSoft : _surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _accentColor,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future<void> _abrirModalCronograma(
    Map<String, dynamic> turma,
  ) async {
    final numeroAulaController = TextEditingController();
    final dataController = TextEditingController();
    final mesController = TextEditingController();
    final horarioFixo = _texto(turma['horario']);

    DateTime? dataSelecionada;
    bool isLoading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final screen = MediaQuery.sizeOf(dialogContext);
            final compact = screen.width < 450;

            return Dialog(
              backgroundColor: _surface,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              insetPadding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 24,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: _border),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 470,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 18 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _successSoft,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.event_available_outlined,
                              color: _successColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adicionar aula',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Nova atividade no cronograma',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: _cardDecoration(
                          color: _accentSoft,
                          radius: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.groups_outlined,
                              size: 19,
                              color: _accentColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_texto(turma['dia_semana'])} - $horarioFixo',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: numeroAulaController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration(
                          label: 'Número da aula',
                          hint: 'Ex.: 1, 2, 3...',
                          icon: Icons.format_list_numbered_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: dataController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          label: 'Data da aula',
                          hint: 'Selecione uma data',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                final agora = DateTime.now();
                                final primeiroDia = DateTime(
                                  agora.year,
                                  agora.month,
                                  agora.day,
                                );

                                final results =
                                    await showCalendarDatePicker2Dialog(
                                  context: dialogContext,
                                  config:
                                      CalendarDatePicker2WithActionButtonsConfig(
                                    calendarType:
                                        CalendarDatePicker2Type.single,
                                    firstDate: primeiroDia,
                                    lastDate: primeiroDia.add(
                                      const Duration(days: 365),
                                    ),
                                    currentDate: primeiroDia,
                                    selectedDayHighlightColor:
                                        _accentColor,
                                    selectedDayTextStyle:
                                        const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    cancelButton:
                                        const Text('Cancelar'),
                                    okButton:
                                        const Text('Confirmar'),
                                  ),
                                  dialogSize: Size(
                                    screen.width < 400
                                        ? screen.width - 32
                                        : 350,
                                    450,
                                  ),
                                  value: [
                                    dataSelecionada ?? primeiroDia,
                                  ],
                                );

                                if (!dialogContext.mounted ||
                                    results == null ||
                                    results.isEmpty ||
                                    results.first == null) {
                                  return;
                                }

                                final selectedDate = results.first!;

                                final formatada =
                                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                                    '${selectedDate.year}';

                                int mesCalculado =
                                    ((selectedDate.month - agora.month) +
                                            12) %
                                        12;

                                mesCalculado = mesCalculado == 0
                                    ? 1
                                    : mesCalculado + 1;

                                if (mesCalculado > 6) {
                                  mesCalculado = 6;
                                }

                                setModalState(() {
                                  dataSelecionada = selectedDate;
                                  dataController.text = formatada;
                                  mesController.text =
                                      mesCalculado.toString();
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: TextEditingController(
                          text: horarioFixo,
                        ),
                        readOnly: true,
                        decoration: _inputDecoration(
                          label: 'Horário',
                          hint: 'Horário fixo da turma',
                          icon: Icons.access_time_outlined,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: mesController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          label: 'Mês do programa',
                          hint: 'Calculado automaticamente',
                          icon: Icons.calendar_month_outlined,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _textSecondary,
                                side: const BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final numero = int.tryParse(
                                        numeroAulaController.text.trim(),
                                      );

                                      if (numero == null ||
                                          numero <= 0 ||
                                          dataSelecionada == null ||
                                          mesController.text.isEmpty) {
                                        ToastService.showError(
                                          dialogContext,
                                          'Preencha todos os campos obrigatórios',
                                        );
                                        return;
                                      }

                                      setModalState(
                                        () => isLoading = true,
                                      );

                                      try {
                                        await AuthService()
                                            .adicionarAulaCronograma(
                                          turma['id'],
                                          numero,
                                          dataSelecionada!
                                              .toIso8601String()
                                              .split('T')[0],
                                          horarioFixo,
                                          int.parse(mesController.text),
                                        );

                                        if (!dialogContext.mounted) {
                                          return;
                                        }

                                        Navigator.pop(dialogContext);

                                        if (!mounted) return;

                                        _carregarCronograma();

                                        ToastService.showSuccess(
                                          context,
                                          'Aula adicionada com sucesso!',
                                        );
                                      } catch (e) {
                                        if (!dialogContext.mounted) {
                                          return;
                                        }

                                        ToastService.showError(
                                          dialogContext,
                                          'Erro ao adicionar aula: $e',
                                        );

                                        setModalState(
                                          () => isLoading = false,
                                        );
                                      }
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                isLoading
                                    ? 'Salvando...'
                                    : 'Adicionar',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _successColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    _successColor.withValues(alpha: 0.6),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
            );
          },
        );
      },
    );

    numeroAulaController.dispose();
    dataController.dispose();
    mesController.dispose();
  }

  Future<void> _confirmarDeletarAula(
    int turmaId,
    int aulaId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _dangerSoft,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _dangerColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Excluir aula',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tem certeza que deseja excluir esta aula do cronograma? Esta ação não pode ser desfeita.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.6,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textSecondary,
                            side: const BorderSide(color: _border),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                          ),
                          label: const Text('Excluir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _dangerColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await AuthService().deletarAulaCronograma(aulaId);

      if (!mounted) return;

      _carregarCronograma();

      ToastService.showSuccess(
        context,
        'Aula excluída com sucesso!',
      );
    } catch (e) {
      if (!mounted) return;

      ToastService.showError(
        context,
        'Erro ao excluir aula: $e',
      );
    }
  }
}

class _CronogramaStat {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  const _CronogramaStat(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}
