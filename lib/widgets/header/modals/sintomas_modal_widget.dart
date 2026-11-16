import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:tabagismo_app/services/sintoma_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class SintomasModalWidget {
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SintomasModalContent(),
    );
  }
}

class _SintomaInfo {
  final String titulo;
  final String campo;
  final IconData icone;
  final Color cor;

  const _SintomaInfo({
    required this.titulo,
    required this.campo,
    required this.icone,
    required this.cor,
  });
}

class _SintomasModalContent extends StatefulWidget {
  const _SintomasModalContent();

  @override
  State<_SintomasModalContent> createState() => _SintomasModalContentState();
}

class _SintomasModalContentState extends State<_SintomasModalContent> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _pageBackground = Color(0xFFFAF8F3);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);

  static const List<_SintomaInfo> _tipos = [
    _SintomaInfo(
      titulo: 'Ansiedade',
      campo: 'ansiedade',
      icone: Icons.psychology_outlined,
      cor: Color(0xFF426E8C),
    ),
    _SintomaInfo(
      titulo: 'Irritabilidade',
      campo: 'irritabilidade',
      icone: Icons.bolt_outlined,
      cor: Color(0xFFC65D47),
    ),
    _SintomaInfo(
      titulo: 'Insônia',
      campo: 'insonia',
      icone: Icons.bedtime_outlined,
      cor: Color(0xFF8B73A8),
    ),
    _SintomaInfo(
      titulo: 'Fome',
      campo: 'fome',
      icone: Icons.restaurant_outlined,
      cor: Color(0xFFC18A43),
    ),
    _SintomaInfo(
      titulo: 'Dificuldade de concentração',
      campo: 'dificuldade_concentracao',
      icone: Icons.center_focus_strong_outlined,
      cor: Color(0xFF568B79),
    ),
    _SintomaInfo(
      titulo: 'Vontade de fumar',
      campo: 'vontade_fumar',
      icone: Icons.smoke_free_outlined,
      cor: Color(0xFFB76F61),
    ),
  ];

  final SintomaService _sintomaService = SintomaService();
  final TextEditingController _observacoesController = TextEditingController();
  final ScrollController _graficoScrollController = ScrollController();

  final Map<String, int> _valores = {
    'ansiedade': 0,
    'irritabilidade': 0,
    'insonia': 0,
    'fome': 0,
    'dificuldade_concentracao': 0,
    'vontade_fumar': 0,
  };

  List<Map<String, dynamic>> _sintomas = [];

  bool _isLoading = true;
  bool _isSaving = false;
  int _abaSelecionada = 0;
  int _sintomaSelecionado = 0;

  @override
  void initState() {
    super.initState();
    _carregarSintomas();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _graficoScrollController.dispose();
    super.dispose();
  }

  int _valorRegistro(Map<String, dynamic> registro, String campo) {
    final valor = registro[campo];

    if (valor is num) return valor.toInt().clamp(0, 10);

    return (int.tryParse(valor?.toString() ?? '') ?? 0).clamp(0, 10);
  }

  Future<void> _carregarSintomas() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _sintomaService.getSintomas(limit: 30);

      if (!mounted) return;

      setState(() {
        _sintomas = response;
      });
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Não foi possível carregar o histórico de sintomas.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _salvarSintomas() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final hoje = DateTime.now().toIso8601String().split('T')[0];

      await _sintomaService.registrarSintoma(
        data: hoje,
        ansiedade: _valores['ansiedade']!,
        irritabilidade: _valores['irritabilidade']!,
        insonia: _valores['insonia']!,
        fome: _valores['fome']!,
        dificuldadeConcentracao: _valores['dificuldade_concentracao']!,
        vontadeFumar: _valores['vontade_fumar']!,
        observacoes: _observacoesController.text.trim(),
      );

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Sintomas registrados com sucesso!',
      );

      _observacoesController.clear();

      setState(() {
        for (final campo in _valores.keys) {
          _valores[campo] = 0;
        }

        _abaSelecionada = 1;
      });

      await _carregarSintomas();
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao registrar sintomas: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _nivel(int valor) {
    if (valor <= 2) return 'Muito leve';
    if (valor <= 4) return 'Leve';
    if (valor <= 6) return 'Moderado';
    if (valor <= 8) return 'Intenso';
    return 'Muito intenso';
  }

  Color _corNivel(int valor) {
    if (valor <= 2) return const Color(0xFF2E8B6A);
    if (valor <= 4) return const Color(0xFF789B36);
    if (valor <= 6) return const Color(0xFFD18A28);
    return const Color(0xFFC65D47);
  }

  String _formatarData(String? valor) {
    if (valor == null || valor.isEmpty) return '';

    try {
      final data = DateTime.parse(valor);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return '';
    }
  }

  String _formatarDataCurta(String? valor) {
    if (valor == null || valor.isEmpty) return '';

    try {
      final data = DateTime.parse(valor);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);
    final isMobile = tamanho.width < 800;
    final isSmallMobile = tamanho.width < 480;

    return Dialog(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 8 : (isMobile ? 12 : 24),
        vertical: isMobile ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1050,
          maxHeight: tamanho.height - (isMobile ? 24 : 48),
        ),
        child: SizedBox(
          height: tamanho.height * (isMobile ? 0.94 : 0.86),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              children: [
                _buildHeader(isMobile),
                const Divider(height: 1, color: _border),
                if (isMobile) _buildTabs(),
                Expanded(
                  child: isMobile
                      ? _buildMobileContent()
                      : _buildDesktopContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 15 : 24,
        vertical: isMobile ? 15 : 19,
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
              Icons.monitor_heart_outlined,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sintomas diários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Registre como você está se sentindo',
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _isSaving ? null : () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close,
                size: 19,
                color: _secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: _background,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Registrar',
              Icons.edit_note_outlined,
              0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              'Evolução',
              Icons.show_chart,
              1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String titulo, IconData icone, int indice) {
    final selecionado = _abaSelecionada == indice;

    return InkWell(
      onTap: () {
        setState(() {
          _abaSelecionada = indice;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selecionado ? _softBlue : _surface,
          border: Border.all(
            color: selecionado ? _primary : _border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 17,
              color: selecionado ? _primary : _secondary,
            ),
            const SizedBox(width: 7),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selecionado ? _primary : _secondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return IndexedStack(
      index: _abaSelecionada,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildFormulario(),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildEvolucao(),
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            color: _pageBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildFormulario(),
            ),
          ),
        ),
        Container(width: 1, color: _border),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildEvolucao(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeading({
    required String titulo,
    required String descricao,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: _foreground,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          descricao,
          style: const TextStyle(
            fontSize: 12,
            height: 1.55,
            color: _secondary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          titulo: 'Registrar sintomas',
          descricao:
              'Indique a intensidade de cada sintoma de 0 a 10, considerando como você se sente hoje.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: _softBlue.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _primary,
                size: 17,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  '0 = nenhum sintoma     10 = intensidade máxima',
                  style: TextStyle(
                    fontSize: 11,
                    color: _primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _tipos.length; i++) ...[
                _buildSintomaSlider(_tipos[i]),
                if (i < _tipos.length - 1)
                  const Divider(
                    height: 1,
                    indent: 15,
                    endIndent: 15,
                    color: _border,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Observações',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _foreground,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Opcional. Registre algo importante sobre o seu dia.',
          style: TextStyle(
            fontSize: 11,
            color: _secondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 11),
        TextField(
          controller: _observacoesController,
          maxLines: 3,
          minLines: 3,
          maxLength: 1000,
          style: const TextStyle(
            fontSize: 13,
            color: _foreground,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: 'Como foi seu dia? Houve alguma situação diferente?',
            hintStyle: const TextStyle(
              color: _secondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _primary),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _salvarSintomas,
            icon: _isSaving
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              _isSaving ? 'Salvando...' : 'Registrar sintomas',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _primary.withValues(alpha: 0.65),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  
Widget _buildSintomaSlider(_SintomaInfo sintoma) {
  final valor = _valores[sintoma.campo] ?? 0;
  final cor = sintoma.cor;

  return Padding(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                sintoma.icone,
                size: 18,
                color: cor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sintoma.titulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Container(
              width: 36,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.10),
                border: Border.all(
                  color: cor.withValues(alpha: 0.18),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$valor',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: cor,
            inactiveTrackColor: cor.withValues(alpha: 0.14),
            thumbColor: cor,
            overlayColor: cor.withValues(alpha: 0.12),
            valueIndicatorColor: cor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 7,
            ),
          ),
          child: Slider(
            value: valor.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$valor',
            onChanged: _isSaving
                ? null
                : (novoValor) {
                    setState(() {
                      _valores[sintoma.campo] = novoValor.round();
                    });
                  },
          ),
        ),
      ],
    ),
  );
}


  Widget _buildEvolucao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          titulo: 'Evolução dos sintomas',
          descricao:
              'Consulte seus registros e acompanhe as mudanças ao longo do tempo.',
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          _buildLoading()
        else if (_sintomas.isEmpty)
          _buildEmptyState()
        else ...[
          _buildGraficoSection(),
          const SizedBox(height: 26),
          _buildUltimoRegistro(),
        ],
      ],
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 310,
      child: Center(
        child: CircularProgressIndicator(
          color: _primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: _pageBackground,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.show_chart,
              size: 31,
              color: _primary,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Seu histórico começa aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _foreground,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Após registrar seus sintomas, você poderá acompanhar como eles variam ao longo dos dias.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: _secondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoSection() {
    final selecionado = _tipos[_sintomaSelecionado];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Text(
              '${_sintomas.length} ${_sintomas.length == 1 ? 'registro' : 'registros'}',
              style: const TextStyle(
                fontSize: 11,
                color: _secondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: DropdownButtonFormField<int>(
                initialValue: _sintomaSelecionado,
                isExpanded: true,
                dropdownColor: _surface,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _secondary,
                ),
                decoration: InputDecoration(
                  labelText: 'Sintoma exibido',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    color: _secondary,
                    fontFamily: 'Inter',
                  ),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: const BorderSide(color: _primary),
                  ),
                ),
                items: List.generate(
                  _tipos.length,
                  (index) {
                    final tipo = _tipos[index];

                    return DropdownMenuItem<int>(
                      value: index,
                      child: Row(
                        children: [
                          Icon(
                            tipo.icone,
                            size: 17,
                            color: _secondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tipo.titulo,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _foreground,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _sintomaSelecionado = value;
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 14, 12),
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: selecionado.cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selecionado.titulo,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _foreground,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const Text(
                      'Escala de 0 a 10',
                      style: TextStyle(
                        fontSize: 10,
                        color: _secondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLineChart(selecionado),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(_SintomaInfo selecionado) {
    final registros = _sintomas.reversed.toList();

    final pontos = List<fl_chart.FlSpot>.generate(
      registros.length,
      (index) {
        return fl_chart.FlSpot(
          index.toDouble(),
          _valorRegistro(registros[index], selecionado.campo).toDouble(),
        );
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraDisponivel = constraints.maxWidth;
        final larguraGrafico = registros.length <= 1
            ? larguraDisponivel
            : (registros.length * 55.0).clamp(
                larguraDisponivel,
                double.infinity,
              );

        return Column(
          children: [
            SizedBox(
              height: 270,
              child: Scrollbar(
                controller: _graficoScrollController,
                thumbVisibility: larguraGrafico > larguraDisponivel,
                child: SingleChildScrollView(
                  controller: _graficoScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: larguraGrafico,
                    height: 260,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        right: 10,
                        bottom: 8,
                      ),
                      child: fl_chart.LineChart(
                        fl_chart.LineChartData(
                          minX: 0,
                          maxX: registros.length <= 1
                              ? 1
                              : (registros.length - 1).toDouble(),
                          minY: 0,
                          maxY: 10,
                          clipData: const fl_chart.FlClipData.all(),
                          gridData: fl_chart.FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (value) {
                              return const fl_chart.FlLine(
                                color: _border,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: fl_chart.FlBorderData(
                            show: false,
                          ),
                          titlesData: fl_chart.FlTitlesData(
                            topTitles: const fl_chart.AxisTitles(
                              sideTitles: fl_chart.SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: const fl_chart.AxisTitles(
                              sideTitles: fl_chart.SideTitles(
                                showTitles: false,
                              ),
                            ),
                            leftTitles: fl_chart.AxisTitles(
                              sideTitles: fl_chart.SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 2,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _secondary,
                                      fontFamily: 'Inter',
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: fl_chart.AxisTitles(
                              sideTitles: fl_chart.SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: registros.length > 12 ? 2 : 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();

                                  if (index < 0 ||
                                      index >= registros.length ||
                                      value != index.toDouble()) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Text(
                                      _formatarDataCurta(
                                        registros[index]['data']?.toString(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _secondary,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: fl_chart.LineTouchData(
                            enabled: true,
                            touchTooltipData: fl_chart.LineTouchTooltipData(
                              getTooltipColor: (spot) => _foreground,
                              getTooltipItems: (spots) {
                                return spots.map((spot) {
                                  return fl_chart.LineTooltipItem(
                                    '${spot.y.toInt()} / 10',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            fl_chart.LineChartBarData(
                              spots: pontos,
                              isCurved: false,
                              color: selecionado.cor,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: fl_chart.FlDotData(
                                show: true,
                                getDotPainter: (
                                  spot,
                                  percent,
                                  bar,
                                  index,
                                ) {
                                  return fl_chart.FlDotCirclePainter(
                                    radius: 3.5,
                                    color: selecionado.cor,
                                    strokeWidth: 1.5,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: fl_chart.BarAreaData(
                                show: true,
                                color: selecionado.cor.withValues(alpha: 0.06),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (larguraGrafico > larguraDisponivel)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 15,
                      color: _secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Deslize para visualizar outros dias',
                      style: TextStyle(
                        fontSize: 10,
                        color: _secondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUltimoRegistro() {
    if (_sintomas.isEmpty) return const SizedBox.shrink();

    final ultimo = _sintomas.first;
    final data = _formatarData(ultimo['data']?.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Último registro',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (data.isNotEmpty)
              Text(
                data,
                style: const TextStyle(
                  fontSize: 11,
                  color: _secondary,
                  fontFamily: 'Inter',
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _tipos.length; i++) ...[
                _buildResumoLinha(
                  _tipos[i],
                  _valorRegistro(ultimo, _tipos[i].campo),
                ),
                if (i < _tipos.length - 1)
                  const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: _border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumoLinha(_SintomaInfo sintoma, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            sintoma.icone,
            size: 17,
            color: _secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sintoma.titulo,
              style: const TextStyle(
                fontSize: 12,
                color: _foreground,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _nivel(valor),
            style: TextStyle(
              fontSize: 10,
              color: _corNivel(valor),
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 43,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pageBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$valor/10',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _foreground,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}