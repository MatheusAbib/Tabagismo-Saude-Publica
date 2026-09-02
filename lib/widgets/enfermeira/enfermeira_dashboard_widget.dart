import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class DashboardWidget extends StatefulWidget {
  final int upaId;

  const DashboardWidget({Key? key, required this.upaId}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _evolucao = {};
  bool _carregando = true;

  int _alunosPage = 0;
  int _alunosPerPage = 5;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final stats = await AuthService().getEnfermeiraDashboardStats();
      final evolucao = await AuthService().getEvolucaoGeral();
      setState(() {
        _stats = stats;
        _evolucao = evolucao;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      ToastService.showError(context, 'Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    final padding = isSmallMobile ? 8.0 : (isMobile ? 16.0 : 20.0);

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _exportarPDF(),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: isMobile ? const Text('Exportar PDF') : const Text('Exportar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dangerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildDemographicSection(),
          const SizedBox(height: 24),
          _buildHealthSection(),
          const SizedBox(height: 24),
          _buildEvolucaoSection(),
          const SizedBox(height: 24),
          _buildChartSection(),
        ],
      ),
    );
  }

  Future<void> _exportarPDF() async {
    try {
      await PdfService.gerarRelatorioDashboardCompleto(_stats, _evolucao, 'Enfermeira', '');
      ToastService.showSuccess(context, 'PDF gerado com sucesso!');
    } catch (e) {
      ToastService.showError(context, 'Erro ao gerar PDF: $e');
    }
  }

  Widget _buildStatsRow() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Usuários', _stats['totalUsuarios']?.toString() ?? '0', Icons.people, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Em Espera', _stats['totalEmEspera']?.toString() ?? '0', Icons.hourglass_empty, _warningColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Matriculados', _stats['totalMatriculados']?.toString() ?? '0', Icons.check_circle, _successColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Cancelados', _stats['totalCancelados']?.toString() ?? '0', Icons.cancel, _dangerColor)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Usuários', _stats['totalUsuarios']?.toString() ?? '0', Icons.people, const Color(0xFF3B82F6))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Em Espera', _stats['totalEmEspera']?.toString() ?? '0', Icons.hourglass_empty, _warningColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Matriculados', _stats['totalMatriculados']?.toString() ?? '0', Icons.check_circle, _successColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Cancelados', _stats['totalCancelados']?.toString() ?? '0', Icons.cancel, _dangerColor)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: isMobile ? 16 : 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: isMobile ? 10 : 12, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildDemographicSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Color(0xFF1F4E6E)),
                SizedBox(width: 8),
                Text('Demografia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Maiores de 18', '${_stats['maiores18'] ?? 0} usuários', Icons.person, const Color(0xFF3B82F6))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoItem('Menores de 18', '${_stats['menores18'] ?? 0} usuários', Icons.child_care, _successColor)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSexoDistribution(_stats['distribuicaoSexo'] ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                Text(title, style: TextStyle(fontSize: isMobile ? 9 : 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDistribution(List<dynamic> sexoData) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;

    for (var item in sexoData) {
      if (item['sexo'] == 'Masculino') masculino = item['total'];
      else if (item['sexo'] == 'Feminino') feminino = item['total'];
      else outro = item['total'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distribuição por Sexo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSexoBar('Masculino', masculino, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Feminino', feminino, const Color(0xFFEC4899))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Outro', outro, const Color(0xFF6B21A8))),
          ],
        ),
      ],
    );
  }

  Widget _buildSexoBar(String label, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(total.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

Widget _buildHealthSection() {
  final usuariosComCancer = _stats['usuariosComCancer'] ?? 0;
  final usuariosComCardiovascular = _stats['usuariosComCardiovascular'] ?? 0;
  final mediaScore = _stats['mediaScoreFagestrom'] ?? 0;

  double mediaScoreDouble = 0.0;
  if (mediaScore is String) {
    mediaScoreDouble = double.tryParse(mediaScore) ?? 0.0;
  } else if (mediaScore is int) {
    mediaScoreDouble = mediaScore.toDouble();
  } else if (mediaScore is double) {
    mediaScoreDouble = mediaScore;
  }

  final isMobile = MediaQuery.of(context).size.width < 600;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.health_and_safety, size: 20, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Saúde', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildHealthItem('Câncer', '$usuariosComCancer', Icons.health_and_safety, _dangerColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildHealthItem('Cardiovascular', '$usuariosComCardiovascular', Icons.favorite, const Color(0xFFEC4899))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildHealthItem('Score Fagerström', '${mediaScoreDouble.toStringAsFixed(1)}', Icons.assessment, _accentColor)),
                        const SizedBox(width: 12),
                        Expanded(child: Container()),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildHealthItem('Câncer', '$usuariosComCancer', Icons.health_and_safety, _dangerColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHealthItem('Cardiovascular', '$usuariosComCardiovascular', Icons.favorite, const Color(0xFFEC4899))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHealthItem('Score Fagerström', '${mediaScoreDouble.toStringAsFixed(1)}', Icons.assessment, _accentColor)),
                  ],
                ),
        ),
      ],
    ),
  );
}
  Widget _buildHealthItem(String title, String value, IconData icon, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                Text(title, style: TextStyle(fontSize: isMobile ? 9 : 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolucaoSection() {
  final data = _evolucao;
  final alunosAtivos = data['alunos_ativos'] ?? {};
  final alunosConcluidos = data['alunos_concluidos'] ?? {};
  final isMobile = MediaQuery.of(context).size.width < 600;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Color(0xFF6B21A8)),
              SizedBox(width: 8),
              Text('Evolução dos Alunos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              isMobile
                  ? Column(
                      children: [
                        _buildEvolucaoCard('Alunos Ativos', alunosAtivos, const Color(0xFF3B82F6)),
                        const SizedBox(height: 12),
                        _buildEvolucaoCard('Alunos Concluídos', alunosConcluidos, _successColor),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildEvolucaoCard('Alunos Ativos', alunosAtivos, const Color(0xFF3B82F6))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEvolucaoCard('Alunos Concluídos', alunosConcluidos, _successColor)),
                      ],
                    ),
              const SizedBox(height: 24),
              _buildEvolucaoChart(data),
              const SizedBox(height: 24),
              _buildAlunosDetalhados(data),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildEvolucaoCard(String titulo, Map<String, dynamic> dados, Color cor) {
    final total = _parseToInt(dados['total']);
    final fumando = _parseToInt(dados['fumando']);
    final semFumar = _parseToInt(dados['sem_fumar']);
    final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600, color: cor)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(total.toString(), style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                    const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: _warningColor, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(fumando.toString(), style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600, color: _warningColor)),
                      ],
                    ),
                    const Text('Fumando', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(semFumar.toString(), style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
                      ],
                    ),
                    const Text('Sem fumar', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total > 0 ? semFumar / total : 0,
            backgroundColor: _warningColor.withValues(alpha: 0.2),
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600, color: taxaSucesso >= 50 ? _successColor : _warningColor),
          ),
        ],
      ),
    );
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      return 0;
    }
    return 0;
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
      return 0.0;
    }
    return 0.0;
  }

  Widget _buildEvolucaoChart(Map<String, dynamic> data) {
    final evolucaoAtivos = List<Map<String, dynamic>>.from(data['evolucao_mensal_ativos'] ?? []);

    if (evolucaoAtivos.isEmpty) {
      return const Center(child: Text('Sem dados para exibir', style: TextStyle(color: Color(0xFF64748B))));
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Evolução Mensal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _buildMensalChart(evolucaoAtivos, 'Alunos Ativos', isMobile),
      ],
    );
  }

  Widget _buildMensalChart(List<Map<String, dynamic>> dados, String titulo, bool isMobile) {
    final maxValor = dados.fold<int>(0, (max, item) {
      final fumando = _parseToInt(item['fumando']);
      final semFumar = _parseToInt(item['sem_fumar']);
      final total = fumando + semFumar;
      return total > max ? total : max;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          width: isMobile ? double.infinity : null,
          child: SingleChildScrollView(
            scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: dados.map((item) {
                final mes = item['mes'] as String;
                final fumando = _parseToInt(item['fumando']).toDouble();
                final semFumar = _parseToInt(item['sem_fumar']).toDouble();
                final total = fumando + semFumar;
                final altura = maxValor > 0 ? (total / maxValor) * 120 : 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(total.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: isMobile ? 30 : 35,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          if (altura > 0)
                            Column(
                              children: [
                                if (semFumar > 0)
                                  Container(
                                    width: isMobile ? 30 : 35,
                                    height: (semFumar / total) * altura,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ),
                                if (fumando > 0)
                                  Container(
                                    width: isMobile ? 30 : 35,
                                    height: (fumando / total) * altura,
                                    decoration: BoxDecoration(
                                      color: _warningColor,
                                      borderRadius: BorderRadius.vertical(
                                        top: semFumar > 0 ? Radius.zero : Radius.circular(6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: isMobile ? 35 : 45,
                        child: Text(
                          mes.substring(5),
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendaItem(_warningColor, 'Fumando'),
            const SizedBox(width: 16),
            _buildLegendaItem(const Color(0xFF3B82F6), 'Sem fumar'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildAlunosDetalhados(Map<String, dynamic> data) {
  final alunos = List<Map<String, dynamic>>.from(data['alunos_detalhados'] ?? []);

  if (alunos.isEmpty) {
    return const SizedBox.shrink();
  }

  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  final totalPages = (alunos.length / _alunosPerPage).ceil();
  final startIndex = _alunosPage * _alunosPerPage;
  final endIndex = (startIndex + _alunosPerPage) > alunos.length ? alunos.length : (startIndex + _alunosPerPage);
  final alunosPaginados = alunos.sublist(startIndex, endIndex);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Situação Atual dos Alunos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: isSmallMobile
                  ? Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11))),
                            SizedBox(width: 50, child: Text('Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10), textAlign: TextAlign.center)),
                            SizedBox(width: 50, child: Text('Situação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10), textAlign: TextAlign.center)),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Expanded(child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                        SizedBox(width: isMobile ? 60 : 80, child: Text('Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                        SizedBox(width: isMobile ? 60 : 80, child: Text('Situação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                      ],
                    ),
            ),
            ...alunosPaginados.map((aluno) {
              final ultimaObservacao = aluno['ultima_observacao'];
              final semanasFumando = aluno['semanas_fumando'] ?? 0;
              final semanasSemFumar = aluno['semanas_sem_fumar'] ?? 0;

              String situacao;
              Color situacaoCor;

              if (ultimaObservacao == '2- Sem fumar') {
                situacao = 'Sem fumar';
                situacaoCor = const Color(0xFF3B82F6);
              } else if (ultimaObservacao == '1- Está fumando') {
                situacao = 'Fumando';
                situacaoCor = _warningColor;
              } else {
                situacao = 'Sem registro';
                situacaoCor = const Color(0xFF94A3B8);
              }

              return Container(
                padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: isSmallMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(aluno['nome_completo'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: situacaoCor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  situacao,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: situacaoCor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Turma: ${aluno['turma_horario']?.split(' - ')[0] ?? '-'}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'F: $semanasFumando • SF: $semanasSemFumar',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(aluno['nome_completo'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(
                                  'F: $semanasFumando • SF: $semanasSemFumar',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: isMobile ? 60 : 80,
                            child: Text(
                              aluno['turma_horario']?.split(' - ')[0] ?? '-',
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: isMobile ? 60 : 80,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: situacaoCor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                situacao,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: situacaoCor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            }).toList(),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _alunosPage > 0 ? () {
                        setState(() {
                          _alunosPage--;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_alunosPage + 1} de $totalPages',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _accentColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _alunosPage < totalPages - 1 ? () {
                        setState(() {
                          _alunosPage++;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildChartSection() {
    final usuariosPorMes = _stats['usuariosPorMes'] as List? ?? [];

    if (usuariosPorMes.isEmpty) {
      return Container();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: Color(0xFF6B21A8)),
                SizedBox(width: 8),
                Text('Matrículas por Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 250,
              child: usuariosPorMes.reversed.isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : _buildBarChart(usuariosPorMes.reversed.toList(), isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> dados, bool isMobile) {
    List<String> meses = [];
    List<double> valores = [];

    for (var item in dados) {
      meses.add(item['mes']);
      double valor = (item['total'] as num).toDouble();
      valores.add(valor);
    }

    if (valores.isEmpty) {
      return const Center(child: Text('Sem dados', style: TextStyle(color: Color(0xFF64748B))));
    }

    final maxValor = valores.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(dados.length, (index) {
          double altura = 0;
          if (maxValor > 0) {
            altura = (valores[index] / maxValor) * 150;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valores[index].toInt().toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Container(
                  width: isMobile ? 30 : 40,
                  height: altura,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C7DA0), Color(0xFF1A4A6F)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(meses[index].toString().substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          );
        }),
      ),
    );
  }
}