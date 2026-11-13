
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/cronograma_modal_widget.dart';
import 'package:tabagismo_app/widgets/enfermeira/modals/presenca_historico_modal_widget.dart';

class ListaPresencaWidget extends StatefulWidget {
  final int upaId;

  const ListaPresencaWidget({
    super.key,
    required this.upaId,
  });

  @override
  State<ListaPresencaWidget> createState() => _ListaPresencaWidgetState();
}

class _ListaPresencaWidgetState extends State<ListaPresencaWidget> {
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
  static const Color _warningColor = Color(0xFFD97706);
  static const Color _warningSoft = Color(0xFFFFF3E2);
  static const Color _dangerColor = Color(0xFFC65D47);
  static const Color _dangerSoft = Color(0xFFF8ECEA);

  late Future<Map<String, dynamic>> _presencasFuture;
  final Set<String> _turmasSalvando = {};

  @override
  void initState() {
    super.initState();
    _presencasFuture = _buscarPresencas();
  }

  Future<Map<String, dynamic>> _buscarPresencas() async {
    return await AuthService().getUsuariosMatriculadosComPresencas();
  }

  Future<void> _recarregar() async {
    final future = _buscarPresencas();

    setState(() {
      _presencasFuture = future;
    });

    try {
      await future;
    } catch (_) {}
  }

  String _texto(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int _inteiro(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  List<Map<String, dynamic>> _usuarios(Map<String, dynamic> turma) {
    final lista = turma['usuarios'];

    if (lista is! List) return [];

    return lista
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> _agruparTurmasPorDia(
    List<dynamic> turmas,
  ) {
    final grupos = <String, List<Map<String, dynamic>>>{};

    for (final item in turmas) {
      if (item is! Map) continue;

      final turma = Map<String, dynamic>.from(item);
      final nome = _texto(turma['nome']);
      final dia = nome.isEmpty
          ? 'Outros dias'
          : nome.split(' - ').first;

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

    int indice(String dia) {
      final normalizado = dia.toLowerCase();

      for (var i = 0; i < ordem.length; i++) {
        if (normalizado.contains(ordem[i])) return i;
      }

      return 99;
    }

    final entries = grupos.entries.toList()
      ..sort((a, b) {
        final comparacao = indice(a.key).compareTo(indice(b.key));

        if (comparacao != 0) return comparacao;

        return a.key.compareTo(b.key);
      });

    return Map.fromEntries(entries);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return ColoredBox(
      color: _background,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _presencasFuture,
        builder: (context, snapshot) {
          final carregando =
              snapshot.connectionState == ConnectionState.waiting;

          final response = snapshot.data;
          final turmas = response?['turmas'] is List
              ? response!['turmas'] as List
              : <dynamic>[];

          final grupos = _agruparTurmasPorDia(turmas);

          final todasTurmas = grupos.values
              .expand((grupo) => grupo)
              .toList();

          final totalAlunos = todasTurmas.fold<int>(
            0,
            (total, turma) => total + _usuarios(turma).length,
          );

          final totalVagas = todasTurmas.fold<int>(
            0,
            (total, turma) =>
                total + _inteiro(turma['vagas_totais'], fallback: 4),
          );

          return RefreshIndicator(
            color: _accentColor,
            onRefresh: _recarregar,
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
                      _buildHeader(mobile),
                      const SizedBox(height: 26),
                      _buildIndicadores(
                        turmas: todasTurmas.length,
                        alunos: totalAlunos,
                        vagas: totalVagas,
                        dias: grupos.length,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionHeader(),
                      const SizedBox(height: 16),
                      if (carregando)
                        _buildLoading()
                      else if (snapshot.hasError)
                        _buildErro(snapshot.error)
                      else if (grupos.isEmpty)
                        _buildVazio()
                      else
                        ...grupos.entries.map(
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool mobile) {
    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACOMPANHAMENTO DOS PARTICIPANTES',
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
          'Lista de presença',
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
          'Registre a participação dos alunos e acompanhe as atividades de cada turma.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.6,
            color: _textSecondary,
          ),
        ),
      ],
    );

    final atualizar = OutlinedButton.icon(
      onPressed: _recarregar,
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
          titulo,
          const SizedBox(height: 18),
          atualizar,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titulo),
        const SizedBox(width: 20),
        atualizar,
      ],
    );
  }

  Widget _buildIndicadores({
    required int turmas,
    required int alunos,
    required int vagas,
    required int dias,
  }) {
    final indicadores = [
      _PresencaIndicador(
        'Turmas cadastradas',
        turmas,
        Icons.groups_outlined,
        _accentColor,
        _accentSoft,
      ),
      _PresencaIndicador(
        'Alunos matriculados',
        alunos,
        Icons.people_outline_rounded,
        _successColor,
        _successSoft,
      ),
      _PresencaIndicador(
        'Vagas disponíveis',
        (vagas - alunos).clamp(0, vagas),
        Icons.person_add_alt_outlined,
        _warningColor,
        _warningSoft,
      ),
      _PresencaIndicador(
        'Dias de atendimento',
        dias,
        Icons.calendar_month_outlined,
        _accentColor,
        _accentSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 4 : 2;
        final gap = width < 400 ? 10.0 : 14.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: indicadores.map((item) {
            return SizedBox(
              width: cardWidth,
              child: Container(
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
                        color: item.background,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        item.icon,
                        size: 21,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      '${item.value}',
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
                      item.label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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
            Icons.fact_check_outlined,
            size: 21,
            color: _accentColor,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controle de frequência',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Selecione a presença e a observação de cada aluno',
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

  Widget _buildErro(Object? erro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _dangerColor,
            size: 40,
          ),
          const SizedBox(height: 14),
          const Text(
            'Não foi possível carregar as presenças',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$erro',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
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
            Icons.people_outline_rounded,
            size: 48,
            color: _accentColor,
          ),
          SizedBox(height: 18),
          Text(
            'Nenhum usuário matriculado',
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
            'Aguardando matrículas na sua UPA.',
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
              children: turmas.map((turma) {
                return _TurmaPresencaCard(
                  key: ValueKey(
                    '${_texto(turma['id'])}-${_texto(turma['nome'])}',
                  ),
                  turma: turma,
                  onCronograma: () => _verCronogramaTurma(turma),
                  onHistorico: () => _abrirHistoricoTurma(turma),
                  onEncerrar: () => _confirmarEncerrarTurma(turma),
                  onSalvar: (usuarios) => _salvarPresencas(
                    turma,
                    usuarios,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _salvarPresencas(
    Map<String, dynamic> turma,
    List<Map<String, dynamic>> usuarios,
  ) async {
    final chave = _texto(
      turma['id'],
      fallback: _texto(turma['nome']),
    );

    if (_turmasSalvando.contains(chave)) return false;

    _turmasSalvando.add(chave);

    try {
      final now = DateTime.now();

      final dataStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final presencas = usuarios.map((usuario) {
        return {
          'matriculaId': usuario['matricula_id'],
          'status': usuario['presenca_status'] ?? 'falta',
          'observacao': usuario['observacao_semanal'],
        };
      }).toList();

      await AuthService().salvarPresencasEmLote(
        presencas,
        dataStr,
      );

      if (!mounted) return false;

      ToastService.showSuccess(
        context,
        'Presenças salvas com sucesso!',
      );

      return true;
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao salvar presenças: $e',
        );
      }

      return false;
    } finally {
      _turmasSalvando.remove(chave);
    }
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';

    final numeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }

    return cpf;
  }

  void _verCronogramaTurma(Map<String, dynamic> turma) {
    final usuarios = turma['usuarios'];

    if (usuarios is! List || usuarios.isEmpty) return;

    final primeiro = usuarios.first;

    if (primeiro is! Map) return;

    final matriculaId = _inteiro(primeiro['matricula_id']);

    if (matriculaId <= 0) return;

    _verCronograma(
      matriculaId,
      _texto(turma['nome']),
    );
  }

  void _verCronograma(int matriculaId, String turmaHorario) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final mobile = size.width < 700;

        return Dialog(
          backgroundColor: _surface,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(
            horizontal: mobile ? 10 : 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: size.height * 0.88,
            ),
            child: SizedBox(
              width: 700,
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

  void _abrirHistoricoTurma(Map<String, dynamic> turma) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final mobile = size.width < 700;

        return Dialog(
          backgroundColor: _surface,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(
            horizontal: mobile ? 10 : 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1100,
              maxHeight: size.height * 0.88,
            ),
            child: SizedBox(
              width: 1100,
              child: HistoricoTurmaModal(
                turmaNome: _texto(turma['nome']),
                upaNome: 'Pronto Atendimento Alto Ipiranga',
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarEncerrarTurma(
    Map<String, dynamic> turma,
  ) async {
    String? tipoSelecionado;
    bool isLoading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final size = MediaQuery.sizeOf(dialogContext);
            final compact = size.width < 450;

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
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 18 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _warningSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: _warningColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Encerrar turma',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Finalização das atividades',
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
                        padding: const EdgeInsets.all(14),
                        decoration: _cardDecoration(
                          color: _surfaceSoft,
                          radius: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TURMA SELECIONADA',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _texto(turma['nome']),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Selecione o tipo de encerramento',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOpcaoEncerramento(
                        titulo: 'Turma concluída',
                        descricao:
                            'O programa foi finalizado com sucesso.',
                        valor: 'concluida',
                        selecionado: tipoSelecionado,
                        icon: Icons.check_circle_outline_rounded,
                        cor: _successColor,
                        habilitado: !isLoading,
                        onTap: () {
                          setModalState(
                            () => tipoSelecionado = 'concluida',
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildOpcaoEncerramento(
                        titulo: 'Turma cancelada',
                        descricao:
                            'O programa foi interrompido antes do fim.',
                        valor: 'cancelada',
                        selecionado: tipoSelecionado,
                        icon: Icons.cancel_outlined,
                        cor: _dangerColor,
                        habilitado: !isLoading,
                        onTap: () {
                          setModalState(
                            () => tipoSelecionado = 'cancelada',
                          );
                        },
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
                            child: ElevatedButton(
                              onPressed:
                                  tipoSelecionado == null || isLoading
                                      ? null
                                      : () async {
                                          setModalState(
                                            () => isLoading = true,
                                          );

                                          final sucesso =
                                              await _encerrarTurma(
                                            turma,
                                            tipoSelecionado!,
                                          );

                                          if (!dialogContext.mounted) {
                                            return;
                                          }

                                          if (sucesso) {
                                            Navigator.pop(dialogContext);
                                          } else {
                                            setModalState(
                                              () => isLoading = false,
                                            );
                                          }
                                        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    tipoSelecionado == 'concluida'
                                        ? _successColor
                                        : _dangerColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _border,
                                disabledForegroundColor: _textSecondary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      tipoSelecionado == 'concluida'
                                          ? 'Concluir'
                                          : 'Cancelar turma',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
            );
          },
        );
      },
    );
  }

  Widget _buildOpcaoEncerramento({
    required String titulo,
    required String descricao,
    required String valor,
    required String? selecionado,
    required IconData icon,
    required Color cor,
    required bool habilitado,
    required VoidCallback onTap,
  }) {
    final ativo = selecionado == valor;

    return InkWell(
      onTap: habilitado ? onTap : null,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ativo ? cor.withValues(alpha: 0.06) : _surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: ativo ? cor : _border,
            width: ativo ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: cor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
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
            const SizedBox(width: 10),
            Icon(
              ativo
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: ativo ? cor : _textSecondary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _encerrarTurma(
    Map<String, dynamic> turma,
    String tipoEncerramento,
  ) async {
    try {
      await AuthService().encerrarTurma(
        widget.upaId,
        turma['nome'],
        tipoEncerramento,
      );

      if (!mounted) return false;

      ToastService.showSuccess(
        context,
        'Turma encerrada com sucesso!',
      );

      await _recarregar();

      return true;
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao encerrar turma: $e',
        );
      }

      return false;
    }
  }
}

class _TurmaPresencaCard extends StatefulWidget {
  final Map<String, dynamic> turma;
  final VoidCallback onCronograma;
  final VoidCallback onHistorico;
  final VoidCallback onEncerrar;
  final Future<bool> Function(List<Map<String, dynamic>>) onSalvar;

  const _TurmaPresencaCard({
    super.key,
    required this.turma,
    required this.onCronograma,
    required this.onHistorico,
    required this.onEncerrar,
    required this.onSalvar,
  });

  @override
  State<_TurmaPresencaCard> createState() => _TurmaPresencaCardState();
}

class _TurmaPresencaCardState extends State<_TurmaPresencaCard> {
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accentColor = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);
  static const Color _successColor = Color(0xFF397C69);
  static const Color _dangerColor = Color(0xFFC65D47);
  static const Color _warningColor = Color(0xFFD97706);

  late List<Map<String, dynamic>> _usuarios;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _sincronizarUsuarios();
  }

  @override
  void didUpdateWidget(covariant _TurmaPresencaCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.turma, widget.turma)) {
      _sincronizarUsuarios();
    }
  }

  void _sincronizarUsuarios() {
    final lista = widget.turma['usuarios'];

    _usuarios = lista is List
        ? lista
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : [];
  }

  String _texto(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';

    final numeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }

    return cpf;
  }

  bool get _podeSalvar {
    return _usuarios.isNotEmpty &&
        _usuarios.every((usuario) {
          final status = usuario['presenca_status'];
          return status == 'presente' || status == 'falta';
        });
  }

  int get _marcados {
    return _usuarios.where((usuario) {
      final status = usuario['presenca_status'];
      return status == 'presente' || status == 'falta';
    }).length;
  }

  Future<void> _salvar() async {
    if (_salvando || !_podeSalvar) return;

    setState(() => _salvando = true);

    await widget.onSalvar(_usuarios);

    if (!mounted) return;

    setState(() => _salvando = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final nome = _texto(widget.turma['nome'], fallback: 'Turma');
    final vagas = int.tryParse(
          widget.turma['vagas_totais']?.toString() ?? '',
        ) ??
        4;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(mobile ? 14 : 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;

                final identificacao = Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_outlined,
                        size: 21,
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
                            '${_usuarios.length}/$vagas vagas ocupadas',
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

                final progresso = _buildProgresso();

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      identificacao,
                      const SizedBox(height: 15),
                      progresso,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: identificacao),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 180,
                      child: progresso,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(color: _border, height: 1),
          Padding(
            padding: EdgeInsets.all(mobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_usuarios.isEmpty)
                  _buildSemAlunos()
                else if (mobile)
                  _buildListaMobile()
                else
                  _buildTabelaDesktop(),
                const SizedBox(height: 16),
                _buildAcoes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresso() {
    final total = _usuarios.length;
    final progresso = total == 0 ? 0.0 : _marcados / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Presenças preenchidas',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: _textSecondary,
                ),
              ),
            ),
            Text(
              '$_marcados/$total',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 6,
            backgroundColor: _accentSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(
              _successColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemAlunos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 32,
            color: _textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum aluno nesta turma',
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

  Widget _buildListaMobile() {
    return Column(
      children: _usuarios.map((usuario) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: _accentColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _texto(
                            usuario['nome_completo'],
                            fallback: 'Aluno',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatarCpf(
                            _texto(usuario['cpf']),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 270;

                  if (compact) {
                    return Column(
                      children: [
                        _buildCampoPresenca(usuario),
                        const SizedBox(height: 10),
                        _buildCampoObservacao(usuario),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildCampoPresenca(usuario),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCampoObservacao(usuario),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabelaDesktop() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            color: _surfaceSoft,
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ALUNO / CPF',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PRESENÇA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    'OBSERVAÇÃO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._usuarios.asMap().entries.map((entry) {
            final usuario = entry.value;
            final ultimo = entry.key == _usuarios.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: ultimo
                    ? null
                    : const Border(
                        bottom: BorderSide(color: _border),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _texto(
                            usuario['nome_completo'],
                            fallback: 'Aluno',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatarCpf(
                            _texto(usuario['cpf']),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildCampoPresenca(
                      usuario,
                      mostrarLabel: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildCampoObservacao(
                      usuario,
                      mostrarLabel: false,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampoPresenca(
    Map<String, dynamic> usuario, {
    bool mostrarLabel = true,
  }) {
    final status = _texto(
      usuario['presenca_status'],
      fallback: 'nenhum',
    );

    const options = {
      'nenhum': 'Selecionar',
      'presente': 'Presente',
      'falta': 'Falta',
    };

    final valor = options.containsKey(status) ? status : 'nenhum';

    final cor = valor == 'presente'
        ? _successColor
        : valor == 'falta'
            ? _dangerColor
            : _textSecondary;

    return _buildDropdown(
      label: mostrarLabel ? 'Presença' : null,
      value: valor,
      options: options,
      color: cor,
      onChanged: _salvando
          ? null
          : (value) {
              setState(() {
                usuario['presenca_status'] =
                    value == 'nenhum' ? null : value;
              });
            },
    );
  }

  Widget _buildCampoObservacao(
    Map<String, dynamic> usuario, {
    bool mostrarLabel = true,
  }) {
    final observacao = _texto(usuario['observacao_semanal']);

    const options = {
      '': 'Selecionar',
      '1- Está fumando': 'Fumando',
      '2- Sem fumar': 'Sem fumar',
    };

    final valor = options.containsKey(observacao)
        ? observacao
        : '';

    final cor = valor == '1- Está fumando'
        ? _warningColor
        : valor == '2- Sem fumar'
            ? _accentColor
            : _textSecondary;

    return _buildDropdown(
      label: mostrarLabel ? 'Observação' : null,
      value: valor,
      options: options,
      color: cor,
      onChanged: _salvando
          ? null
          : (value) {
              setState(() {
                usuario['observacao_semanal'] =
                    value == '' ? null : value;
              });
            },
    );
  }

  Widget _buildDropdown({
    required String? label,
    required String value,
    required Map<String, String> options,
    required Color color,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 7),
        ],
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 19,
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: color.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _accentColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _border),
            ),
          ),
          items: options.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAcoes() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 470;

        final opcoes = PopupMenuButton<String>(
          tooltip: 'Opções da turma',
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(color: _border),
          ),
          onSelected: (value) {
            switch (value) {
              case 'cronograma':
                widget.onCronograma();
                break;
              case 'historico':
                widget.onHistorico();
                break;
              case 'encerrar':
                widget.onEncerrar();
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'cronograma',
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: _accentColor,
                    size: 19,
                  ),
                  SizedBox(width: 12),
                  Text('Cronograma'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'historico',
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: _accentColor,
                    size: 19,
                  ),
                  SizedBox(width: 12),
                  Text('Histórico'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'encerrar',
              child: Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: _dangerColor,
                    size: 19,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Encerrar turma',
                    style: TextStyle(color: _dangerColor),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.more_horiz_rounded,
                  color: _accentColor,
                  size: 20,
                ),
                SizedBox(width: 7),
                Text(
                  'Opções',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
        );

        final salvar = ElevatedButton.icon(
          onPressed: _salvando || !_podeSalvar ? null : _salvar,
          icon: _salvando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                  size: 18,
                ),
          label: Text(
            _salvando ? 'Salvando...' : 'Marcar presenças',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _successColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _border,
            disabledForegroundColor: _textSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
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
          return Row(
            children: [
              opcoes,
              const SizedBox(width: 10),
              Expanded(child: salvar),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            opcoes,
            const SizedBox(width: 12),
            salvar,
          ],
        );
      },
    );
  }
}

class _PresencaIndicador {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  const _PresencaIndicador(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}
