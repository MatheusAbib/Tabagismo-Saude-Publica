import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/services/sintoma_service.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'dart:html' as html;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;
  int _currentBannerIndex = 0;



Future<void> _showSintomasGrafico() async {
  try {
    final sintomaService = SintomaService();
    final sintomas = await sintomaService.getSintomas(limit: 30);
    
    if (sintomas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ainda não há registros de sintomas. Registre seu primeiro diário!'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 700,
            height: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
Row(
  children: [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.show_chart, size: 24, color: Color(0xFF3B82F6)),
    ),
    const SizedBox(width: 12),
    const Text(
      'Evolução dos Sintomas',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    ),
    const Spacer(),
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    ),
  ],
),
const SizedBox(height: 20),
Wrap(
  spacing: 16,
  runSpacing: 10,
  alignment: WrapAlignment.center,
  children: [
    _buildLegendaItem(const Color(0xFF3B82F6), 'Ansiedade'),
    _buildLegendaItem(const Color(0xFFEF4444), 'Irritabilidade'),
    _buildLegendaItem(const Color(0xFF8B5CF6), 'Insônia'),
    _buildLegendaItem(const Color(0xFFF97316), 'Fome'),
    _buildLegendaItem(const Color(0xFF10B981), 'Dificuldade de Concentração'),
    _buildLegendaItem(const Color(0xFFF59E0B), 'Vontade de Fumar'),
  ],
),
const SizedBox(height: 16),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildSintomasGrafico(sintomas),
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar gráfico: $e'), backgroundColor: const Color(0xFFEF4444)),
    );
  }
}


Widget _buildLegendaItem(Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildSintomasGrafico(List<Map<String, dynamic>> sintomas) {
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
  
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Container(
      width: 600,
      height: 350,
      child: fl_chart.LineChart(
        fl_chart.LineChartData(
          gridData: fl_chart.FlGridData(show: true),
          titlesData: fl_chart.FlTitlesData(
            bottomTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                },
                reservedSize: 30,
              ),
            ),
            topTitles: fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
            rightTitles: fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
          ),
          borderData: fl_chart.FlBorderData(show: true),
          minX: 0,
          maxX: (sintomas.length - 1).toDouble(),
          minY: 0,
          maxY: 10,
          lineBarsData: [
            fl_chart.LineChartBarData(
              spots: List.generate(ansiedade.length, (i) => fl_chart.FlSpot(i.toDouble(), ansiedade[i])),
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(irritabilidade.length, (i) => fl_chart.FlSpot(i.toDouble(), irritabilidade[i])),
              isCurved: true,
              color: const Color(0xFFEF4444),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(vontadeFumar.length, (i) => fl_chart.FlSpot(i.toDouble(), vontadeFumar[i])),
              isCurved: true,
              color: const Color(0xFFF59E0B),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(insonia.length, (i) => fl_chart.FlSpot(i.toDouble(), insonia[i])),
              isCurved: true,
              color: const Color(0xFF8B5CF6),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(fome.length, (i) => fl_chart.FlSpot(i.toDouble(), fome[i])),
              isCurved: true,
              color: const Color(0xFFF97316),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(dificuldadeConcentracao.length, (i) => fl_chart.FlSpot(i.toDouble(), dificuldadeConcentracao[i])),
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              dotData: fl_chart.FlDotData(show: true),
            ),
          ],
        ),
      ),
    ),
  );
}


void _showSintomasModal() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      int ansiedade = 0;
      int irritabilidade = 0;
      int insonia = 0;
      int fome = 0;
      int dificuldadeConcentracao = 0;
      int vontadeFumar = 0;
      String observacoes = '';
      bool isLoading = false;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 700,
              constraints: BoxConstraints(maxHeight: 800),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFF3B82F6).withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Icon(Icons.show_chart, size: 24, color: Color(0xFF3B82F6)),
),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diário de Sintomas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Registre como você se sente hoje',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSintomaSlider(
                            'Ansiedade',
                            Icons.psychology,
                            ansiedade,
                            (value) => setState(() => ansiedade = value),
                            const Color(0xFF3B82F6),
                          ),
                          _buildSintomaSlider(
                            'Irritabilidade',
                            Icons.flash_on,
                            irritabilidade,
                            (value) => setState(() => irritabilidade = value),
                            const Color(0xFFEF4444),
                          ),
                          _buildSintomaSlider(
                            'Insônia',
                            Icons.nightlight_round,
                            insonia,
                            (value) => setState(() => insonia = value),
                            const Color(0xFF8B5CF6),
                          ),
                          _buildSintomaSlider(
                            'Fome',
                            Icons.restaurant,
                            fome,
                            (value) => setState(() => fome = value),
                            const Color(0xFFF59E0B),
                          ),
                          _buildSintomaSlider(
                            'Dificuldade de Concentração',
                            Icons.auto_awesome,
                            dificuldadeConcentracao,
                            (value) => setState(() => dificuldadeConcentracao = value),
                            const Color(0xFF10B981),
                          ),
                          _buildSintomaSlider(
                            'Vontade de Fumar',
                            Icons.smoking_rooms,
                            vontadeFumar,
                            (value) => setState(() => vontadeFumar = value),
                            const Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Observações (opcional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Como foi seu dia? Algum gatilho específico?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) => observacoes = value,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        setState(() => isLoading = true);
                        try {
                          final sintomaService = SintomaService();
                          final hoje = DateTime.now().toIso8601String().split('T')[0];
                          await sintomaService.registrarSintoma(
                            data: hoje,
                            ansiedade: ansiedade,
                            irritabilidade: irritabilidade,
                            insonia: insonia,
                            fome: fome,
                            dificuldadeConcentracao: dificuldadeConcentracao,
                            vontadeFumar: vontadeFumar,
                            observacoes: observacoes,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sintomas registrados com sucesso!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao registrar: $e'), backgroundColor: Color(0xFFEF4444)),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Registrar Sintomas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildSintomaSlider(String titulo, IconData icon, int valor, Function(int) onChanged, Color cor) {
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
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                valor.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: valor.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: cor,
          inactiveColor: cor.withOpacity(0.2),
          onChanged: (value) => onChanged(value.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nenhum', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            Text('Moderado', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            Text('Máximo', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    ),
  );
}


void _showGoalModal() {
  DateTime? existingStopDate;
  int? existingTargetDays;
  int? existingCigarrosPorDia;
  double? existingValorCarteira;
  
  if (_userData.containsKey('stopDate') && _userData['stopDate'] != null) {
    final stopDateStr = _userData['stopDate'].toString();
    if (stopDateStr.isNotEmpty && stopDateStr != 'null') {
      try {
        existingStopDate = DateTime.parse(stopDateStr);
      } catch (e) {
        final parts = stopDateStr.split('-');
        if (parts.length == 3) {
          existingStopDate = DateTime(
            int.parse(parts[0]), 
            int.parse(parts[1]), 
            int.parse(parts[2])
          );
        }
      }
    }
  }
  if (_userData.containsKey('targetDays') && _userData['targetDays'] != null) {
    existingTargetDays = _userData['targetDays'];
  }
  if (_userData.containsKey('cigarrosPorDia') && _userData['cigarrosPorDia'] != null) {
    existingCigarrosPorDia = _userData['cigarrosPorDia'];
  }
  if (_userData.containsKey('valorCarteira') && _userData['valorCarteira'] != null) {
    existingValorCarteira = _userData['valorCarteira'];
  }
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      DateTime? stopDate = existingStopDate;
      int? targetDays = existingTargetDays;
      int? cigarrosPorDia = existingCigarrosPorDia;
      double? valorCarteira = existingValorCarteira;
      TextEditingController cigarrosController = TextEditingController(text: existingCigarrosPorDia?.toString() ?? '');
      TextEditingController valorController = TextEditingController(text: existingValorCarteira?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
      TextEditingController metaController = TextEditingController(text: existingTargetDays?.toString() ?? '');
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Definir Meta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registre quando parou de fumar e defina sua meta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF3B82F6)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Data que parou de fumar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      stopDate == null ? 'Selecione uma data' : _formatDate(stopDate!),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: stopDate == null ? Color(0xFF94A3B8) : Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                            onPressed: () async {
                              final results = await showCalendarDatePicker2Dialog(
                                context: context,
                                config: CalendarDatePicker2WithActionButtonsConfig(
                                  calendarType: CalendarDatePicker2Type.single,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  currentDate: DateTime.now(),
                                  selectedDayHighlightColor: const Color(0xFF3B82F6),
                                  selectedDayTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  cancelButton: const Text('Cancelar'),
                                  okButton: const Text('Confirmar'),
                                ),
                                dialogSize: const Size(350, 450),
                                value: [stopDate ?? DateTime.now()],
                              );
                              
                              if (results != null && results.isNotEmpty) {
                                setState(() {
                                  stopDate = results.first;
                                });
                              }
                            },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text(
                                  'Selecionar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.flag, size: 20, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Meta em dias',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: metaController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Ex: 30, 60, 90',
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                      onChanged: (value) {
                                        targetDays = int.tryParse(value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'dias',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Color(0xFF475569)),
                      const SizedBox(width: 12),
                      const Text(
                        'Informações adicionais para cálculo de economia',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.smoking_rooms, size: 20, color: Color(0xFFEF4444)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cigarros por dia',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: cigarrosController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Ex: 20',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                onChanged: (value) {
                                  cigarrosPorDia = int.tryParse(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'cigarros/dia',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.attach_money, size: 20, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valor da carteira',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: valorController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Ex: 10,00',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                onChanged: (value) {
                                  valorCarteira = double.tryParse(value.replaceAll(',', '.'));
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'R\$',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Uma carteira geralmente tem 20 cigarros',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (stopDate != null && targetDays != null && targetDays! > 0) {
                              _saveGoal(stopDate!, targetDays!, 
                                cigarrosPorDia: cigarrosPorDia, 
                                valorCarteira: valorCarteira
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Salvar Meta',
                            style: TextStyle(
                              fontSize: 15,
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
          );
        },
      );
    },
  );
}
String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

void _saveGoal(DateTime stopDate, int targetDays, {int? cigarrosPorDia, double? valorCarteira}) async {
  try {
    final authService = AuthService();
    
    final formattedDate = '${stopDate.year}-${stopDate.month.toString().padLeft(2, '0')}-${stopDate.day.toString().padLeft(2, '0')}';
    
    await authService.updateGoal(formattedDate, targetDays, cigarrosPorDia, valorCarteira);
    
    if (mounted) {
      setState(() {
        _userData['stopDate'] = formattedDate; 
        _userData['targetDays'] = targetDays;
        if (cigarrosPorDia != null) _userData['cigarrosPorDia'] = cigarrosPorDia;
        if (valorCarteira != null) _userData['valorCarteira'] = valorCarteira;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta definida com sucesso!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar meta: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}

void _performLogout() async {
  final authService = AuthService();
  await authService.logout();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (route) => false,
  );
}
  
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Você não está sozinho',
      'subtitle': 'Milhares de pessoas já pararam de fumar com nossa ajuda',
      'icon': Icons.people_outline,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Grupo-Apoio.png',
    },
    {
      'title': 'Benefícios imediatos',
      'subtitle': 'Após 20 minutos, sua pressão e pulsação voltam ao normal',
      'icon': Icons.favorite_outline,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Beneficios-Imediatos.png',
    },
    {
      'title': 'Economize dinheiro',
      'subtitle': 'Em 1 ano você economiza mais de R\$7.000',
      'icon': Icons.attach_money_outlined,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Economize.png',
    },
    {
      'title': 'Viva mais e melhor',
      'subtitle': 'Aumente sua expectativa de vida em até 10 anos',
      'icon': Icons.self_improvement_outlined,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Viva-Mais.png',
    },
  ];

  final List<Map<String, dynamic>> _materiais = [
    {
      'title': 'Guia Completo para Parar de Fumar',
      'subtitle': "Por: Ronaldo Laranjeira",
      'description': 'Artigo científico para ser estudado ',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFEF4444),
      'image': 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400',
      'tag': 'Guia',
    },
    {
      'title': 'Alimentação que ajuda no processo de parar',
      'subtitle': "Por: Nutricionista Dra. Mariana Silva",
      'description': 'Alimentos que ajudam a diminuir a vontade de fumar',
      'icon': Icons.restaurant,
      'color': Color(0xFFEF4444),
      'image': 'https://media.todojujuy.com/p/5f84a771b8171b18024059aae54d9e83/adjuntos/227/imagenes/003/260/0003260714/970x546/smart/salud.jpg',
      'tag': 'Guia',
      'url': 'https://www.riodasostras.rj.gov.br/wp-content/uploads/2023/08/orientacao-nutricional-tabagismo-pdf.pdf',
    },
    {
      'title': 'Exercícios Respiratórios',
      'subtitle': "Por: Dra. Anna Luyza",
      'description': 'Controle a ansiedade e a vontade de fumar',
      'icon': Icons.self_improvement,
      'color': Color(0xFF10B981),
      'image': 'https://media.istockphoto.com/id/2029462033/photo/young-asian-woman-with-eyes-closed-and-hands-on-chest-breathing-fresh-air-and-feeling-the.jpg?s=170667a&w=0&k=20&c=lsleyvRsACbx1zvglFC5qNkSpEoYP5jQ3yB72_f-6qw=',
      'tag': 'Vídeo',
      'videoId': 'Ghbhtri8em4', 
    },
    {
      'title': 'Grupos de Apoio',
      'subtitle': "Por: Portal RBV",
      'description': 'Encontre pessoas que estão na mesma jornada',
      'icon': Icons.group,
      'color': Color(0xFF10B981),
      'image': 'https://thumbs.dreamstime.com/b/reuni%C3%A3o-do-grupo-de-apoio-31168555.jpg',
      'tag': 'Vídeo',
      'videoId': 'GpgUjWvyN-s', 
    },
    {
      'title': 'O Impacto do Tabagismo na Saúde Mental e Bem-Estar',
      'subtitle': "Por: Busca Clínicas de Recuperação",
      'description': 'Cigarro e Ansiedade: o ciclo que te prende',
      'icon': Icons.psychology,
      'color': Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1734808324535-a314d2042677?q=80&w=1631&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'tag': 'Website',
      'url': 'https://www.buscaclinicasderecuperacao.com.br/blog/tabagismo/o-impacto-do-tabagismo-na-saude-mental-e-bem-estar',
    },
    {
      'title': '6 efeitos do cigarro na sua aparência',
      'subtitle': "Por: Minhavida Beleza",
      'description': 'O que o cigarro faz com sua pele e envelhecimento',
      'icon': Icons.face,
      'color': Color(0xFF8B5CF6),
      'image': 'https://lirp.cdn-website.com/26492c66/dms3rep/multi/opt/fumante-1024x683-1920w.jpg',
      'tag': 'Website',
      'url': 'https://www.minhavida.com.br/materias/materia-9311',
    },
    {
      'title': 'Economia: Quanto dinheiro a pessoa perde fumando',
      'subtitle': "Por: Cargatabagicacalculadora",
      'description': 'Quanto dinheiro você perde fumando por ano',
      'icon': Icons.attach_money,
      'color': Color(0xFF8B5CF6),
      'image': 'https://media.istockphoto.com/id/1453501486/pt/foto/cigarettes-lie-on-dollars-and-an-empty-bottle-of-alcohol-on-a-white-background-cigarettes-and.jpg?s=612x612&w=0&k=20&c=kKUCLrYEdrLwFSDKC8rDIPto78ISkgESQDg2r0BLMaU=',
      'tag': 'Website',
      'url': 'https://cargatabagicacalculadora.vercel.app/calculadora-economia-parar-fumar',
    },
    {
      'title': 'Tabagismo e Performance Física',
      'subtitle': "Por: Papo Maromba",
      'description': '“Seu fôlego nunca mais será o mesmo enquanto fumar',
      'icon': Icons.attach_money,
      'color': Color(0xFF8B5CF6),
      'image': 'https://tse4.mm.bing.net/th/id/OIP.daUJH43hLu42Khu7JtPGJgHaEH?w=1060&h=590&rs=1&pid=ImgDetMain&o=7&rm=3',
      'tag': 'Website',
      'url': 'https://papomaromba.com.br/2025/04/04/nutricao/cigarro-impacto-academia/',
    },
  ];

Timer? _updateTimer;

@override
void initState() {
  super.initState();
  _userData = widget.userData;
  print('Nome do usuário: ${_userData['nomeCompleto']}');
  _startAutoCarousel();
  _loadGoalData();
  _startRealtimeUpdate();
}

void _startRealtimeUpdate() {
  _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
    if (mounted) {
      setState(() {});
    }
  });
}

@override
void dispose() {
  _updateTimer?.cancel();
  super.dispose();
}

void _loadGoalData() async {
  try {
    final authService = AuthService();
    final response = await authService.getUserData();
    final userData = response['user'];
    
    print('=== DADOS COMPLETOS DO BACKEND ===');
    print(userData);
    print('stop_date: ${userData['stop_date']}');
    print('target_days: ${userData['target_days']}');
    print('cigarros_por_dia: ${userData['cigarros_por_dia']}');
    print('valor_carteira: ${userData['valor_carteira']}');
    
    if (mounted) {
      setState(() {
        if (userData['stop_date'] != null && userData['stop_date'] != '' && userData['stop_date'] != 'null') {
          _userData['stopDate'] = userData['stop_date'].toString();
        }
        if (userData['target_days'] != null && userData['target_days'] > 0) {
          _userData['targetDays'] = userData['target_days'];
        }
        if (userData['cigarros_por_dia'] != null && userData['cigarros_por_dia'] != '') {
          int? valor = int.tryParse(userData['cigarros_por_dia'].toString());
          if (valor != null && valor > 0) {
            _userData['cigarrosPorDia'] = valor;
          }
        }
        if (userData['valor_carteira'] != null && userData['valor_carteira'] != '') {
          double? valor = double.tryParse(userData['valor_carteira'].toString());
          if (valor != null && valor > 0) {
            _userData['valorCarteira'] = valor;
          }
        }
      });
    }
  } catch (e) {
    print('Erro ao carregar meta: $e');
  }
}
  void _startAutoCarousel() {
    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        });
        _startAutoCarousel();
      }
    });
  }

  void _updateUserName(String newName) {
    setState(() {
      _userData['nomeCompleto'] = newName;
    });
  }

  void _openPDF(String pdfFileName) {
    html.window.open('/assets/pdf/$pdfFileName', '_blank');
  }

  void _openYouTubeVideo(String videoId) {
    html.window.open('https://www.youtube.com/watch?v=$videoId', '_blank');
  }

  void _openWebsite(String url) {
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF8FAFC),
        child: Column(
          children: [
HeaderWidget(
  userName: _userData['nomeCompleto']?.toString() ?? 'Usuário',
  userData: _userData,
  onNameUpdated: _updateUserName,
  showBackButton: false,
  onSintomasPressed: _showSintomasModal,
  onSintomasGraficoPressed: _showSintomasGrafico,
),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroBanner(),
                    _buildSectionHeader('Recursos e Informações'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sidebar com altura baseada no conteúdo
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _buildProfileCard(),
                                const SizedBox(height: 24),
                                _buildTipCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Conteúdo dos materiais
                          Expanded(
                            flex: 8,
                            child: Column(
                              children: [
                                _buildMaterialsContent(),
                                // Espaço extra para garantir que o conteúdo role
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    FooterWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsContent() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.9,
      ),
      itemCount: _materiais.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(_materiais[index]);
      },
    );
  }

Widget _buildHeroBanner() {
  final banner = _banners[_currentBannerIndex];
  final Color primaryDark = const Color(0xFF0F2B3D);
  final Color accentColor = const Color(0xFF2C7DA0);
  
  return SizedBox(
    height: 720,
    width: double.infinity,
    child: Stack(
      children: [
        Image.network(
          banner['image'],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
        color: Colors.black.withValues(alpha: 0.55),
      ),
        Positioned(
          left: 60,
          right: 60,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'O lugar onde o fumo deixa de existir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.2,
                              height: 1.1,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 80,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            banner['subtitle']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildProfileCard() {
String memberSince = '';
if (_userData.containsKey('created_at') && _userData['created_at'] != null) {
  try {
    DateTime createdDate = DateTime.parse(_userData['created_at'].toString());
    memberSince = '${createdDate.day}/${createdDate.month}/${createdDate.year}';
  } catch (e) {
    memberSince = '${DateTime.now().year}';
  }
} else {
  memberSince = '${DateTime.now().year}';
}
  
DateTime? stopDate;
int? targetDays;

if (_userData.containsKey('stopDate') && _userData['stopDate'] != null) {
  final stopDateStr = _userData['stopDate'];
  if (stopDateStr is String && stopDateStr.isNotEmpty) {
    final parts = stopDateStr.split('-');
    if (parts.length == 3) {
      stopDate = DateTime(
        int.parse(parts[0]), 
        int.parse(parts[1]), 
        int.parse(parts[2])
      );
    }
  }
}
  if (_userData.containsKey('targetDays') && _userData['targetDays'] != null) {
    targetDays = _userData['targetDays'];
  }
  
  String timeWithoutSmoking = '';
  if (stopDate != null) {
    final now = DateTime.now();
    final diff = now.difference(stopDate);
    final days = diff.inDays;
    
    if (days == 0) {
      timeWithoutSmoking = 'Menos de 1 dia';
    } else if (days == 1) {
      timeWithoutSmoking = '1 dia';
    } else {
      timeWithoutSmoking = '$days dias';
    }
  }
  
  int cigarrosNaoFumados = 0;
  double economia = 0.0;
  int? cigarrosPorDia = _userData['cigarrosPorDia'];
  double? valorCarteira = _userData['valorCarteira'];
  
  if (stopDate != null && cigarrosPorDia != null && valorCarteira != null) {
    final days = DateTime.now().difference(stopDate).inDays;
    cigarrosNaoFumados = days * cigarrosPorDia;
    final cigarrosPorCarteira = 20;
    final valorPorCigarro = valorCarteira / cigarrosPorCarteira;
    economia = cigarrosNaoFumados * valorPorCigarro;
  }
  
  List<Widget> _getBadges() {
    List<Widget> badges = [];
    if (stopDate != null) {
      final days = DateTime.now().difference(stopDate).inDays;
      
      if (days >= 7) {
        badges.add(_buildBadge('7 dias', Icons.emoji_events, Color(0xFFF59E0B)));
      }
      if (days >= 30) {
        badges.add(_buildBadge('1 mês', Icons.star, Color(0xFF10B981)));
      }
      if (days >= 365) {
        badges.add(_buildBadge('1 ano', Icons.workspace_premium, Color(0xFFEF4444)));
      }
    }
    return badges;
  }
  
  int currentDays = stopDate != null ? DateTime.now().difference(stopDate).inDays : 0;
  int progress = targetDays != null && targetDays > 0 ? (currentDays * 100 ~/ targetDays).clamp(0, 100) : 0;
  
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userData['nomeCompleto']?.toString() ?? 'Usuário')}&background=3B82F6&color=fff&size=100',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userData['nomeCompleto']?.toString() ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                  const SizedBox(height: 4),
                  Text(
                    'Membro desde $memberSince',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (stopDate != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tempo sem fumar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeWithoutSmoking,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              'Parou em: ${_formatDate(stopDate)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (targetDays != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            color: Colors.white,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Meta: $currentDays de $targetDays dias ($progress%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentDays.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const Text(
                            'Dias',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            targetDays != null ? '$targetDays' : '--',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const Text(
                            'Meta (dias)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (cigarrosPorDia != null && valorCarteira != null && stopDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$cigarrosNaoFumados',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const Text(
                              'Cigarros não fumados',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'R\$ ${economia.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const Text(
                              'Economizados',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showGoalModal,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text(
                    'Definir Meta',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_getBadges().isNotEmpty)
          Positioned(
            top: 12,
            right: 12,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: _getBadges(),
            ),
          ),
      ],
    ),
  );
}

Widget _buildBadge(String title, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildTipCard() {
    Widget buildDItem(
      IconData icon,
      String title,
      String description,
      Color color,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology_outlined,
                    color: Color(0xFFF59E0B), size: 30),
                SizedBox(width: 12),
                Text(
                  'Técnica dos 5 D’s',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                buildDItem(
                  Icons.directions_walk,
                  'Distrair',
                  'Levante, mude de ambiente, beba água ou lave o rosto. '
                      'A fissura dura apenas alguns minutos.',
                  const Color(0xFF3B82F6),
                ),
                buildDItem(
                  Icons.block,
                  'Dizer NÃO',
                  'Fale para si mesmo: "Eu não fumo mais. Isso vai passar." '
                      'Isso ativa seu controle racional.',
                  const Color(0xFFEF4444), 
                ),
                buildDItem(
                  Icons.timer,
                  'Demorar',
                  'Espere 10 minutos antes de qualquer decisão. '
                      'O pico da vontade cai rapidamente.',
                  const Color(0xFFF59E0B), 
                ),
                buildDItem(
                  Icons.air,
                  'Respirar fundo',
                  'Puxe o ar por 4s, segure por 4s e solte por 6s. '
                      'Repita 5 vezes para reduzir a ansiedade.',
                  const Color(0xFF10B981), 
                ),
                buildDItem(
                  Icons.chat_bubble_outline,
                  'Desabafar',
                  'Fale com alguém ou escreva o que está sentindo. '
                      'Isso reduz a pressão emocional da fissura.',
                  const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 10),
                const Text(
                  'A vontade passa mesmo que você não fume. Aguente alguns minutos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 50),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Recursos selecionados para ajudar na sua jornada',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  material['image'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: material['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    material['tag'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (material.containsKey('subtitle')) ...[
                  const SizedBox(height: 4),
                  Text(
                    material['subtitle'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B82F6),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  material['description'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (material['title'] == 'Guia Completo para Parar de Fumar') {
                        _openPDF('GuiaPratico.pdf');
                      } else if (material.containsKey('videoId')) {
                        _openYouTubeVideo(material['videoId']);
                      } else if (material.containsKey('url')) {
                        _openWebsite(material['url']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Em desenvolvimento: ${material['title']}')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: material['color']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Acessar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: material['color'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}