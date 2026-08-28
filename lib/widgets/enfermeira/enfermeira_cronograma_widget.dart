import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class CronogramaWidget extends StatefulWidget {
  final int upaId;

  const CronogramaWidget({Key? key, required this.upaId}) : super(key: key);

  @override
  _CronogramaWidgetState createState() => _CronogramaWidgetState();
}

class _CronogramaWidgetState extends State<CronogramaWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _dangerColor = const Color(0xFFC65D47);

  List<Map<String, dynamic>> _turmas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCronograma();
  }

  Future<void> _carregarCronograma() async {
    setState(() => _carregando = true);
    try {
      final response = await AuthService().getTurmasComCronograma();
      setState(() {
        _turmas = List<Map<String, dynamic>>.from(response['turmas']);
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      ToastService.showError(context, 'Erro ao carregar cronograma: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 12.0 : 20.0;

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    final turmasPorDia = _agruparTurmasPorDia(_turmas);

    if (turmasPorDia.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Nenhum cronograma cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione aulas para criar o cronograma',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: turmasPorDia.entries.map((entry) {
          return _buildDiaCard(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _agruparTurmasPorDia(List<Map<String, dynamic>> turmas) {
    Map<String, List<Map<String, dynamic>>> grupos = {};

    for (var turma in turmas) {
      String nome = turma['nome'] ?? '';
      String diaSemana = nome.split(' - ').first;
      
      if (!grupos.containsKey(diaSemana)) {
        grupos[diaSemana] = [];
      }
      grupos[diaSemana]!.add(turma);
    }

    return grupos;
  }

  Widget _buildDiaCard(String dia, List<Map<String, dynamic>> turmas) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calendar_today, color: _accentColor, size: isMobile ? 16 : 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dia,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${turmas.length} turma(s)',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...turmas.map((turma) {
            return _buildTurmaCronogramaCard(turma);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTurmaCronogramaCard(Map<String, dynamic> turma) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    final aulas = List<Map<String, dynamic>>.from(turma['aulas'] ?? []);
    final nomeTurma = turma['nome'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nomeTurma,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirModalCronograma(turma),
                icon: Icon(Icons.add, size: isMobile ? 14 : 16),
                label: Text(
                  isSmallMobile ? 'Adicionar' : (isMobile ? 'Adicionar' : 'Adicionar Aula'),
                  style: TextStyle(fontSize: isMobile ? 10 : 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _successColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (aulas.isEmpty)
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.schedule, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma aula cadastrada',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: const Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...aulas.map((aula) {
              return _buildAulaItem(aula, turma);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAulaItem(Map<String, dynamic> aula, Map<String, dynamic> turma) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${aula['numero_aula']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aula ${aula['numero_aula']}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '${aula['data_formatada']} • ${aula['horario']}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: const Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: _dangerColor, size: isMobile ? 18 : 20),
            onPressed: () => _confirmarDeletarAula(turma['id'], aula['id']),
          ),
        ],
      ),
    );
  }

void _abrirModalCronograma(Map<String, dynamic> turma) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  final numeroAulaController = TextEditingController();
  final dataController = TextEditingController();
  final mesController = TextEditingController();

  DateTime? dataSelecionada;
  final horarioFixo = turma['horario'];
  bool isLoading = false;
  String dataSelecionadaFormatada = '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: EdgeInsets.all(isSmallMobile ? 4 : (isMobile ? 8 : 20)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.92 : 450,
              padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month, color: Color(0xFF1F4E6E), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSmallMobile ? 'Adicionar Aula' : 'Adicionar Aula',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
const SizedBox(height: 4),
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: _accentColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.calendar_today, size: 14, color: _accentColor),
      const SizedBox(width: 6),
      Text(
        '${turma['dia_semana']} - $horarioFixo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _accentColor,
          fontFamily: 'Inter',
        ),
      ),
    ],
  ),
),
                  const SizedBox(height: 16),
                  TextField(
                    controller: numeroAulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número da Aula',
                      hintText: 'Ex: 1, 2, 3...',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dataController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data da Aula',
                      hintText: 'Selecione uma data',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onTap: () async {
                      final results = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(
                          calendarType: CalendarDatePicker2Type.single,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          currentDate: DateTime.now(),
                          selectedDayHighlightColor: const Color(0xFF1F4E6E),
                          selectedDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          cancelButton: const Text('Cancelar'),
                          okButton: const Text('Confirmar'),
                        ),
                        dialogSize: const Size(350, 450),
                        value: [DateTime.now()],
                      );

                      if (results != null && results.isNotEmpty) {
                        final selectedDate = results.first!;
                        dataSelecionada = selectedDate;
                        dataSelecionadaFormatada = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
                        dataController.text = dataSelecionadaFormatada;

                        int mesCalculado = ((selectedDate.month - DateTime.now().month) + 12) % 12;
                        mesCalculado = mesCalculado == 0 ? 1 : mesCalculado + 1;
                        if (mesCalculado > 6) mesCalculado = 6;
                        mesController.text = mesCalculado.toString();
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: horarioFixo),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Horário',
                      hintText: 'Horário fixo da turma',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mesController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Mês do Programa',
                      hintText: 'Calculado automaticamente',
                      prefixIcon: Icon(Icons.calendar_month),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (numeroAulaController.text.isEmpty || dataSelecionada == null) {
                                    ToastService.showError(context, 'Preencha todos os campos obrigatórios');
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await AuthService().adicionarAulaCronograma(
                                      turma['id'],
                                      int.parse(numeroAulaController.text),
                                      dataSelecionada!.toIso8601String().split('T')[0],
                                      horarioFixo,
                                      int.parse(mesController.text),
                                    );
                                    if (mounted) {
                                      Navigator.pop(context);
                                      _carregarCronograma();
                                      ToastService.showSuccess(context, 'Aula adicionada com sucesso!');
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ToastService.showError(context, 'Erro ao adicionar aula: $e');
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _successColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Adicionar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
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

  void _confirmarDeletarAula(int turmaId, int aulaId) async {
    final isMobile = MediaQuery.of(context).size.width < 500;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.92 : 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: _dangerColor, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir Aula',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tem certeza que deseja excluir esta aula?\n\nEsta ação não pode ser desfeita.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(
                          fontSize: 14,
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

    if (confirm == true) {
      try {
        await AuthService().deletarAulaCronograma(aulaId);
        if (mounted) {
          _carregarCronograma();
          ToastService.showSuccess(context, 'Aula excluída com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          ToastService.showError(context, 'Erro ao excluir aula: $e');
        }
      }
    }
  }
}