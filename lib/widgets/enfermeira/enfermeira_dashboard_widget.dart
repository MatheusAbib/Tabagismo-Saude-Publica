
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class DashboardWidget extends StatefulWidget {
  final int upaId;

  const DashboardWidget({
    super.key,
    required this.upaId,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accentColor = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);
  static const Color _successColor = Color(0xFF397C69);
  static const Color _warningColor = Color(0xFFB87935);
  static const Color _dangerColor = Color(0xFFC65D47);

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _evolucao = {};

  bool _carregando = true;
  bool _exportando = false;

  int _alunosPage = 0;
  final int _alunosPerPage = 5;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() => _carregando = true);

    try {
      final stats = await AuthService().getEnfermeiraDashboardStats();
      final evolucao = await AuthService().getEvolucaoGeral();

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _evolucao = evolucao;
        _alunosPage = 0;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _carregando = false);
      ToastService.showError(context, 'Erro ao carregar dados: $e');
    }
  }

  Future<void> _exportarPDF() async {
    if (_exportando) return;

    setState(() => _exportando = true);

    try {
      await PdfService.gerarRelatorioDashboardCompleto(
        _stats,
        _evolucao,
        'Enfermeira',
        '',
      );

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'PDF gerado com sucesso!',
      );
    } catch (e) {
      if (!mounted) return;

      ToastService.showError(
        context,
        'Erro ao gerar PDF: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _exportando = false);
      }
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ??
          double.tryParse(value.replaceAll(',', '.'))?.toInt() ??
          0;
    }

    return 0;
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }

    return 0;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _texto(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _mesLabel(dynamic value) {
    final text = _texto(value, fallback: '-');
    final parts = text.split('-');

    if (parts.length >= 2) {
      const months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];

      final month = int.tryParse(parts[1]);

      if (month != null && month >= 1 && month <= 12) {
        return months[month - 1];
      }
    }

    return text;
  }

  String _turmaResumida(dynamic value) {
    final text = _texto(value, fallback: '-');
    return text.split(' - ').first;
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

    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: _accentColor,
          strokeWidth: 2.5,
        ),
      );
    }

    return ColoredBox(
      color: _background,
      child: RefreshIndicator(
        color: _accentColor,
        onRefresh: _carregarDados,
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
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildSectionIntroduction(
                    'Perfil dos participantes',
                    'Informações demográficas e condições de saúde dos usuários.',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 950) {
                        return Column(
                          children: [
                            _buildDemographicSection(),
                            const SizedBox(height: 16),
                            _buildHealthSection(),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDemographicSection(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildHealthSection(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildSectionIntroduction(
                    'Acompanhamento do tratamento',
                    'Evolução dos participantes e resultados registrados.',
                  ),
                  const SizedBox(height: 16),
                  _buildEvolucaoSection(),
                  const SizedBox(height: 30),
                  _buildSectionIntroduction(
                    'Histórico de matrículas',
                    'Quantidade de matrículas registradas ao longo dos meses.',
                  ),
                  const SizedBox(height: 16),
                  _buildChartSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool mobile) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAINEL DE ACOMPANHAMENTO',
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
          'Visão geral',
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
          'Acompanhe os dados das matrículas e a evolução dos participantes.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.6,
            color: _textSecondary,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: _carregando ? null : _carregarDados,
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
        ),
        ElevatedButton.icon(
          onPressed: _exportando ? null : _exportarPDF,
          icon: _exportando
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: Text(_exportando ? 'Gerando...' : 'Exportar PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accentColor,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
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
        ),
      ],
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 20),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        const SizedBox(width: 20),
        actions,
      ],
    );
  }

  Widget _buildSectionIntroduction(
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            height: 1.5,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final cards = [
      _DashboardStat(
        'Total de usuários',
        _parseToInt(_stats['totalUsuarios']).toString(),
        Icons.people_outline_rounded,
        _accentColor,
        _accentSoft,
      ),
      _DashboardStat(
        'Em espera',
        _parseToInt(_stats['totalEmEspera']).toString(),
        Icons.hourglass_empty_rounded,
        _warningColor,
        const Color(0xFFFAEEDC),
      ),
      _DashboardStat(
        'Matriculados',
        _parseToInt(_stats['totalMatriculados']).toString(),
        Icons.how_to_reg_outlined,
        _successColor,
        const Color(0xFFE7F2EC),
      ),
      _DashboardStat(
        'Cancelados',
        _parseToInt(_stats['totalCancelados']).toString(),
        Icons.person_off_outlined,
        _dangerColor,
        const Color(0xFFF8ECEA),
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
          children: cards.map((stat) {
            return SizedBox(
              width: cardWidth,
              child: _buildStatCard(stat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(_DashboardStat stat) {
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
            stat.value,
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

  Widget _buildPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: _border,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicSection() {
    final maiores = _parseToInt(_stats['maiores18']);
    final menores = _parseToInt(_stats['menores18']);

    return _buildPanel(
      title: 'Demografia',
      subtitle: 'Faixa etária e distribuição por sexo',
      icon: Icons.groups_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 340) {
                return Column(
                  children: [
                    _buildInfoItem(
                      'Maiores de 18 anos',
                      '$maiores usuários',
                      Icons.person_outline,
                      _accentColor,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoItem(
                      'Menores de 18 anos',
                      '$menores usuários',
                      Icons.child_care_outlined,
                      _successColor,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Maiores de 18 anos',
                      '$maiores usuários',
                      Icons.person_outline,
                      _accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoItem(
                      'Menores de 18 anos',
                      '$menores usuários',
                      Icons.child_care_outlined,
                      _successColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSexoDistribution(
            _asList(_stats['distribuicaoSexo']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 11,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 1.4,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDistribution(
    List<Map<String, dynamic>> sexoData,
  ) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;

    for (final item in sexoData) {
      final sexo = _texto(item['sexo'], fallback: '').toLowerCase();
      final total = _parseToInt(item['total']);

      if (sexo == 'masculino') {
        masculino += total;
      } else if (sexo == 'feminino') {
        feminino += total;
      } else {
        outro += total;
      }
    }

    final total = masculino + feminino + outro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribuição por sexo',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: total == 0
                ? const ColoredBox(color: _border)
                : Row(
                    children: [
                      if (masculino > 0)
                        Expanded(
                          flex: masculino,
                          child: const ColoredBox(
                            color: _accentColor,
                          ),
                        ),
                      if (feminino > 0)
                        Expanded(
                          flex: feminino,
                          child: const ColoredBox(
                            color: _successColor,
                          ),
                        ),
                      if (outro > 0)
                        Expanded(
                          flex: outro,
                          child: const ColoredBox(
                            color: _warningColor,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),
        _buildDistributionItem(
          'Masculino',
          masculino,
          total,
          _accentColor,
        ),
        const SizedBox(height: 12),
        _buildDistributionItem(
          'Feminino',
          feminino,
          total,
          _successColor,
        ),
        const SizedBox(height: 12),
        _buildDistributionItem(
          'Outro',
          outro,
          total,
          _warningColor,
        ),
      ],
    );
  }

  Widget _buildDistributionItem(
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? value / total * 100 : 0.0;

    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSection() {
    final cancer = _parseToInt(_stats['usuariosComCancer']);
    final cardiovascular =
        _parseToInt(_stats['usuariosComCardiovascular']);
    final score = _parseToDouble(_stats['mediaScoreFagestrom']);

    String classificacao;

    if (score <= 2) {
      classificacao = 'Muito baixa';
    } else if (score <= 4) {
      classificacao = 'Baixa';
    } else if (score == 5) {
      classificacao = 'Média';
    } else if (score <= 7) {
      classificacao = 'Elevada';
    } else {
      classificacao = 'Muito elevada';
    }

    return _buildPanel(
      title: 'Saúde dos participantes',
      subtitle: 'Condições registradas e dependência de nicotina',
      icon: Icons.monitor_heart_outlined,
      child: Column(
        children: [
          _buildHealthItem(
            'Pacientes com câncer',
            cancer.toString(),
            Icons.health_and_safety_outlined,
            _dangerColor,
          ),
          const SizedBox(height: 10),
          _buildHealthItem(
            'Condições cardiovasculares',
            cardiovascular.toString(),
            Icons.favorite_border_rounded,
            _warningColor,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: _accentSoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accentColor.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      color: _accentColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Teste de Fagerström',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '/ 10 pontos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (score / 10).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.white,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dependência média: $classificacao',
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
    );
  }

  Widget _buildHealthItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 11,
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolucaoSection() {
    final ativos = _asMap(_evolucao['alunos_ativos']);
    final concluidos = _asMap(_evolucao['alunos_concluidos']);

    return _buildPanel(
      title: 'Evolução dos alunos',
      subtitle: 'Situação do tabagismo durante e após o tratamento',
      icon: Icons.trending_up_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 750) {
                return Column(
                  children: [
                    _buildEvolucaoCard(
                      'Alunos ativos',
                      ativos,
                      _accentColor,
                    ),
                    const SizedBox(height: 12),
                    _buildEvolucaoCard(
                      'Alunos concluídos',
                      concluidos,
                      _successColor,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildEvolucaoCard(
                      'Alunos ativos',
                      ativos,
                      _accentColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildEvolucaoCard(
                      'Alunos concluídos',
                      concluidos,
                      _successColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _buildEvolucaoChart(_evolucao),
          const SizedBox(height: 28),
          _buildAlunosDetalhados(_evolucao),
        ],
      ),
    );
  }

  Widget _buildEvolucaoCard(
    String titulo,
    Map<String, dynamic> dados,
    Color cor,
  ) {
    final total = _parseToInt(dados['total']);
    final fumando = _parseToInt(dados['fumando']);
    final semFumar = _parseToInt(dados['sem_fumar']);
    final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            '$total',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Participantes',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  'Sem fumar',
                  semFumar,
                  _successColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniMetric(
                  'Fumando',
                  fumando,
                  _warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: total <= 0
                  ? const ColoredBox(color: _border)
                  : Row(
                      children: [
                        if (semFumar > 0)
                          Expanded(
                            flex: semFumar,
                            child: const ColoredBox(
                              color: _successColor,
                            ),
                          ),
                        if (fumando > 0)
                          Expanded(
                            flex: fumando,
                            child: const ColoredBox(
                              color: _warningColor,
                            ),
                          ),
                        if (total > semFumar + fumando)
                          Expanded(
                            flex: total - semFumar - fumando,
                            child: const ColoredBox(
                              color: _border,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Taxa de sucesso',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ),
              Text(
                '${taxaSucesso.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: taxaSucesso >= 50
                      ? _successColor
                      : _warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    String label,
    int value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolucaoChart(Map<String, dynamic> data) {
    final dados = _asList(data['evolucao_mensal_ativos']);

    if (dados.isEmpty) {
      return _buildEmptyState(
        Icons.bar_chart_outlined,
        'Nenhum dado de evolução disponível',
        'Os registros mensais aparecerão aqui quando estiverem disponíveis.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolução mensal',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Distribuição mensal dos alunos ativos por situação.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildMensalChart(dados),
        const SizedBox(height: 15),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            _buildLegendaItem(_successColor, 'Sem fumar'),
            _buildLegendaItem(_warningColor, 'Fumando'),
          ],
        ),
      ],
    );
  }

  Widget _buildMensalChart(
    List<Map<String, dynamic>> dados,
  ) {
    final maxValor = dados.fold<int>(0, (current, item) {
      final total = _parseToInt(item['fumando']) +
          _parseToInt(item['sem_fumar']);

      return math.max(current, total);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth < 500 ? 44.0 : 58.0;
        final chartWidth = math.max(
          constraints.maxWidth,
          dados.length * (barWidth + 14),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 225,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dados.map((item) {
                final fumando = _parseToInt(item['fumando']);
                final semFumar = _parseToInt(item['sem_fumar']);
                final total = fumando + semFumar;
                final altura = maxValor > 0
                    ? (total / maxValor) * 155.0
                    : 0.0;

                final alturaFumando = total > 0
                    ? altura * fumando / total
                    : 0.0;

                final alturaSemFumar = total > 0
                    ? altura * semFumar / total
                    : 0.0;

                return SizedBox(
                  width: barWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 155,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: barWidth - 14,
                              height: math.max(altura, 2),
                              child: Column(
                                children: [
                                  if (semFumar > 0)
                                    Container(
                                      height: alturaSemFumar,
                                      color: _successColor,
                                    ),
                                  if (fumando > 0)
                                    Container(
                                      height: alturaFumando,
                                      color: _warningColor,
                                    ),
                                  if (total == 0)
                                    const Expanded(
                                      child: ColoredBox(
                                        color: _border,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        _mesLabel(item['mes']),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlunosDetalhados(Map<String, dynamic> data) {
    final alunos = _asList(data['alunos_detalhados']);

    if (alunos.isEmpty) {
      return _buildEmptyState(
        Icons.people_outline,
        'Nenhum aluno para exibir',
        'Os dados individuais aparecerão quando houver registros.',
      );
    }

    final totalPages = (alunos.length / _alunosPerPage).ceil();
    final currentPage = _alunosPage.clamp(0, totalPages - 1);
    final startIndex = currentPage * _alunosPerPage;
    final endIndex = math.min(
      startIndex + _alunosPerPage,
      alunos.length,
    );
    final alunosPaginados = alunos.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: _border, height: 1),
        const SizedBox(height: 25),
        const Text(
          'Situação atual dos alunos',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${alunos.length} participantes com registros de acompanhamento.',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 17),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 680) {
              return Column(
                children: alunosPaginados
                    .map(_buildAlunoMobileCard)
                    .toList(),
              );
            }

            return _buildAlunosTable(alunosPaginados);
          },
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 18),
          _buildPagination(currentPage, totalPages),
        ],
      ],
    );
  }

  _AlunoSituacao _situacaoAluno(Map<String, dynamic> aluno) {
    final observacao = _texto(
      aluno['ultima_observacao'],
      fallback: '',
    );

    if (observacao == '2- Sem fumar') {
      return const _AlunoSituacao(
        'Sem fumar',
        _successColor,
        Color(0xFFE7F2EC),
      );
    }

    if (observacao == '1- Está fumando') {
      return const _AlunoSituacao(
        'Fumando',
        _warningColor,
        Color(0xFFFAEEDC),
      );
    }

    return const _AlunoSituacao(
      'Sem registro',
      _textSecondary,
      _surfaceSoft,
    );
  }

  Widget _buildSituacaoBadge(_AlunoSituacao situacao) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: situacao.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        situacao.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: situacao.color,
        ),
      ),
    );
  }

  Widget _buildAlunoMobileCard(Map<String, dynamic> aluno) {
    final situacao = _situacaoAluno(aluno);
    final semanasFumando = _parseToInt(aluno['semanas_fumando']);
    final semanasSemFumar = _parseToInt(aluno['semanas_sem_fumar']);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 11,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _texto(aluno['nome_completo']),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSituacaoBadge(situacao),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Turma: ${_turmaResumida(aluno['turma_horario'])}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 12,
            runSpacing: 7,
            children: [
              _buildSmallDetail(
                Icons.smoking_rooms_outlined,
                '$semanasFumando semanas fumando',
              ),
              _buildSmallDetail(
                Icons.check_circle_outline,
                '$semanasSemFumar semanas sem fumar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _textSecondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlunosTable(
    List<Map<String, dynamic>> alunos,
  ) {
    return Container(
      decoration: _cardDecoration(radius: 11),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: _surfaceSoft,
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'PARTICIPANTE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TURMA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SEMANAS F / SF',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SITUAÇÃO',
                    textAlign: TextAlign.center,
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
          ...alunos.map((aluno) {
            final situacao = _situacaoAluno(aluno);
            final fumando = _parseToInt(aluno['semanas_fumando']);
            final semFumar = _parseToInt(aluno['semanas_sem_fumar']);

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 15,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      _texto(aluno['nome_completo']),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _turmaResumida(aluno['turma_horario']),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$fumando / $semFumar',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildSituacaoBadge(situacao),
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

  Widget _buildPagination(int currentPage, int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPaginationButton(
          Icons.chevron_left,
          currentPage > 0
              ? () => setState(() => _alunosPage = currentPage - 1)
              : null,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: _cardDecoration(
            color: _surfaceSoft,
            radius: 9,
          ),
          child: Text(
            '${currentPage + 1} de $totalPages',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildPaginationButton(
          Icons.chevron_right,
          currentPage < totalPages - 1
              ? () => setState(() => _alunosPage = currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPaginationButton(
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: _accentColor,
        disabledForegroundColor: _textSecondary.withValues(alpha: 0.35),
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: _border),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final usuariosPorMes = _asList(_stats['usuariosPorMes']);

    return _buildPanel(
      title: 'Matrículas por mês',
      subtitle: 'Histórico de registros de matrículas',
      icon: Icons.bar_chart_rounded,
      child: usuariosPorMes.isEmpty
          ? _buildEmptyState(
              Icons.insert_chart_outlined,
              'Nenhuma matrícula registrada',
              'O histórico aparecerá quando houver dados disponíveis.',
            )
          : _buildBarChart(
              usuariosPorMes.reversed.toList(),
            ),
    );
  }

  Widget _buildBarChart(
    List<Map<String, dynamic>> dados,
  ) {
    final maxValor = dados.fold<int>(0, (current, item) {
      return math.max(
        current,
        _parseToInt(item['total']),
      );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;
        final barWidth = mobile ? 48.0 : 68.0;
        final chartWidth = math.max(
          constraints.maxWidth,
          dados.length * (barWidth + 14),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 255,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dados.map((item) {
                final total = _parseToInt(item['total']);
                final altura = maxValor > 0
                    ? total / maxValor * 185.0
                    : 0.0;

                return SizedBox(
                  width: barWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 185,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: barWidth - 16,
                            height: math.max(altura, 2),
                            decoration: BoxDecoration(
                              color: total > 0
                                  ? _accentColor
                                  : _border,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        _mesLabel(item['mes']),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: _cardDecoration(
        color: _surfaceSoft,
        radius: 11,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _accentColor,
            size: 30,
          ),
          const SizedBox(height: 13),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 1.5,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _DashboardStat(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

class _AlunoSituacao {
  final String label;
  final Color color;
  final Color background;

  const _AlunoSituacao(
    this.label,
    this.color,
    this.background,
  );
}
