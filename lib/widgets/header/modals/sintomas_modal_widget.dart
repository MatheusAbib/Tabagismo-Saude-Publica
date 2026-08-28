import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:tabagismo_app/services/sintoma_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'dart:async';

class SintomasModalWidget {
  static void show(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;

    final _sintomaService = SintomaService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final ansiedade = ValueNotifier<int>(0);
        final irritabilidade = ValueNotifier<int>(0);
        final insonia = ValueNotifier<int>(0);
        final fome = ValueNotifier<int>(0);
        final dificuldadeConcentracao = ValueNotifier<int>(0);
        final vontadeFumar = ValueNotifier<int>(0);

        String observacoes = '';
        bool isLoading = false;
        bool isLoadingGrafico = true;
        List<Map<String, dynamic>> sintomas = [];

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> carregarGrafico() async {
              if (sintomas.isNotEmpty) return;
              setState(() => isLoadingGrafico = true);
              try {
                final response = await _sintomaService.getSintomas(limit: 30);
                if (context.mounted) {
                  setState(() {
                    sintomas = response;
                    isLoadingGrafico = false;
                  });
                }
              } catch (e) {
                print('Erro ao carregar gráfico: $e');
                if (context.mounted) {
                  setState(() => isLoadingGrafico = false);
                }
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              carregarGrafico();
            });

            return Dialog(
              insetPadding: EdgeInsets.all(isSmallMobile ? 4 : (isMobile ? 8 : 20)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 1000 ? 1100 : MediaQuery.of(context).size.width * 0.95),
                height: isMobile ? MediaQuery.of(context).size.height * 0.95 : (MediaQuery.of(context).size.height > 800 ? 750 : MediaQuery.of(context).size.height * 0.9),
                constraints: BoxConstraints(maxWidth: 1100),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 20),
                        decoration: BoxDecoration(color: const Color(0xFF334155)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.monitor_heart, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sintomas Diários',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Registre e acompanhe sua evolução',
                                    style: TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isMobile
                            ? SingleChildScrollView(
                                padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
                                child: Column(
                                  children: [
                                    _buildFormulario(
                                      context,
                                      ansiedade,
                                      irritabilidade,
                                      insonia,
                                      fome,
                                      dificuldadeConcentracao,
                                      vontadeFumar,
                                      observacoes,
                                      isLoading,
                                      setState,
                                      carregarGrafico,
                                      _sintomaService,
                                    ),
                                    const SizedBox(height: 20),
                                    _GraficoSintomasWidget(
                                      sintomas: sintomas,
                                      isLoadingGrafico: isLoadingGrafico,
                                    )
                                  ],
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(20),
                                      child: _buildFormulario(
                                        context,
                                        ansiedade,
                                        irritabilidade,
                                        insonia,
                                        fome,
                                        dificuldadeConcentracao,
                                        vontadeFumar,
                                        observacoes,
                                        isLoading,
                                        setState,
                                        carregarGrafico,
                                        _sintomaService,
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.grey.shade200),
                                  Expanded(
                                    flex: 6,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(20),
                                      child: _GraficoSintomasWidget(
                                        sintomas: sintomas,
                                        isLoadingGrafico: isLoadingGrafico,
                                      )
                                    ),
                                  ),
                                ],
                              ),
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

  static Widget _buildFormulario(
    BuildContext context,
    ValueNotifier<int> ansiedade,
    ValueNotifier<int> irritabilidade,
    ValueNotifier<int> insonia,
    ValueNotifier<int> fome,
    ValueNotifier<int> dificuldadeConcentracao,
    ValueNotifier<int> vontadeFumar,
    String observacoes,
    bool isLoading,
    StateSetter setState,
    Future<void> Function() carregarGrafico,
    SintomaService _sintomaService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar Sintomas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        _buildSintomaSlider('Ansiedade', Icons.psychology, ansiedade, const Color(0xFF1F4E6E)),
        _buildSintomaSlider('Irritabilidade', Icons.flash_on, irritabilidade, const Color(0xFFC65D47)),
        _buildSintomaSlider('Insônia', Icons.nightlight_round, insonia, const Color(0xFF6B21A8)),
        _buildSintomaSlider('Fome', Icons.restaurant, fome, const Color(0xFFD97706)),
        _buildSintomaSlider('Dificuldade de Concentração', Icons.auto_awesome, dificuldadeConcentracao, const Color(0xFF2E8B6A)),
        _buildSintomaSlider('Vontade de Fumar', Icons.smoking_rooms, vontadeFumar, const Color(0xFFC65D47)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Observações (opcional)',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Inter'),
            ),
            onChanged: (value) => observacoes = value,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() => isLoading = true);
                    try {
                      final hoje = DateTime.now().toIso8601String().split('T')[0];
                      await _sintomaService.registrarSintoma(
                        data: hoje,
                        ansiedade: ansiedade.value,
                        irritabilidade: irritabilidade.value,
                        insonia: insonia.value,
                        fome: fome.value,
                        dificuldadeConcentracao: dificuldadeConcentracao.value,
                        vontadeFumar: vontadeFumar.value,
                        observacoes: observacoes,
                      );
                      ToastService.showSuccess(context, 'Sintomas registrados com sucesso!');
                      await carregarGrafico();
                    } catch (e) {
                      ToastService.showError(context, 'Erro ao registrar sintomas: $e');
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B6A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Registrar Sintomas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSintomaSlider(
    String titulo,
    IconData icon,
    ValueNotifier<int> valorNotifier,
    Color cor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: valorNotifier,
                builder: (context, valor, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      valor.toString(),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: valorNotifier,
            builder: (context, valor, child) {
              return Slider(
                value: valor.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: cor,
                inactiveColor: cor.withValues(alpha: 0.2),
                onChanged: (value) {
                  valorNotifier.value = value.round();
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nenhum', style: TextStyle(fontSize: 10, color: const Color(0xFF94A3B8))),
              Text('Moderado', style: TextStyle(fontSize: 10, color: const Color(0xFF94A3B8))),
              Text('Máximo', style: TextStyle(fontSize: 10, color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraficoSintomasWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sintomas;
  final bool isLoadingGrafico;

  const _GraficoSintomasWidget({
    required this.sintomas,
    required this.isLoadingGrafico,
  });

  @override
  State<_GraficoSintomasWidget> createState() => _GraficoSintomasWidgetState();
}

class _GraficoSintomasWidgetState extends State<_GraficoSintomasWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Evolução dos Sintomas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Acompanhe sua evolução ao longo do tempo',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isLoadingGrafico)
          Container(
            height: 350,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1F4E6E)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando gráfico...',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter'),
                  ),
                ],
              ),
            ),
          )
        else if (widget.sintomas.isEmpty)
          Container(
            height: 350,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4E6E).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.show_chart, size: 40, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum sintoma registrado ainda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569), fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre seus primeiros sintomas para ver o gráfico',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontFamily: 'Inter'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4E6E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: const Color(0xFF1F4E6E)),
                      const SizedBox(width: 6),
                      Text(
                        'Preencha os campos ao lado e registre',
                        style: TextStyle(fontSize: 12, color: const Color(0xFF1F4E6E), fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildLineChart(widget.sintomas),
          ),
        if (widget.sintomas.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildResumoCards(widget.sintomas),
          ),
        ],
      ],
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> sintomas) {
    sintomas = sintomas.reversed.toList();

    List<double> ansiedade = [];
    List<double> irritabilidade = [];
    List<double> vontadeFumar = [];
    List<double> insonia = [];
    List<double> fome = [];
    List<double> dificuldadeConcentracao = [];
    List<String> labels = [];

    for (var s in sintomas) {
      ansiedade.add((s['ansiedade'] ?? 0).toDouble());
      irritabilidade.add((s['irritabilidade'] ?? 0).toDouble());
      vontadeFumar.add((s['vontade_fumar'] ?? 0).toDouble());
      insonia.add((s['insonia'] ?? 0).toDouble());
      fome.add((s['fome'] ?? 0).toDouble());
      dificuldadeConcentracao.add((s['dificuldade_concentracao'] ?? 0).toDouble());

      final data = DateTime.parse(s['data']);
      labels.add('${data.day}/${data.month}');
    }

    final width = labels.length * 70;
    final hasScroll = width > 800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: hasScroll ? 340 : 320,
          child: Scrollbar(
            thumbVisibility: hasScroll,
            thickness: 8,
            radius: const Radius.circular(10),
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              child: Container(
                width: width.toDouble(),
                height: hasScroll ? 340 : 320,
                padding: const EdgeInsets.only(top: 15, bottom: 10, left: 8, right: 8),
                child: fl_chart.LineChart(
                  fl_chart.LineChartData(
                    gridData: fl_chart.FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      horizontalInterval: 2,
                      verticalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return fl_chart.FlLine(
                          color: const Color(0xFFE2E8F0),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return fl_chart.FlLine(
                          color: const Color(0xFFE2E8F0),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: fl_chart.FlTitlesData(
                      bottomTitles: fl_chart.AxisTitles(
                        sideTitles: fl_chart.SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 50,
                        ),
                      ),
                      leftTitles: fl_chart.AxisTitles(
                        sideTitles: fl_chart.SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                              ),
                            );
                          },
                          reservedSize: 45,
                        ),
                      ),
                      topTitles: const fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                      rightTitles: const fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                    ),
                    minX: 0,
                    maxX: (sintomas.length - 1).toDouble(),
                    minY: 0,
                    maxY: 10,
                    lineTouchData: fl_chart.LineTouchData(
                      enabled: true,
                      touchTooltipData: fl_chart.LineTouchTooltipData(
                        getTooltipItems: (List<fl_chart.LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            return fl_chart.LineTooltipItem(
                              '${spot.y.toInt()}',
                              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            );
                          }).toList();
                        },
                        getTooltipColor: (spot) {
                          return const Color(0xFF1F4E6E).withValues(alpha: 0.9);
                        },
                        maxContentWidth: 40,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                      ),
                      touchSpotThreshold: 20,
                    ),
                    lineBarsData: [
                      fl_chart.LineChartBarData(
                        spots: List.generate(ansiedade.length, (i) => fl_chart.FlSpot(i.toDouble(), ansiedade[i])),
                        isCurved: true,
                        color: const Color(0xFF1F4E6E),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                      fl_chart.LineChartBarData(
                        spots: List.generate(irritabilidade.length, (i) => fl_chart.FlSpot(i.toDouble(), irritabilidade[i])),
                        isCurved: true,
                        color: const Color(0xFFC65D47),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                      fl_chart.LineChartBarData(
                        spots: List.generate(vontadeFumar.length, (i) => fl_chart.FlSpot(i.toDouble(), vontadeFumar[i])),
                        isCurved: true,
                        color: const Color(0xFFD97706),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                      fl_chart.LineChartBarData(
                        spots: List.generate(insonia.length, (i) => fl_chart.FlSpot(i.toDouble(), insonia[i])),
                        isCurved: true,
                        color: const Color(0xFF6B21A8),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                      fl_chart.LineChartBarData(
                        spots: List.generate(fome.length, (i) => fl_chart.FlSpot(i.toDouble(), fome[i])),
                        isCurved: true,
                        color: const Color(0xFFF97316),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                      fl_chart.LineChartBarData(
                        spots: List.generate(dificuldadeConcentracao.length, (i) => fl_chart.FlSpot(i.toDouble(), dificuldadeConcentracao[i])),
                        isCurved: true,
                        color: const Color(0xFF2E8B6A),
                        barWidth: 3,
                        dotData: const fl_chart.FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasScroll)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Arraste para ver mais',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'Inter'),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade500),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResumoCards(List<Map<String, dynamic>> sintomas) {
    if (sintomas.isEmpty) return const SizedBox.shrink();

    final ultimo = sintomas.first;

    final sintomasList = [
      {
        'titulo': 'Ansiedade',
        'valor': ultimo['ansiedade'] ?? 0,
        'cor': const Color(0xFF1F4E6E),
        'icon': Icons.psychology,
        'descricao': _getDescricaoSintoma('ansiedade', ultimo['ansiedade'] ?? 0),
      },
      {
        'titulo': 'Irritabilidade',
        'valor': ultimo['irritabilidade'] ?? 0,
        'cor': const Color(0xFFC65D47),
        'icon': Icons.flash_on,
        'descricao': _getDescricaoSintoma('irritabilidade', ultimo['irritabilidade'] ?? 0),
      },
      {
        'titulo': 'Insônia',
        'valor': ultimo['insonia'] ?? 0,
        'cor': const Color(0xFF6B21A8),
        'icon': Icons.nightlight_round,
        'descricao': _getDescricaoSintoma('insonia', ultimo['insonia'] ?? 0),
      },
      {
        'titulo': 'Fome',
        'valor': ultimo['fome'] ?? 0,
        'cor': const Color(0xFFD97706),
        'icon': Icons.restaurant,
        'descricao': _getDescricaoSintoma('fome', ultimo['fome'] ?? 0),
      },
      {
        'titulo': 'Dificuldade de Concentração',
        'valor': ultimo['dificuldade_concentracao'] ?? 0,
        'cor': const Color(0xFF2E8B6A),
        'icon': Icons.auto_awesome,
        'descricao': _getDescricaoSintoma('dificuldade_concentracao', ultimo['dificuldade_concentracao'] ?? 0),
      },
      {
        'titulo': 'Vontade de Fumar',
        'valor': ultimo['vontade_fumar'] ?? 0,
        'cor': const Color(0xFFC65D47),
        'icon': Icons.smoking_rooms,
        'descricao': _getDescricaoSintoma('vontade_fumar', ultimo['vontade_fumar'] ?? 0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.assessment, size: 18, color: Color(0xFF1F4E6E)),
            SizedBox(width: 8),
            Text(
              'Último registro',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            int crossAxisCount = 2;
            if (availableWidth > 600) crossAxisCount = 3;
            if (availableWidth > 900) crossAxisCount = 4;
            if (availableWidth > 1200) crossAxisCount = 6;

            final cardWidth = (availableWidth - (12 * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: sintomasList.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: _buildSintomaCard(
                    titulo: item['titulo'] as String,
                    valor: item['valor'] as int,
                    cor: item['cor'] as Color,
                    icon: item['icon'] as IconData,
                    descricao: item['descricao'] as String,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSintomaCard({
    required String titulo,
    required int valor,
    required Color cor,
    required IconData icon,
    required String descricao,
  }) {
    String getNivel(int valor) {
      if (valor <= 2) return 'Baixo';
      if (valor <= 4) return 'Moderado';
      if (valor <= 6) return 'Elevado';
      return 'Muito Elevado';
    }

    IconData getNivelIcon(int valor) {
      if (valor <= 2) return Icons.emoji_emotions_outlined;
      if (valor <= 4) return Icons.sentiment_satisfied_outlined;
      if (valor <= 6) return Icons.sentiment_neutral_outlined;
      return Icons.sentiment_very_dissatisfied_outlined;
    }

    Color getNivelColor(int valor) {
      if (valor <= 2) return const Color(0xFF2E8B6A);
      if (valor <= 4) return const Color(0xFF84CC16);
      if (valor <= 6) return const Color(0xFFD97706);
      return const Color(0xFFC65D47);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: cor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                valor.toString(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cor, fontFamily: 'Poppins'),
              ),
              const SizedBox(width: 8),
              Text(
                '/ 10',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(getNivelIcon(valor), size: 14, color: getNivelColor(valor)),
              const SizedBox(width: 4),
              Text(
                getNivel(valor),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: getNivelColor(valor), fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            descricao,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'Inter', height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getDescricaoSintoma(String sintoma, int valor) {
    switch (sintoma) {
      case 'ansiedade':
        if (valor <= 2) return 'Tranquilo';
        if (valor <= 4) return 'Leve apreensão';
        if (valor <= 6) return 'Ansiedade moderada';
        if (valor <= 8) return 'Ansiedade intensa';
        return 'Crise de ansiedade';
      case 'irritabilidade':
        if (valor <= 2) return 'Calmo';
        if (valor <= 4) return 'Levemente irritado';
        if (valor <= 6) return 'Irritado';
        if (valor <= 8) return 'Muito irritado';
        return 'Extremamente irritado';
      case 'insonia':
        if (valor <= 2) return 'Dorme bem';
        if (valor <= 4) return 'Leve dificuldade';
        if (valor <= 6) return 'Dificuldade moderada';
        if (valor <= 8) return 'Muita dificuldade';
        return 'Não dorme';
      case 'fome':
        if (valor <= 2) return 'Normal';
        if (valor <= 4) return 'Leve fome';
        if (valor <= 6) return 'Fome moderada';
        if (valor <= 8) return 'Muita fome';
        return 'Fome excessiva';
      case 'dificuldade_concentracao':
        if (valor <= 2) return 'Foco total';
        if (valor <= 4) return 'Leve dispersão';
        if (valor <= 6) return 'Dificuldade moderada';
        if (valor <= 8) return 'Muita dificuldade';
        return 'Sem concentração';
      case 'vontade_fumar':
        if (valor <= 2) return 'Sem vontade';
        if (valor <= 4) return 'Vontade leve';
        if (valor <= 6) return 'Vontade moderada';
        if (valor <= 8) return 'Vontade intensa';
        return 'Fissura extrema';
      default:
        return '';
    }
  }
}