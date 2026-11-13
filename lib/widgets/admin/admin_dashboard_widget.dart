
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _primary = Color(0xFF30383E);
  static const Color _secondary = Color(0xFF758087);
  static const Color _accent = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFEAF2F7);
  static const Color _success = Color(0xFF397C69);
  static const Color _successSoft = Color(0xFFEAF4EF);
  static const Color _warning = Color(0xFFB57B42);
  static const Color _warningSoft = Color(0xFFFAF1E5);
  static const Color _danger = Color(0xFFC65D47);
  static const Color _dangerSoft = Color(0xFFFBEDE9);

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

  Future<void> _carregarDados({bool mostrarLoading = true}) async {
    if (mostrarLoading && mounted) {
      setState(() {
        _carregando = true;
      });
    }

    try {
      final stats = await AuthService().getAdminDashboardStats();
      final evolucao = await AuthService().getAdminEvolucaoGeral();

      if (!mounted) return;

      setState(() {
        _stats = Map<String, dynamic>.from(stats);
        _evolucao = Map<String, dynamic>.from(evolucao);
        _carregando = false;
        _alunosPage = 0;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ToastService.showError(
        context,
        'Erro ao carregar dados: $e',
      );
    }
  }

  Future<void> _exportarPDF() async {
    if (_exportando) return;

    setState(() {
      _exportando = true;
    });

    try {
      await PdfService.gerarRelatorioAdminDashboardCompleto(
        _stats,
        _evolucao,
        'Admin',
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
        setState(() {
          _exportando = false;
        });
      }
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt() ??
        0;
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
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

  String _formatMes(dynamic value) {
    final texto = value?.toString() ?? '';

    if (texto.isEmpty) return '-';

    final partes = texto.split('-');

    if (partes.length >= 2) {
      final numero = int.tryParse(partes[1]);

      const meses = [
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

      if (numero != null && numero >= 1 && numero <= 12) {
        return meses[numero - 1];
      }
    }

    return texto;
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = _accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
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
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _secondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Color color = _accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            color: color,
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.north_east_rounded,
                color: _border,
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            value.toString(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final items = [
      _buildStatCard(
        title: 'Total de usuários',
        value: _parseToInt(_stats['totalUsuarios']),
        icon: Icons.people_outline_rounded,
        color: _accent,
        description: 'Pessoas cadastradas',
      ),
      _buildStatCard(
        title: 'Enfermeiras',
        value: _parseToInt(_stats['totalEnfermeiras']),
        icon: Icons.medical_services_outlined,
        color: _success,
        description: 'Profissionais cadastradas',
      ),
      _buildStatCard(
        title: 'Matrículas',
        value: _parseToInt(_stats['totalMatriculas']),
        icon: Icons.school_outlined,
        color: _warning,
        description: 'Registros de matrícula',
      ),
      _buildStatCard(
        title: 'Unidades',
        value: _parseToInt(_stats['totalUPAs']),
        icon: Icons.local_hospital_outlined,
        color: _danger,
        description: 'Unidades cadastradas',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 1;

        const gap = 14.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDistribution(dynamic data) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;

    for (final item in _asList(data)) {
      final total = _parseToInt(item['total']);

      switch (item['sexo']?.toString().toLowerCase()) {
        case 'masculino':
          masculino += total;
          break;
        case 'feminino':
          feminino += total;
          break;
        default:
          outro += total;
      }
    }

    final total = masculino + feminino + outro;

    final grupos = [
      _SexoItem('Masculino', masculino, _accent),
      _SexoItem('Feminino', feminino, _danger),
      _SexoItem('Outro', outro, _warning),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribuição por sexo',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: grupos.map((grupo) {
              return Expanded(
                flex: total > 0 ? math.max(1, grupo.value) : 1,
                child: Container(
                  height: 9,
                  color: grupo.color,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 450 ? 1 : 3;
            const gap = 10.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: grupos.map((grupo) {
                final percentual =
                    total > 0 ? grupo.value / total * 100 : 0.0;

                return SizedBox(
                  width: width,
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: grupo.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          grupo.label,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _secondary,
                          ),
                        ),
                      ),
                      Text(
                        '${grupo.value} (${percentual.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDemographicSection() {
    return _buildSection(
      title: 'Demografia',
      subtitle: 'Perfil dos usuários cadastrados na plataforma.',
      icon: Icons.groups_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;

              final items = [
                _buildInfoTile(
                  title: 'Maiores de 18 anos',
                  value: '${_parseToInt(_stats['maiores18'])} usuários',
                  icon: Icons.person_outline_rounded,
                  color: _accent,
                ),
                _buildInfoTile(
                  title: 'Menores de 18 anos',
                  value: '${_parseToInt(_stats['menores18'])} usuários',
                  icon: Icons.child_care_outlined,
                  color: _success,
                ),
              ];

              if (isNarrow) {
                return Column(
                  children: [
                    items[0],
                    const SizedBox(height: 10),
                    items[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: items[0]),
                  const SizedBox(width: 12),
                  Expanded(child: items[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSexoDistribution(_stats['distribuicaoSexo']),
        ],
      ),
    );
  }

  Widget _buildHealthItem({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: color,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _secondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    final media = _parseToDouble(_stats['mediaScoreFagestrom']);

    final items = [
      _buildHealthItem(
        title: 'Câncer',
        value: '${_parseToInt(_stats['usuariosComCancer'])}',
        description: 'Usuários com registro',
        icon: Icons.health_and_safety_outlined,
        color: _danger,
      ),
      _buildHealthItem(
        title: 'Cardiovascular',
        value: '${_parseToInt(_stats['usuariosComCardiovascular'])}',
        description: 'Usuários com registro',
        icon: Icons.favorite_border_rounded,
        color: _warning,
      ),
      _buildHealthItem(
        title: 'Score Fagerström',
        value: media.toStringAsFixed(1),
        description: 'Média de dependência',
        icon: Icons.monitor_heart_outlined,
        color: _accent,
      ),
    ];

    return _buildSection(
      title: 'Indicadores de saúde',
      subtitle: 'Informações clínicas consolidadas dos usuários.',
      icon: Icons.monitor_heart_outlined,
      color: _danger,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 680
              ? 3
              : constraints.maxWidth >= 430
                  ? 2
                  : 1;

          const gap = 12.0;
          final width =
              (constraints.maxWidth - gap * (columns - 1)) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: items
                .map(
                  (item) => SizedBox(
                    width: width,
                    child: item,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildEvolucaoCard({
    required String title,
    required Map<String, dynamic> dados,
    required Color color,
    required IconData icon,
  }) {
    final total = _parseToInt(dados['total']);
    final fumando = _parseToInt(dados['fumando']);
    final semFumar = _parseToInt(dados['sem_fumar']);
    final taxa = _parseToDouble(dados['taxa_sucesso']);
    final progresso =
        total > 0 ? (semFumar / total).clamp(0.0, 1.0).toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: color,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
              Text(
                '$total',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  label: 'Fumando',
                  value: fumando,
                  color: _warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetric(
                  label: 'Sem fumar',
                  value: semFumar,
                  color: _success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: _warningSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(_success),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Taxa de sucesso',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
              ),
              Text(
                '${taxa.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: taxa >= 50 ? _success : _warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendaItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMensalChart(List<Map<String, dynamic>> dados) {
    if (dados.isEmpty) {
      return _buildEmptyState(
        'Nenhum dado mensal disponível.',
      );
    }

    final maxValor = dados.fold<int>(0, (maximo, item) {
      final total = _parseToInt(item['fumando']) +
          _parseToInt(item['sem_fumar']);

      return math.max(maximo, total);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth < 500 ? 34.0 : 42.0;
        final itemWidth = constraints.maxWidth < 500 ? 59.0 : 74.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução mensal',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 205,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dados.map((item) {
                      final fumando = _parseToInt(item['fumando']);
                      final semFumar = _parseToInt(item['sem_fumar']);
                      final total = fumando + semFumar;

                      final altura = maxValor > 0
                          ? total / maxValor * 140
                          : 0.0;

                      final alturaFumando = total > 0
                          ? fumando / total * altura
                          : 0.0;

                      final alturaSemFumar = total > 0
                          ? semFumar / total * altura
                          : 0.0;

                      return SizedBox(
                        width: itemWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              width: barWidth,
                              height: 140,
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: _background,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: _border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (alturaFumando > 0)
                                      Container(
                                        width: barWidth,
                                        height: alturaFumando,
                                        color: _warning,
                                      ),
                                    if (alturaSemFumar > 0)
                                      Container(
                                        width: barWidth,
                                        height: alturaSemFumar,
                                        color: _success,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              _formatMes(item['mes']),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _buildLegendaItem(_warning, 'Fumando'),
                _buildLegendaItem(_success, 'Sem fumar'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAlunosDetalhados() {
    final alunos = _asList(_evolucao['alunos_detalhados']);

    if (alunos.isEmpty) {
      return _buildEmptyState(
        'Nenhum aluno disponível para consulta.',
      );
    }

    final totalPages = (alunos.length / _alunosPerPage).ceil();
    final paginaAtual = _alunosPage.clamp(0, totalPages - 1).toInt();
    final startIndex = paginaAtual * _alunosPerPage;
    final endIndex = math.min(
      startIndex + _alunosPerPage,
      alunos.length,
    );

    final alunosPaginados = alunos.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Situação atual dos alunos',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ),
            Text(
              '${alunos.length} registros',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int index = 0;
                  index < alunosPaginados.length;
                  index++) ...[
                _buildAlunoRow(alunosPaginados[index]),
                if (index < alunosPaginados.length - 1)
                  const Divider(
                    height: 1,
                    color: _border,
                  ),
              ],
            ],
          ),
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(
                Icons.chevron_left_rounded,
                paginaAtual > 0
                    ? () {
                        setState(() {
                          _alunosPage = paginaAtual - 1;
                        });
                      }
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                '${paginaAtual + 1} de $totalPages',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _secondary,
                ),
              ),
              const SizedBox(width: 12),
              _buildPaginationButton(
                Icons.chevron_right_rounded,
                paginaAtual < totalPages - 1
                    ? () {
                        setState(() {
                          _alunosPage = paginaAtual + 1;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAlunoRow(Map<String, dynamic> aluno) {
    final nome = aluno['nome_completo']?.toString() ?? '-';
    final turmaCompleta = aluno['turma_horario']?.toString() ?? '-';
    final turma = turmaCompleta.split(' - ').first;

    final semanasFumando = _parseToInt(aluno['semanas_fumando']);
    final semanasSemFumar = _parseToInt(aluno['semanas_sem_fumar']);

    final ultimaObservacao = aluno['ultima_observacao'];

    String situacao;
    Color situacaoCor;

    if (ultimaObservacao == '2- Sem fumar') {
      situacao = 'Sem fumar';
      situacaoCor = _success;
    } else if (ultimaObservacao == '1- Está fumando') {
      situacao = 'Fumando';
      situacaoCor = _warning;
    } else {
      situacao = 'Sem registro';
      situacaoCor = _secondary;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 560;

        if (isMobile) {
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        nome,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(situacao, situacaoCor),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 7,
                  children: [
                    _buildAlunoDetail(
                      Icons.groups_outlined,
                      turma,
                    ),
                    _buildAlunoDetail(
                      Icons.smoking_rooms_outlined,
                      '$semanasFumando sem. fumando',
                    ),
                    _buildAlunoDetail(
                      Icons.smoke_free_outlined,
                      '$semanasSemFumar sem. sem fumar',
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Fumando: $semanasFumando sem.  •  Sem fumar: $semanasSemFumar sem.',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: _secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  turma,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildStatusBadge(
                    situacao,
                    situacaoCor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlunoDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: _secondary,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: _secondary,
          ),
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
      icon: Icon(icon, size: 19),
      color: _accent,
      disabledColor: _border,
      style: IconButton.styleFrom(
        backgroundColor: _surface,
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Widget _buildEvolucaoSection() {
    final ativos = _asMap(_evolucao['alunos_ativos']);
    final concluidos = _asMap(_evolucao['alunos_concluidos']);
    final evolucaoMensal =
        _asList(_evolucao['evolucao_mensal_ativos']);

    return _buildSection(
      title: 'Evolução dos alunos',
      subtitle: 'Acompanhamento do progresso no tratamento.',
      icon: Icons.trending_up_rounded,
      color: _success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final ativo = _buildEvolucaoCard(
                title: 'Alunos ativos',
                dados: ativos,
                color: _accent,
                icon: Icons.person_outline_rounded,
              );

              final concluido = _buildEvolucaoCard(
                title: 'Alunos concluídos',
                dados: concluidos,
                color: _success,
                icon: Icons.verified_outlined,
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    ativo,
                    const SizedBox(height: 12),
                    concluido,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ativo),
                  const SizedBox(width: 14),
                  Expanded(child: concluido),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _buildMensalChart(evolucaoMensal),
          const SizedBox(height: 28),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 25),
          _buildAlunosDetalhados(),
        ],
      ),
    );
  }

  Widget _buildMatriculasChart() {
    final dados = _asList(_stats['usuariosPorMes']).reversed.toList();

    if (dados.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValor = dados.fold<double>(
      0,
      (maximo, item) => math.max(
        maximo,
        _parseToDouble(item['total']),
      ),
    );

    return _buildSection(
      title: 'Matrículas por mês',
      subtitle: 'Volume de matrículas registradas ao longo do tempo.',
      icon: Icons.bar_chart_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth < 500 ? 58.0 : 74.0;
          final barWidth = constraints.maxWidth < 500 ? 32.0 : 42.0;

          return SizedBox(
            height: 215,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dados.map((item) {
                    final valor = _parseToDouble(item['total']);
                    final altura =
                        maxValor > 0 ? valor / maxValor * 145 : 0.0;

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${valor.toInt()}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: barWidth,
                            height: 145,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: _background,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: _border),
                            ),
                            child: Container(
                              width: barWidth,
                              height: altura,
                              decoration: const BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            _formatMes(item['mes']),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: _secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.insert_chart_outlined_rounded,
            size: 27,
            color: _secondary,
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(bool isMobile) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visão geral',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Indicadores e acompanhamento geral da plataforma.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        OutlinedButton.icon(
          onPressed: () => _carregarDados(
            mostrarLoading: false,
          ),
          icon: const Icon(
            Icons.refresh_rounded,
            size: 17,
          ),
          label: const Text('Atualizar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _accent,
            side: const BorderSide(color: _border),
            backgroundColor: _surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
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
        ),
        ElevatedButton.icon(
          onPressed: _exportando ? null : _exportarPDF,
          icon: _exportando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 17,
                ),
          label: Text(
            _exportando ? 'Gerando...' : 'Exportar PDF',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accent.withOpacity(0.6),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
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
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 17),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 16),
        actions,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2.5,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = constraints.maxWidth < 400 ? 14.0 : 24.0;

        return RefreshIndicator(
          color: _accent,
          onRefresh: () => _carregarDados(
            mostrarLoading: false,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? padding : 30,
              vertical: isMobile ? 22 : 30,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1360,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(isMobile),
                    const SizedBox(height: 25),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, innerConstraints) {
                        if (innerConstraints.maxWidth < 1000) {
                          return Column(
                            children: [
                              _buildDemographicSection(),
                              const SizedBox(height: 20),
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
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildHealthSection(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildEvolucaoSection(),
                    if (_asList(_stats['usuariosPorMes']).isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildMatriculasChart(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SexoItem {
  final String label;
  final int value;
  final Color color;

  const _SexoItem(
    this.label,
    this.value,
    this.color,
  );
}
